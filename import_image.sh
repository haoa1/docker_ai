#!/bin/bash
# Docker镜像导入脚本
# 用于离线环境下部署Docker AI开发环境

set -e

# 默认参数
DEFAULT_IMAGE_FILE="python-dev_3.12.tar.gz"
UNCOMPRESSED_FILE="python-dev_3.12.tar"

echo "=== Docker镜像导入脚本 ==="
echo ""

# 检查Docker是否运行
if ! docker info > /dev/null 2>&1; then
    echo "错误: Docker守护进程未运行或当前用户无权限"
    exit 1
fi

# 确定镜像文件
if [ -n "$1" ]; then
    IMAGE_FILE="$1"
else
    IMAGE_FILE="${DEFAULT_IMAGE_FILE}"
fi

# 检查文件是否存在
if [ ! -f "${IMAGE_FILE}" ]; then
    echo "错误: 镜像文件不存在: ${IMAGE_FILE}"
    echo ""
    echo "使用说明:"
    echo "1. 确保镜像文件存在于当前目录或指定路径"
    echo "2. 支持的格式:"
    echo "   - 压缩文件: *.tar.gz"
    echo "   - 未压缩文件: *.tar"
    echo ""
    echo "示例:"
    echo "  $0 python-dev_3.12.tar.gz"
    echo "  $0 /path/to/image.tar"
    exit 1
fi

# 解压文件（如果是压缩文件）
if [[ "${IMAGE_FILE}" == *.gz ]]; then
    echo "检测到压缩文件: ${IMAGE_FILE}"
    echo "正在解压..."
    
    UNCOMPRESSED_FILE="${IMAGE_FILE%.gz}"
    gzip -d -c "${IMAGE_FILE}" > "${UNCOMPRESSED_FILE}"
    
    if [ $? -ne 0 ]; then
        echo "错误: 文件解压失败"
        exit 1
    fi
    
    echo "解压完成: ${UNCOMPRESSED_FILE}"
    SOURCE_FILE="${UNCOMPRESSED_FILE}"
else
    SOURCE_FILE="${IMAGE_FILE}"
fi

# 导入镜像
echo "正在导入镜像..."
docker load -i "${SOURCE_FILE}"

if [ $? -eq 0 ]; then
    echo "镜像导入成功"
    
    # 显示导入的镜像信息
    echo ""
    echo "已导入的镜像:"
    docker images | grep python-dev
    
    # 检查docker-compose.yml是否存在
    if [ -f "docker-compose.yml" ]; then
        echo ""
        echo "检测到 docker-compose.yml 文件"
        echo "可以使用以下命令启动容器:"
        echo "  docker compose up -d"
        
        # 可选：自动启动容器
        read -p "是否要启动容器？(y/N): " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo "正在启动容器..."
            docker compose up -d
            
            if [ $? -eq 0 ]; then
                echo "容器启动成功"
                echo ""
                echo "使用以下命令进入容器:"
                echo "  docker exec -it 3.12-slim_compose bash"
            else
                echo "警告: 容器启动失败，请手动检查"
            fi
        fi
    else
        echo ""
        echo "提示: 未找到 docker-compose.yml 文件"
        echo "可以直接运行容器:"
        echo "  docker run -it --network host --name python-dev -v \$(pwd):/workspace python-dev:3.12 bash"
    fi
    
    # 清理临时文件（如果是解压的）
    if [[ "${IMAGE_FILE}" == *.gz ]] && [ -f "${UNCOMPRESSED_FILE}" ]; then
        echo ""
        read -p "是否要删除解压后的临时文件 ${UNCOMPRESSED_FILE}？(y/N): " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rm -f "${UNCOMPRESSED_FILE}"
            echo "已删除临时文件"
        fi
    fi
    
else
    echo "错误: 镜像导入失败"
    # 清理临时文件
    if [[ "${IMAGE_FILE}" == *.gz ]] && [ -f "${UNCOMPRESSED_FILE}" ]; then
        rm -f "${UNCOMPRESSED_FILE}"
    fi
    exit 1
fi

echo ""
echo "=== 脚本执行完成 ==="