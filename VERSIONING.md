# 版本管理指南

本文档提供 Claude Skills 项目的版本管理规范和自动化工具使用指南。

## 版本管理规范

### 语义化版本控制 (SemVer)

本项目采用 [语义化版本规范 (Semantic Versioning)](https://semver.org/):

**版本格式**: `vMAJOR.MINOR.PATCH`

- **MAJOR** (主版本号): 不兼容的 API 修改
- **MINOR** (次版本号): 向下兼容的功能性新增
- **PATCH** (修订号): 向下兼容的问题修正

### 提交信息规范

使用 [约定式提交 (Conventional Commits)](https://www.conventionalcommits.org/) 格式:

```
<type>: <description>

[可选正文]

[可选脚注]
```

**提交类型**:
- `feat`: 新功能
- `fix`: 修复 bug
- `docs`: 文档更新
- `style`: 代码格式调整
- `refactor`: 重构
- `perf`: 性能优化
- `test`: 测试相关
- `chore`: 构建/工具链相关

**示例**:
```
feat: add new algorithmic-art skill

- Add fractal generation capabilities
- Include color palette customization
- Add export to SVG and PNG formats
```

## 自动化版本管理工具

### 安装和使用

1. **确保脚本可执行**:
```bash
chmod +x version-manager.sh
```

2. **基本使用**:
```bash
# 交互式版本管理
./version-manager.sh

# 显示当前状态
./version-manager.sh --status

# 显示版本历史
./version-manager.sh --version

# 显示帮助
./version-manager.sh --help
```

### 工作流程

1. **开发新功能或修复问题**
2. **运行版本管理工具**:
```bash
./version-manager.sh
```
3. **选择提交类型** (feat, fix, docs 等)
4. **输入提交描述**
5. **工具自动处理**:
   - 添加所有变更文件
   - 提交变更
   - 计算新版本号
   - 创建 Git 标签
   - 推送到远程仓库

### 版本号自动计算规则

| 提交类型 | 版本变化 | 示例 |
|---------|----------|------|
| `feat` | MINOR +1 | v1.2.3 → v1.3.0 |
| `fix` | PATCH +1 | v1.2.3 → v1.2.4 |
| `perf` | PATCH +1 | v1.2.3 → v1.2.4 |
| `major` | MAJOR +1 | v1.2.3 → v2.0.0 |
| 其他类型 | 保持不变 | v1.2.3 → v1.2.3 |

## 手动版本管理

### 查看版本历史
```bash
# 查看所有标签
git tag -l

# 查看带描述的标签
git tag -l -n9

# 查看特定版本的提交
git show v1.2.3
```

### 创建标签
```bash
# 创建带注释的标签
git tag -a v1.2.3 -m "Release v1.2.3

- 新增 algorithmic-art 技能
- 修复文档格式问题
- 优化性能"

# 推送标签到远程
git push origin v1.2.3
```

### 删除标签
```bash
# 删除本地标签
git tag -d v1.2.3

# 删除远程标签
git push origin --delete v1.2.3
```

## 分支策略

### 主要分支
- **main**: 主分支，保持稳定，用于发布
- **develop**: 开发分支，集成功能

### 支持分支
- **feature/***: 功能分支 (从 develop 创建)
- **release/***: 发布分支 (从 develop 创建)
- **hotfix/***: 热修复分支 (从 main 创建)

### 工作流程示例
```bash
# 1. 创建功能分支
git checkout -b feature/new-skill develop

# 2. 开发新技能
# ... 开发工作 ...

# 3. 提交变更
./version-manager.sh

# 4. 合并到开发分支
git checkout develop
git merge --no-ff feature/new-skill

# 5. 删除功能分支
git branch -d feature/new-skill
```

## 发布流程

### 常规发布
1. 从 `develop` 创建 `release/vX.Y.Z` 分支
2. 进行最终测试和修复
3. 更新版本号和文档
4. 合并到 `main` 并打标签
5. 合并回 `develop`

### 热修复发布
1. 从 `main` 创建 `hotfix/vX.Y.Z` 分支
2. 修复问题
3. 合并到 `main` 并打标签
4. 合并回 `develop`

## 版本回退

### 回退到特定版本
```bash
# 查看提交历史
git log --oneline

# 回退到特定提交
git reset --hard <commit-hash>

# 强制推送到远程
git push origin main --force
```

### 恢复已删除的标签
```bash
# 查找标签的提交
git fsck --unreachable | grep tag

# 恢复标签
git tag v1.2.3 <commit-hash>
```

## 最佳实践

### 1. 频繁提交
- 小步提交，每次提交一个完整的功能或修复
- 使用有意义的提交信息

### 2. 版本号管理
- 遵循 SemVer 规范
- 重大变更时增加主版本号
- 新功能时增加次版本号
- bug 修复时增加修订号

### 3. 标签管理
- 每个发布版本都打标签
- 标签信息包含变更摘要
- 及时推送标签到远程

### 4. 分支管理
- 使用功能分支开发新功能
- 定期同步主分支
- 及时清理已合并的分支

## 故障排除

### 常见问题

**问题 1**: 脚本执行权限错误
```bash
# 解决方案
chmod +x version-manager.sh
```

**问题 2**: Git 未初始化
```bash
# 解决方案
git init
git add .
git commit -m "Initial commit"
```

**问题 3**: 远程仓库未设置
```bash
# 解决方案
git remote add origin <repository-url>
```

**问题 4**: 版本冲突
```bash
# 查看当前标签
git tag -l

# 删除冲突标签
git tag -d v1.2.3
git push origin --delete v1.2.3
```

## 工具开发说明

### 脚本结构
```
version-manager.sh
├── 颜色定义和日志函数
├── Git 环境检查
├── 版本号计算逻辑
├── 提交和标签创建
├── 远程推送功能
└── 命令行参数处理
```

### 扩展功能
如需扩展脚本功能，可修改以下部分:
1. `calculate_new_version()`: 版本计算逻辑
2. `commit_changes()`: 提交处理逻辑
3. `create_tag()`: 标签创建逻辑
4. 添加新的命令行参数

### 测试脚本
```bash
# 模拟运行
./version-manager.sh --dry-run

# 检查语法
bash -n version-manager.sh

# 运行 ShellCheck
shellcheck version-manager.sh
```

## 更新日志

| 版本 | 日期 | 变更说明 |
|------|------|----------|
| v1.0.0 | 2025-12-03 | 初始版本创建 |
| v1.0.1 | 2025-12-03 | 添加故障排除章节 |

## 参考资料

- [语义化版本规范](https://semver.org/)
- [约定式提交](https://www.conventionalcommits.org/)
- [Git 官方文档](https://git-scm.com/doc)
- [Shell 脚本编程指南](https://www.shellscript.sh/)

---

**注意**: 本指南和工具适用于 Claude Skills 项目。其他项目可能需要适当调整。