#!/bin/bash

# ================================
# 显示界面标题和设计信息
# ================================
echo "================================"
echo "一键安装和卸载脚本：在 iStoreOS 上安装/卸载 Git、Go 和 \`q\`"
echo "design by Henry Chiao"
echo "==============================="

# 输出开始界面
echo "请选择操作:"
echo "1. 安装 Git、Go 和 q"
echo "2. 卸载 q"
echo "其他. 退出脚本"

# 读取用户输入
read -p "请输入选项 [1/2]: " choice

# 检查平台类型（ARM64 或 x86_64）
ARCH=$(uname -m)
if [[ "$ARCH" == "aarch64" ]]; then
    PLATFORM="arm64"
elif [[ "$ARCH" == "x86_64" ]]; then
    PLATFORM="amd64"
else
    echo "不支持的平台: $ARCH，退出脚本。"
    exit 1
fi

# 根据用户输入进行处理
case "$choice" in
    1)
        # 安装部分
        echo "开始检测并安装必要的工具..."

        # ================================
        # 1. 前置检查 `q` 是否已安装
        # ================================
        if command -v q &> /dev/null; then
            echo "`q` 已安装，版本：$(q --version)"
            echo "无需执行安装，退出脚本。"
            exit 0
        fi

        # ================================
        # 2. 检查是否已安装 Git
        # ================================
        if command -v git &> /dev/null; then
            echo "Git 已安装，版本：$(git --version)"
        else
            echo "Git 未安装，正在安装..."
            opkg update
            opkg install git git-http ca-certificates
        fi

        # ================================
        # 3. 检查是否已安装 Go (版本 >= 1.22)
        # ================================
        GO_VERSION=$(go version | awk '{print $3}' | cut -d'.' -f2)
        if command -v go &> /dev/null && [ "$GO_VERSION" -ge 22 ]; then
            echo "Go 已安装，版本：$(go version)"
        else
            echo "Go 未安装或版本不符合要求，正在安装..."
            cd /tmp

            # 根据平台选择下载 Go 版本
            if [ "$PLATFORM" == "arm64" ]; then
                wget -q https://go.dev/dl/go1.22.0.linux-arm64.tar.gz
                echo "下载 ARM64 版本 Go..."
            elif [ "$PLATFORM" == "amd64" ]; then
                wget -q https://go.dev/dl/go1.22.0.linux-amd64.tar.gz
                echo "下载 AMD64 版本 Go..."
            fi

            mkdir -p /opt/go
            tar -C /opt/go -xzf go1.22.0.linux-${PLATFORM}.tar.gz
            echo 'export PATH=/opt/go/go/bin:$PATH' >> ~/.profile
            source ~/.profile
            echo "Go 安装完成！版本：$(go version)"
        fi

        # ================================
        # 4. 安装 `q`
        # ================================
        echo "开始安装 `q`..."
        go install github.com/natesales/q@latest > /dev/null 2>&1
        echo 'export PATH=$(go env GOPATH)/bin:$PATH' >> ~/.profile
        source ~/.profile
        echo "`q` 安装完成！版本：$(q --version)"

        # ================================
        # 安装完成提示
        # ================================
        echo "安装完成！"
        echo "⚠️ 请重新进入 SSH 终端，或者执行 \`source ~/.profile\` 来使环境变量生效。"
        echo "一切安装完毕，感谢使用本脚本！"
        ;;
    
    2)
        # 卸载部分
        echo "正在卸载 q..."

        # 查找 `q` 可执行文件路径
        Q_BIN=$(go env GOPATH)/bin/q
        if [ -f "$Q_BIN" ]; then
            # 删除 `q` 可执行文件
            rm -f "$Q_BIN"
            echo "`q` 已卸载！"
            
            # 删除环境变量配置
            sed -i '/$(go env GOPATH)\/bin/d' ~/.profile
            source ~/.profile
            echo "卸载完成！"
        else
            echo "`q` 没有安装，无法卸载。"
        fi
        ;;
    
    *)
        # 其他输入，退出脚本
        echo "无效输入，退出脚本。"
        exit 0
        ;;
esac
