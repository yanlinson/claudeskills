# CLAUDE.md

本文件为 Claude Code (claude.ai/code) 提供在此仓库中工作的指导。

## 项目概述

这是 Claude Skills 官方仓库，包含各种技能示例和模板，用于演示和扩展 Claude 的能力。

## 环境配置

- **操作系统**: macOS (Darwin)
- **Node.js 管理**: 推荐使用 bun 或 npm
- **Python 环境**: 推荐使用 uv 或 conda
- **Git 代码托管**: GitHub

## 项目结构

```
.
├── skills/                    # 技能集合目录
│   ├── algorithmic-art/      # 算法艺术生成
│   ├── brand-guidelines/     # 品牌设计指南
│   ├── canvas-design/        # Canvas 设计工具
│   ├── docx/                # Word 文档处理
│   ├── frontend-design/     # 前端设计
│   ├── internal-comms/      # 内部通信模板
│   ├── mcp-builder/         # MCP 服务器构建工具
│   ├── pdf/                 # PDF 文档处理
│   ├── pptx/                # PowerPoint 演示文稿
│   ├── skill-creator/       # 技能创建工具
│   ├── slack-gif-creator/   # Slack GIF 创建
│   ├── story-continuation/  # 故事续写
│   ├── theme-factory/       # 主题工厂
│   ├── web-artifacts-builder/ # Web 工件构建器
│   └── webapp-testing/      # Web 应用测试
├── spec/                    # Agent Skills 规范
├── template/               # 技能模板
└── story-continuation/     # 故事续写示例
```

## 常用命令

### Git 相关

```bash
# 克隆仓库
git clone https://github.com/anthropics/skills.git

# 查看状态
git status

# 添加所有变更
git add .

# 提交变更
git commit -m "描述变更内容"

# 推送变更
git push origin main
```

### 技能开发

```bash
# 创建新技能目录
mkdir skills/my-new-skill

# 创建技能文件
touch skills/my-new-skill/SKILL.md

# 使用技能模板
cp template/skill-template.md skills/my-new-skill/SKILL.md
```

## 核心功能说明

### 技能系统
技能是包含指令、脚本和资源的文件夹，Claude 可以动态加载这些技能来提升特定任务的性能。

**技能结构**:
- 每个技能在独立文件夹中
- 包含 `SKILL.md` 文件（包含 YAML frontmatter 和指令）
- 可包含相关配置和模板文件

**主要技能分类**:
1. **创意与设计**: algorithmic-art, brand-guidelines, canvas-design, frontend-design, theme-factory
2. **开发与技术**: mcp-builder, webapp-testing, web-artifacts-builder
3. **企业通信**: internal-comms, slack-gif-creator
4. **文档处理**: docx, pdf, pptx, xlsx
5. **工具与模板**: skill-creator, story-continuation

### 文档处理技能
位于 `skills/docx/`, `skills/pdf/`, `skills/pptx/`, `skills/xlsx/` 子文件夹：
- 支持创建、编辑和提取文档内容
- 基于 Apache 2.0 许可证（部分为源可用，非开源）
- 作为复杂技能的生产参考

## 架构设计原则

### 文件组织
- 每个技能目录独立，包含完整的技能定义
- `SKILL.md` 文件使用 YAML frontmatter 定义元数据
- 相关资源文件放在技能目录内

### 技能开发规范
- 使用清晰的技能名称（小写，连字符分隔）
- 提供完整的技能描述
- 包含使用示例和指南
- 遵循技能模板结构

### 错误处理
- 技能应包含错误处理指南
- 提供清晰的用户反馈
- 区分不同类型的错误场景

## 项目初始化指南

当在新的技能目录开始工作时：

1. **创建技能目录**:
   ```bash
   mkdir skills/my-new-skill
   ```

2. **创建技能文件**:
   ```bash
   # 使用模板
   cp template/skill-template.md skills/my-new-skill/SKILL.md
   
   # 或手动创建
   touch skills/my-new-skill/SKILL.md
   ```

3. **编辑技能文件**:
   ```markdown
   ---
   name: my-new-skill
   description: 清晰描述技能功能和适用场景
   ---
   
   # 技能名称
   
   [在此添加 Claude 执行此技能时遵循的指令]
   
   ## 示例
   - 示例用法 1
   - 示例用法 2
   
   ## 指南
   - 指南 1
   - 指南 2
   ```

4. **添加相关资源**:
   ```bash
   # 如有需要，添加配置文件、模板等
   touch skills/my-new-skill/config.json
   mkdir skills/my-new-skill/templates/
   ```

## MCP 服务器集成

当前项目支持 MCP 服务器集成，可通过 Claude Code 配置：

**推荐的 MCP 服务器**:
- **context7**: 获取最新的库文档和代码示例
- **sequential-thinking**: 动态问题解决和思维链分析
- **fetch**: 网页内容获取
- **MiniMax**: Web 搜索和图片理解
- **acp**: 文件读写和 Bash 命令执行

**配置方法**:
在 Claude Code 设置中添加 MCP 服务器配置，参考各服务器的官方文档。

## 技能使用

### 在 Claude Code 中使用
```bash
# 注册为 Claude Code 插件市场
/plugin marketplace add anthropics/skills

# 安装特定技能集
/plugin install document-skills@anthropic-agent-skills
/plugin install example-skills@anthropic-agent-skills
```

### 在 Claude.ai 中使用
- 付费计划已包含这些示例技能
- 可上传自定义技能使用

### 在 Claude API 中使用
- 通过 API 使用预构建技能
- 上传自定义技能
- 参考 [Skills API Quickstart](https://docs.claude.com/en/api/skills-guide#creating-a-skill)

## 语言偏好

所有技能指令、文档和输出应使用**英文**，因为这是国际化的技能仓库。中文注释和说明可作为补充。

---

## 版本管理规则

### 语义化版本控制

本项目采用 [语义化版本规范 (Semantic Versioning)](https://semver.org/)：

**版本格式**: `vMAJOR.MINOR.PATCH`

- **MAJOR** (主版本号): 不兼容的 API 修改
- **MINOR** (次版本号): 向下兼容的功能性新增
- **PATCH** (修订号): 向下兼容的问题修正

### 提交信息规范

使用 [约定式提交 (Conventional Commits)](https://www.conventionalcommits.org/) 格式：

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

### 自动化工作流建议

完成重大变更后，建议执行：

```bash
#!/bin/bash
# 自动化版本管理和发布脚本

# 步骤 1: 添加所有变更
git add .

# 步骤 2: 提交变更
read -p "Enter commit message (feat/fix/docs/etc): " commit_msg
git commit -m "$commit_msg"

# 步骤 3: 获取当前版本号
CURRENT_VERSION=$(git describe --tags --abbrev=0 2>/dev/null || echo "v0.0.0")

# 步骤 4: 计算新版本号
if [[ $commit_msg == feat:* ]]; then
    # 新功能 - 增加 MINOR 版本
    NEW_VERSION=$(echo $CURRENT_VERSION | awk -F. '{$2 = $2 + 1; $3 = 0;} 1' | sed 's/ /./g')
elif [[ $commit_msg == fix:* ]] || [[ $commit_msg == perf:* ]]; then
    # 修复或优化 - 增加 PATCH 版本
    NEW_VERSION=$(echo $CURRENT_VERSION | awk -F. '{$3 = $3 + 1;} 1' | sed 's/ /./g')
else
    # 其他类型 - 保持版本不变
    NEW_VERSION=$CURRENT_VERSION
fi

# 步骤 5: 创建新标签（仅当版本变化时）
if [ "$CURRENT_VERSION" != "$NEW_VERSION" ]; then
    echo "Creating new tag: $NEW_VERSION"
    git tag -a $NEW_VERSION -m "Release $NEW_VERSION"
    git push origin $NEW_VERSION
fi

# 步骤 6: 推送提交
git push origin main
```

### 版本历史

| 版本号 | 发布日期 | 主要变更 |
|--------|----------|----------|
| 初始版本 | - | 项目初始化，包含基础技能集合 |

## Git 工作流

### 分支策略

- **main**: 主分支，保持稳定
- **feature/***: 功能分支（用于新技能开发）
- **fix/***: 修复分支（用于问题修复）
- **docs/***: 文档分支（用于文档更新）

### 开发流程

1. 从 main 分支创建功能分支
2. 在功能分支上开发新技能或功能
3. 提交变更并推送到远程
4. 创建 Pull Request 到 main 分支
5. 代码审查后合并

### 推送前检查

在推送前，确保：
- [ ] 技能文件格式正确
- [ ] SKILL.md 包含完整的 YAML frontmatter
- [ ] 提交信息符合规范
- [ ] 无敏感信息泄露
- [ ] 文档更新完整

## 贡献指南

1. **Fork 仓库**
2. **创建功能分支**
3. **开发新技能或改进现有技能**
4. **测试技能功能**
5. **提交 Pull Request**
6. **等待代码审查**

## 许可证说明

- 大多数技能使用 Apache 2.0 许可证
- 文档处理技能（docx, pdf, pptx, xlsx）为源可用，非开源
- 详细许可证信息见 THIRD_PARTY_NOTICES.md

## 技术支持

- 技能文档: https://support.claude.com/en/articles/12512176-what-are-skills
- 技能创建指南: https://support.claude.com/en/articles/12512198-creating-custom-skills
- API 文档: https://docs.claude.com/en/api/skills-guide
- GitHub Issues: 报告问题或建议功能