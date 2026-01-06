# 使用官方 Python 3.12 slim 镜像作为基础
FROM python:3.12-slim

# 设置代理（构建时使用）
ARG HTTP_PROXY=http://192.168.0.116:7890
ARG HTTPS_PROXY=http://192.168.0.116:7890

# 设置环境变量（运行时也生效）
ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    
    # 代理环境变量 - 大写版本（标准）
    HTTP_PROXY=http://192.168.0.116:7890 \
    HTTPS_PROXY=http://192.168.0.116:7890 \
    ALL_PROXY=http://192.168.0.116:7890 \
    
    # 代理环境变量 - 小写版本（部分工具使用）
    http_proxy=http://192.168.0.116:7890 \
    https_proxy=http://192.168.0.116:7890 \
    all_proxy=http://192.168.0.116:7890 \
    
    # 不需要代理的地址
    NO_PROXY=localhost,127.0.0.1,0.0.0.0,172.16.0.0/12,192.168.0.0/16,10.0.0.0/8,.docker.internal \
    no_proxy=localhost,127.0.0.1,0.0.0.0,172.16.0.0/12,192.168.0.0/16,10.0.0.0/8,.docker.internal \
    
    # 应用特定代理
    PIP_PROXY=http://192.168.0.116:7890 \
    GIT_PROXY=http://192.168.0.116:7890 \
    npm_config_proxy=http://192.168.0.116:7890 \
    npm_config_https_proxy=http://192.168.0.116:7890

# 配置 APT 使用代理（如果需要）
RUN echo 'Acquire::http::Proxy "http://192.168.0.116:7890";' > /etc/apt/apt.conf.d/proxy.conf && \
    echo 'Acquire::https::Proxy "http://192.168.0.116:7890";' >> /etc/apt/apt.conf.d/proxy.conf

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

# 配置 git 代理
RUN git config --global http.proxy http://192.168.0.116:7890 && \
    git config --global https.proxy http://192.168.0.116:7890

# 配置 pip 使用代理
RUN pip config set global.proxy http://192.168.0.116:7890

# 设置时区
RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

# 创建非 root 用户并确保代理环境变量继承
RUN useradd -m -s /bin/bash devuser && \
    echo "devuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/devuser

# 创建工作目录
RUN mkdir -p /workspace && chown -R devuser:devuser /workspace

# 为用户配置文件添加代理设置
RUN echo 'export HTTP_PROXY=http://192.168.0.116:7890' >> /home/devuser/.bashrc && \
    echo 'export HTTPS_PROXY=http://192.168.0.116:7890' >> /home/devuser/.bashrc && \
    echo 'export http_proxy=http://192.168.0.116:7890' >> /home/devuser/.bashrc && \
    echo 'export https_proxy=http://192.168.0.116:7890' >> /home/devuser/.bashrc && \
    echo 'export NO_PROXY=localhost,127.0.0.1' >> /home/devuser/.bashrc && \
    echo 'export no_proxy=localhost,127.0.0.1' >> /home/devuser/.bashrc

# 创建配置文件，确保非交互式 shell 也能加载代理
RUN echo 'export HTTP_PROXY=http://192.168.0.116:7890' >> /home/devuser/.profile && \
    echo 'export HTTPS_PROXY=http://192.168.0.116:7890' >> /home/devuser/.profile

# 设置工作目录
WORKDIR /workspace

# 切换到非 root 用户
USER devuser

# 验证代理设置

# 设置默认 shell
SHELL ["/bin/bash", "-c"]

# 保持容器运行
CMD ["tail", "-f", "/dev/null"]
