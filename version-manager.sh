#!/bin/bash

# ============================================
# Claude Skills 版本管理自动化脚本
# 版本: 1.0.0
# 最后更新: 2025-12-03
# ============================================

set -e  # 遇到错误时退出

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日志函数
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

# 检查 Git 是否安装
check_git() {
    if ! command -v git &> /dev/null; then
        log_error "Git 未安装，请先安装 Git"
        exit 1
    fi
    log_info "Git 版本: $(git --version)"
}

# 检查是否在 Git 仓库中
check_git_repo() {
    if [ ! -d ".git" ]; then
        log_error "当前目录不是 Git 仓库"
        exit 1
    fi
}

# 获取当前版本
get_current_version() {
    local current_version=$(git describe --tags --abbrev=0 2>/dev/null || echo "v0.0.0")
    echo "$current_version"
}

# 计算新版本号
calculate_new_version() {
    local current_version=$1
    local commit_type=$2

    # 移除 'v' 前缀
    current_version=${current_version#v}

    # 分割版本号
    IFS='.' read -r major minor patch <<< "$current_version"

    case $commit_type in
        "major")
            major=$((major + 1))
            minor=0
            patch=0
            ;;
        "minor"|"feat")
            minor=$((minor + 1))
            patch=0
            ;;
        "patch"|"fix"|"perf")
            patch=$((patch + 1))
            ;;
        *)
            # 默认不增加版本号
            ;;
    esac

    echo "v${major}.${minor}.${patch}"
}

# 显示当前状态
show_status() {
    log_info "=== 当前状态 ==="
    log_info "分支: $(git branch --show-current)"
    log_info "最新提交: $(git log -1 --oneline)"
    log_info "当前版本: $(get_current_version)"
    log_info "未暂存变更: $(git status --porcelain | wc -l) 个文件"
    echo ""
}

# 添加和提交变更
commit_changes() {
    local commit_msg="$1"

    log_info "添加变更文件..."
    git add .

    log_info "提交变更..."
    git commit -m "$commit_msg"

    log_success "变更已提交: $commit_msg"
}

# 创建新标签
create_tag() {
    local new_version="$1"
    local commit_msg="$2"

    log_info "创建新标签: $new_version"
    git tag -a "$new_version" -m "Release $new_version

$commit_msg"

    log_success "标签 $new_version 已创建"
}

# 推送到远程
push_to_remote() {
    local current_branch=$(git branch --show-current)
    local new_version="$1"

    log_info "推送到远程仓库..."
    git push origin "$current_branch"

    if [ "$new_version" != "v0.0.0" ]; then
        log_info "推送标签..."
        git push origin "$new_version"
    fi

    log_success "变更已推送到远程"
}

# 显示版本历史
show_version_history() {
    log_info "=== 版本历史 ==="
    git tag -l -n9 | head -20
    echo ""
}

# 主函数
main() {
    log_info "Claude Skills 版本管理工具"
    log_info "============================="
    echo ""

    # 检查环境
    check_git
    check_git_repo

    # 显示当前状态
    show_status

    # 获取提交信息
    echo "请选择提交类型:"
    echo "1) feat    - 新功能"
    echo "2) fix     - 修复 bug"
    echo "3) docs    - 文档更新"
    echo "4) style   - 代码格式"
    echo "5) refactor- 重构"
    echo "6) perf    - 性能优化"
    echo "7) test    - 测试相关"
    echo "8) chore   - 构建/工具"
    echo "9) major   - 重大版本更新"
    echo ""

    read -p "请输入选项编号 (1-9): " option

    case $option in
        1) commit_type="feat" ;;
        2) commit_type="fix" ;;
        3) commit_type="docs" ;;
        4) commit_type="style" ;;
        5) commit_type="refactor" ;;
        6) commit_type="perf" ;;
        7) commit_type="test" ;;
        8) commit_type="chore" ;;
        9) commit_type="major" ;;
        *)
            log_error "无效选项"
            exit 1
            ;;
    esac

    read -p "请输入提交描述: " description

    # 构建完整的提交信息
    commit_msg="$commit_type: $description"

    # 获取当前版本
    current_version=$(get_current_version)
    log_info "当前版本: $current_version"

    # 计算新版本
    new_version=$(calculate_new_version "$current_version" "$commit_type")

    if [ "$current_version" != "$new_version" ]; then
        log_info "新版本: $new_version"

        # 确认版本更新
        read -p "确认更新版本到 $new_version? (y/N): " confirm
        if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
            log_warning "版本更新已取消"
            new_version="$current_version"
        fi
    else
        log_info "版本保持不变: $new_version"
    fi

    # 确认提交
    echo ""
    log_info "即将执行以下操作:"
    log_info "1. 提交信息: $commit_msg"
    log_info "2. 新版本: $new_version"
    echo ""

    read -p "确认执行? (y/N): " final_confirm
    if [[ ! "$final_confirm" =~ ^[Yy]$ ]]; then
        log_warning "操作已取消"
        exit 0
    fi

    echo ""

    # 执行操作
    commit_changes "$commit_msg"

    if [ "$current_version" != "$new_version" ] && [[ "$new_version" != "v0.0.0" ]]; then
        create_tag "$new_version" "$commit_msg"
    fi

    push_to_remote "$new_version"

    echo ""
    log_success "=== 操作完成 ==="
    log_info "提交: $commit_msg"
    log_info "版本: $new_version"
    log_info "分支: $(git branch --show-current)"
    echo ""

    # 显示版本历史
    show_version_history
}

# 帮助信息
show_help() {
    echo "用法: ./version-manager.sh [选项]"
    echo ""
    echo "选项:"
    echo "  -h, --help     显示帮助信息"
    echo "  -s, --status   显示当前状态"
    echo "  -v, --version  显示版本历史"
    echo "  --dry-run      模拟运行，不实际执行"
    echo ""
    echo "示例:"
    echo "  ./version-manager.sh          # 交互式版本管理"
    echo "  ./version-manager.sh --status # 显示当前状态"
    echo "  ./version-manager.sh --version # 显示版本历史"
}

# 处理命令行参数
case "$1" in
    -h|--help)
        show_help
        exit 0
        ;;
    -s|--status)
        check_git
        check_git_repo
        show_status
        exit 0
        ;;
    -v|--version)
        check_git
        check_git_repo
        show_version_history
        exit 0
        ;;
    --dry-run)
        log_info "模拟运行模式..."
        # 这里可以添加模拟运行的逻辑
        exit 0
        ;;
    *)
        # 无参数或无效参数，执行主函数
        if [ $# -eq 0 ]; then
            main
        else
            log_error "未知参数: $1"
            show_help
            exit 1
        fi
        ;;
esac
