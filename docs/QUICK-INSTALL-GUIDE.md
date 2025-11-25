# 快速安装指南 - 无需 NPM 发布

本指南提供三种无需发布到 NPM 即可快速使用 Claude Code Collective 的方法。

## 📋 目录

- [方法一：一键快速安装（推荐）](#方法一一键快速安装推荐)
- [方法二：全局安装 .tgz 包](#方法二全局安装-tgz-包)
- [方法三：直接使用本地包](#方法三直接使用本地包)
- [方法四：创建本地 NPM 链接](#方法四创建本地-npm-链接)

---

## 方法一：一键快速安装（推荐）

### Windows 用户

```cmd
# 进入你的项目目录
cd D:\MyProject

# 运行快速安装脚本
D:\MyDevelop\Qoder\claude-code-sub-agent-collective-main\scripts\quick-install.bat
```

### Linux/Mac 用户

```bash
# 进入你的项目目录
cd /path/to/your/project

# 运行快速安装脚本
/path/to/claude-code-sub-agent-collective-main/scripts/quick-install.sh
```

### 工作原理

脚本自动执行以下步骤：
1. 在源码目录创建 `.tgz` 安装包
2. 在目标目录安装该包
3. 执行 Qoder 平台初始化
4. 显示安装状态

---

## 方法二：全局安装 .tgz 包

适合需要在多个项目中使用的情况。

### 步骤 1：创建安装包

```bash
# 在源码目录
cd D:\MyDevelop\Qoder\claude-code-sub-agent-collective-main

# 创建 .tgz 包
npm pack

# 输出: claude-code-collective-2.1.0.tgz
```

### 步骤 2：全局安装

```bash
# 全局安装本地包
npm install -g D:\MyDevelop\Qoder\claude-code-sub-agent-collective-main\claude-code-collective-2.1.0.tgz

# 验证安装
claude-code-collective --version
# 输出: 2.1.0
```

### 步骤 3：在任意项目中使用

```bash
# 进入任意项目目录
cd D:\MyProject

# 直接使用命令（已在全局）
claude-code-collective init --yes --platform=qoder

# 检查状态
claude-code-collective status

# 验证安装
claude-code-collective validate
```

### 步骤 4：更新全局安装

```bash
# 当源码有更新时
cd D:\MyDevelop\Qoder\claude-code-sub-agent-collective-main

# 重新打包
npm pack

# 重新全局安装（会覆盖旧版本）
npm install -g claude-code-collective-2.1.0.tgz
```

### 卸载全局安装

```bash
npm uninstall -g claude-code-collective
```

---

## 方法三：直接使用本地包

适合临时测试或单次使用。

### 使用绝对路径

```bash
# 方式 A: 先打包再使用
cd D:\MyDevelop\Qoder\claude-code-sub-agent-collective-main
npm pack

cd D:\MyProject
npx D:\MyDevelop\Qoder\claude-code-sub-agent-collective-main\claude-code-collective-2.1.0.tgz init --yes --platform=qoder

# 方式 B: 直接使用源码目录
cd D:\MyProject
npx D:\MyDevelop\Qoder\claude-code-sub-agent-collective-main init --yes --platform=qoder
```

### 使用相对路径

```bash
# 假设目录结构:
# D:\MyDevelop\Qoder\
#   ├── claude-code-sub-agent-collective-main/
#   └── MyProject/

cd D:\MyDevelop\Qoder\MyProject

# 使用相对路径
npx ../claude-code-sub-agent-collective-main init --yes --platform=qoder
```

### 创建便捷别名（可选）

**Windows (PowerShell):**

```powershell
# 添加到 PowerShell 配置文件
notepad $PROFILE

# 添加以下内容:
function ccc-install {
    npx D:\MyDevelop\Qoder\claude-code-sub-agent-collective-main\claude-code-collective-2.1.0.tgz $args
}

# 使用:
cd D:\MyProject
ccc-install init --yes --platform=qoder
```

**Linux/Mac (Bash):**

```bash
# 添加到 ~/.bashrc 或 ~/.zshrc
alias ccc-install='npx /path/to/claude-code-sub-agent-collective-main/claude-code-collective-2.1.0.tgz'

# 重新加载配置
source ~/.bashrc

# 使用:
cd /path/to/project
ccc-install init --yes --platform=qoder
```

---

## 方法四：创建本地 NPM 链接

适合开发和调试场景，可以实时看到代码变更效果。

### 步骤 1：创建全局链接

```bash
# 在源码目录创建全局符号链接
cd D:\MyDevelop\Qoder\claude-code-sub-agent-collective-main
npm link

# 输出类似:
# added 1 package in 0.5s
# C:\Users\YourName\AppData\Roaming\npm\node_modules\claude-code-collective -> D:\MyDevelop\Qoder\claude-code-sub-agent-collective-main
```

### 步骤 2：在项目中使用

```bash
# 方式 A: 在项目中链接（作为依赖）
cd D:\MyProject
npm link claude-code-collective

# 方式 B: 直接使用全局命令
cd D:\MyProject
claude-code-collective init --yes --platform=qoder
```

### 步骤 3：实时开发

```bash
# 修改源码
cd D:\MyDevelop\Qoder\claude-code-sub-agent-collective-main
# 编辑 lib/installer.js 或其他文件...

# 立即测试（无需重新打包）
cd D:\MyProject
claude-code-collective init --yes --platform=qoder --force
```

### 步骤 4：解除链接

```bash
# 在项目中解除链接
cd D:\MyProject
npm unlink claude-code-collective

# 删除全局链接
cd D:\MyDevelop\Qoder\claude-code-sub-agent-collective-main
npm unlink
```

---

## 🔍 各方法对比

| 方法 | 速度 | 便捷性 | 适用场景 | 实时更新 |
|------|------|--------|----------|----------|
| 一键脚本 | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ | 快速部署 | ❌ |
| 全局安装 | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | 多项目使用 | ❌ |
| 直接使用 | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | 临时测试 | ❌ |
| NPM Link | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | 开发调试 | ✅ |

---

## 📝 完整示例流程

### 场景：在新项目中快速使用

**Windows PowerShell:**

```powershell
# 1. 进入源码目录，创建包
cd D:\MyDevelop\Qoder\claude-code-sub-agent-collective-main
npm pack

# 2. 全局安装（只需一次）
npm install -g .\claude-code-collective-2.1.0.tgz

# 3. 在任意项目使用
cd D:\MyProject
claude-code-collective init --yes --platform=qoder
claude-code-collective status

# 4. 验证
claude-code-collective validate --detailed

# 5. 开始使用 Qoder CLI
# 在 Qoder CLI 中，系统会自动加载配置和 agents
```

**Linux/Mac:**

```bash
# 1. 进入源码目录，创建包
cd ~/develop/claude-code-sub-agent-collective-main
npm pack

# 2. 全局安装（只需一次）
sudo npm install -g ./claude-code-collective-2.1.0.tgz

# 3. 在任意项目使用
cd ~/projects/my-project
claude-code-collective init --yes --platform=qoder
claude-code-collective status

# 4. 验证
claude-code-collective validate --detailed
```

---

## ⚡ 快速参考

### 常用命令

```bash
# 安装到当前目录（快速模式）
claude-code-collective init --yes --platform=qoder

# 安装到指定目录
claude-code-collective init /path/to/project --yes --platform=qoder

# 检查安装状态
claude-code-collective status

# 详细验证
claude-code-collective validate --detailed

# 查看帮助
claude-code-collective --help

# 查看版本
claude-code-collective --version
```

### 安装选项

```bash
# 最小安装（核心组件）
claude-code-collective init --minimal --yes --platform=qoder

# 强制覆盖
claude-code-collective init --force --yes --platform=qoder

# 完整备份
claude-code-collective init --backup full --yes --platform=qoder

# 同时安装 Claude Code 和 Qoder
claude-code-collective init --platform=both --sync-platforms
```

---

## 🔧 故障排除

### 问题 1：全局命令找不到

**症状:**
```bash
claude-code-collective: command not found
```

**解决方案:**

```bash
# 检查全局安装路径
npm config get prefix

# Windows: 确保路径在 PATH 环境变量中
# C:\Users\YourName\AppData\Roaming\npm

# Linux/Mac: 添加到 PATH
export PATH="$(npm config get prefix)/bin:$PATH"
```

### 问题 2：npx 找不到包

**症状:**
```bash
npx: command not found or package not found
```

**解决方案:**

```bash
# 使用绝对路径
npx "D:/MyDevelop/Qoder/claude-code-sub-agent-collective-main/claude-code-collective-2.1.0.tgz" init

# 或使用反斜杠（Windows）
npx "D:\MyDevelop\Qoder\claude-code-sub-agent-collective-main\claude-code-collective-2.1.0.tgz" init
```

### 问题 3：权限错误（Linux/Mac）

**症状:**
```bash
EACCES: permission denied
```

**解决方案:**

```bash
# 全局安装使用 sudo
sudo npm install -g ./claude-code-collective-2.1.0.tgz

# 或配置 npm 使用用户目录
npm config set prefix ~/.npm-global
export PATH=~/.npm-global/bin:$PATH
```

### 问题 4：包版本不更新

**症状:** 修改代码后，全局命令仍使用旧版本

**解决方案:**

```bash
# 方法 A: 重新打包和安装
cd source-directory
npm pack
npm install -g claude-code-collective-2.1.0.tgz --force

# 方法 B: 使用 npm link（开发推荐）
cd source-directory
npm link
# 现在修改代码会立即生效
```

---

## 💡 最佳实践建议

### 开发阶段

1. **使用 `npm link`** - 实时看到代码变更
2. **配合 `--force`** - 快速覆盖测试安装
3. **使用测试目录** - 避免污染实际项目

```bash
# 开发流程
cd ~/develop/claude-code-sub-agent-collective-main
npm link

# 测试
mkdir /tmp/test-project
cd /tmp/test-project
claude-code-collective init --yes --platform=qoder --force

# 修改代码后重新测试
claude-code-collective init --yes --platform=qoder --force
```

### 日常使用阶段

1. **全局安装稳定版本**
2. **创建别名或脚本**
3. **定期更新**

```bash
# 稳定使用流程
npm install -g ~/develop/claude-code-sub-agent-collective-main/claude-code-collective-2.1.0.tgz

# 在项目中使用
cd ~/projects/my-app
claude-code-collective init --yes --platform=qoder
```

### 团队共享阶段

1. **共享 .tgz 文件** - 上传到内部服务器或网盘
2. **统一安装路径**
3. **编写安装文档**

```bash
# 团队成员安装
npm install -g \\shared-server\tools\claude-code-collective-2.1.0.tgz

# 或使用 HTTP 服务器
npm install -g http://internal-server/packages/claude-code-collective-2.1.0.tgz
```

---

## 📚 相关文档

- [INSTALLATION-GUIDE.md](../INSTALLATION-GUIDE.md) - 完整安装指南（包括 NPM 发布）
- [QODER-USAGE.md](../docs/QODER-USAGE.md) - Qoder CLI 使用指南
- [TESTING-GUIDE.md](../TESTING-GUIDE.md) - 测试流程文档
- [README.md](../README.md) - 项目概述

---

## 🎯 总结

**推荐方案：**

- **快速测试** → 方法一（一键脚本）
- **日常使用** → 方法二（全局安装）
- **开发调试** → 方法四（npm link）
- **临时使用** → 方法三（直接 npx）

所有方法都无需发布到 NPM，可以立即使用最新代码！
