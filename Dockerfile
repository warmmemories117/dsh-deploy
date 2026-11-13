# DeepSeek Harness 最小部署镜像
# 说明：直接安装 npm 预编译包，不从源码构建（源码需要 node>=24.9 + pnpm 完整构建，太重）
FROM node:24-alpine

RUN npm install -g @deepseek-ai/dsh@latest && npm cache clean --force

WORKDIR /app
COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

ENV DSH_HOME=/data
ENV PORT=8080
RUN mkdir -p /data
VOLUME ["/data"]

EXPOSE 8080

CMD ["/app/entrypoint.sh"]
