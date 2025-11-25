# GitHub 安装指南

通过 GitHub 仓库直接安装 Claude Code Collective，无需发布到 NPM。

## 📋 目录

- [快速安装](#快速安装)
- [安装方法对比](#安装方法对比)
- [方法一：NPM 直接安装（推荐）](#方法一npm-直接安装推荐)
- [方法二：Git Clone + 本地安装](#方法二git-clone--本地安装)
- [方法三：下载压缩包安装](#方法三下载压缩包安装)
- [方法四：NPM Link 开发模式](#方法四npm-link-开发模式)
- [更新和卸载](#更新和卸载)
- [故障排除](#故障排除)
- [团队使用指南](#团队使用指南)

---

## 🚀 快速安装

### 最简单的方式（推荐）

```bash
# 全局安装（可在任意项目使用）
npm install -g https://github.com/ljymaster/claude-code-sub-agent-collective.git

# 在项目中初始化
cd /path/to/your/project
ccc init --yes --platform=qoder

# 验证安装
ccc status
ccc validate
```

**可用命令：**
- **`ccc`** - 短命令（推荐日常使用）
- **`claude-code-collective-v2`** - 完整命令（明确标识版本）

**包名：** `@ljymaster/claude-code-collective`（与旧版本 `claude-code-collective` 并存）

### 项目本地安装

```bash
# 在项目目录中作为依赖安装
cd /path/to/your/project
npm install https://github.com/ljymaster/claude-code-sub-agent-collective.git

# 使用 npx 运行
npx @ljymaster/claude-code-collective init --yes --platform=qoder

# 或使用短命令
npx ccc init --yes --platform=qoder
```

---

## 📊 安装方法对比

| 方法 | 速度 | 便捷性 | 更新 | 适用场景 | 网络要求 |
|------|------|--------|------|----------|----------|
| NPM 直接安装 | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | 简单 | 日常使用 | 需要 |
| Git Clone | ⭐⭐⭐ | ⭐⭐⭐ | 手动 | 开发调试 | 需要 |
| 下载压缩包 | ⭐⭐ | ⭐⭐ | 手动 | 离线环境 | 一次性 |
| NPM Link | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | 实时 | 开发贡献 | 需要 |

---

## 方法一：NPM 直接安装（推荐）

### 1.1 全局安装（推荐）

**适用场景：** 在多个项目中使用

```bash
# 安装最新版本（main 分支）
npm install -g https://github.com/ljymaster/claude-code-sub-agent-collective.git

# 安装特定分支
npm install -g https://github.com/ljymaster/claude-code-sub-agent-collective.git#develop

# 安装特定标签/版本
npm install -g https://github.com/ljymaster/claude-code-sub-agent-collective.git#v2.1.0

# 安装特定提交
npm install -g https://github.com/ljymaster/claude-code-sub-agent-collective.git#3dbfd66
```

**验证安装：**

```bash
# 检查命令是否可用
claude-code-collective --version
# 输出: 2.1.0

# 查看帮助
claude-code-collective --help
```

**在项目中使用：**

```bash
# 进入任意项目目录
cd D:\MyProject

# 初始化（Qoder CLI）
claude-code-collective init --yes --platform=qoder

# 或初始化（Claude Code）
claude-code-collective init --yes --platform=claude

# 或同时安装两个平台
claude-code-collective init --yes --platform=both --sync-platforms

# 检查状态
claude-code-collective status

# 详细验证
claude-code-collective validate --detailed
```

### 1.2 项目本地安装

**适用场景：** 单个项目使用，或作为项目依赖

```bash
# 进入项目目录
cd /path/to/your/project

# 作为开发依赖安装
npm install --save-dev https://github.com/ljymaster/claude-code-sub-agent-collective.git

# 或作为普通依赖
npm install --save https://github.com/ljymaster/claude-code-sub-agent-collective.git
```

**package.json 中会添加：**

```json
{
  "devDependencies": {
    "claude-code-collective": "github:ljymaster/claude-code-sub-agent-collective"
  }
}
```

**使用 npx 运行：**

```bash
# 初始化
npx claude-code-collective init --yes --platform=qoder

# 检查状态
npx claude-code-collective status

# 验证
npx claude-code-collective validate
```

**添加到 npm scripts：**

```json
{
  "scripts": {
    "collective:init": "claude-code-collective init --yes --platform=qoder",
    "collective:status": "claude-code-collective status",
    "collective:validate": "claude-code-collective validate"
  }
}
```

```bash
# 使用 npm scripts
npm run collective:init
npm run collective:status
npm run collective:validate
```

### 1.3 高级安装选项

```bash
# 指定安装位置
npm install -g --prefix /custom/path https://github.com/ljymaster/claude-code-sub-agent-collective.git

# 强制重新安装
npm install -g --force https://github.com/ljymaster/claude-code-sub-agent-collective.git

# 使用 SSH 地址（需要 GitHub SSH key 配置）
npm install -g git+ssh://git@github.com/ljymaster/claude-code-sub-agent-collective.git

# 指定 GitHub Token（私有仓库）
npm install -g https://YOUR_GITHUB_TOKEN@github.com/ljymaster/claude-code-sub-agent-collective.git
```

---

## 方法二：Git Clone + 本地安装

### 2.1 克隆仓库

```bash
# 克隆到本地目录
git clone https://github.com/ljymaster/claude-code-sub-agent-collective.git

# 或使用 SSH
git clone git@github.com:ljymaster/claude-code-sub-agent-collective.git

# 进入目录
cd claude-code-sub-agent-collective

# 安装依赖
npm install
```

### 2.2 全局安装

**方式 A：使用 npm install**

```bash
# 在克隆的目录中
npm install -g .

# 验证
claude-code-collective --version
```

**方式 B：使用 npm link（推荐开发）**

```bash
# 在克隆的目录中
npm link

# 现在可以在任意位置使用，且修改代码会实时生效
cd /path/to/your/project
claude-code-collective init --yes --platform=qoder
```

### 2.3 创建打包文件

```bash
# 在克隆的目录中创建 .tgz 包
npm pack

# 输出: claude-code-collective-2.1.0.tgz

# 全局安装该包
npm install -g claude-code-collective-2.1.0.tgz

# 或分享给团队成员
# 他们可以使用: npm install -g /path/to/claude-code-collective-2.1.0.tgz
```

### 2.4 直接使用（不安装）

```bash
# 在克隆的目录中
cd claude-code-sub-agent-collective

# 直接在项目中使用
cd /path/to/your/project
npx /path/to/claude-code-sub-agent-collective init --yes --platform=qoder

# Windows 示例
npx D:\Git\claude-code-sub-agent-collective init --yes --platform=qoder

# Linux/Mac 示例
npx ~/git/claude-code-sub-agent-collective init --yes --platform=qoder
```

---

## 方法三：下载压缩包安装

### 3.1 下载源码

**从 GitHub 下载：**

1. 访问 https://github.com/ljymaster/claude-code-sub-agent-collective
2. 点击 **Code** → **Download ZIP**
3. 解压到本地目录（如 `D:\Downloads\claude-code-sub-agent-collective-main`）

**或使用命令行：**

```bash
# 下载 main 分支压缩包
curl -L https://github.com/ljymaster/claude-code-sub-agent-collective/archive/refs/heads/main.zip -o claude-code-collective.zip

# 或使用 wget
wget https://github.com/ljymaster/claude-code-sub-agent-collective/archive/refs/heads/main.zip -O claude-code-collective.zip

# 解压（Windows PowerShell）
Expand-Archive -Path claude-code-collective.zip -DestinationPath .

# 解压（Linux/Mac）
unzip claude-code-collective.zip
```

### 3.2 安装

```bash
# 进入解压后的目录
cd claude-code-sub-agent-collective-main

# 安装依赖
npm install

# 创建包
npm pack

# 全局安装
npm install -g claude-code-collective-2.1.0.tgz
```

---

## 方法四：NPM Link 开发模式

### 4.1 设置开发环境

```bash
# 克隆仓库
git clone https://github.com/ljymaster/claude-code-sub-agent-collective.git
cd claude-code-sub-agent-collective

# 安装依赖
npm install

# 创建全局符号链接
npm link

# 验证链接
which claude-code-collective  # Linux/Mac
where claude-code-collective  # Windows
```

### 4.2 使用开发版本

```bash
# 在任意项目中使用
cd /path/to/your/project
claude-code-collective init --yes --platform=qoder

# 修改源码后无需重新安装，立即生效
cd /path/to/claude-code-sub-agent-collective
# 编辑 lib/installer.js 或其他文件...

# 立即测试
cd /path/to/your/project
claude-code-collective init --yes --platform=qoder --force
```

### 4.3 解除链接

```bash
# 在源码目录
cd claude-code-sub-agent-collective
npm unlink

# 或在全局
npm unlink -g claude-code-collective
```

---

## 🔄 更新和卸载

### 更新到最新版本

**方法一：重新安装（全局安装）**

```bash
# 卸载旧版本
npm uninstall -g claude-code-collective

# 安装最新版本
npm install -g https://github.com/ljymaster/claude-code-sub-agent-collective.git

# 或强制更新
npm install -g https://github.com/ljymaster/claude-code-sub-agent-collective.git --force
```

**方法二：Git 更新（Clone 方式）**

```bash
# 进入源码目录
cd claude-code-sub-agent-collective

# 拉取最新代码
git pull origin main

# 重新安装依赖
npm install

# 如果使用 npm link，代码会立即生效
# 如果使用 npm install -g，需要重新安装
npm install -g . --force
```

**方法三：项目依赖更新**

```bash
# 进入项目目录
cd /path/to/your/project

# 更新到最新版本
npm update claude-code-collective

# 或重新安装
npm install https://github.com/ljymaster/claude-code-sub-agent-collective.git --force
```

### 卸载

**卸载全局安装：**

```bash
# 标准卸载
npm uninstall -g claude-code-collective

# 验证卸载
claude-code-collective --version
# 应该显示: command not found
```

**卸载项目依赖：**

```bash
# 在项目目录
npm uninstall claude-code-collective
```

**清理已安装的配置（可选）：**

```bash
# 进入项目目录
cd /path/to/your/project

# 删除已安装的 collective 文件
# Qoder CLI
rm -rf .qoder/agents .qoder/hooks .qoder/commands
rm .qoder/CLAUDE.md

# Claude Code
rm -rf .claude/agents .claude/hooks .claude/commands
rm .claude/CLAUDE.md

# 删除测试文件
rm -rf .claude-collective
```

---

## 🔧 故障排除

### 问题 1：无法从 GitHub 安装

**症状：**
```bash
npm ERR! Error while executing:
npm ERR! fatal: could not read Username for 'https://github.com'
```

**解决方案：**

```bash
# 方法 A：使用 Git 协议（需要配置 SSH key）
npm install -g git+ssh://git@github.com/ljymaster/claude-code-sub-agent-collective.git

# 方法 B：配置 Git 凭据
git config --global credential.helper store

# 方法 C：先 clone 再本地安装
git clone https://github.com/ljymaster/claude-code-sub-agent-collective.git
cd claude-code-sub-agent-collective
npm install -g .
```

### 问题 2：权限错误（Linux/Mac）

**症状：**
```bash
npm ERR! Error: EACCES: permission denied
```

**解决方案：**

```bash
# 方法 A：使用 sudo（不推荐）
sudo npm install -g https://github.com/ljymaster/claude-code-sub-agent-collective.git

# 方法 B：配置 npm 使用用户目录（推荐）
mkdir ~/.npm-global
npm config set prefix '~/.npm-global'
echo 'export PATH=~/.npm-global/bin:$PATH' >> ~/.bashrc
source ~/.bashrc

# 现在可以不用 sudo 安装
npm install -g https://github.com/ljymaster/claude-code-sub-agent-collective.git
```

### 问题 3：网络超时

**症状：**
```bash
npm ERR! network timeout
```

**解决方案：**

```bash
# 方法 A：增加超时时间
npm config set timeout 60000
npm install -g https://github.com/ljymaster/claude-code-sub-agent-collective.git

# 方法 B：使用国内镜像（如果是私有仓库不适用）
npm config set registry https://registry.npmmirror.com
npm install -g https://github.com/ljymaster/claude-code-sub-agent-collective.git
npm config set registry https://registry.npmjs.org

# 方法 C：使用下载压缩包方式（见方法三）
```

### 问题 4：版本不匹配

**症状：**
```bash
claude-code-collective --version
# 显示旧版本号
```

**解决方案：**

```bash
# 清除 npm 缓存
npm cache clean --force

# 卸载旧版本
npm uninstall -g claude-code-collective

# 重新安装
npm install -g https://github.com/ljymaster/claude-code-sub-agent-collective.git

# 验证版本
claude-code-collective --version
```

### 问题 5：命令找不到（Windows）

**症状：**
```bash
claude-code-collective: command not found
```

**解决方案：**

```bash
# 检查 npm 全局路径
npm config get prefix

# 确保该路径在系统 PATH 中
# Windows: C:\Users\YourName\AppData\Roaming\npm
# 添加到环境变量 PATH

# 或使用完整路径
%APPDATA%\npm\claude-code-collective --version

# 或重新安装到指定位置
npm install -g --prefix C:\tools https://github.com/ljymaster/claude-code-sub-agent-collective.git
# 然后添加 C:\tools 到 PATH
```

### 问题 6：Git 未安装

**症状：**
```bash
npm ERR! Error while executing: git
npm ERR! spawn git ENOENT
```

**解决方案：**

```bash
# 安装 Git
# Windows: https://git-scm.com/download/win
# Mac: brew install git
# Linux: sudo apt-get install git

# 或使用下载压缩包方式（方法三）
```

---

## 👥 团队使用指南

### 场景 1：团队统一安装

**创建安装脚本（install-collective.sh）：**

```bash
#!/bin/bash

echo "🚀 安装 Claude Code Collective..."

# 检查 Git 是否已安装
if ! command -v git &> /dev/null; then
    echo "❌ 未检测到 Git，请先安装 Git"
    exit 1
fi

# 全局安装
echo "📦 从 GitHub 安装..."
npm install -g https://github.com/ljymaster/claude-code-sub-agent-collective.git

# 验证安装
if command -v claude-code-collective &> /dev/null; then
    VERSION=$(claude-code-collective --version)
    echo "✅ 安装成功！版本: $VERSION"
    echo ""
    echo "💡 使用方法："
    echo "   cd /path/to/your/project"
    echo "   claude-code-collective init --yes --platform=qoder"
else
    echo "❌ 安装失败，请检查错误信息"
    exit 1
fi
```

**Windows 版本（install-collective.bat）：**

```batch
@echo off
echo 正在安装 Claude Code Collective...

REM 检查 Git
where git >nul 2>nul
if %errorlevel% neq 0 (
    echo 未检测到 Git，请先安装 Git
    exit /b 1
)

REM 全局安装
echo 从 GitHub 安装...
npm install -g https://github.com/ljymaster/claude-code-sub-agent-collective.git

REM 验证
claude-code-collective --version >nul 2>nul
if %errorlevel% equ 0 (
    echo 安装成功！
    claude-code-collective --version
) else (
    echo 安装失败，请检查错误信息
    exit /b 1
)
```

### 场景 2：项目 package.json 配置

**在项目中添加依赖：**

```json
{
  "name": "your-project",
  "version": "1.0.0",
  "devDependencies": {
    "claude-code-collective": "github:ljymaster/claude-code-sub-agent-collective"
  },
  "scripts": {
    "setup": "npm install && npm run collective:init",
    "collective:init": "claude-code-collective init --yes --platform=qoder",
    "collective:status": "claude-code-collective status",
    "collective:validate": "claude-code-collective validate",
    "collective:update": "npm update claude-code-collective"
  }
}
```

**团队成员使用：**

```bash
# 克隆项目后
npm install

# 初始化 collective
npm run setup

# 或单独初始化
npm run collective:init

# 检查状态
npm run collective:status
```

### 场景 3：指定版本/分支

**使用特定版本标签：**

```json
{
  "devDependencies": {
    "claude-code-collective": "github:ljymaster/claude-code-sub-agent-collective#v2.1.0"
  }
}
```

**使用特定分支：**

```json
{
  "devDependencies": {
    "claude-code-collective": "github:ljymaster/claude-code-sub-agent-collective#develop"
  }
}
```

**使用特定提交：**

```json
{
  "devDependencies": {
    "claude-code-collective": "github:ljymaster/claude-code-sub-agent-collective#3dbfd66"
  }
}
```

### 场景 4：私有仓库访问

**使用 SSH（推荐）：**

```bash
# 确保已配置 GitHub SSH key
# https://docs.github.com/en/authentication/connecting-to-github-with-ssh

# 安装
npm install -g git+ssh://git@github.com/ljymaster/claude-code-sub-agent-collective.git
```

**使用个人访问令牌（PAT）：**

```bash
# 创建 GitHub PAT: https://github.com/settings/tokens
# 需要 repo 权限

# 方法 A：直接使用
npm install -g https://YOUR_GITHUB_TOKEN@github.com/ljymaster/claude-code-sub-agent-collective.git

# 方法 B：使用环境变量
export GITHUB_TOKEN=your_token_here
npm install -g https://${GITHUB_TOKEN}@github.com/ljymaster/claude-code-sub-agent-collective.git
```

**在 CI/CD 中使用：**

```yaml
# GitHub Actions 示例
name: Setup Collective

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '16'
      
      - name: Install Collective
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        run: |
          npm install -g https://${GITHUB_TOKEN}@github.com/ljymaster/claude-code-sub-agent-collective.git
          claude-code-collective --version
      
      - name: Initialize Project
        run: |
          claude-code-collective init --yes --platform=qoder
          claude-code-collective validate
```

---

## 📚 完整安装示例

### 示例 1：新项目快速开始

```bash
# 创建新项目
mkdir my-awesome-project
cd my-awesome-project
npm init -y

# 从 GitHub 安装 collective
npm install -g https://github.com/ljymaster/claude-code-sub-agent-collective.git

# 初始化
claude-code-collective init --yes --platform=qoder

# 验证
claude-code-collective status
claude-code-collective validate

# 开始使用 Qoder CLI
# Qoder 会自动加载 .qoder/ 中的配置和 agents
```

### 示例 2：现有项目集成

```bash
# 进入现有项目
cd /path/to/existing/project

# 检查当前状态
ls -la .qoder/  # 或 .claude/

# 全局安装 collective
npm install -g https://github.com/ljymaster/claude-code-sub-agent-collective.git

# 初始化（会智能合并现有配置）
claude-code-collective init --platform=qoder

# 如果需要强制覆盖
claude-code-collective init --platform=qoder --force --backup full

# 验证
claude-code-collective validate --detailed
```

### 示例 3：多平台支持

```bash
# 同时支持 Claude Code 和 Qoder CLI
claude-code-collective init --platform=both --sync-platforms

# 这会创建：
# .claude/        - Claude Code 配置
# .qoder/         - Qoder CLI 配置
# 两者会自动同步

# 验证两个平台
claude-code-collective status
```

### 示例 4：团队协作项目

```bash
# 项目负责人设置
cd team-project
npm init -y

# 添加到 package.json
npm install --save-dev github:ljymaster/claude-code-sub-agent-collective

# 添加 scripts
# 编辑 package.json:
{
  "scripts": {
    "setup": "npm install && npx claude-code-collective init --yes --platform=qoder",
    "collective:status": "npx claude-code-collective status"
  }
}

# 提交到版本控制
git add package.json package-lock.json
git commit -m "Add claude-code-collective"
git push

# 团队成员使用
git clone <repo-url>
cd team-project
npm run setup
```

---

## 🎯 最佳实践

### 1. 选择合适的安装方式

- **个人使用** → 全局安装（方法一）
- **团队项目** → 项目依赖（package.json）
- **开发贡献** → Git Clone + npm link（方法四）
- **离线环境** → 下载压缩包（方法三）

### 2. 版本管理

```bash
# 生产环境：使用稳定标签
npm install -g github:ljymaster/claude-code-sub-agent-collective#v2.1.0

# 开发环境：使用开发分支
npm install -g github:ljymaster/claude-code-sub-agent-collective#develop

# 锁定特定提交（最稳定）
npm install -g github:ljymaster/claude-code-sub-agent-collective#3dbfd66
```

### 3. 定期更新

```bash
# 每周检查更新
npm install -g https://github.com/ljymaster/claude-code-sub-agent-collective.git --force

# 或设置定时任务（Linux/Mac）
# crontab -e
# 0 9 * * 1 npm install -g https://github.com/ljymaster/claude-code-sub-agent-collective.git --force
```

### 4. 备份配置

```bash
# 在更新前备份
claude-code-collective init --backup full --force

# 手动备份
tar -czf collective-backup-$(date +%Y%m%d).tar.gz .qoder/ .claude/
```

---

## 📖 相关资源

- **GitHub 仓库**: https://github.com/ljymaster/claude-code-sub-agent-collective
- **问题反馈**: https://github.com/ljymaster/claude-code-sub-agent-collective/issues
- **贡献指南**: https://github.com/ljymaster/claude-code-sub-agent-collective/blob/main/CONTRIBUTING.md

## 📝 相关文档

- [README.md](../README.md) - 项目概述
- [INSTALLATION-GUIDE.md](../INSTALLATION-GUIDE.md) - 完整安装指南
- [QUICK-INSTALL-GUIDE.md](./QUICK-INSTALL-GUIDE.md) - 本地快速安装
- [QODER-USAGE.md](./QODER-USAGE.md) - Qoder CLI 使用指南
- [TESTING-GUIDE.md](../TESTING-GUIDE.md) - 测试指南

---

## ✅ 总结

**推荐安装流程（最简单）：**

```bash
# 1. 全局安装
npm install -g https://github.com/ljymaster/claude-code-sub-agent-collective.git

# 2. 在项目中使用
cd /path/to/your/project
claude-code-collective init --yes --platform=qoder

# 3. 验证
claude-code-collective status
claude-code-collective validate

# 完成！开始使用 Qoder CLI
```

**优势：**
- ✅ 无需发布到 NPM
- ✅ 始终使用最新代码
- ✅ 一行命令安装
- ✅ 支持版本控制
- ✅ 团队协作友好

如有问题，请访问 [GitHub Issues](https://github.com/ljymaster/claude-code-sub-agent-collective/issues) 反馈。
