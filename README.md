# Docker AI 开发环境

基于 Python 3.12-slim-bullseye 的 Docker 开发环境，适用于 AI 和 Python 开发工作。支持在线构建和离线部署。

## 功能特性

- Python 3.12.12 运行环境（基于 Debian Bullseye）
- 常用开发工具：git, vim, curl, wget, net-tools, procps, iputils-ping, htop, tree, jq, ssh, sudo 等
- 非 root 用户运行（devuser）
- 国内镜像源加速（阿里云镜像）
- Host 网络模式，解决网络连接问题
- 工作目录挂载：`/work/workspace/` -> `/workspace`
- 支持离线部署和镜像导出/导入

## 使用方法

### 在线构建（有网络环境）
```bash
# 使用host网络模式解决网络问题
docker build --network host -t python-dev:3.12 .

# 或使用docker compose构建
docker compose build
```

### 启动容器
```bash
docker compose up -d
```

### 进入容器
```bash
docker exec -it 3.12-slim_compose bash
```

### 停止容器
```bash
docker compose down
```

## 离线部署方法

### 1. 在有网络的环境中准备镜像
```bash
# 确保脚本有执行权限
chmod +x export_image.sh import_image.sh

# 导出镜像（生成压缩文件）
./export_image.sh

# 输出文件: python-dev_3.12.tar.gz
```

### 2. 在离线环境中部署
```bash
# 将 python-dev_3.12.tar.gz 复制到离线环境

# 导入镜像
./import_image.sh python-dev_3.12.tar.gz

# 启动容器
docker compose up -d
```

### 3. 手动导入镜像（不使用脚本）
```bash
# 解压镜像文件
gzip -d python-dev_3.12.tar.gz

# 导入镜像
docker load -i python-dev_3.12.tar

# 验证镜像
docker images python-dev:3.12
```

## 配置说明

### Dockerfile 配置
- 基础镜像：python:3.12-slim-bullseye（稳定版）
- 时区：Asia/Shanghai
- 工作目录：/workspace
- 默认用户：devuser（具有 sudo 权限，无需密码）
- APT 镜像源：阿里云镜像（针对 Bullseye 版本）
- 清除代理设置，避免代理冲突

### docker-compose.yml 配置
- 服务名称：python-dev
- 容器名称：3.12-slim_compose
- 网络模式：host（解决网络连接问题）
- 卷挂载：
  - `/work/workspace/` -> `/workspace`
  - `~/.ssh` -> `/home/devuser/.ssh:ro`
  - `~/.gitconfig` -> `/home/devuser/.gitconfig:ro`
  - 数据卷：python-dev-data -> `/data`

## 故障排除

### 网络连接问题（构建失败）
如果遇到网络连接问题，特别是DNS解析正常但HTTP连接失败：

1. **使用 host 网络模式构建**：
   ```bash
   docker build --network host -t python-dev:3.12 .
   ```

2. **检查 Docker 网络配置**：
   ```bash
   # 检查DNS配置
   cat /etc/docker/daemon.json
   
   # 重启Docker服务
   sudo systemctl restart docker
   ```

3. **清除代理设置**：
   ```bash
   # 检查Docker代理配置
   cat /etc/systemd/system/docker.service.d/http-proxy.conf
   cat ~/.docker/config.json
   
   # 清除代理设置（如果需要）
   echo '{}' > ~/.docker/config.json
   ```

### 软件包安装失败
如果 APT 更新失败：
- Dockerfile 已配置使用阿里云镜像源（针对 Bullseye 版本）
- 如果镜像源不可用，可修改 Dockerfile 中的镜像源地址

### 权限问题
```bash
# 修复Docker socket权限问题
sudo chmod 666 /var/run/docker.sock

# 将用户添加到docker组
sudo usermod -aG docker $USER
```

## 离线部署脚本

### export_image.sh
- 导出 Docker 镜像为压缩文件
- 自动检查并构建镜像（如果需要）
- 生成离线部署包

### import_image.sh
- 导入 Docker 镜像到离线环境
- 支持压缩和未压缩格式
- 可选自动启动容器

## 开发计划

已完成：
- [x] 修复代理配置问题
- [x] 配置国内镜像源（阿里云）
- [x] 验证容器构建和运行
- [x] 创建离线部署脚本
- [x] 解决网络连接问题（host网络模式）

待完成：
- [ ] 添加容器健康检查
- [ ] 优化资源限制配置
- [ ] 添加多阶段构建支持
- [ ] 创建开发工具脚本

## 许可证

MIT