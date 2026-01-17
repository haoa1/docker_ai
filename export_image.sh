#!/bin/bash
# Docker镜像导出脚本
# 用于离线环境下部署Docker AI开发环境

set -e

# 镜像名称和标签
IMAGE_NAME="python-dev"
IMAGE_TAG="3.12"
OUTPUT_FILE="${IMAGE_NAME}_${IMAGE_TAG}.tar"
COMPRESSED_FILE="${OUTPUT_FILE}.gz"

echo "=== Docker镜像导出脚本 ==="
echo "镜像: ${IMAGE_NAME}:${IMAGE_TAG}"
echo "输出文件: ${OUTPUT_FILE}"
echo "压缩文件: ${COMPRESSED_FILE}"
echo ""

# 检查Docker是否运行
if ! docker info > /dev/null 2>&1; then
    echo "错误: Docker守护进程未运行或当前用户无权限"
    exit 1
fi

# 检查镜像是否存在
if ! docker image inspect "${IMAGE_NAME}:${IMAGE_TAG}" > /dev/null 2>&1; then
    echo "警告: 镜像 ${IMAGE_NAME}:${IMAGE_TAG} 不存在"
    echo "尝试构建镜像..."
    
    # 构建镜像（使用host网络模式以解决网络问题）
    docker build --network host -t "${IMAGE_NAME}:${IMAGE_TAG}" .
    
    if [ $? -ne 0 ]; then
        echo "错误: 镜像构建失败"
        exit 1
    fi
    
    echo "镜像构建成功"
fi

# 导出镜像
echo "正在导出镜像..."
docker save -o "${OUTPUT_FILE}" "${IMAGE_NAME}:${IMAGE_TAG}"

if [ $? -eq 0 ]; then
    echo "镜像导出成功: ${OUTPUT_FILE}"
    
    # 压缩镜像文件（可选）
    echo "正在压缩镜像文件..."
    gzip -f "${OUTPUT_FILE}"
    
    if [ $? -eq 0 ]; then
        echo "镜像压缩成功: ${COMPRESSED_FILE}"
        echo ""
        echo "使用说明:"
        echo "1. 将 ${COMPRESSED_FILE} 复制到离线环境"
        echo "2. 在离线环境中运行: gzip -d ${COMPRESSED_FILE}"
        echo "3. 导入镜像: docker load -i ${OUTPUT_FILE}"
        echo "4. 运行容器: docker compose up -d"
    else
        echo "警告: 压缩失败，但镜像已导出到 ${OUTPUT_FILE}"
    fi
    
    echo ""
    echo "镜像信息:"
    docker image inspect --format='{{.Id}}' "${IMAGE_NAME}:${IMAGE_TAG}"
    
else
    echo "错误: 镜像导出失败"
    exit 1
fi

echo "=== 脚本执行完成 ==="