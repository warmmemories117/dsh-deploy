# dsh-deploy

一键把 **DeepSeek Harness** 部署到 [Render](https://render.com)（免费层即可）。

## 这是什么

一个极简 Docker 镜像：装 npm 上的预编译包 `@deepseek-ai/dsh`，直接起 Web 服务。
**不构建源码**（源码要 node≥24.9 + pnpm 完整构建，又慢又容易失败）。

## 部署步骤（约 5 分钟）

1. 打开 https://dashboard.render.com/ → **New** → **Web Service**
2. 选 **Build and deploy from a Git repository** → 连接 GitHub → 选本仓库 `dsh-deploy`
3. 配置：
   - **Name**：`deepseek-harness`（决定域名，可自定）
   - **Region**：`Singapore`（离国内最近）
   - **Language**：**Docker**
   - **Instance Type**：**Free**
   - 其余留空
4. 点 **Create Web Service**，等 2~4 分钟构建
5. 打开 **Logs**，找这一行：

   ```
   dsh web: https://<你的域名>.onrender.com/?token=xxxxxxxx
   ```

   **把这个网址收藏**——它就是入口（带 token 才能进）。

## 注意

- **免费层会休眠**：15 分钟没人访问就睡，下次打开要等约 50 秒冷启动
- **文件不持久**：免费层没有持久磁盘，容器重启后 `DSH_HOME` 里的会话会丢
- **token 会变**：实例重建后 token 会重新生成，届时去 Logs 里重新抄
- 想要常驻 + 持久化：升到 Starter（$7/月）并挂一块 Disk 到 `/data`

## 本地跑（可选）

```bash
docker build -t dsh .
docker run -p 8080:8080 -v dsh-data:/data dsh
# 打开日志里打印的 http://localhost:8080/?token=...
```

## 已知坑

- `dsh web` **拒绝绑定 `0.0.0.0`**（会报 wildcard address not supported，防止把 RCE 暴露到网络）。
  `entrypoint.sh` 因此先用 node 探测容器的第一块非回环 IPv4，再绑定那个地址。
- 反向代理必须把 `Host` 传进来，否则信任校验会拒；`entrypoint.sh` 已用 `RENDER_EXTERNAL_URL`
  自动补上 `--public-url` 与 `--trusted-host`。
