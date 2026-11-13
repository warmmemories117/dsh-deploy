# dsh-deploy

把 **DeepSeek Harness** 跑在云上，iPad 关掉也不影响。

目前支持两种方式：

| 方式 | 费用 | 需要绑卡 | 常驻 |
|---|---|---|---|
| **A. GitHub Codespaces**（推荐先试） | 每月免费 60 小时 | ❌ 不需要 | 30 分钟空闲会停 |
| **B. Render**（免费层） | $0 | ✅ 要验卡（$1 预授权） | 15 分钟空闲会休眠 |

---

## A. 用 Codespaces 跑（不用卡）

1. 打开 https://github.com/warmmemories117/dsh-deploy
2. 点绿色 **`Code`** → 切到 **`Codespaces`** 标签 → **`Create codespace on main`**
3. 等 1–2 分钟（会自动装好 dsh）
4. 终端里会自动启动服务，滚动到下面找这一行：

   ```
   dsh web: https://<随机名>-8080.app.github.dev/?token=xxxxx
   ```

   **这个网址就是入口**，任何设备打开都能用。

### 常用操作

| 想做什么 | 怎么做 |
|---|---|
| 服务停了重新起 | 终端里跑 `dsh --profile web --no-open --host 127.0.0.1 --port 8080` |
| 端口没公开 | 底部 **PORTS** 面板 → 找到 8080 → 右键 → **Port Visibility → Public** |
| 停止 Codespace | 左下角 **Codespaces** → 选自己的 → **Stop codespace**（不占时间） |
| 找回网址 | 重新打开 codespace，跑一次启动命令即可 |

> 免费额度：个人账号每月 **120 core-hours**（2 核 = 60 小时）。用完前会邮件提醒。

---

## B. 用 Render 部署

1. https://dashboard.render.com/ → **New** → **Web Service**
2. 选 **Public Git repository**，填 `https://github.com/warmmemories117/dsh-deploy`
3. Name 随意，Region **Singapore**，Language **Docker**，Instance **Free**
4. 需要绑卡验证（$1 临时授权，不扣费）→ **Deploy web service**
5. 在 **Logs** 里找 `dsh web: https://...?token=...`

---

## 本地 Docker

```bash
docker build -t dsh .
docker run -p 8080:8080 -v dsh-data:/data dsh
```

## 已知坑

- `dsh web` **拒绝绑定 `0.0.0.0`**（报 wildcard address not supported，防止把 RCE 暴露到网络）。
  `entrypoint.sh` 会按环境自动选择监听地址：Codespaces 用 `127.0.0.1`，容器用第一块网卡 IP。
- 反向代理需要正确的 `Host`，否则信任校验会拒；脚本用 `RENDER_EXTERNAL_URL` / `CODESPACE_NAME`
  自动补 `--public-url` 与 `--trusted-host`。
- 源码构建（`pnpm build`）需要 node ≥ 24.9，本项目**不构建源码**，只装 npm 预编译包。
