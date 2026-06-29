# Giffgaff Number Keeper

一个用于 giffgaff SIM 保号的静态网页工具。它通过浏览器下载一个固定大小的 `payload.bin` 文件，帮助触发一次移动数据连接记录。

> 这不是 giffgaff 官方项目。规则、价格和判定方式可能变化，最终以 giffgaff 官方帮助和条款为准。

## 我确认到的保号规则

giffgaff 官方帮助文章 [Understanding why your number has been deactivated](https://help.giffgaff.com/en/articles/242797-understanding-why-your-number-has-been-deactivated) 说明：SIM 最近 6 个月没有使用会被视为 inactive/deactivated。要阻止停用，至少每 6 个月做一次以下任一动作：

- 给其他号码打一次电话、发一次 SMS 或 MMS；不包括紧急服务、Member Services、0800 或免费号码。
- 使用移动数据连接一次互联网。
- 购买一次 Airtime Credit 或 plan。

这个项目只覆盖第二种方式：使用 giffgaff SIM 的移动数据下载一个约 150 KiB 的静态文件。

## 可能产生的费用

本工具的 `payload.bin` 约 150 KiB。按 giffgaff 当前 UK pay as you go 数据价格 `10p/MB` 粗略估算，单次下载约等于 0.15 MB，理论费用约 1.5p。

实际扣费可能不同：

- 如果你有可用 plan/data allowance，通常会消耗套餐流量，而不是额外按 PAYG 数据扣费。
- 如果没有套餐，可能按 PAYG 数据价格扣费；运营商计费舍入可能让实际费用高于理论值。
- 浏览器、系统服务或后台应用可能产生额外流量，所以操作前应关闭 Wi-Fi 并限制其他应用联网。
- giffgaff 价格和漫游规则可能变化，最终以 [giffgaff pricing](https://www.giffgaff.com/pricing) 和账户扣费记录为准。

## 其他保号方式费用对比

giffgaff 官方认可的保号动作不止移动数据。按当前 UK pay as you go 价格粗略比较：

| 方式 | 当前费用参考 | 备注 |
| --- | ---: | --- |
| 本工具下载 150 KiB | 约 1.5p 起 | 按 10p/MB 估算；实际可能因舍入和额外流量更高 |
| 打一个普通 UK 手机/座机号码 | 25p 起 | 25p/min，且通常有 1 分钟最低计费 |
| 发一条普通 UK SMS | 10p 起 | 160 字符短信 10p/text |
| 发一条 MMS | 30p 起 | MMS 30p/message，且没有必要为了保号用这种方式 |
| 购买 Airtime Credit 或 plan | 按购买金额 | 能满足官方规则，但成本取决于你实际购买的 credit/plan |

所以，如果只是为了产生一次低成本活动记录，使用少量移动数据通常比打电话或发短信更便宜；但最终是否扣费、扣多少，仍以 giffgaff 账户记录为准。

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

## 文件说明

```text
.
├── index.html   # 单页应用
├── payload.bin  # 150 KiB 下载目标文件
├── README.md    # 项目说明
├── LICENSE      # MIT License
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

## License

MIT
