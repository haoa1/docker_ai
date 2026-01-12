# Docker AI 开发环境

基于 Python 3.12-slim 的 Docker 开发环境，适用于 AI 和 Python 开发工作。

## 功能特性

- Python 3.12.12 运行环境
- 常用开发工具：git, vim, curl, wget, net-tools, procps, htop, tree, jq, ssh, sudo 等
- 非 root 用户运行（devuser）
- 国内镜像源加速（清华大学镜像）
- Host 网络模式
- 工作目录挂载：`/work/workspace/` -> `/workspace`

## 使用方法

### 构建镜像
```bash
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

## 配置说明

### Dockerfile 配置
- 基础镜像：python:3.12-slim
- 时区：Asia/Shanghai
- 工作目录：/workspace
- 默认用户：devuser（具有 sudo 权限，无需密码）

### docker-compose.yml 配置
- 服务名称：python-dev
- 容器名称：3.12-slim_compose
- 网络模式：host
- 卷挂载：
  - `/work/workspace/` -> `/workspace`
  - `~/.ssh` -> `/home/devuser/.ssh:ro`
  - `~/.gitconfig` -> `/home/devuser/.gitconfig:ro`
  - 数据卷：python-dev-data -> `/data`

## 故障排除

### 构建失败：代理问题
如果遇到代理连接问题：
1. 检查 Docker 代理配置：
   ```bash
   cat /etc/systemd/system/docker.service.d/http-proxy.conf
   cat ~/.docker/config.json
   ```
2. 清除代理设置（如果需要）：
   - 编辑 `~/.docker/config.json`，将代理设置为空字符串
   - 重启 Docker 服务：`sudo systemctl restart docker`

### 软件包安装失败
如果 APT 更新失败：
- Dockerfile 已配置使用清华大学镜像源
- 如果镜像源不可用，可修改 Dockerfile 中的镜像源地址

## 开发计划

已完成：
- [x] 修复代理配置问题
- [x] 配置国内镜像源
- [x] 验证容器构建和运行

待完成：
- [ ] 添加容器健康检查
- [ ] 优化资源限制配置
- [ ] 添加多阶段构建支持
- [ ] 创建开发工具脚本

## 许可证

MIT