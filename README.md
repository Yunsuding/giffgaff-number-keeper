# Giffgaff Number Keeper

一个用于 giffgaff SIM 保号的静态网页工具。它通过浏览器下载一个固定大小的 `payload.bin` 文件，帮助触发一次移动数据连接记录。

> 这不是 giffgaff 官方项目。规则、价格和判定方式可能变化，最终以 giffgaff 官方帮助和条款为准。

## 我确认到的保号规则

giffgaff 官方帮助文章 [Understanding why your number has been deactivated](https://help.giffgaff.com/en/articles/242797-understanding-why-your-number-has-been-deactivated) 说明：SIM 最近 6 个月没有使用会被视为 inactive/deactivated。要阻止停用，至少每 6 个月做一次以下任一动作：

- 给其他号码打一次电话、发一次 SMS 或 MMS；不包括紧急服务、Member Services、0800 或免费号码。
- 使用移动数据连接一次互联网。
- 购买一次 Airtime Credit 或 plan。

这个项目只覆盖第二种方式：使用 giffgaff SIM 的移动数据下载一个约 150 KiB 的静态文件。

## 项目特点

- 纯静态：`index.html` + `payload.bin`，适合 GitHub Pages。
- 强制防缓存：每次请求都带随机参数和 no-store headers。
- 手机优先：开始前必须勾选 Wi-Fi、后台联网和余额确认。
- 本地记录：只用 `localStorage` 保存最近几次下载结果，不上传任何数据。
- 不承诺官方成功：页面只能证明文件下载完成，最终应以 giffgaff 账户、余额或使用记录为准。

## 使用方式

1. 在手机上打开部署后的网页。
2. 关闭 Wi-Fi。
3. 确认当前浏览器会使用 giffgaff SIM 的移动数据。
4. 临时限制其他应用后台联网，避免额外流量。
5. 勾选三项确认后点击下载按钮。
6. 页面显示下载完成后，立即关闭移动数据。
7. 登录 giffgaff 或查看余额/使用记录，确认是否产生了活动。

建议每 3-4 个月执行一次，留出缓冲；官方规则是至少每 6 个月一次。

## 部署到 GitHub Pages

1. 在 GitHub 创建一个新仓库，例如 `giffgaff-number-keeper`。
2. 上传本项目所有文件，或用 git push 到 `main` 分支。
3. 进入仓库 `Settings` -> `Pages`。
4. Source 选择 `Deploy from a branch`。
5. Branch 选择 `main`，目录选择 `/ (root)`，保存。
6. 等待部署完成，访问 `https://你的用户名.github.io/giffgaff-number-keeper/`。

## 让 Codex 帮你创建公开仓库

我已经放好了 `.env` 和 `scripts/publish-to-github.ps1`。你只需要填写 `.env`：

```env
GITHUB_TOKEN=你的 GitHub token
GITHUB_OWNER=你的 GitHub 用户名
GITHUB_REPO_NAME=giffgaff-number-keeper
GITHUB_REPO_DESCRIPTION=Static giffgaff SIM number keeper helper
GITHUB_REPO_HOMEPAGE=
```

Token 最省事的方式是使用 classic personal access token，并勾选 `public_repo` scope。也可以使用 fine-grained token，但它必须能创建公开仓库并写入仓库内容；如果你的 fine-grained token 不能创建仓库，可以先在 GitHub 手动创建一个空的公开仓库，再给 token 授权写入该仓库内容。填好后告诉 Codex 继续发布即可。

## 文件说明

```text
.
├── index.html   # 单页应用
├── payload.bin  # 150 KiB 下载目标文件
├── README.md    # 项目说明
├── scripts/
│   └── publish-to-github.ps1
├── LICENSE      # MIT License
├── .env.example
├── .gitignore
└── .nojekyll    # 让 GitHub Pages 原样发布静态文件
```

## 本地测试

如果你有 Python：

```bash
python -m http.server 8000
```

然后打开 `http://localhost:8000/`。

也可以直接双击 `index.html` 查看界面，但浏览器本地文件模式可能限制 `fetch("payload.bin")`，因此建议用静态服务器测试。

## 注意事项

- 不要用 Wi-Fi 操作；Wi-Fi 下载不会产生 giffgaff 移动数据连接。
- 不要频繁点击；一次成功下载后，去 giffgaff 账户或余额记录确认。
- 如果 SIM 已经停用，本工具不能恢复号码。官方帮助文章说明，停用后短期内可联系 giffgaff agents 申请 PAC，具体以官方页面为准。
- 运营商计费、流量舍入和价格可能变化，本项目不写死费用估算。

## Credit

实现思路参考了 [dennischancs/gg-keeper](https://github.com/dennischancs/gg-keeper)，但本项目重新实现了界面、交互、说明文档和默认 payload 大小。

## License

MIT
