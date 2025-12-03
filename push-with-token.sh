#!/bin/bash

# GitHub 推送脚本（使用 Personal Access Token）
# 使用方法: ./push-with-token.sh YOUR_PAT

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查参数
if [ $# -eq 0 ]; then
    echo "使用方法: $0 YOUR_PERSONAL_ACCESS_TOKEN"
    echo ""
    echo "如何获取 Personal Access Token:"
    echo "1. 登录 GitHub → Settings → Developer settings"
    echo "2. 选择 Personal access tokens → Tokens (classic)"
    echo "3. 点击 Generate new token → Generate new token (classic)"
    echo "4. 设置权限: 至少勾选 'repo'"
    echo "5. 生成并复制 token（只会显示一次!）"
    exit 1
fi

PAT="$1"
USERNAME="yanlinson"
REPO_URL="https://github.com/yanlinson/claudeskills.git"

log_info "开始推送操作..."
log_info "用户名: $USERNAME"
log_info "仓库: $REPO_URL"

# 临时修改远程 URL 包含 PAT
log_info "设置临时远程 URL..."
git remote set-url origin "https://${USERNAME}:${PAT}@github.com/yanlinson/claudeskills.git"

# 检查当前状态
log_info "检查 Git 状态..."
git status --short

# 推送主分支
log_info "推送主分支到 origin..."
if git push origin main; then
    log_info "主分支推送成功!"
else
    log_error "主分支推送失败"
    # 恢复原始 URL
    git remote set-url origin "$REPO_URL"
    exit 1
fi

# 推送标签
log_info "推送标签 v0.1.0..."
if git push origin v0.1.0; then
    log_info "标签推送成功!"
else
    log_error "标签推送失败"
fi

# 恢复原始 URL
log_info "恢复原始远程 URL..."
git remote set-url origin "$REPO_URL"

# 验证推送结果
log_info "验证远程状态..."
echo ""
echo "=== 推送结果 ==="
echo "提交: $(git log -1 --oneline)"
echo "标签: v0.1.0"
echo "远程分支: origin/main"
echo ""
echo "您可以在浏览器中查看:"
echo "https://github.com/yanlinson/claudeskills"
echo ""
echo "如果需要查看提交详情:"
echo "git log --oneline -10"
echo "git show v0.1.0"

log_info "推送操作完成!"
