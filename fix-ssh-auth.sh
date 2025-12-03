#!/bin/bash

# SSH 认证修复脚本
# 解决 "Permission denied (publickey)" 错误

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
log_info "=== SSH 认证问题修复 ==="
echo "错误: git@github.com: Permission denied (publickey)"
echo ""

# 1. 检查 SSH 密钥文件
log_info "1. 检查 SSH 密钥文件..."
if [ -f ~/.ssh/github_rsa ]; then
    log_success "找到 SSH 私钥: ~/.ssh/github_rsa"
    log_info "公钥指纹:"
    ssh-keygen -lf ~/.ssh/github_rsa.pub

    echo ""
    log_info "公钥内容 (请确认已添加到 GitHub):"
    cat ~/.ssh/github_rsa.pub
    echo ""
else
    log_error "未找到 ~/.ssh/github_rsa"
    exit 1
fi

# 2. 启动 SSH 代理
log_info "2. 启动 SSH 代理..."
eval "$(ssh-agent -s)" > /dev/null 2>&1
log_success "SSH 代理已启动 (PID: $SSH_AGENT_PID)"

# 3. 添加 SSH 密钥到代理
log_info "3. 添加 SSH 密钥到代理..."
log_warning "注意: 您的 SSH 密钥受密码保护，需要输入密码"
echo ""

if ssh-add ~/.ssh/github_rsa; then
    log_success "SSH 密钥已成功添加到代理"
else
    log_error "添加 SSH 密钥失败"
    log_info "可能的原因:"
    echo "  - 密码错误"
    echo "  - 密钥文件权限问题"
    echo "  - 密钥格式不正确"
    echo ""
    log_info "尝试修复权限..."
    chmod 600 ~/.ssh/github_rsa
    chmod 644 ~/.ssh/github_rsa.pub
    echo "重新尝试添加密钥..."
    ssh-add ~/.ssh/github_rsa || {
        log_error "仍然失败，请检查密码或考虑生成新密钥"
        exit 1
    }
fi

# 4. 验证密钥已加载
log_info "4. 验证密钥加载状态..."
ssh-add -l

# 5. 测试 GitHub 连接
log_info "5. 测试 GitHub SSH 连接..."
echo "测试连接 (可能需要几秒钟)..."
if ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
    log_success "SSH 认证成功!"
    ssh -T git@github.com
else
    log_warning "SSH 认证仍然失败"
    log_info "详细调试信息:"
    ssh -Tv git@github.com 2>&1 | tail -20

    echo ""
    log_info "可能的问题和解决方案:"
    echo "1. SSH 公钥未添加到 GitHub"
    echo "   解决方案: 将上面的公钥内容添加到 GitHub Settings → SSH and GPG keys"
    echo ""
    echo "2. 使用了错误的 GitHub 账户"
    echo "   解决方案: 确认公钥关联的邮箱 (yanlinson@github.com) 是正确的 GitHub 账户"
    echo ""
    echo "3. SSH 密钥密码错误"
    echo "   解决方案: 如果忘记密码，需要生成新的 SSH 密钥对"
    echo ""
    echo "4. 网络或防火墙问题"
    echo "   解决方案: 检查网络连接，尝试使用 HTTPS + PAT 作为临时方案"
fi

# 6. 检查 Git 远程配置
log_info "6. 检查 Git 远程配置..."
echo "当前远程 URL:"
git remote -v

# 7. 备选方案：生成新密钥
echo ""
log_info "备选方案: 生成新的 SSH 密钥"
read -p "是否要生成新的 SSH 密钥? (y/N): " generate_new

if [[ "$generate_new" =~ ^[Yy]$ ]]; then
    log_info "生成新的 SSH 密钥..."
    ssh-keygen -t ed25519 -C "franklinmagic@gmail.com" -f ~/.ssh/id_ed25519_github_new

    log_success "新密钥已生成: ~/.ssh/id_ed25519_github_new"
    echo ""
    log_info "新公钥内容 (请添加到 GitHub):"
    cat ~/.ssh/id_ed25519_github_new.pub
    echo ""

    log_info "添加新密钥到代理..."
    ssh-add ~/.ssh/id_ed25519_github_new

    log_info "测试新密钥连接..."
    ssh -T git@github.com
fi

echo ""
log_success "=== 诊断完成 ==="
echo ""
echo "建议的下一步:"
echo "1. 确认公钥已添加到 GitHub: https://github.com/settings/keys"
echo "2. 如果仍然失败，考虑生成新密钥"
echo "3. 临时使用 PAT: ./push-with-token.sh YOUR_PAT"
echo "4. 测试推送: git push --dry-run origin main"
