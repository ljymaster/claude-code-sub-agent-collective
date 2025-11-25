# AI Code Collective - 完整安装、测试和使用指南

## 📋 目录
1. [发布到 GitHub 和 NPM](#发布流程)
2. [本地测试方法](#本地测试)
3. [不同项目中使用](#跨项目使用)
4. [完整使用示例](#使用示例)
5. [故障排除](#故障排除)

---

## 🚀 发布流程

### 方案 A: 发布到 NPM（推荐）

#### 1. 准备发布

```bash
# 1. 确保在项目根目录
cd D:\MyDevelop\Qoder\claude-code-sub-agent-collective-main

# 2. 确保所有改动已提交
git status
git add .
git commit -m "feat: add multi-platform support for Qoder CLI"

# 3. 更新版本号
npm version patch -m "chore: release v%s - add Qoder CLI support"
# 或
npm version minor -m "chore: release v%s - multi-platform support"
# 或
npm version major -m "chore: release v%s - breaking changes with platform support"

# 4. 运行测试确保一切正常
npm test

# 5. 构建（如果有构建步骤）
# npm run build
```

#### 2. 发布到 NPM

```bash
# 1. 登录 NPM（首次需要）
npm login
# 输入用户名、密码、邮箱

# 2. 发布包
npm publish

# 3. 验证发布成功
npm info claude-code-collective
```

#### 3. 推送到 GitHub

```bash
# 1. 推送代码和标签
git push origin main
git push origin --tags

# 2. 在 GitHub 上创建 Release（可选但推荐）
# 访问 https://github.com/vanzan01/claude-code-sub-agent-collective/releases
# 点击 "Draft a new release"
# 选择刚才创建的 tag
# 填写 Release notes
```

### 方案 B: 仅发布到 GitHub（适合测试）

```bash
# 1. 推送到 GitHub
git add .
git commit -m "feat: add Qoder CLI support"
git push origin main

# 2. 其他项目中使用 GitHub 安装
# npx 可以直接从 GitHub 安装
```

---

## 🧪 本地测试

### 方法 1: 使用项目提供的测试脚本

```bash
# 在项目根目录
cd D:\MyDevelop\Qoder\claude-code-sub-agent-collective-main

# 运行自动化测试脚本
./scripts/test-local.sh

# 脚本会自动:
# 1. 创建 .tgz 包
# 2. 在 ../npm-tests/ 创建测试目录
# 3. 安装包
# 4. 运行验证
```

### 方法 2: 手动本地测试

```bash
# 1. 在项目根目录创建包
cd D:\MyDevelop\Qoder\claude-code-sub-agent-collective-main
npm pack
# 生成: claude-code-collective-2.1.0.tgz

# 2. 创建测试项目
mkdir D:\test-projects\test-qoder-collective
cd D:\test-projects\test-qoder-collective

# 3. 使用本地包安装
npx D:\MyDevelop\Qoder\claude-code-sub-agent-collective-main\claude-code-collective-2.1.0.tgz init --yes --platform=qoder

# 4. 验证安装
npx D:\MyDevelop\Qoder\claude-code-sub-agent-collective-main\claude-code-collective-2.1.0.tgz validate

# 5. 检查文件结构
ls -la
ls .qoder/
ls .qoder/agents/
ls .qoder/hooks/
```

### 方法 3: 使用 npm link（开发时最方便）

```bash
# 1. 在项目目录创建全局链接
cd D:\MyDevelop\Qoder\claude-code-sub-agent-collective-main
npm link

# 2. 在测试项目中使用链接
mkdir D:\test-projects\test-link
cd D:\test-projects\test-link
npm link claude-code-collective

# 3. 现在可以直接使用
npx claude-code-collective init --yes --platform=qoder

# 4. 测试完成后解除链接
npm unlink claude-code-collective

# 5. 在源项目也解除全局链接
cd D:\MyDevelop\Qoder\claude-code-sub-agent-collective-main
npm unlink -g
```

---

## 📦 跨项目使用

### 场景 1: 从 NPM 安装（发布后）

```bash
# 在任何项目目录
cd D:\my-projects\project-a

# 安装 - Qoder CLI
npx claude-code-collective init --yes --platform=qoder

# 安装 - Claude Code
npx claude-code-collective init --yes --platform=claude

# 安装 - 两个平台都支持
npx claude-code-collective init --platform=both --sync-platforms
```

### 场景 2: 从 GitHub 直接安装

```bash
# 使用 GitHub URL
cd D:\my-projects\project-b

# 方法 A: 使用 npx + GitHub
npx github:vanzan01/claude-code-sub-agent-collective init --yes --platform=qoder

# 方法 B: 先安装再使用
npm install -g github:vanzan01/claude-code-sub-agent-collective
claude-code-collective init --yes --platform=qoder
```

### 场景 3: 从本地文件安装

```bash
# 先打包
cd D:\MyDevelop\Qoder\claude-code-sub-agent-collective-main
npm pack

# 在其他项目使用
cd D:\my-projects\project-c
npx D:\MyDevelop\Qoder\claude-code-sub-agent-collective-main\claude-code-collective-2.1.0.tgz init --yes --platform=qoder
```

---

## 💻 完整使用示例

### 示例 1: Qoder CLI 新项目设置

```bash
# 1. 创建新项目
mkdir D:\my-projects\react-todo-app
cd D:\my-projects\react-todo-app

# 2. 初始化项目
npm init -y

# 3. 安装 AI Code Collective for Qoder
npx claude-code-collective init --yes --platform=qoder

# 4. 验证安装
npx claude-code-collective validate --detailed

# 5. 检查安装内容
ls -la
# 应该看到:
# - CLAUDE.md
# - .qoder/
# - .claude-collective/

# 6. 查看配置
cat .qoder/settings.json

# 7. 查看可用 agents
ls .qoder/agents/

# 8. 在 Qoder CLI 中开始使用
# 打开 Qoder CLI，导航到这个项目
# 输入: "Build a React todo app with TypeScript and tests"
# AI 会自动:
# - 路由到 @routing-agent
# - 分析需求
# - 调用 @prd-research-agent
# - 创建任务分解
# - 使用 @testing-agent 写测试
# - 使用 @feature-implementation-agent 实现
```

### 示例 2: Claude Code 项目设置

```bash
# 1. 创建项目
mkdir D:\my-projects\express-api
cd D:\my-projects\express-api
npm init -y

# 2. 安装 for Claude Code
npx claude-code-collective init --yes --platform=claude

# 3. 验证
npx claude-code-collective validate

# 4. 重启 Claude Code（必需）
# 关闭并重新打开 Claude Code

# 5. 在 Claude Code 中使用
# 输入: "Create a REST API with Express and PostgreSQL"
```

### 示例 3: 双平台项目（团队协作）

```bash
# 1. 创建项目
mkdir D:\my-projects\team-project
cd D:\my-projects\team-project
npm init -y

# 2. 安装两个平台支持
npx claude-code-collective init --platform=both --sync-platforms

# 3. 验证两个平台都安装了
ls .claude/
ls .qoder/

# 4. 提交到 Git
git init
git add .
git commit -m "chore: setup AI Code Collective for both platforms"

# 5. 团队成员使用
# - 使用 Claude Code 的成员: 可以直接使用
# - 使用 Qoder CLI 的成员: 也可以直接使用
# - 配置自动同步，保持一致
```

### 示例 4: 现有项目添加支持

```bash
# 1. 进入现有项目
cd D:\my-projects\existing-project

# 2. 备份现有配置（如果有）
cp -r .claude .claude.backup 2>/dev/null || true

# 3. 安装 collective（智能合并模式）
npx claude-code-collective init --mode=smart-merge --platform=qoder

# 4. 检查合并结果
npx claude-code-collective validate

# 5. 如果需要，恢复特定配置
# 手动编辑 .qoder/settings.json
```

---

## 🔍 详细测试步骤

### 测试 1: 基础安装测试

```bash
# 1. 创建干净的测试目录
mkdir D:\test-ai-collective
cd D:\test-ai-collective

# 2. 安装
npx claude-code-collective init --yes --platform=qoder

# 3. 验证文件存在
test -f CLAUDE.md && echo "✅ CLAUDE.md exists" || echo "❌ CLAUDE.md missing"
test -d .qoder && echo "✅ .qoder/ exists" || echo "❌ .qoder/ missing"
test -f .qoder/settings.json && echo "✅ settings.json exists" || echo "❌ settings.json missing"
test -d .qoder/agents && echo "✅ agents/ exists" || echo "❌ agents/ missing"
test -d .qoder/hooks && echo "✅ hooks/ exists" || echo "❌ hooks/ missing"

# 4. 验证 agent 数量
ls .qoder/agents/*.md | wc -l
# 应该显示 32 个 agent 文件

# 5. 验证 hooks
ls .qoder/hooks/*.sh
# 应该显示所有 hook 脚本

# 6. 运行官方验证
npx claude-code-collective validate --detailed
```

### 测试 2: 平台检测测试

```bash
# 1. 测试自动检测
cd D:\test-auto-detect
npx claude-code-collective init --yes --platform=auto

# 2. 检查安装了什么平台
npx claude-code-collective status
# 应该显示检测到的平台

# 3. 测试强制 Qoder
cd D:\test-force-qoder
npx claude-code-collective init --yes --platform=qoder
ls -d .qoder  # 应该存在

# 4. 测试强制 Claude
cd D:\test-force-claude
npx claude-code-collective init --yes --platform=claude
ls -d .claude  # 应该存在

# 5. 测试双平台
cd D:\test-both
npx claude-code-collective init --yes --platform=both
ls -d .claude .qoder  # 两个都应该存在
```

### 测试 3: Hook 功能测试

```bash
# 1. 安装
cd D:\test-hooks
npx claude-code-collective init --yes --platform=qoder

# 2. 检查 hook 脚本可执行
ls -l .qoder/hooks/*.sh
# 所有脚本应该有 x 权限

# 3. 手动测试 hook（模拟）
bash .qoder/hooks/load-behavioral-system.sh
# 应该输出平台信息和加载的文件

# 4. 检查日志
ls /tmp/*qoder*.log
# 应该看到各种日志文件

# 5. 查看日志内容
tail /tmp/directive-enforcer-Qoder.log
```

### 测试 4: Agent 调用测试（需要在 Qoder CLI 中）

```bash
# 1. 安装
cd D:\test-agents
npx claude-code-collective init --yes --platform=qoder

# 2. 在 Qoder CLI 中:
# 打开 Qoder，进入这个项目目录

# 3. 测试基础路由
# 输入: "Route to @routing-agent"
# 应该: 自动识别并使用 routing agent

# 4. 测试 TDD 工作流
# 输入: "Create a simple calculator function with tests"
# 应该:
# - 路由到 @testing-agent (写测试)
# - 然后到 @feature-implementation-agent (实现)
# - 返回测试结果

# 5. 检查生成的文件
ls -la
# 应该看到测试文件和实现文件
```

### 测试 5: 配置同步测试

```bash
# 1. 安装双平台
cd D:\test-sync
npx claude-code-collective init --yes --platform=both --sync-platforms

# 2. 检查两个配置文件
cat .claude/settings.json | grep -c "CLAUDE_PROJECT_DIR"
cat .qoder/settings.json | grep -c "QODER_PROJECT_DIR"
# 应该看到平台特定的环境变量

# 3. 修改一个配置
# 编辑 .qoder/settings.json，添加自定义 hook

# 4. 重新同步
npx claude-code-collective init --sync-platforms

# 5. 检查是否同步到 .claude/
# 应该看到相同的配置（路径已转换）
```

---

## ⚙️ 配置选项详解

### 命令行参数

```bash
# 基础安装
npx claude-code-collective init

# 完整参数
npx claude-code-collective init \
  --yes \                          # 快速模式，无提示
  --force \                        # 强制覆盖现有文件
  --platform=qoder \               # 指定平台: auto/claude/qoder/both
  --sync-platforms \               # 同步跨平台配置
  --minimal \                      # 最小化安装（仅核心 agents）
  --mode=smart-merge \             # 合并模式: smart-merge/force/skip-conflicts
  --backup=full \                  # 备份策略: full/simple/none
  --interactive                    # 交互模式（默认）
```

### 验证命令

```bash
# 基础验证
npx claude-code-collective validate

# 详细验证
npx claude-code-collective validate --detailed

# 状态检查
npx claude-code-collective status

# 显示信息
npx claude-code-collective info

# 帮助
npx claude-code-collective --help
```

---

## 🔧 故障排除

### 问题 1: 安装失败

```bash
# 症状: npm install 失败

# 解决方案 1: 清理缓存
npm cache clean --force
npx claude-code-collective init --force

# 解决方案 2: 使用特定版本
npx claude-code-collective@latest init

# 解决方案 3: 从 GitHub 安装
npx github:vanzan01/claude-code-sub-agent-collective init
```

### 问题 2: Hooks 不工作

```bash
# 症状: Hooks 不触发

# 检查 1: 文件权限
ls -l .qoder/hooks/*.sh
chmod +x .qoder/hooks/*.sh  # 添加执行权限

# 检查 2: 配置文件
cat .qoder/settings.json
# 确保 hooks 配置存在

# 检查 3: 重启 Qoder CLI
# 关闭并重新打开 Qoder CLI

# 检查 4: 环境变量
echo $QODER_PROJECT_DIR
# 应该指向当前项目
```

### 问题 3: Agents 找不到

```bash
# 症状: 调用 agent 时报错

# 检查 1: Agent 文件存在
ls .qoder/agents/routing-agent.md

# 检查 2: 验证安装
npx claude-code-collective validate --detailed

# 检查 3: 重新安装
npx claude-code-collective init --force --platform=qoder

# 检查 4: 查看日志
tail /tmp/*qoder*.log
```

### 问题 4: 平台检测错误

```bash
# 症状: 检测到错误的平台

# 解决: 强制指定平台
npx claude-code-collective init --force --platform=qoder

# 验证平台
npx claude-code-collective status
# 应该显示 "Platform: Qoder"
```

### 问题 5: 双平台冲突

```bash
# 症状: 同时有 .claude 和 .qoder 导致混乱

# 解决方案 1: 移除一个平台
rm -rf .claude  # 或 .qoder

# 解决方案 2: 重新同步
npx claude-code-collective init --platform=both --sync-platforms

# 解决方案 3: 分别配置
# 手动编辑 .claude/settings.json 和 .qoder/settings.json
```

---

## 📊 验证检查清单

安装后使用此检查清单验证:

```bash
# 1. 文件结构检查
[ ] CLAUDE.md 存在
[ ] .qoder/ 或 .claude/ 目录存在
[ ] .qoder/settings.json 存在
[ ] .qoder/agents/ 包含 30+ agent 文件
[ ] .qoder/hooks/ 包含 11 个 hook 脚本
[ ] .claude-collective/ 目录存在

# 2. 配置检查
[ ] settings.json 包含正确的 hooks 配置
[ ] 环境变量使用正确 (QODER_PROJECT_DIR/CLAUDE_PROJECT_DIR)
[ ] Hook 脚本有执行权限

# 3. 验证命令
[ ] npx claude-code-collective validate 通过
[ ] npx claude-code-collective status 显示正确平台

# 4. 功能测试
[ ] 在 AI 平台中可以调用 agents
[ ] Hooks 正常触发
[ ] TDD 工作流正常运行

# 5. 日志检查
[ ] /tmp/ 目录有相关日志文件
[ ] 日志显示正确的平台名称
```

---

## 🎯 推荐工作流

### 首次使用

```bash
# 1. 发布到 NPM（一次性）
cd D:\MyDevelop\Qoder\claude-code-sub-agent-collective-main
npm version minor
npm publish
git push origin main --tags

# 2. 在新项目中使用
cd D:\my-projects\new-project
npx claude-code-collective init --yes --platform=qoder
npx claude-code-collective validate

# 3. 开始开发
# 在 Qoder CLI 中正常使用
```

### 日常开发

```bash
# 1. 新建项目时
npx claude-code-collective init --yes --platform=qoder

# 2. 验证
npx claude-code-collective validate

# 3. 直接在 AI 平台使用
# 无需手动调用命令
```

### 团队协作

```bash
# 1. 项目初始化者
npx claude-code-collective init --platform=both --sync-platforms
git add .
git commit -m "chore: setup AI collective"
git push

# 2. 团队成员克隆后
git clone <repo-url>
cd <repo>
# 配置已存在，可直接使用
# Claude Code 用户: 重启 Claude Code
# Qoder CLI 用户: 直接使用
```

---

## 📚 额外资源

- **GitHub 仓库**: https://github.com/vanzan01/claude-code-sub-agent-collective
- **NPM 包**: https://npmjs.com/package/claude-code-collective
- **Qoder 使用指南**: `docs/QODER-USAGE.md`
- **平台迁移指南**: `docs/PLATFORM-AGNOSTIC-AGENTS.md`
- **贡献指南**: `CONTRIBUTING.md`

---

## 🆘 获取帮助

```bash
# CLI 帮助
npx claude-code-collective --help

# 详细验证（包含诊断信息）
npx claude-code-collective validate --detailed

# 查看版本
npx claude-code-collective version

# 查看项目信息
npx claude-code-collective info
```

---

**版本**: 2.1.0  
**平台支持**: Claude Code, Qoder CLI  
**最后更新**: 2024-11  
