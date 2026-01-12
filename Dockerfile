# 使用官方 Python 3.12 slim 镜像作为基础
FROM python:3.12-slim

# 设置环境变量 - 显式覆盖代理设置
ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    # 清除代理设置
    HTTP_PROXY= \
    HTTPS_PROXY= \
    http_proxy= \
    https_proxy= \
    NO_PROXY=* \
    no_proxy=*

# 确保没有APT代理配置，并明确禁用代理
RUN rm -f /etc/apt/apt.conf.d/proxy.conf && \
    echo 'Acquire::http::Proxy "false";' > /etc/apt/apt.conf.d/99noproxy && \
    echo 'Acquire::https::Proxy "false";' >> /etc/apt/apt.conf.d/99noproxy

# 使用国内镜像源加速下载（清华大学镜像）
# 首先检查 sources.list 文件是否存在，如果存在则替换镜像源
RUN if [ -f /etc/apt/sources.list ]; then \
        sed -i 's|http://deb.debian.org|https://mirrors.tuna.tsinghua.edu.cn|g' /etc/apt/sources.list && \
        sed -i 's|http://security.debian.org|https://mirrors.tuna.tsinghua.edu.cn/debian-security|g' /etc/apt/sources.list; \
    else \
        # 对于 slim 镜像，可能需要创建 sources.list
        echo "deb https://mirrors.tuna.tsinghua.edu.cn/debian/ bookworm main" > /etc/apt/sources.list && \
        echo "deb https://mirrors.tuna.tsinghua.edu.cn/debian/ bookworm-updates main" >> /etc/apt/sources.list && \
        echo "deb https://mirrors.tuna.tsinghua.edu.cn/debian-security bookworm-security main" >> /etc/apt/sources.list; \
    fi

# 安装常用开发工具
RUN apt-get update && apt-get install -y \
    git \
    vim \
    curl \
    wget \
    net-tools \
    procps \
    iputils-ping \
    htop \
    tree \
    jq \
    ssh \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# 设置时区
RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

# 创建非 root 用户
RUN useradd -m -s /bin/bash devuser && \
    echo "devuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/devuser

# 创建工作目录
RUN mkdir -p /workspace && chown -R devuser:devuser /workspace

# 设置工作目录
WORKDIR /workspace

# 切换到非 root 用户
USER devuser

# 设置默认 shell
SHELL ["/bin/bash", "-c"]

# 保持容器运行
CMD ["tail", "-f", "/dev/null"]