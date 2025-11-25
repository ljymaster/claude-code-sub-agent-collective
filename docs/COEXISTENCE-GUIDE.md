# 双版本并存配置说明

本项目已配置为可与旧版本 `claude-code-collective` (2.0.8) 并存。

## 📦 包配置变更

### 包名改变
- **旧包名**: `claude-code-collective`
- **新包名**: `@ljymaster/claude-code-collective` (scoped package)

### 命令别名
安装后提供三个命令，功能完全相同：

1. **`ccc`** - 短命令（推荐日常使用）
2. **`claude-code-collective-v2`** - 明确标识 v2 版本
3. **通过 npx**: `npx @ljymaster/claude-code-collective`

## 🚀 安装方式

### 方法一：从 GitHub 安装（推荐）

```bash
# 安装新版本（与旧版本并存）
npm install -g https://github.com/ljymaster/claude-code-sub-agent-collective.git

# 验证安装
ccc --version                           # 应显示 2.1.0
claude-code-collective-v2 --version     # 应显示 2.1.0
claude-code-collective --version        # 旧版本，应显示 2.0.8
```

### 方法二：从本地安装

```bash
# 进入项目目录
cd D:\MyDevelop\Qoder\claude-code-sub-agent-collective-main

# 创建安装包
npm pack
# 输出: ljymaster-claude-code-collective-2.1.0.tgz

# 全局安装
npm install -g ljymaster-claude-code-collective-2.1.0.tgz

# 验证
ccc --version
```

### 方法三：使用 npm link（开发模式）

```bash
# 在项目目录创建链接
cd D:\MyDevelop\Qoder\claude-code-sub-agent-collective-main
npm link

# 验证
ccc --version
claude-code-collective-v2 --version
```

## 📋 版本对比

| 特性 | 旧版本 (2.0.8) | 新版本 (2.1.0) |
|------|---------------|---------------|
| **命令名称** | `claude-code-collective` | `ccc` / `claude-code-collective-v2` |
| **包名** | `claude-code-collective` | `@ljymaster/claude-code-collective` |
| **Qoder 支持** | ❌ | ✅ |
| **多平台检测** | ❌ | ✅ |
| **跨平台 Hooks** | ❌ | ✅ |
| **仓库地址** | anthropics | ljymaster |

## 💡 使用示例

### 使用新版本 (2.1.0)

```bash
# 快速命令
ccc init --yes --platform=qoder
ccc status
ccc validate

# 完整命令
claude-code-collective-v2 init --yes --platform=qoder
claude-code-collective-v2 status
claude-code-collective-v2 validate

# 使用 npx（无需全局安装）
npx @ljymaster/claude-code-collective init --yes --platform=qoder
```

### 使用旧版本 (2.0.8)

```bash
# 旧版本命令（保持不变）
claude-code-collective init
claude-code-collective status
claude-code-collective validate
```

## 🔄 在项目中使用

### 新项目 - 使用新版本

```bash
cd /path/to/new/project

# 使用短命令（推荐）
ccc init --yes --platform=qoder
ccc status

# 或使用完整命令
claude-code-collective-v2 init --yes --platform=qoder
```

### 现有项目 - 保持使用旧版本

```bash
cd /path/to/existing/project

# 继续使用旧命令
claude-code-collective init
claude-code-collective status
```

### 切换版本

```bash
# 在项目中使用新版本
ccc init --yes --platform=qoder --force

# 回退到旧版本
claude-code-collective init --force
```

## 📦 项目依赖配置

### package.json 示例

```json
{
  "name": "my-project",
  "version": "1.0.0",
  "devDependencies": {
    "@ljymaster/claude-code-collective": "github:ljymaster/claude-code-sub-agent-collective"
  },
  "scripts": {
    "collective:init": "ccc init --yes --platform=qoder",
    "collective:status": "ccc status",
    "collective:validate": "ccc validate"
  }
}
```

### 使用 npm scripts

```bash
npm run collective:init
npm run collective:status
npm run collective:validate
```

## 🛠️ 卸载

### 卸载新版本

```bash
# 卸载新版本（保留旧版本）
npm uninstall -g @ljymaster/claude-code-collective

# 验证
ccc --version                       # 应显示 command not found
claude-code-collective --version    # 旧版本仍然可用，显示 2.0.8
```

### 卸载旧版本

```bash
# 卸载旧版本（保留新版本）
npm uninstall -g claude-code-collective

# 验证
claude-code-collective --version    # 应显示 command not found
ccc --version                       # 新版本仍然可用，显示 2.1.0
```

### 全部卸载

```bash
# 卸载所有版本
npm uninstall -g claude-code-collective
npm uninstall -g @ljymaster/claude-code-collective

# 清理缓存
npm cache clean --force
```

## ✅ 验证并存状态

### 检查安装

```bash
# 查看所有已安装的版本
npm list -g | grep claude-code-collective

# 应该看到类似输出：
# ├── claude-code-collective@2.0.8
# └── @ljymaster/claude-code-collective@2.1.0

# 检查可用命令
which ccc                           # 或 where ccc (Windows)
which claude-code-collective        # 或 where claude-code-collective
which claude-code-collective-v2     # 或 where claude-code-collective-v2
```

### 验证版本

```bash
# 新版本
ccc --version                           # 2.1.0
claude-code-collective-v2 --version     # 2.1.0

# 旧版本
claude-code-collective --version        # 2.0.8
```

### 测试功能

```bash
# 创建测试目录
mkdir /tmp/test-v2
cd /tmp/test-v2

# 测试新版本
ccc init --yes --platform=qoder
ccc status
ccc validate

# 测试旧版本
mkdir /tmp/test-v1
cd /tmp/test-v1
claude-code-collective init
claude-code-collective status
```

## 🎯 推荐工作流

### 新项目开发

```bash
# 使用新版本 (2.1.0) - 支持 Qoder CLI
cd /path/to/new/project
ccc init --yes --platform=qoder
ccc status
```

### 维护现有项目

```bash
# 保持使用旧版本 (2.0.8) - 避免破坏性变更
cd /path/to/existing/project
claude-code-collective status
```

### 逐步迁移

```bash
# 1. 在新分支测试新版本
git checkout -b test-v2

# 2. 使用新版本初始化
ccc init --yes --platform=qoder --force --backup full

# 3. 验证功能
ccc validate --detailed

# 4. 测试通过后合并
git checkout main
git merge test-v2
```

## 📚 相关文档

- [GitHub 安装指南](./GITHUB-INSTALL-GUIDE.md)
- [快速安装指南](./QUICK-INSTALL-GUIDE.md)
- [Qoder 使用指南](./QODER-USAGE.md)
- [完整安装指南](../INSTALLATION-GUIDE.md)

## 💬 技术支持

- **GitHub Issues**: https://github.com/ljymaster/claude-code-sub-agent-collective/issues
- **仓库地址**: https://github.com/ljymaster/claude-code-sub-agent-collective

## 📝 更新日志

### v2.1.0 变更
- ✅ 改为 scoped package (`@ljymaster/claude-code-collective`)
- ✅ 添加短命令 `ccc`
- ✅ 添加版本明确命令 `claude-code-collective-v2`
- ✅ 支持与旧版本并存
- ✅ 更新仓库地址为 ljymaster
- ✅ 新增 Qoder CLI 完整支持
- ✅ 新增多平台自动检测
- ✅ 新增跨平台 Hook 系统

---

**总结**: 通过使用 scoped package 和不同的命令名称，新旧版本可以完美并存，互不干扰。推荐在新项目中使用 `ccc` 命令，在现有项目中保持使用 `claude-code-collective` 命令。
