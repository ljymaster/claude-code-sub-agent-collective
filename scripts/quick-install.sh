#!/bin/bash
# 快速安装脚本 - 无需 NPM 发布

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo "🚀 Claude Code Collective - 快速安装"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 检查目标目录
if [ -z "$1" ]; then
    TARGET_DIR="$(pwd)"
else
    TARGET_DIR="$1"
fi

echo "📁 目标目录: $TARGET_DIR"
echo ""

# 打包
echo "📦 创建安装包..."
cd "$PROJECT_ROOT"
PACKAGE_FILE=$(npm pack 2>/dev/null | tail -n 1)
echo "✅ 创建成功: $PACKAGE_FILE"
echo ""

# 安装
echo "⚙️  开始安装..."
cd "$TARGET_DIR"
npx "$PROJECT_ROOT/$PACKAGE_FILE" init --yes --platform=qoder

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ 安装完成！"
echo ""
echo "📊 检查状态:"
npx "$PROJECT_ROOT/$PACKAGE_FILE" status
echo ""
echo "💡 提示: 运行以下命令进行验证"
echo "   npx $PROJECT_ROOT/$PACKAGE_FILE validate"
