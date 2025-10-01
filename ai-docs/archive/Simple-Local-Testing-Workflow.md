# Simple Local Testing Workflow

A straightforward guide for testing NPM packages locally before publishing, using the npm pack method.

## Quick Reference

Test your changes locally without pushing to Git or publishing to NPM.

## The Simple 4-Step Process

### 1. Create Branch & Make Changes
```bash
# Create new feature branch
git checkout -b feature/new-functionality

# Make your changes
# ... edit files ...

# Commit changes (but don't push yet)
git add .
git commit -m "feat: add new functionality"
```

### 2. Create Test Package
```bash
# In your project directory, create a tarball
npm pack

# This creates: claude-code-collective-2.0.5.tgz (or your version number)
```

### 3. Test Installation in Fresh Directory
```bash
# Create test directory in npm-tests folder
mkdir -p ../npm-tests/test-my-feature
cd ../npm-tests/test-my-feature

# Install from your local tarball (NOT from NPM registry)
npm install ../../taskmaster-agent-claude-code/claude-code-collective-2.0.5.tgz

# Test NPX functionality with your changes
# Non-interactive testing (for validation/CI)
npx claude-code-collective init --yes --force
npx claude-code-collective validate
npx claude-code-collective status

# Interactive testing (for development)
npx claude-code-collective init
```

### 4. Clean Up
```bash
# Go back to your project
cd ../../taskmaster-agent-claude-code

# Remove test files
rm claude-code-collective-*.tgz           # Remove tarball
rm -rf ../npm-tests/test-my-feature       # Remove test directory
```

## Key Points

### Why This Works
- **File path vs package name**: `npm install ../path/to/file.tgz` installs from file, not NPM registry
- **Local testing**: Tests your exact changes without publishing anything
- **Real simulation**: Mimics exactly what users will experience

### Non-Interactive Testing Flags
- **`--yes`**: Skip all prompts and use defaults
- **`--force`**: Overwrite existing files without asking
- **`--minimal`**: Install minimal version (fewer components)
- **Combined**: `--yes --force` for automated validation testing

### NPM Install Behavior
```bash
# These are DIFFERENT:
npm install claude-code-collective                    # Downloads from NPM registry (prod)
npm install ../project/claude-code-collective-*.tgz  # Installs from your local file (test)
```

### Verification Commands
```bash
# Check what version you actually installed
npm list claude-code-collective

# View the installed package details
cat node_modules/claude-code-collective/package.json
```

## When to Use This Workflow

- **Before pushing**: Test changes locally before committing to Git
- **Before PR**: Validate everything works as expected
- **Before publishing**: Final check before NPM publish
- **During development**: Quick validation of new features

## Common Issues & Solutions

### Issue: "Command not found"
```bash
# Make sure bin is configured in package.json
{
  "bin": {
    "claude-code-collective": "./bin/claude-code-collective.js"
  }
}

# Make sure bin file has shebang
#!/usr/bin/env node
```

### Issue: Wrong version installed
```bash
# Check you're using file path, not package name
npm install ../project/file.tgz  # ✅ Correct - uses local file
npm install package-name          # ❌ Wrong - uses NPM registry
```

### Issue: Changes not reflected
```bash
# Make sure you re-run npm pack after changes
npm pack  # Creates new tarball with latest changes
```

## Advanced: Iterate and Test

If you find issues during testing:

```bash
# 1. Go back to project and fix
cd ../taskmaster-agent-claude-code
# ... make fixes ...
git add .
git commit -m "fix: resolve issue"

# 2. Create new test package
npm pack

# 3. Test again (you can reuse same test directory)
cd ../npm-tests/test-my-feature
npm install ../../taskmaster-agent-claude-code/claude-code-collective-*.tgz --force
npx claude-code-collective init
```

## Ready for Production

When testing passes:

```bash
# Push your branch
git push -u origin feature/new-functionality

# Create PR
gh pr create --title "Add new functionality"

# After merge, tag and publish
git checkout main
git pull
git tag v2.0.6
git push --tags

# Or publish to NPM
npm publish
```

## One-Liner Testing Script

Add this to your `package.json` scripts:

```json
{
  "scripts": {
    "test-local": "npm pack && mkdir -p ../test-local && cd ../test-local && npm install ../$(basename $(pwd))/$(basename $(pwd))-*.tgz && npx $(basename $(pwd)) init"
  }
}
```

Then just run:
```bash
npm run test-local
```

---

This workflow gives you confidence that your package will work for users before you publish or merge any changes.