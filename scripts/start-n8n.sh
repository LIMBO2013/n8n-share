#!/bin/bash

# 检查 Docker 是否运行
if ! docker info > /dev/null 2>&1; then
    echo "🚫 Docker 没有运行，请先在 Windows 上启动 Docker Desktop。"
    exit 1
fi

# 创建卷（如果还没创建）
if ! docker volume inspect n8n_data > /dev/null 2>&1; then
    echo "📦 创建数据卷 n8n_data ..."
    docker volume create n8n_data
else
    echo "📦 数据卷 n8n_data 已存在。"
fi

# 启动 n8n 容器（后台运行）
echo "🚀 启动 n8n 容器 ..."
docker run -it -d --rm --name n8n -p 5678:5678 -v n8n_data:/home/node/.n8n -e N8N_ALLOW_LOADING_CUSTOM_NODES=true -e N8N_ENABLE_NODE_DEV_MODE=true docker.n8n.io/n8nio/n8n

# 等待容器端口就绪（最多等 10 秒）
echo "⏳ 正在等待 n8n 启动 ..."
for i in {1..10}; do
    if curl -s http://localhost:5678 > /dev/null; then
        break
    fi
    sleep 1
done

# ✅ 用 Windows PowerShell 打开浏览器
echo "🌐 打开浏览器 http://localhost:5678"
powershell.exe start http://localhost:5678

# 🔁 每秒刷新一次页面，直到 30 秒后，或页面正常为止
echo "🔄 检查页面是否正常加载 ..."

powershell.exe -Command "
  \$max = 30
  for (\$i = 0; \$i -lt \$max; \$i++) {
    try {
      \$response = Invoke-WebRequest -Uri 'http://localhost:5678' -UseBasicParsing -ErrorAction Stop
      if (\$response.StatusCode -eq 200 -and \$response.Content -notmatch '502|error|not available|cannot') {
        Write-Host '✅ 页面已正常加载！'
        break
      }
    } catch {
      # 页面未就绪
    }
    Start-Sleep -Seconds 1
    # 刷新浏览器窗口（重新打开）
    Start-Process 'http://localhost:5678'
  }
"

