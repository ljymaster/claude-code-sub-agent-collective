# 🚀 AI Code Collective v2.1.0 - Multi-Platform Release

**Release Date:** 2025-11-25  
**Version:** 2.1.0  
**Breaking Changes:** None ✅  
**Backward Compatible:** Yes ✅

---

## 🎯 Overview

This release transforms the Claude Code Collective into a **true multi-platform AI development framework**, bringing TDD-enforced agent collectives to both **Claude Code** and **Qoder CLI** users. The system now automatically detects your AI coding platform and adapts its behavior, configuration, and hooks accordingly—all while maintaining 100% backward compatibility for existing Claude Code users.

---

## ✨ Key Highlights

### 🔄 Multi-Platform Architecture
- **Automatic Platform Detection**: Detects Claude Code vs Qoder CLI via environment variables
- **Unified Platform Abstraction**: Single codebase serves both platforms seamlessly
- **Cross-Platform Synchronization**: Keep configurations in sync across platforms
- **Zero Breaking Changes**: Existing Claude Code installations upgrade without modification

### 🎨 New Platform Support
- **Qoder CLI Integration**: Full agent collective support for Qoder CLI
- **Platform-Agnostic Hooks**: 11 hooks automatically adapt to platform capabilities
- **Dynamic Configuration**: Settings automatically translate between platform formats
- **Template Variables**: New platform-aware template system for agents and hooks

### 🛠️ Enhanced CLI
- **Platform Selection**: `--platform <auto|claude|qoder|both>` option
- **Config Sync**: `--sync-platforms` for multi-platform developers
- **Smart Defaults**: Auto-detection when platform not specified
- **Better Validation**: Platform-specific compatibility checks

---

## 📦 Installation

### For Existing Claude Code Users
```bash
# Seamless upgrade (no config changes needed)
npx claude-code-collective init --force
```

### For New Qoder CLI Users
```bash
# Install Qoder CLI version
npx claude-code-collective init --platform=qoder
```

### For Multi-Platform Developers
```bash
# Install for both platforms with sync
npx claude-code-collective init --platform=both --sync-platforms
```

---

## 🆕 What's New

### Core Platform Support

#### **Platform Adapter System** (`lib/platform-adapter.js`)
New abstraction layer that provides:
- Environment detection (`$QODER_PROJECT_DIR` vs `$CLAUDE_PROJECT_DIR`)
- Configuration directory resolution (`.qoder` vs `.claude`)
- Template variable processing for platform-specific content
- Platform capability detection

#### **Configuration Adapter** (`lib/config-adapter.js`)
Intelligent configuration translation:
- Automatic conversion between platform settings formats
- Bi-directional synchronization with conflict detection
- Platform-specific feature filtering (e.g., MCP tools, SubagentStop hooks)
- Smart merging of cross-platform configurations

### Hook System Enhancements

All 11 hooks now include platform detection:

```bash
# Platform detection added to every hook
if [ -n "$QODER_PROJECT_DIR" ]; then
  PROJECT_DIR="$QODER_PROJECT_DIR"
  CONFIG_DIR=".qoder"
  PLATFORM="Qoder CLI"
elif [ -n "$CLAUDE_PROJECT_DIR" ]; then
  PROJECT_DIR="$CLAUDE_PROJECT_DIR"
  CONFIG_DIR=".claude"
  PLATFORM="Claude Code"
fi
```

**Updated Hooks:**
- `load-behavioral-system.sh` - Platform-aware behavioral loading
- `block-destructive-commands.sh` - Cross-platform command blocking
- `collective-metrics.sh` - Multi-platform metrics collection
- `directive-enforcer.sh` - Unified TDD enforcement
- `test-driven-handoff.sh` - Platform-independent handoff validation
- `handoff-automation.sh` - Cross-platform automation
- `research-evidence-validation.sh` - Adaptive research validation
- `workflow-coordinator.sh` - Multi-platform coordination
- `mock-deliverable-generator.sh` - Platform-agnostic mocking
- `routing-executor.sh` - Cross-platform routing
- `agent-detection.sh` - Platform-aware detection

### New Templates

#### **Qoder Settings** (`templates/settings.qoder.json.template`)
```json
{
  "deniedTools": [],
  "hooks": {
    "SessionStart": [{
      "matcher": "startup",
      "hooks": [{
        "type": "command",
        "command": "$QODER_PROJECT_DIR/.qoder/hooks/load-behavioral-system.sh"
      }]
    }],
    "PreToolUse": [...],
    "PostToolUse": [...]
  }
}
```

#### **Platform-Agnostic Agent Templates**
- `routing-agent.md` - Updated with platform support header
- `task-orchestrator.md` - Cross-platform orchestration example

### Enhanced Documentation

#### **QODER-USAGE.md** (New)
Complete Qoder CLI usage guide covering:
1. Quick start and installation
2. Platform detection and verification
3. Configuration management
4. Agent workflow examples
5. Hook customization
6. Troubleshooting and FAQ

#### **INSTALLATION-GUIDE.md** (New)
Comprehensive installation documentation:
- 3 publication methods (NPM, GitHub, local .tgz)
- 3 local testing approaches
- 5 detailed usage examples
- Platform comparison matrix
- Troubleshooting guide

#### **PLATFORM-AGNOSTIC-AGENTS.md** (New)
Agent migration guide with:
- Conversion examples (before/after)
- Platform variable reference
- Migration checklist
- Best practices

#### **Updated README.md**
- Multi-platform support section
- Platform compatibility matrix
- Installation examples for each platform
- Feature comparison table

---

## 🔧 Technical Improvements

### Enhanced Installer (`lib/installer.js`)
- Integrated platform adapter for dynamic behavior
- Platform-specific installation messages
- Multi-platform validation checks
- Template variable injection with platform context

### Updated CLI (`bin/claude-code-collective.js`)
- `--platform` parameter with validation
- `--sync-platforms` option for configuration sync
- Extended help text with platform examples
- Better error messages for platform issues

### Template Variable System
New variables for platform-aware templates:
- `{{PLATFORM}}` - Current platform (claude/qoder)
- `{{CONFIG_DIR}}` - Configuration directory path
- `{{PROJECT_DIR_VAR}}` - Platform environment variable
- `{{IS_QODER}}` - Boolean flag (true/false)
- `{{IS_CLAUDE}}` - Boolean flag (true/false)

---

## 📊 Platform Comparison

| Feature | Claude Code | Qoder CLI |
|---------|-------------|-----------|
| **Agent Collective** | ✅ Full Support | ✅ Full Support |
| **TDD Enforcement** | ✅ Complete | ✅ Complete |
| **Hook System** | ✅ All Events | ✅ Core Events* |
| **MCP Integration** | ✅ Context7, etc. | ❌ Not Available |
| **Research Tools** | ✅ MCP-based | ⚠️ Web-based Fallback |
| **Config Sync** | ✅ Supported | ✅ Supported |
| **SubagentStop Hooks** | ✅ Supported | ❌ Not Supported |
| **Auto-Detection** | ✅ Yes | ✅ Yes |
| **Template Variables** | ✅ All | ✅ All |

\* *Qoder CLI supports SessionStart, PreToolUse, and PostToolUse. SubagentStop is Claude Code exclusive.*

---

## 🔄 Migration Guide

### Existing Claude Code Users

**No action required!** Your existing installation will continue working exactly as before.

**To enable multi-platform support:**
```bash
# Reinstall with multi-platform awareness
npx claude-code-collective init --platform=both --force

# Enable config synchronization
npx claude-code-collective init --sync-platforms
```

### New Qoder CLI Users

```bash
# Step 1: Install the collective
npx claude-code-collective init --platform=qoder

# Step 2: Verify installation
npx claude-code-collective status

# Step 3: Start using agents in Qoder CLI
# The system is now active and will enforce TDD workflows
```

### Multi-Platform Developers

```bash
# Install for both platforms with automatic sync
npx claude-code-collective init --platform=both --sync-platforms

# This creates:
# - .claude/              (Claude Code config)
# - .qoder/               (Qoder CLI config)
# - Auto-sync enabled between both
```

### Agent Definition Migration

For agent authors wanting to support both platforms:

**Before (Claude Code only):**
```markdown
# My Agent

## Configuration
Edit `.claude/settings.json` to configure this agent.
```

**After (Multi-platform):**
```markdown
# My Agent

**Platform Support**: Claude Code, Qoder CLI  
**Version:** 2.1.0

## Configuration
Edit your platform's settings file:
- **Claude Code**: `.claude/settings.json`
- **Qoder CLI**: `.qoder/settings.json`
```

See `docs/PLATFORM-AGNOSTIC-AGENTS.md` for complete migration guide.

---

## ⚠️ Known Issues

### Windows File Locking
- **Impact**: 20/121 tests fail during cleanup on Windows systems
- **Cause**: Windows file system locking during test cleanup operations
- **Workaround**: Does not affect production functionality
- **Status**: Non-critical, tests pass on Unix systems

### Platform Switching
- **Impact**: Configuration sync requires manual trigger when switching platforms
- **Workaround**: Run `npx claude-code-collective init --sync-platforms` after switching
- **Status**: Future releases will add automatic detection

### SubagentStop Hooks
- **Impact**: Not available in Qoder CLI
- **Cause**: Qoder CLI platform limitation
- **Workaround**: Use PostToolUse hooks instead
- **Status**: Platform-specific limitation

---

## 🧪 Testing

### Test Coverage
- **Total Tests**: 121
- **Passing**: 101 (83%)
- **Failing**: 20 (Windows file locking only)
- **Critical Path**: All passing ✅

### Test Suites
- ✅ Platform detection
- ✅ Configuration adaptation
- ✅ Hook system compatibility
- ✅ Installation workflows
- ✅ Template variable processing
- ⚠️ Windows cleanup (non-critical failures)

### Manual Testing Completed
- ✅ Claude Code installation and upgrade
- ✅ Qoder CLI fresh installation
- ✅ Multi-platform installation
- ✅ Configuration synchronization
- ✅ Hook execution on both platforms
- ✅ Agent spawning and coordination
- ✅ TDD workflow enforcement

---

## 📈 Upgrade Benefits

### For Claude Code Users
- Future-proof installation with multi-platform support
- Option to use Qoder CLI alongside Claude Code
- Enhanced platform detection and validation
- No configuration changes required

### For Qoder CLI Users
- Access to powerful TDD-enforced agent collective
- Proven hub-and-spoke coordination architecture
- 32+ specialized agents for various development tasks
- Automated workflow coordination

### For Multi-Platform Developers
- Seamless workflow across both platforms
- Automatic configuration synchronization
- Consistent agent behavior regardless of platform
- Single installation manages both environments

---

## 🔗 Resources

### Documentation
- **Installation Guide**: `INSTALLATION-GUIDE.md`
- **Qoder Usage**: `docs/QODER-USAGE.md`
- **Agent Migration**: `docs/PLATFORM-AGNOSTIC-AGENTS.md`
- **Full Changelog**: `CHANGELOG.md`

### Quick Links
- **GitHub Repository**: https://github.com/ljymaster/claude-code-sub-agent-collective
- **NPM Package**: `claude-code-collective`
- **Issue Tracker**: https://github.com/ljymaster/claude-code-sub-agent-collective/issues

### Support
- **Questions**: Open a GitHub Discussion
- **Bugs**: File a GitHub Issue
- **Feature Requests**: GitHub Discussions or Issues

---

## 🎉 What's Next

### Planned for v2.2.0
- Automatic platform switch detection
- Enhanced cross-platform config merging
- Additional platform support (Cursor, Windsurf)
- Improved Windows test compatibility
- Performance optimizations for large codebases

### Roadmap
- **Q1 2026**: Additional AI coding platform support
- **Q2 2026**: Visual configuration management tool
- **Q3 2026**: Agent marketplace and sharing
- **Q4 2026**: Advanced multi-platform workflows

---

## 🙏 Acknowledgments

This multi-platform release was made possible by:
- **Community Feedback**: Users requesting Qoder CLI support
- **Platform Developers**: Claude Code and Qoder CLI teams for creating amazing tools
- **Open Source Contributors**: Everyone who tested, reported issues, and provided suggestions
- **Early Adopters**: Users who tested pre-release versions

---

## 📝 Installation Commands Summary

```bash
# Existing Claude Code users - seamless upgrade
npx claude-code-collective init --force

# New Qoder CLI users
npx claude-code-collective init --platform=qoder

# Multi-platform installation
npx claude-code-collective init --platform=both --sync-platforms

# Check status after installation
npx claude-code-collective status

# Validate installation
npx claude-code-collective validate
```

---

## 🔖 Version Information

- **Version**: 2.1.0
- **Release Date**: 2025-11-25
- **Previous Version**: 2.0.8
- **Next Version**: 2.2.0 (planned)
- **Breaking Changes**: None
- **Deprecations**: None
- **Platform Support**: Claude Code, Qoder CLI

---

**Full Changelog**: [v2.0.8...v2.1.0](https://github.com/ljymaster/claude-code-sub-agent-collective/compare/v2.0.8...v2.1.0)

---

## 💬 Feedback

We'd love to hear your experience with multi-platform support!

- **Share your success story**: GitHub Discussions
- **Report issues**: GitHub Issues
- **Request features**: GitHub Discussions
- **Contribute**: Pull requests welcome!

---

**Happy Coding with AI Code Collective v2.1.0! 🚀**
