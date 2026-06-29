Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$ProjectRoot = Split-Path -Parent $PSScriptRoot
$EnvPath = Join-Path $ProjectRoot ".env"

if (-not (Test-Path -LiteralPath $EnvPath)) {
    throw "Missing .env. Copy .env.example to .env and fill in GitHub settings."
}

function Read-DotEnv {
    param([string] $Path)

    $values = @{}
    foreach ($line in Get-Content -LiteralPath $Path) {
        $trimmed = $line.Trim()
        if ($trimmed.Length -eq 0 -or $trimmed.StartsWith("#")) {
            continue
        }

        $parts = $trimmed.Split("=", 2)
        if ($parts.Count -ne 2) {
            continue
        }

        $key = $parts[0].Trim()
        $value = $parts[1].Trim().Trim('"').Trim("'")
        $values[$key] = $value
    }

    return $values
}

function Require-Value {
    param(
        [hashtable] $Values,
        [string] $Name
    )

    if (-not $Values.ContainsKey($Name) -or [string]::IsNullOrWhiteSpace($Values[$Name])) {
        throw "Missing $Name in .env"
    }

    return $Values[$Name]
}

$envValues = Read-DotEnv -Path $EnvPath
$token = Require-Value -Values $envValues -Name "GITHUB_TOKEN"
$owner = Require-Value -Values $envValues -Name "GITHUB_OWNER"
$repo = Require-Value -Values $envValues -Name "GITHUB_REPO_NAME"
$description = if ($envValues.ContainsKey("GITHUB_REPO_DESCRIPTION")) { $envValues["GITHUB_REPO_DESCRIPTION"] } else { "" }
$homepage = if ($envValues.ContainsKey("GITHUB_REPO_HOMEPAGE")) { $envValues["GITHUB_REPO_HOMEPAGE"] } else { "" }

Set-Location -LiteralPath $ProjectRoot

$repoBody = @{
    name = $repo
    description = $description
    homepage = $homepage
    private = $false
    has_issues = $true
    has_projects = $false
    has_wiki = $false
    auto_init = $false
} | ConvertTo-Json

$headers = @{
    Authorization = "Bearer $token"
    Accept = "application/vnd.github+json"
    "X-GitHub-Api-Version" = "2022-11-28"
}

try {
    Invoke-RestMethod -Method Post -Uri "https://api.github.com/user/repos" -Headers $headers -Body $repoBody -ContentType "application/json" | Out-Null
    Write-Host "Created GitHub repository: $owner/$repo"
} catch {
    $statusCode = $_.Exception.Response.StatusCode.value__
    if ($statusCode -eq 422) {
        Write-Host "Repository may already exist: $owner/$repo"
    } else {
        throw
    }
}

$insideWorkTree = $false
try {
    $insideWorkTree = (git rev-parse --is-inside-work-tree 2>$null) -eq "true"
} catch {
    $insideWorkTree = $false
}

if (-not $insideWorkTree) {
    git init -b main
}

git add .

$hasStagedChanges = $false
try {
    git diff --cached --quiet
} catch {
    $hasStagedChanges = $true
}

if ($hasStagedChanges) {
    git commit -m "Initial static giffgaff keeper"
} else {
    Write-Host "No staged changes to commit."
}

$remoteUrl = "https://github.com/$owner/$repo.git"
$existingRemote = ""
try {
    $existingRemote = git remote get-url origin 2>$null
} catch {
    $existingRemote = ""
}

if ([string]::IsNullOrWhiteSpace($existingRemote)) {
    git remote add origin $remoteUrl
} else {
    git remote set-url origin $remoteUrl
}

git -c "http.extraheader=AUTHORIZATION: bearer $token" push -u origin main

Write-Host "Published: https://github.com/$owner/$repo"
Write-Host "Enable GitHub Pages from Settings -> Pages -> Deploy from a branch -> main / root."
