#!/bin/bash
# test-local.sh - Automated local package testing script

set -e

echo "🧪 Starting local package testing..."

# Get package name and version from package.json
PACKAGE_NAME=$(node -p "require('./package.json').name")
PACKAGE_VERSION=$(node -p "require('./package.json').version")

echo "📦 Package: $PACKAGE_NAME v$PACKAGE_VERSION"

# Step 1: Create package
echo "📦 Creating package tarball..."
npm pack

TARBALL_NAME="${PACKAGE_NAME}-${PACKAGE_VERSION}.tgz"
echo "✅ Created: $TARBALL_NAME"

# Step 2: Create npm-tests directory and find next available test directory
NPM_TESTS_DIR="../npm-tests"
if [ ! -d "$NPM_TESTS_DIR" ]; then
    echo "📁 Creating npm-tests directory: $NPM_TESTS_DIR"
    mkdir "$NPM_TESTS_DIR"
fi

TEST_BASE="$NPM_TESTS_DIR/ccc-testing"
TEST_DIR="${TEST_BASE}-v1"
COUNTER=1

while [ -d "$TEST_DIR" ]; do
    COUNTER=$((COUNTER + 1))
    TEST_DIR="${TEST_BASE}-v${COUNTER}"
done

echo "📁 Creating test directory: $TEST_DIR"
mkdir "$TEST_DIR"

# Step 3: Install and test
echo "📥 Installing package in test directory..."
cd "$TEST_DIR"

# Calculate correct path to tarball based on our new location
TARBALL_PATH="../../taskmaster-agent-claude-code/$TARBALL_NAME"
npm install "$TARBALL_PATH"

echo ""
echo "🚀 Testing NPX functionality..."
echo "Package version check:"
npx "$PACKAGE_NAME" --version
echo ""

echo "🧪 Running non-interactive validation tests..."
echo "Testing init with --yes --force flags:"
npx "$PACKAGE_NAME" init --yes --force
echo ""
echo "Testing status command:"
npx "$PACKAGE_NAME" status 2>&1 | head -10
echo ""
echo "Testing validate command:"
npx "$PACKAGE_NAME" validate 2>&1 | head -10
echo ""

echo "🧪 Running smoke tests..."
echo ""
if [ -x ".claude-collective/smoke-tests/run-all.sh" ]; then
    if ./.claude-collective/smoke-tests/run-all.sh; then
        echo ""
        echo "✅ All smoke tests passed!"
    else
        echo ""
        echo "❌ Smoke tests failed - see output above"
        echo "⚠️  Installation may have issues"
    fi
else
    echo "⚠️  Smoke tests not found (expected at .claude-collective/smoke-tests/run-all.sh)"
fi
echo ""

echo "✅ Installation complete!"
echo ""
echo "🎯 You are now in: $(pwd)"
echo "💡 Additional manual testing commands:"
echo "   npx $PACKAGE_NAME init            # Interactive mode"
echo "   npx $PACKAGE_NAME init --minimal  # Minimal installation"
echo "   npx $PACKAGE_NAME --help          # Help information"
echo ""
echo "🧹 When done testing, run: cd ../taskmaster-agent-claude-code && ./scripts/cleanup-tests.sh"