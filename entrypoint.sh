#!/bin/sh
# 启动 DeepSeek Harness 的 Web 服务
# 注意：dsh 拒绝绑定 0.0.0.0（通配地址），必须绑定一个具体网卡 IP。
set -e

PORT="${PORT:-8080}"
DSH_HOME="${DSH_HOME:-/data}"
mkdir -p "$DSH_HOME"

# 取容器的第一块非回环 IPv4 网卡地址；取不到就退回 127.0.0.1
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

# Render 会自动注入 RENDER_EXTERNAL_URL（形如 https://xxx.onrender.com）
PUBLIC="${RENDER_EXTERNAL_URL:-http://localhost:${PORT}}"
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
