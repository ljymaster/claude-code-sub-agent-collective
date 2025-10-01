# NPM Testing Guide

A comprehensive guide for testing NPM packages locally before publishing to ensure reliability and prevent production issues.

## Overview

This guide covers various methods to test NPM packages locally before publishing, including both public NPM registry and private Git repository distribution scenarios. Essential for preventing broken releases and ensuring package integrity.

## Why Test Before Publishing?

### Risks of Direct Publishing
- **Broken installations** for users
- **Cannot unpublish** after 24 hours (NPM policy)
- **Version number waste** if package is broken
- **Reputation damage** from unreliable packages
- **User frustration** and support burden

### Benefits of Local Testing
- **Catch installation issues** before users see them
- **Verify NPX functionality** works correctly
- **Test cross-platform compatibility** 
- **Validate package contents** and file inclusion
- **Ensure dependency resolution** works properly

## Testing Methods Overview

| Method | Use Case | Pros | Cons |
|--------|----------|------|------|
| `npm link` | Active development | Fast, automatic updates | Not real installation |
| `npm pack` | Pre-publish validation | Most accurate to real install | Manual process |
| `npx .` | Local NPX testing | Tests NPX directly | Only works in package dir |
| Beta versions | Public testing | Real registry test | Uses version numbers |
| Git installation | Private repos | Tests git workflow | Requires git setup |

## Method 1: npm link (Development Testing)

### Best for: Active development and iteration

```bash
# In your package directory
npm link

# In test project directory
npm link claude-code-collective

# Test the package
npx claude-code-collective init

# Make changes to package, test automatically updates

# Clean up when done
npm unlink claude-code-collective
cd /path/to/package
npm unlink
```

### Advantages
- **Automatic updates** - Changes reflect immediately
- **Fast iteration** - No reinstallation needed
- **Development workflow** - Perfect for active coding

### Disadvantages
- **Not real installation** - Symlinked, not copied
- **Missing dependency issues** - May not catch resolution problems
- **Platform differences** - Different from actual user experience

### When to Use
- During active development
- Testing new features
- Iterating on functionality
- Quick validation of changes

## Method 2: npm pack (Production Simulation)

### Best for: Pre-publish validation and final testing

```bash
# In your package directory
npm pack
# Creates: claude-code-collective-2.0.5.tgz

# Test installation in fresh directory
mkdir ../test-pack-install
cd ../test-pack-install

# Install from tarball (simulates exact NPM experience)
npm install ../taskmaster-agent-claude-code/claude-code-collective-2.0.5.tgz

# Test NPX functionality
npx claude-code-collective init
npx claude-code-collective status
npx claude-code-collective validate

# Test global installation
npm install -g ../taskmaster-agent-claude-code/claude-code-collective-2.0.5.tgz
claude-code-collective init

# Clean up
cd ../taskmaster-agent-claude-code
rm -rf ../test-pack-install
rm claude-code-collective-*.tgz
```

### Advantages
- **Most accurate** - Exactly simulates NPM registry installation
- **Tests packaging** - Validates files array in package.json
- **Dependency validation** - Tests real dependency resolution
- **Cross-platform** - Tests on actual target environments

### Disadvantages
- **Manual process** - Need to repack after each change
- **Slower iteration** - Full reinstall required for testing changes
- **File cleanup** - Need to manage .tgz files

### When to Use
- **Before every publish** - Final validation step
- **CI/CD pipelines** - Automated testing
- **Release candidates** - Comprehensive testing
- **Cross-platform testing** - Different OS/Node versions

## Method 3: npx . (Local NPX Testing)

### Best for: Quick NPX functionality validation

```bash
# In your package directory (must have bin in package.json)
npx . init
npx . status
npx . validate
npx . --help

# Test with different arguments
npx . init --minimal
npx . init --interactive
npx . init --force
```

### Advantages
- **Fast and simple** - No installation needed
- **Tests NPX directly** - Validates bin configuration
- **Immediate feedback** - Quick validation of CLI changes

### Disadvantages
- **Limited scope** - Only tests in package directory
- **Missing dependencies** - May not catch install-time issues
- **Not real user experience** - Different from actual installation

### When to Use
- **CLI development** - Testing command-line interface
- **Quick validation** - Fast checks during development
- **Bin configuration** - Validating executable setup
- **Argument parsing** - Testing command options

## Method 4: Beta/Prerelease Testing

### Best for: Public testing with real NPM registry

```bash
# Publish beta version
npm version prerelease --preid=beta
# Updates to: 2.0.6-beta.0

npm publish --tag beta
# Published as beta, not latest

# Test beta installation
npm install -g claude-code-collective@beta
claude-code-collective init

# Or test with NPX
npx claude-code-collective@beta init

# If testing successful, promote to latest
npm dist-tag add claude-code-collective@2.0.6-beta.0 latest

# If testing fails, fix and republish beta
npm version prerelease --preid=beta
# Updates to: 2.0.6-beta.1
npm publish --tag beta
```

### Beta Version Workflow
```bash
# 1. Create beta
npm version prerelease --preid=beta
npm publish --tag beta

# 2. Test thoroughly
npx claude-code-collective@beta init
npm install -g claude-code-collective@beta

# 3. Get feedback from beta users
# Share: npm install claude-code-collective@beta

# 4. Fix issues and iterate
npm version prerelease --preid=beta
npm publish --tag beta

# 5. Promote stable release
npm version patch  # Remove beta, increment version
npm publish  # Publishes as latest
```

### Advantages
- **Real registry** - Tests actual NPM infrastructure
- **User feedback** - Get real-world testing
- **Safe iteration** - Beta tag prevents accidental installs
- **Rollback capability** - Can abandon beta versions

### Disadvantages
- **Uses version numbers** - Beta versions consume semver space
- **Public visibility** - Beta versions are still public
- **Registry dependency** - Requires NPM registry access

### When to Use
- **Major releases** - Significant changes need validation
- **Public packages** - When you have beta users
- **Complex packages** - Multiple dependencies or platforms
- **Breaking changes** - Need extensive validation

## Method 5: Git Repository Testing

### Best for: Private packages and Git distribution

```bash
# Commit and push changes
git add .
git commit -m "feat: new functionality"
git push origin main

# Test git installation in fresh directory
mkdir ../test-git-install
cd ../test-git-install

# Test SSH installation
npm install git+ssh://git@github.com/username/taskmaster-agent-claude-code.git
npx claude-code-collective init

# Test HTTPS installation (with token)
npm install git+https://username:token@github.com/username/taskmaster-agent-claude-code.git

# Test NPX directly from git
npx git+ssh://git@github.com/username/taskmaster-agent-claude-code.git init

# Test specific version/tag
git tag v2.0.5
git push --tags
npm install git+ssh://git@github.com/username/taskmaster-agent-claude-code.git#v2.0.5

# Clean up
cd ../taskmaster-agent-claude-code
rm -rf ../test-git-install
```

### Advantages
- **Private testing** - No public registry needed
- **Version control** - Full git workflow
- **Access control** - Repository permissions manage access
- **Branch testing** - Test different branches/features

### Disadvantages
- **Git setup required** - SSH keys, authentication
- **More complex** - Additional configuration needed
- **Limited discoverability** - Users need specific instructions

### When to Use
- **Private packages** - Not ready for public release
- **Client work** - Proprietary or client-specific packages
- **Internal tools** - Company or team-specific packages
- **Development branches** - Testing features before merge

## Comprehensive Testing Workflow

### Pre-Publish Checklist

```bash
# 1. Run all automated tests
npm run test:jest
npm run test:coverage
npm run test:contracts
npm run test:handoffs

# 2. Test local NPX functionality
npx . init --force
npx . status
npx . validate

# 3. Test npm pack installation
npm pack
mkdir ../test-pack && cd ../test-pack
npm install ../taskmaster-agent-claude-code/claude-code-collective-*.tgz
npx claude-code-collective init
cd ../taskmaster-agent-claude-code && rm -rf ../test-pack

# 4. Test version management
npm version --dry-run patch
git status  # Ensure clean working directory

# 5. Test cross-platform (if possible)
# Windows: Test in PowerShell/CMD
# macOS: Test in Terminal
# Linux: Test in various distributions

# 6. Test Node version compatibility
nvm use 16 && npm test && npx . init
nvm use 18 && npm test && npx . init
nvm use 20 && npm test && npx . init
```

### Automated Testing Script

Create `scripts/test-package.sh`:

```bash
#!/bin/bash
# test-package.sh - Automated package testing

set -e  # Exit on error

echo "🧪 Starting comprehensive package testing..."

# 1. Run unit tests
echo "📋 Running unit tests..."
npm run test:jest

# 2. Test local NPX
echo "🔧 Testing local NPX functionality..."
npx . init --force
npx . status
npx . validate

# 3. Test npm pack
echo "📦 Testing npm pack installation..."
npm pack
TEST_DIR="../test-$(date +%s)"
mkdir "$TEST_DIR"
cd "$TEST_DIR"

echo "📥 Installing from tarball..."
npm install ../taskmaster-agent-claude-code/claude-code-collective-*.tgz

echo "🚀 Testing NPX functionality..."
npx claude-code-collective init
npx claude-code-collective status
npx claude-code-collective validate

# 4. Test global installation
echo "🌐 Testing global installation..."
npm install -g ../taskmaster-agent-claude-code/claude-code-collective-*.tgz
claude-code-collective --version

# 5. Clean up
echo "🧹 Cleaning up..."
npm uninstall -g claude-code-collective
cd ../taskmaster-agent-claude-code
rm -rf "$TEST_DIR"
rm claude-code-collective-*.tgz

echo "✅ All tests passed!"
```

Make executable and run:
```bash
chmod +x scripts/test-package.sh
./scripts/test-package.sh
```

## Platform-Specific Testing

### Windows Testing
```powershell
# PowerShell testing
npm pack
mkdir ..\test-windows
cd ..\test-windows
npm install ..\taskmaster-agent-claude-code\claude-code-collective-*.tgz
npx claude-code-collective init

# Command Prompt testing
cmd /c "npx claude-code-collective init"
```

### macOS Testing
```bash
# Bash testing
npm pack
mkdir ../test-macos
cd ../test-macos
npm install ../taskmaster-agent-claude-code/claude-code-collective-*.tgz
npx claude-code-collective init

# Zsh testing (default macOS shell)
zsh -c "npx claude-code-collective init"
```

### Linux Testing
```bash
# Various shell testing
bash -c "npx claude-code-collective init"
zsh -c "npx claude-code-collective init"
fish -c "npx claude-code-collective init"

# Different distributions (using Docker)
docker run -v $(pwd):/app -w /app node:16-alpine npm pack
docker run -v $(pwd):/app -w /app node:16-alpine sh -c "
  mkdir test && cd test && 
  npm install ../claude-code-collective-*.tgz && 
  npx claude-code-collective init
"
```

## CI/CD Integration

### GitHub Actions Example

Create `.github/workflows/test-package.yml`:

```yaml
name: Package Testing

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test-package:
    runs-on: ${{ matrix.os }}
    strategy:
      matrix:
        os: [ubuntu-latest, windows-latest, macos-latest]
        node-version: [16, 18, 20]

    steps:
    - uses: actions/checkout@v4
    
    - name: Setup Node.js
      uses: actions/setup-node@v4
      with:
        node-version: ${{ matrix.node-version }}
        cache: 'npm'

    - name: Install dependencies
      run: npm ci

    - name: Run tests
      run: npm run test:jest

    - name: Test local NPX
      run: |
        npx . init --force
        npx . status
        npx . validate

    - name: Test npm pack installation
      run: |
        npm pack
        mkdir ../test-pack
        cd ../test-pack
        npm install ../taskmaster-agent-claude-code/claude-code-collective-*.tgz
        npx claude-code-collective init
        npx claude-code-collective validate
```

### Package Testing with Docker

Create `docker/test-package.dockerfile`:

```dockerfile
FROM node:18-alpine

WORKDIR /app
COPY package*.json ./
COPY . .

RUN npm ci
RUN npm pack

# Test installation
RUN mkdir /test && cd /test
RUN npm install /app/claude-code-collective-*.tgz
RUN npx claude-code-collective init
RUN npx claude-code-collective validate

CMD ["echo", "Package testing completed successfully"]
```

Run with:
```bash
docker build -f docker/test-package.dockerfile -t test-package .
docker run --rm test-package
```

## Common Issues and Solutions

### File Inclusion Problems

**Issue**: Files missing from package
```bash
# Debug: Check what files are included
npm pack --dry-run

# Fix: Update package.json files array
{
  "files": [
    "bin/",
    "lib/",
    "templates/",
    "README.md"
  ]
}
```

### Dependency Resolution Issues

**Issue**: Package works locally but fails when installed
```bash
# Debug: Test with clean node_modules
rm -rf node_modules package-lock.json
npm install
npm test

# Fix: Check peer dependencies and engine requirements
{
  "engines": {
    "node": ">=16.0.0"
  },
  "peerDependencies": {
    "some-peer-dep": "^1.0.0"
  }
}
```

### NPX Binary Issues

**Issue**: NPX command not found or not executable
```bash
# Debug: Check bin configuration
{
  "bin": {
    "claude-code-collective": "./bin/claude-code-collective.js"
  }
}

# Fix: Ensure file has shebang and is executable
#!/usr/bin/env node
chmod +x bin/claude-code-collective.js
```

### Cross-Platform Path Issues

**Issue**: Package works on one OS but not others
```bash
# Debug: Use path module for cross-platform paths
const path = require('path');
const filePath = path.join(__dirname, 'templates', 'file.txt');

# Fix: Avoid hardcoded path separators
// Wrong: 'templates/file.txt'
// Right: path.join('templates', 'file.txt')
```

## Best Practices

### Testing Strategy
1. **Test early and often** - Don't wait until release
2. **Test multiple environments** - Different OS and Node versions
3. **Automate testing** - Use CI/CD for consistent validation
4. **Test edge cases** - Different installation methods and scenarios
5. **Validate user experience** - Test from user perspective

### Version Management
1. **Use semantic versioning** - Follow semver principles
2. **Test before version bump** - Validate before incrementing
3. **Use beta versions** - For major changes or uncertain releases
4. **Document changes** - Maintain changelog for all versions
5. **Tag releases** - Use git tags for version tracking

### Release Process
1. **Comprehensive testing** - All methods and platforms
2. **Documentation updates** - README, changelog, guides
3. **Version consistency** - Package.json, tags, documentation
4. **Rollback plan** - Know how to handle broken releases
5. **User communication** - Notify users of important changes

---

This guide provides a complete framework for testing NPM packages before publishing, ensuring reliable and professional package distribution.