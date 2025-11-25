# 双版本并存 - 完整安装测试指南

## 🎯 测试目标

验证新版本 `@ljymaster/claude-code-collective` (2.1.0) 可以与旧版本 `claude-code-collective` (2.0.8) 完美并存。

## 📋 测试步骤

### 步骤 1: 检查当前状态

```bash
# 查看已安装的版本
npm list -g | grep claude-code-collective

# 应该看到旧版本：
# └── claude-code-collective@2.0.8

# 测试旧版本命令
claude-code-collective --version
# 输出: 2.0.8
```

### 步骤 2: 安装新版本（从 GitHub）

```bash
# 从 GitHub 安装新版本
npm install -g https://github.com/ljymaster/claude-code-sub-agent-collective.git

# 等待安装完成...
# 应该看到: changed 65 packages
```

### 步骤 3: 验证两个版本并存

```bash
# 检查全局已安装的包
npm list -g --depth=0 | grep claude-code

# 应该看到两个版本：
# ├── claude-code-collective@2.0.8
# └── @ljymaster/claude-code-collective@2.1.0

# 测试旧版本（应该仍然可用）
claude-code-collective --version
# 输出: 2.0.8

# 测试新版本 - 短命令
ccc --version
# 输出: 2.1.0

# 测试新版本 - 完整命令
claude-code-collective-v2 --version
# 输出: 2.1.0
```

### 步骤 4: 功能测试（新版本）

```bash
# 创建测试目录
mkdir D:\test-v2
cd D:\test-v2

# 使用新版本初始化（Qoder CLI）
ccc init --yes --platform=qoder

# 检查状态
ccc status

# 应该看到：
# 📊 Claude Code Collective Status
# 📁 Project: test-v2
# 📦 Version: 2.1.0
# 🚀 Installed: ✅ Yes
# 🧠 Behavioral System: ✅ Active
# 🪝 Hooks: ✅ Configured
# 🤖 Agents: 29 installed

# 验证安装
ccc validate --detailed

# 清理测试目录（可选）
cd ..
rm -rf test-v2
```

### 步骤 5: 功能测试（旧版本）

```bash
# 创建测试目录
mkdir D:\test-v1
cd D:\test-v1

# 使用旧版本初始化
claude-code-collective init

# 检查状态
claude-code-collective status

# 应该看到：
# 📊 Claude Code Collective Status
# 📦 Version: 2.0.8
# 🚀 Installed: ✅ Yes
# ...

# 清理测试目录（可选）
cd ..
rm -rf test-v1
```

### 步骤 6: 命令对比测试

```bash
# 查看新版本帮助（应该有 --platform 选项）
ccc --help

# 应该看到：
# --platform <platform>  Target platform (auto|claude|qoder|both)

# 查看旧版本帮助（没有 --platform 选项）
claude-code-collective --help

# 对比差异
```

### 步骤 7: 高级测试 - 同一项目切换版本

```bash
# 创建测试项目
mkdir D:\test-switch
cd D:\test-switch

# 先用旧版本初始化
claude-code-collective init
ls -la .claude/  # 查看旧版本文件结构

# 备份旧版本配置
cp -r .claude .claude-backup-v1

# 使用新版本覆盖（强制安装）
ccc init --yes --platform=qoder --force --backup full
ls -la .qoder/  # 查看新版本文件结构

# 对比差异
diff -r .claude-backup-v1 .claude
# 或对比 Qoder 配置
ls -la .qoder/

# 恢复旧版本（如需要）
rm -rf .claude .qoder
mv .claude-backup-v1 .claude
claude-code-collective status

# 清理
cd ..
rm -rf test-switch
```

## ✅ 预期结果

### 成功标志

1. **两个包都已安装**
   ```bash
   npm list -g --depth=0 | grep claude-code
   # ├── claude-code-collective@2.0.8
   # └── @ljymaster/claude-code-collective@2.1.0
   ```

2. **三个命令都可用**
   ```bash
   which claude-code-collective      # 旧版本
   which ccc                         # 新版本（短命令）
   which claude-code-collective-v2   # 新版本（完整命令）
   ```

3. **版本号正确**
   ```bash
   claude-code-collective --version   # 2.0.8
   ccc --version                      # 2.1.0
   claude-code-collective-v2 --version # 2.1.0
   ```

4. **功能独立**
   - 旧版本：只支持 Claude Code，没有 `--platform` 选项
   - 新版本：支持多平台（Claude Code + Qoder CLI），有 `--platform` 选项

### 失败场景

如果出现以下情况说明安装失败：

1. **版本冲突**
   ```bash
   ccc --version
   # 显示 2.0.8 而不是 2.1.0
   ```
   
   **解决方案：**
   ```bash
   npm uninstall -g @ljymaster/claude-code-collective
   npm cache clean --force
   npm install -g https://github.com/ljymaster/claude-code-sub-agent-collective.git --force
   ```

2. **命令不存在**
   ```bash
   ccc --version
   # command not found
   ```
   
   **解决方案：**
   ```bash
   # 检查安装路径
   npm config get prefix
   
   # 确保路径在 PATH 环境变量中
   # Windows: C:\Users\YourName\AppData\Roaming\npm
   # Linux/Mac: /usr/local/bin 或 ~/.npm-global/bin
   ```

3. **旧版本被覆盖**
   ```bash
   claude-code-collective --version
   # 显示 2.1.0 而不是 2.0.8
   ```
   
   **解决方案：**
   ```bash
   # 重新安装旧版本
   npm install -g claude-code-collective@2.0.8
   ```

## 🔍 故障排除

### 问题 1: npm list 只显示一个版本

```bash
# 检查是否真的安装了两个
ls -la $(npm config get prefix)/node_modules | grep claude-code

# 应该看到：
# drwxr-xr-x  claude-code-collective
# drwxr-xr-x  @ljymaster

# 如果只有一个，重新安装缺失的版本
```

### 问题 2: ccc 命令不可用

```bash
# 检查 bin 链接
ls -la $(npm config get prefix) | grep ccc

# 应该看到：
# ccc -> ../node_modules/@ljymaster/claude-code-collective/bin/claude-code-collective.js

# 如果没有，重新安装
npm install -g https://github.com/ljymaster/claude-code-sub-agent-collective.git --force
```

### 问题 3: Windows 路径问题

```bash
# Windows 用户可能需要使用反斜杠
dir %APPDATA%\npm\node_modules | findstr claude-code

# 或在 PowerShell 中
Get-ChildItem "$env:APPDATA\npm\node_modules" | Where-Object Name -like "*claude-code*"
```

## 📊 完整测试报告模板

```bash
# ================================
# 并存测试报告
# ================================

# 1. 环境信息
Node版本: $(node --version)
NPM版本: $(npm --version)
操作系统: Windows/Linux/Mac
安装路径: $(npm config get prefix)

# 2. 已安装包
$(npm list -g --depth=0 | grep claude-code)

# 3. 命令可用性
旧版本命令: $(which claude-code-collective)
新版本短命令: $(which ccc)
新版本完整命令: $(which claude-code-collective-v2)

# 4. 版本检查
旧版本: $(claude-code-collective --version)
新版本(ccc): $(ccc --version)
新版本(v2): $(claude-code-collective-v2 --version)

# 5. 功能测试
旧版本初始化: [成功/失败]
新版本初始化: [成功/失败]
旧版本status: [成功/失败]
新版本status: [成功/失败]

# 6. 测试结论
并存状态: [成功/失败]
问题描述: [如有]
```

## 🎯 快速验证命令（一键检查）

```bash
# 复制并运行以下命令进行快速验证
echo "=== 版本检查 ==="
echo "旧版本:" && claude-code-collective --version
echo "新版本(ccc):" && ccc --version
echo "新版本(v2):" && claude-code-collective-v2 --version

echo -e "\n=== 已安装包 ==="
npm list -g --depth=0 | grep claude-code

echo -e "\n=== 命令位置 ==="
which claude-code-collective || where claude-code-collective
which ccc || where ccc
which claude-code-collective-v2 || where claude-code-collective-v2

echo -e "\n=== 功能测试 ==="
mkdir /tmp/test-coexist && cd /tmp/test-coexist
ccc init --yes --platform=qoder > /dev/null 2>&1 && echo "✅ 新版本初始化成功" || echo "❌ 新版本初始化失败"
ccc status | grep "Version: 2.1.0" > /dev/null && echo "✅ 新版本状态正确" || echo "❌ 新版本状态错误"
cd .. && rm -rf /tmp/test-coexist

echo -e "\n=== 测试完成 ==="
```

## 📝 下一步

测试成功后，可以：

1. **推送到 GitHub**
   ```bash
   cd D:\MyDevelop\Qoder\claude-code-sub-agent-collective-main
   git add .
   git commit -m "feat: support coexistence with v2.0.8 using scoped package"
   git push origin main
   ```

2. **更新文档**
   - 已创建 `docs/COEXISTENCE-GUIDE.md`
   - 已更新 `README.md`
   - 已更新 `docs/GITHUB-INSTALL-GUIDE.md`

3. **通知团队成员**
   - 分享安装指南
   - 说明新旧版本命令差异
   - 提供测试步骤

4. **创建 Release**
   ```bash
   # 在 GitHub 上创建 v2.1.0 Release
   # 附上 CHANGELOG 和安装说明
   ```

---

**祝测试顺利！** 🚀
