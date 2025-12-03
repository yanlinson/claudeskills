#!/bin/bash

# GitHub SSH 设置脚本
# 使用方法: ./setup-ssh-github.sh

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

echo ""
log_info "=== GitHub SSH 密钥设置 ==="
echo ""

# 步骤 1: 检查现有 SSH 密钥
log_info "1. 检查现有 SSH 密钥..."
if [ -f ~/.ssh/github_rsa ]; then
    log_success "找到现有 SSH 密钥: ~/.ssh/github_rsa"
    echo "公钥指纹:"
    ssh-keygen -lf ~/.ssh/github_rsa.pub
else
    log_warning "未找到现有 SSH 密钥"

    read -p "是否要生成新的 SSH 密钥? (y/N): " generate_key
    if [[ "$generate_key" =~ ^[Yy]$ ]]; then
        log_info "生成新的 SSH 密钥..."
        ssh-keygen -t ed25519 -C "franklinmagic@gmail.com" -f ~/.ssh/id_ed25519_github
        log_success "SSH 密钥已生成: ~/.ssh/id_ed25519_github"
    else
        log_error "需要 SSH 密钥才能继续"
        exit 1
    fi
fi

# 步骤 2: 启动 ssh-agent
log_info "2. 启动 ssh-agent..."
eval "$(ssh-agent -s)" > /dev/null 2>&1
log_success "ssh-agent 已启动 (PID: $SSH_AGENT_PID)"

# 步骤 3: 添加 SSH 密钥到 ssh-agent
log_info "3. 添加 SSH 密钥到 ssh-agent..."
if [ -f ~/.ssh/github_rsa ]; then
    log_info "尝试添加现有密钥 ~/.ssh/github_rsa"
    ssh-add ~/.ssh/github_rsa
elif [ -f ~/.ssh/id_ed25519_github ]; then
    log_info "尝试添加新密钥 ~/.ssh/id_ed25519_github"
    ssh-add ~/.ssh/id_ed25519_github
else
    log_error "未找到可用的 SSH 私钥"
    exit 1
fi

# 步骤 4: 接受 GitHub 主机密钥
log_info "4. 接受 GitHub 主机密钥..."
echo "yes" | ssh -o StrictHostKeyChecking=accept-new -T git@github.com > /dev/null 2>&1
log_success "GitHub 主机密钥已接受"

# 步骤 5: 测试 SSH 连接
log_info "5. 测试 SSH 连接到 GitHub..."
if ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
    log_success "SSH 认证成功!"
    ssh -T git@github.com
else
    log_warning "SSH 连接测试未返回预期结果"
    log_info "手动测试连接..."
    ssh -T git@github.com || true
fi

# 步骤 6: 更新 Git 远程 URL 为 SSH
log_info "6. 更新 Git 远程 URL 为 SSH..."
current_origin=$(git remote get-url origin 2>/dev/null || echo "")
if [[ "$current_origin" == https://* ]]; then
    # 转换 HTTPS URL 为 SSH URL
    ssh_url=$(echo "$current_origin" | sed 's|https://github.com/|git@github.com:|')
    git remote set-url origin "$ssh_url"
    log_success "远程 URL 已更新为 SSH: $ssh_url"
elif [[ "$current_origin" == git@github.com:* ]]; then
    log_success "远程 URL 已经是 SSH 格式: $current_origin"
else
    log_warning "无法识别远程 URL 格式: $current_origin"
fi

# 步骤 7: 显示公钥（用于添加到 GitHub）
log_info "7. 显示 SSH 公钥内容..."
echo ""
echo "=== 如果 SSH 密钥尚未添加到 GitHub，请执行以下步骤: ==="
echo "1. 登录 GitHub → Settings → SSH and GPG keys"
echo "2. 点击 'New SSH key'"
echo "3. 粘贴以下公钥内容:"
echo ""
if [ -f ~/.ssh/github_rsa.pub ]; then
    cat ~/.ssh/github_rsa.pub
elif [ -f ~/.ssh/id_ed25519_github.pub ]; then
    cat ~/.ssh/id_ed25519_github.pub
fi
echo ""
echo "=== 公钥结束 ==="
echo ""

# 步骤 8: 验证设置
log_info "8. 验证完整设置..."
echo "当前远程 URL:"
git remote -v
echo ""
echo "SSH 密钥状态:"
ssh-add -l
echo ""
echo "Git 配置:"
git config --list | grep -E "(user\.|remote\..*\.url)" | head -10

# 步骤 9: 测试推送
log_info "9. 测试 Git 操作..."
echo "模拟推送测试:"
git push --dry-run origin main

echo ""
log_success "=== SSH 设置完成 ==="
echo ""
echo "下一步操作:"
echo "1. 如果 SSH 公钥尚未添加到 GitHub，请按上述步骤添加"
echo "2. 运行推送命令: git push origin main"
echo "3. 推送标签: git push origin v0.1.0"
echo ""
echo "如果需要帮助，请运行:"
echo "  ./setup-ssh-github.sh  # 重新运行此脚本"
echo "  ssh -T git@github.com  # 测试 SSH 连接"
echo "  git remote -v          # 查看远程仓库配置"
