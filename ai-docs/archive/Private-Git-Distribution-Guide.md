# Private Git Distribution Guide

A comprehensive guide for distributing NPM packages via private Git repositories instead of the public NPM registry.

## Overview

This guide covers how to distribute the `claude-code-collective` package through private Git repositories, enabling controlled access without public NPM publishing. Perfect for proprietary tools, internal company packages, or projects that aren't ready for public release.

## Why Private Git Distribution?

### Advantages
- **Privacy Control**: Keep code proprietary while enabling easy distribution
- **Access Management**: Use Git repository permissions for access control
- **Version Control**: Leverage Git tags for semantic versioning
- **No Registry Costs**: Avoid private NPM registry fees
- **Simple Workflow**: Users install directly via NPX/NPM commands

### Use Cases
- Internal company tools
- Client-specific implementations
- Beta/experimental packages
- Educational/training materials
- Personal development tools

## Installation Methods for Users

### 1. Direct NPX Execution (Recommended)
```bash
# Install and run immediately
npx git+ssh://git@github.com/username/taskmaster-agent-claude-code.git init

# With specific version/tag
npx git+ssh://git@github.com/username/taskmaster-agent-claude-code.git#v1.0.0 init

# With GitHub shorthand (if public or properly configured)
npx github:username/taskmaster-agent-claude-code init
```

### 2. NPM Install + NPX
```bash
# Install as dependency
npm install git+ssh://git@github.com/username/taskmaster-agent-claude-code.git

# Then use NPX
npx claude-code-collective init
```

### 3. Global Installation
```bash
# Install globally
npm install -g git+ssh://git@github.com/username/taskmaster-agent-claude-code.git

# Use directly
claude-code-collective init
```

### 4. Project Dependency
```json
{
  "dependencies": {
    "claude-code-collective": "git+ssh://git@github.com/username/taskmaster-agent-claude-code.git#v1.0.0"
  },
  "scripts": {
    "setup-collective": "npx claude-code-collective init"
  }
}
```

## Authentication Setup

### SSH Keys (Recommended Method)

#### 1. Generate SSH Key
```bash
# Generate new SSH key
ssh-keygen -t ed25519 -C "your-email@example.com"

# When prompted, save to default location or specify path
# Enter passphrase (optional but recommended)
```

#### 2. Add to SSH Agent
```bash
# Start SSH agent
eval "$(ssh-agent -s)"

# Add key to agent
ssh-add ~/.ssh/id_ed25519
```

#### 3. Add to GitHub/GitLab
```bash
# Copy public key to clipboard
cat ~/.ssh/id_ed25519.pub | pbcopy  # macOS
cat ~/.ssh/id_ed25519.pub | xclip -selection clipboard  # Linux

# Add to GitHub: Settings > SSH and GPG keys > New SSH key
# Paste the public key content
```

#### 4. Test Connection
```bash
# Test GitHub connection
ssh -T git@github.com

# Expected response: "Hi username! You've successfully authenticated..."
```

### Personal Access Tokens (Alternative)

#### 1. Generate Token
- GitHub: Settings > Developer settings > Personal access tokens > Generate new token
- Required scopes: `repo` (full repository access)

#### 2. Use with HTTPS
```bash
# Clone with token
git clone https://username:token@github.com/username/repo.git

# Install with token
npm install git+https://username:token@github.com/username/taskmaster-agent-claude-code.git
```

## Repository Configuration

### Package.json Setup
```json
{
  "name": "claude-code-collective",
  "version": "2.0.5",
  "description": "Sub-agent collective framework for Claude Code",
  "repository": {
    "type": "git",
    "url": "git+ssh://git@github.com/username/taskmaster-agent-claude-code.git"
  },
  "bin": {
    "claude-code-collective": "./bin/claude-code-collective.js"
  },
  "files": [
    "bin/",
    "lib/",
    "templates/",
    "package.json",
    "README.md"
  ]
}
```

### .gitignore Updates
```gitignore
# NPM
node_modules/
npm-debug.log*
*.tgz

# Testing artifacts
coverage/
.nyc_output/

# Environment
.env
.env.local

# OS
.DS_Store
Thumbs.db

# IDE
.vscode/
.idea/
```

## Version Management

### Semantic Versioning with Git Tags
```bash
# Create and push version tags
git tag v1.0.0
git push --tags

# Users can install specific versions
npm install git+ssh://git@github.com/username/taskmaster-agent-claude-code.git#v1.0.0
```

### Branch-based Development
```bash
# Development branch
git checkout -b develop
# Make changes, test, commit

# Release branch
git checkout -b release/v1.1.0
# Final testing, version bump, tag

# Main branch for stable releases
git checkout main
git merge release/v1.1.0
git tag v1.1.0
git push --tags
```

### NPM Version Management
```bash
# Bump version and create tag
npm version patch  # 1.0.0 -> 1.0.1
npm version minor  # 1.0.1 -> 1.1.0
npm version major  # 1.1.0 -> 2.0.0

# Push changes and tags
git push --follow-tags
```

## Testing Workflow

### 1. Local Development Testing
```bash
# Test locally during development
npm run test:jest
npm run test:coverage

# Test NPX functionality locally
npx . init
npx . status
npx . validate
```

### 2. Git Installation Testing
```bash
# Create test directory
mkdir ../test-git-install
cd ../test-git-install

# Test git installation
npm install git+ssh://git@github.com/username/taskmaster-agent-claude-code.git

# Test NPX execution
npx claude-code-collective init
npx claude-code-collective validate

# Cleanup
cd ..
rm -rf test-git-install
```

### 3. Version Testing
```bash
# Test specific version
npm install git+ssh://git@github.com/username/taskmaster-agent-claude-code.git#v1.0.0

# Test latest development
npm install git+ssh://git@github.com/username/taskmaster-agent-claude-code.git#main
```

### 4. Cross-platform Testing
```bash
# Test on different systems
# Windows (PowerShell)
npx git+ssh://git@github.com/username/taskmaster-agent-claude-code.git init

# macOS/Linux
npx git+ssh://git@github.com/username/taskmaster-agent-claude-code.git init

# Different Node versions
nvm use 16 && npx git+ssh://git@github.com/username/taskmaster-agent-claude-code.git init
nvm use 18 && npx git+ssh://git@github.com/username/taskmaster-agent-claude-code.git init
```

## Distribution Workflow

### 1. Development Cycle
```bash
# 1. Make changes
# Edit code, update documentation

# 2. Test locally
npm run test:jest
npm link && cd ../test-project && npm link claude-code-collective
npx claude-code-collective init

# 3. Commit changes
git add .
git commit -m "feat: add new functionality"

# 4. Test git installation
cd ../test-git-fresh
npm install git+ssh://git@github.com/username/taskmaster-agent-claude-code.git
npx claude-code-collective init

# 5. Push to repository
git push origin main
```

### 2. Release Process
```bash
# 1. Update version
npm version minor

# 2. Update changelog
# Edit CHANGELOG.md with release notes

# 3. Create release tag
git add CHANGELOG.md package.json package-lock.json
git commit -m "chore: release v1.1.0"
git tag v1.1.0

# 4. Push release
git push --follow-tags

# 5. Test release
npm install git+ssh://git@github.com/username/taskmaster-agent-claude-code.git#v1.1.0
```

### 3. User Communication
```markdown
## Installation Instructions

### Quick Start
```bash
npx git+ssh://git@github.com/username/taskmaster-agent-claude-code.git init
```

### Version-specific Installation
```bash
npx git+ssh://git@github.com/username/taskmaster-agent-claude-code.git#v1.1.0 init
```

### Prerequisites
- Node.js >= 16.0.0
- Git with SSH access to the repository
- SSH key added to GitHub account
```

## Access Control

### Repository Permissions
```bash
# GitHub repository settings
Settings > Manage access > Invite collaborators

# Permission levels:
# - Read: Can clone and install
# - Write: Can contribute code
# - Admin: Full repository control
```

### Organization Distribution
```bash
# GitHub Organizations
# Create organization repository
# Add teams with appropriate permissions
# Share installation instructions with team
```

### Client Distribution
```bash
# Create client-specific branches
git checkout -b client/acme-corp

# Customize for client
# Commit client-specific changes

# Client installs their branch
npx git+ssh://git@github.com/username/taskmaster-agent-claude-code.git#client/acme-corp init
```

## Alternative Distribution Methods

### 1. GitHub Packages (Private NPM)
```bash
# Setup .npmrc
echo "@username:registry=https://npm.pkg.github.com" > .npmrc

# Authenticate
npm login --scope=@username --registry=https://npm.pkg.github.com

# Publish
npm publish

# Install
npm install @username/claude-code-collective
```

### 2. Self-hosted NPM Registry
```bash
# Install Verdaccio
npm install -g verdaccio

# Start registry
verdaccio

# Configure .npmrc
echo "registry=http://localhost:4873" > .npmrc

# Publish
npm publish

# Install
npm install claude-code-collective
```

### 3. Archive Distribution
```bash
# Create package archive
npm pack

# Distribute .tgz file
# Users install via:
npm install ./claude-code-collective-2.0.5.tgz
```

## Troubleshooting

### Common Issues

#### SSH Authentication Failures
```bash
# Check SSH connection
ssh -T git@github.com

# Debug SSH
ssh -vT git@github.com

# Check SSH agent
ssh-add -l

# Re-add keys
ssh-add ~/.ssh/id_ed25519
```

#### NPM Installation Errors
```bash
# Clear NPM cache
npm cache clean --force

# Use verbose logging
npm install --verbose git+ssh://git@github.com/username/taskmaster-agent-claude-code.git

# Check Node/NPM versions
node --version
npm --version
```

#### Permission Denied
```bash
# Check repository access
git clone git@github.com/username/taskmaster-agent-claude-code.git

# Verify SSH key permissions
chmod 600 ~/.ssh/id_ed25519
chmod 644 ~/.ssh/id_ed25519.pub
```

### Testing Commands
```bash
# Test repository access
git ls-remote git@github.com/username/taskmaster-agent-claude-code.git

# Test NPM installation
npm install --dry-run git+ssh://git@github.com/username/taskmaster-agent-claude-code.git

# Test NPX execution
npx --help git+ssh://git@github.com/username/taskmaster-agent-claude-code.git
```

## Security Considerations

### Repository Security
- Use SSH keys instead of passwords
- Enable two-factor authentication
- Regularly rotate SSH keys
- Monitor repository access logs
- Use branch protection rules

### Access Management
- Grant minimal necessary permissions
- Regularly audit collaborator access
- Use teams for organization-wide access
- Document access procedures
- Remove access when no longer needed

### Code Security
- Never commit secrets/tokens
- Use .gitignore for sensitive files
- Scan for leaked credentials
- Use dependency vulnerability scanning
- Keep dependencies updated

## Best Practices

### Documentation
- Clear installation instructions
- Version compatibility matrix
- Troubleshooting guide
- Changelog maintenance
- API documentation

### Testing
- Comprehensive test suite
- Cross-platform testing
- Version compatibility testing
- Installation testing
- Performance testing

### Maintenance
- Regular dependency updates
- Security patch management
- Version lifecycle planning
- User support processes
- Backup strategies

---

This guide provides a complete framework for distributing NPM packages via private Git repositories, enabling secure and controlled distribution without public registry requirements.