#!/bin/sh
# 启动 DeepSeek Harness 的 Web 服务
# 支持两种环境：Render（容器）/ GitHub Codespaces
# 注意：dsh 拒绝绑定 0.0.0.0（通配地址），必须绑定一个具体 IP。
set -e

PORT="${PORT:-8080}"
DSH_HOME="${DSH_HOME:-/data}"
mkdir -p "$DSH_HOME" 2>/dev/null || true

# ---- 监听地址 ----
if [ -n "$CODESPACE_NAME" ]; then
  # Codespaces 会转发 localhost 端口，绑 127.0.0.1 最稳
  BIND_IP="127.0.0.1"
else
  # 容器里绑第一块非回环网卡
  BIND_IP=$(node -e '
const os = require("os");
const ifs = os.networkInterfaces();
for (const name of Object.keys(ifs)) {
  for (const a of ifs[name] || []) {
    if (a.family === "IPv4" && !a.internal) { console.log(a.address); process.exit(0); }
  }
}
console.log("127.0.0.1");
')
fi

# ---- 对外地址 ----
if [ -n "$RENDER_EXTERNAL_URL" ]; then
  PUBLIC="$RENDER_EXTERNAL_URL"
elif [ -n "$CODESPACE_NAME" ]; then
  PUBLIC="https://${CODESPACE_NAME}-${PORT}.${GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN:-app.github.dev}"
else
  PUBLIC="http://localhost:${PORT}"
fi
AUTHORITY=$(printf '%s' "$PUBLIC" | sed -e 's|^https\{0,1\}://||' -e 's|/.*$||')

echo "== 启动参数 =="
echo "  PORT      = $PORT"
echo "  BIND_IP   = $BIND_IP"
echo "  DSH_HOME  = $DSH_HOME"
echo "  PUBLIC    = $PUBLIC"
echo "  AUTHORITY = $AUTHORITY"

exec dsh --profile web \
  --no-open \
  --host "$BIND_IP" \
  --port "$PORT" \
  --public-url "$PUBLIC" \
  --trusted-host "$AUTHORITY"
