Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$PSNativeCommandUseErrorActionPreference = $true

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

function Invoke-Git {
    param(
        [string[]] $Arguments,
        [string] $Label = "git command"
    )

    & git @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw "$Label failed with exit code $LASTEXITCODE"
    }
}

$envValues = Read-DotEnv -Path $EnvPath
$token = Require-Value -Values $envValues -Name "GITHUB_TOKEN"
$owner = Require-Value -Values $envValues -Name "GITHUB_OWNER"
$repo = Require-Value -Values $envValues -Name "GITHUB_REPO_NAME"
$description = if ($envValues.ContainsKey("GITHUB_REPO_DESCRIPTION")) { $envValues["GITHUB_REPO_DESCRIPTION"] } else { "" }
$homepage = if ($envValues.ContainsKey("GITHUB_REPO_HOMEPAGE")) { $envValues["GITHUB_REPO_HOMEPAGE"] } else { "" }

Set-Location -LiteralPath $ProjectRoot

$headers = @{
    Authorization = "Bearer $token"
    Accept = "application/vnd.github+json"
    "X-GitHub-Api-Version" = "2022-11-28"
}

$repoExists = $false
try {
    Invoke-RestMethod -Method Get -Uri "https://api.github.com/repos/$owner/$repo" -Headers $headers | Out-Null
    $repoExists = $true
    Write-Host "Repository already exists: $owner/$repo"
} catch {
    $statusCode = $_.Exception.Response.StatusCode.value__
    if ($statusCode -ne 404) {
        throw
    }
}

if (-not $repoExists) {
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

    try {
        Invoke-RestMethod -Method Post -Uri "https://api.github.com/user/repos" -Headers $headers -Body $repoBody -ContentType "application/json" | Out-Null
        Write-Host "Created GitHub repository: $owner/$repo"
    } catch {
        $statusCode = $_.Exception.Response.StatusCode.value__
        if ($statusCode -eq 422) {
            Write-Host "Repository may already exist: $owner/$repo"
        } elseif ($statusCode -eq 403) {
            throw "GitHub token cannot create repositories. Create the public repository manually, or use a token with repository creation permission, then rerun this script."
        } else {
            throw
        }
    }
}

$insideWorkTree = $false
try {
    $insideWorkTree = (git rev-parse --is-inside-work-tree 2>$null) -eq "true"
} catch {
    $insideWorkTree = $false
}

if (-not $insideWorkTree) {
    Invoke-Git -Arguments @("init", "-b", "main") -Label "git init"
}

Invoke-Git -Arguments @("add", ".") -Label "git add"

$hasStagedChanges = $false
try {
    git diff --cached --quiet
} catch {
    $hasStagedChanges = $true
}

if ($hasStagedChanges) {
    Invoke-Git -Arguments @("commit", "-m", "Initial static giffgaff keeper") -Label "git commit"
} else {
    Write-Host "No staged changes to commit."
}

$remoteUrl = "https://github.com/$owner/$repo.git"
$basicAuth = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("x-access-token:$token"))
$existingRemote = ""
try {
    $existingRemote = git remote get-url origin 2>$null
} catch {
    $existingRemote = ""
}

if ([string]::IsNullOrWhiteSpace($existingRemote)) {
    Invoke-Git -Arguments @("remote", "add", "origin", $remoteUrl) -Label "git remote add"
} else {
    Invoke-Git -Arguments @("remote", "set-url", "origin", $remoteUrl) -Label "git remote set-url"
}

Invoke-Git -Arguments @("-c", "http.https://github.com/.extraheader=AUTHORIZATION: Basic $basicAuth", "push", "-u", "origin", "main") -Label "git push"

Write-Host "Published: https://github.com/$owner/$repo"
Write-Host "Enable GitHub Pages from Settings -> Pages -> Deploy from a branch -> main / root."
