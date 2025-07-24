#!/bin/bash

# 检查 Docker 是否运行
if ! docker info > /dev/null 2>&1; then
    echo "🚫 Docker 没有运行，请先在 Windows 上启动 Docker Desktop。"
    exit 1
fi

docker run -d --rm -v weaviate_data:/data -p 8080:8080 -p 50051:50051 cr.weaviate.io/semitechnologies/weaviate:1.32.0