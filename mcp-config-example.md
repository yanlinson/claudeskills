# MCP 服务器集成配置指南

本文档提供在 Claude Code 中配置 MCP (Model Context Protocol) 服务器的详细指南。

## 什么是 MCP？

MCP (Model Context Protocol) 是一个开放协议，允许 AI 模型安全地访问外部工具、数据源和服务。通过 MCP，Claude 可以：
- 读取文件系统内容
- 执行 Bash 命令
- 访问网页内容
- 使用专业工具和数据库

## 推荐的 MCP 服务器

### 1. **context7** - 库文档和代码示例
获取最新的库文档、API 参考和代码示例。

**安装配置**:
```bash
# 通过 npm 安装
npm install -g @modelcontextprotocol/server-context7

# 或使用 npx 运行
npx @modelcontextprotocol/server-context7
```

**Claude Code 配置**:
```json
{
  "mcpServers": {
    "context7": {
      "command": "npx",
      "args": ["@modelcontextprotocol/server-context7"]
    }
  }
}
```

### 2. **sequential-thinking** - 思维链分析
动态问题解决和思维链分析工具。

**安装配置**:
```bash
# 通过 npm 安装
npm install -g @modelcontextprotocol/server-sequential-thinking
```

**Claude Code 配置**:
```json
{
  "mcpServers": {
    "sequential-thinking": {
      "command": "npx",
      "args": ["@modelcontextprotocol/server-sequential-thinking"]
    }
  }
}
```

### 3. **fetch** - 网页内容获取
获取和分析网页内容。

**安装配置**:
```bash
# 通过 npm 安装
npm install -g @modelcontextprotocol/server-fetch
```

**Claude Code 配置**:
```json
{
  "mcpServers": {
    "fetch": {
      "command": "npx",
      "args": ["@modelcontextprotocol/server-fetch"]
    }
  }
}
```

### 4. **MiniMax** - Web 搜索和图片理解
Web 搜索和图片内容理解。

**安装配置**:
```bash
# 需要 API 密钥
# 访问 https://www.minimaxi.com/ 获取 API 密钥
```

**Claude Code 配置**:
```json
{
  "mcpServers": {
    "minimax": {
      "command": "npx",
      "args": ["@modelcontextprotocol/server-minimax"],
      "env": {
        "MINIMAX_API_KEY": "your-api-key-here"
      }
    }
  }
}
```

### 5. **acp** - 文件读写和 Bash 命令
文件系统访问和 Bash 命令执行（已集成在 Claude Code 中）。

**自动配置**，无需手动设置。

## 配置步骤

### 步骤 1: 安装 Node.js 和 npm
确保系统已安装 Node.js (v16+) 和 npm。

```bash
# 检查 Node.js 版本
node --version

# 检查 npm 版本
npm --version
```

### 步骤 2: 安装 MCP 服务器
选择需要的 MCP 服务器进行安装：

```bash
# 安装单个服务器
npm install -g @modelcontextprotocol/server-context7

# 或批量安装常用服务器
npm install -g \
  @modelcontextprotocol/server-context7 \
  @modelcontextprotocol/server-sequential-thinking \
  @modelcontextprotocol/server-fetch
```

### 步骤 3: 配置 Claude Code

1. 打开 Claude Code 设置
2. 找到 "MCP Servers" 配置部分
3. 添加服务器配置：

```json
{
  "mcpServers": {
    "context7": {
      "command": "npx",
      "args": ["@modelcontextprotocol/server-context7"]
    },
    "sequential-thinking": {
      "command": "npx",
      "args": ["@modelcontextprotocol/server-sequential-thinking"]
    },
    "fetch": {
      "command": "npx",
      "args": ["@modelcontextprotocol/server-fetch"]
    }
  }
}
```

### 步骤 4: 重启 Claude Code
保存配置后重启 Claude Code 使配置生效。

## 验证配置

### 方法 1: 检查 MCP 服务器状态
在 Claude Code 中执行：

```bash
# 查看可用的 MCP 工具
echo "可用的 MCP 工具列表"
```

### 方法 2: 测试具体功能
```bash
# 测试文件读取
cat README.md

# 测试网页获取（如果配置了 fetch）
curl https://example.com

# 测试库文档查询（如果配置了 context7）
python requests library documentation
```

## 高级配置

### 环境变量配置
某些 MCP 服务器需要环境变量：

```json
{
  "mcpServers": {
    "custom-server": {
      "command": "node",
      "args": ["/path/to/server.js"],
      "env": {
        "API_KEY": "your-api-key",
        "DATABASE_URL": "postgresql://user:pass@localhost/db"
      }
    }
  }
}
```

### 自定义 MCP 服务器
创建自定义 MCP 服务器：

1. **创建服务器脚本** (`my-mcp-server.js`):
```javascript
#!/usr/bin/env node

const { Server } = require('@modelcontextprotocol/sdk/server.js');
const { StdioServerTransport } = require('@modelcontextprotocol/sdk/stdio.js');

const server = new Server(
  {
    name: "my-custom-server",
    version: "1.0.0",
  },
  {
    capabilities: {
      tools: {}
    }
  }
);

// 添加工具定义
server.setRequestHandler("tools/list", async () => {
  return {
    tools: [
      {
        name: "custom_tool",
        description: "My custom tool",
        inputSchema: {
          type: "object",
          properties: {
            param: { type: "string" }
          }
        }
      }
    ]
  };
});

// 启动服务器
const transport = new StdioServerTransport();
await server.connect(transport);
```

2. **配置 Claude Code**:
```json
{
  "mcpServers": {
    "my-custom-server": {
      "command": "node",
      "args": ["/path/to/my-mcp-server.js"]
    }
  }
}
```

## 故障排除

### 常见问题 1: MCP 服务器未启动
**症状**: Claude 无法使用 MCP 工具
**解决方案**:
1. 检查服务器是否安装: `which npx`
2. 检查配置语法是否正确
3. 查看 Claude Code 日志

### 常见问题 2: 权限错误
**症状**: "Permission denied" 错误
**解决方案**:
```bash
# 给予执行权限
chmod +x /path/to/server.js

# 或使用 npx
npx @modelcontextprotocol/server-context7
```

### 常见问题 3: 环境变量未设置
**症状**: API 密钥相关错误
**解决方案**:
1. 在配置中添加 env 字段
2. 确保环境变量值正确
3. 重启 Claude Code

## 安全注意事项

1. **最小权限原则**: 只授予必要的权限
2. **API 密钥管理**: 不要将密钥提交到版本控制
3. **网络访问控制**: 限制不必要的网络访问
4. **文件系统访问**: 限制对敏感目录的访问

## 性能优化建议

1. **按需加载**: 只配置需要的 MCP 服务器
2. **缓存配置**: 利用 MCP 服务器的缓存功能
3. **连接池**: 对于高频使用的服务器配置连接池
4. **监控日志**: 定期检查服务器性能和错误日志

## 参考资料

- [MCP 官方文档](https://spec.modelcontextprotocol.io/)
- [Claude Code MCP 配置指南](https://docs.anthropic.com/en/docs/build-with-claude/claude-code/mcp)
- [MCP 服务器仓库](https://github.com/modelcontextprotocol/servers)
- [创建自定义 MCP 服务器](https://spec.modelcontextprotocol.io/specification/server/)

## 更新日志

| 日期 | 版本 | 变更说明 |
|------|------|----------|
| 2025-12-03 | 1.0.0 | 初始版本创建 |
| 2025-12-03 | 1.0.1 | 添加故障排除和性能优化章节 |

---

**注意**: 本指南基于当前可用的 MCP 服务器和 Claude Code 版本。具体配置可能因版本更新而变化，请参考官方文档获取最新信息。