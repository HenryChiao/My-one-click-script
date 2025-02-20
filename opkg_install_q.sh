#!/bin/bash

# ================================
# 一键安装脚本：在 iStoreOS (ARM64) 上安装 Git、Go 和 `q`
# ================================

# 输出开始安装信息
echo "开始安装 Git、Go 和 q..."

# ================================
# 1. 更新软件包列表
# ================================
echo "正在更新软件包列表..."
opkg update

# ================================
# 2. 安装 Git 和 HTTPS 支持
# ================================
echo "正在安装 Git 和 HTTPS 支持..."
opkg install git git-http ca-certificates

# 检查 Git 是否安装成功
echo "正在检查 Git 安装..."
git --version

# ================================
# 3. 安装 Go 1.22
# ================================
echo "正在下载并安装 Go 1.22..."
cd /tmp
wget https://go.dev/dl/go1.22.0.linux-arm64.tar.gz
mkdir -p /opt/go
tar -C /opt/go -xzf go1.22.0.linux-arm64.tar.gz

# 配置 Go 环境变量
echo "配置 Go 环境变量..."
echo 'export PATH=/opt/go/go/bin:$PATH' >> ~/.profile
source ~/.profile

# 检查 Go 版本
echo "正在检查 Go 版本..."
go version

# ================================
# 4. 安装 `q`
# ================================
echo "正在安装 q..."
go install github.com/natesales/q@latest

# 配置 q 环境变量
echo "配置 q 环境变量..."
echo 'export PATH=$(go env GOPATH)/bin:$PATH' >> ~/.profile
source ~/.profile

# 检查 q 是否安装成功
echo "正在检查 q 是否安装成功..."
q --version

# ================================
# 安装完成提示
# ================================
echo "安装完成！你现在可以使用 \`q\` 命令了！"
echo "如果在执行过程中遇到问题，请确保网络连接正常，或者检查输出的错误信息。"

# 完成提示
echo "一切安装完毕，感谢使用本脚本！"
