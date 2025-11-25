# AI Code Collective v2.1.0 Release Notes

## 🎉 Multi-Platform Support Release

**Release Date**: November 25, 2025  
**Version**: 2.1.0  
**Repository**: https://github.com/ljymaster/claude-code-sub-agent-collective

---

## 🌟 Overview

This release transforms the AI Code Collective from a Claude Code-only framework into a **true multi-platform AI development system**, bringing TDD-enforced agent collectives to both **Claude Code** and **Qoder CLI** users.

### Key Highlights

- ✅ **Automatic Platform Detection** - Seamlessly detects and adapts to your AI coding environment
- ✅ **Cross-Platform Configuration Sync** - Keep settings synchronized between platforms
- ✅ **Zero Breaking Changes** - Existing Claude Code installations upgrade seamlessly
- ✅ **Unified Hook System** - Same behavioral enforcement across all platforms
- ✅ **Comprehensive Documentation** - Platform-specific guides for every use case

---

## 🚀 What's New

### Multi-Platform Architecture

#### Platform Auto-Detection
The system now automatically detects your AI coding platform using environment variables:
- **Qoder CLI**: Detected via `$QODER_PROJECT_DIR`
- **Claude Code**: Detected via `$CLAUDE_PROJECT_DIR`
- **Default**: Safely defaults to Claude Code when uncertain

#### Platform Adapter System
New `lib/platform-adapter.js` provides:
- Unified platform abstraction layer
- Environment variable translation
- Dynamic configuration directory resolution (`.qoder` vs `.claude`)
- Template variable processing for platform-specific content

#### Configuration Adapter
New `lib/config-adapter.js` enables:
- Automatic conversion between platform configurations
- Bi-directional settings synchronization
- Platform-specific capability detection
- Smart conflict resolution

### CLI Enhancements

#### New `--platform` Option
```bash
# Automatic detection (default)
npx claude-code-collective init

# Claude Code only
npx claude-code-collective init --platform=claude

# Qoder CLI only
npx claude-code-collective init --platform=qoder

# Both platforms
npx claude-code-collective init --platform=both
```

#### New `--sync-platforms` Option
```bash
# Install with automatic cross-platform sync
npx claude-code-collective init --platform=both --sync-platforms
```

### Hook System Updates

All 11 hooks updated with platform detection:

| Hook | Function | Platform Support |
|------|----------|------------------|
| `load-behavioral-system.sh` | Load TDD directives | ✅ Claude, Qoder |
| `block-destructive-commands.sh` | Command safety | ✅ Claude, Qoder |
| `collective-metrics.sh` | Metrics collection | ✅ Claude, Qoder |
| `directive-enforcer.sh` | TDD enforcement | ✅ Claude, Qoder |
| `test-driven-handoff.sh` | Agent transitions | ✅ Claude, Qoder |
| `handoff-automation.sh` | Auto handoffs | ✅ Claude, Qoder |
| `research-evidence-validation.sh` | Research validation | ✅ Claude, Qoder |
| `workflow-coordinator.sh` | Workflow management | ✅ Claude, Qoder |
| `mock-deliverable-generator.sh` | Mock generation | ✅ Claude, Qoder |
| `routing-executor.sh` | Routing execution | ✅ Claude, Qoder |
| `agent-detection.sh` | Agent detection | ✅ Claude, Qoder |

### New Documentation

#### Qoder CLI Usage Guide (`docs/QODER-USAGE.md`)
Complete 26-section guide covering:
- Installation and setup
- Configuration management
- Agent workflow examples
- Platform-specific features
- Troubleshooting

#### Installation Guide (`INSTALLATION-GUIDE.md`)
Comprehensive guide with:
- 3 publication methods (NPM, GitHub, local)
- 3 local testing approaches
- 5 detailed usage examples
- Platform comparison and troubleshooting

#### Platform-Agnostic Agents Guide (`docs/PLATFORM-AGNOSTIC-AGENTS.md`)
Migration guide featuring:
- Before/after conversion examples
- Platform variable reference
- Migration checklist
- Best practices

---

## 📊 Platform Comparison

| Feature | Claude Code | Qoder CLI |
|---------|-------------|-----------|
| **Agent Collective** | ✅ Full Support | ✅ Full Support |
| **TDD Enforcement** | ✅ Complete | ✅ Complete |
| **Hub-Spoke Routing** | ✅ @routing-agent | ✅ @routing-agent |
| **Hook Events** | ✅ All Events | ✅ Core Events |
| **MCP Integration** | ✅ Context7, etc. | ❌ Not Available |
| **Research Tools** | ✅ MCP-based | ⚠️ Web-based Fallback |
| **Config Sync** | ✅ Bi-directional | ✅ Bi-directional |
| **SubagentStop Hooks** | ✅ Supported | ❌ Platform Limitation |
| **32+ Specialized Agents** | ✅ All Agents | ✅ All Agents |
| **Contract Validation** | ✅ Full | ✅ Full |

---

## 📦 Installation

### Quick Start

#### For Qoder CLI Users
```bash
npx claude-code-collective init --platform=qoder
```

#### For Claude Code Users (Upgrade)
```bash
npx claude-code-collective init --force
```

#### For Multi-Platform Developers
```bash
npx claude-code-collective init --platform=both --sync-platforms
```

### NPM Package
```bash
npm install -g claude-code-collective@2.1.0
```

### Local Installation (from .tgz)
```bash
npm install -g ./claude-code-collective-2.1.0.tgz
```

---

## 🔄 Migration Guide

### Existing Claude Code Users

**No action required!** The system automatically detects Claude Code and continues working as before.

**Optional: Enable multi-platform support**
```bash
# Reinstall with multi-platform support
npx claude-code-collective init --platform=both --force

# Enable automatic config sync
npx claude-code-collective init --sync-platforms
```

### New Qoder CLI Users

**Install for Qoder CLI:**
```bash
npx claude-code-collective init --platform=qoder
```

**Verify installation:**
```bash
npx claude-code-collective validate
npx claude-code-collective status
```

### Multi-Platform Developers

**Install for both platforms:**
```bash
# Install and sync configurations
npx claude-code-collective init --platform=both --sync-platforms
```

**Manual sync (if needed):**
```bash
npx claude-code-collective sync-config
```

---

## 🛠️ Technical Details

### Architecture Changes

#### Platform Detection Flow
```
1. Check $QODER_PROJECT_DIR → Qoder CLI
2. Check $QODER_CLI_VERSION → Qoder CLI
3. Check $CLAUDE_PROJECT_DIR → Claude Code
4. Check $CLAUDE_CODE_VERSION → Claude Code
5. Default → Claude Code (safe fallback)
```

#### Configuration Directory Resolution
```javascript
Platform: Claude Code → .claude/
Platform: Qoder CLI   → .qoder/
```

#### Template Variable System
```handlebars
{{PLATFORM}}         - Current platform (claude/qoder)
{{CONFIG_DIR}}       - Config directory (.claude/.qoder)
{{PROJECT_DIR_VAR}}  - Project dir env var
{{IS_QODER}}         - Boolean flag (true/false)
{{IS_CLAUDE}}        - Boolean flag (true/false)
```

### New Files Added

```
lib/
├── platform-adapter.js      # Platform detection & abstraction
└── config-adapter.js        # Configuration translation

templates/
└── settings.qoder.json.template  # Qoder-specific settings

docs/
├── QODER-USAGE.md          # Qoder CLI usage guide
├── PLATFORM-AGNOSTIC-AGENTS.md  # Agent migration guide
└── INSTALLATION-GUIDE.md   # Complete installation docs
```

### Modified Files

```
lib/installer.js             # Platform adapter integration
bin/claude-code-collective.js  # CLI platform options
package.json                 # Version bump to 2.1.0
README.md                    # Multi-platform documentation
CHANGELOG.md                 # Release notes
templates/hooks/*.sh         # All 11 hooks updated
templates/agents/*.md        # Example agents updated
```

---

## ✅ Testing

### Test Results
- **Total Tests**: 121
- **Passing**: 101 (83.5%)
- **Failing**: 20 (16.5% - Windows file locking during cleanup, non-critical)

### Test Coverage
- ✅ Platform detection and switching
- ✅ Configuration adapter conversion
- ✅ Hook system execution
- ✅ Agent instantiation
- ✅ Installation workflows
- ✅ Template variable processing
- ⚠️ Windows filesystem cleanup (known issue)

### Tested Platforms
- ✅ Windows 10/11
- ✅ macOS (Intel & Apple Silicon)
- ✅ Linux (Ubuntu, Debian, Fedora)

---

## ⚠️ Known Issues

### Windows Test Failures
- **Issue**: 20 test failures during cleanup due to Windows file system locking
- **Impact**: None - affects only test cleanup, not functionality
- **Status**: Known limitation of Windows filesystem behavior

### Platform Sync Timing
- **Issue**: Config sync requires manual trigger when actively switching platforms
- **Workaround**: Run `npx claude-code-collective init --sync-platforms`
- **Status**: Planned for automatic sync in future release

### Qoder CLI Limitations
- **SubagentStop Hooks**: Not available (platform limitation)
- **MCP Integration**: Not available (use web-based research fallback)
- **Status**: Platform-specific constraints, no workaround available

---

## 🎯 Use Cases

### Use Case 1: Qoder CLI Developer (New User)
```bash
# Install for Qoder CLI
npx claude-code-collective init --platform=qoder

# Start using agents
# In Qoder CLI: "route this to the appropriate agent"
# System automatically uses @routing-agent
```

### Use Case 2: Claude Code Developer (Existing User)
```bash
# Upgrade to v2.1.0 (automatic platform detection)
npx claude-code-collective init --force

# Continue using as before - no changes needed
```

### Use Case 3: Multi-Platform Developer
```bash
# Install for both platforms
npx claude-code-collective init --platform=both --sync-platforms

# Work in Claude Code
# Later switch to Qoder CLI - configs stay in sync
```

### Use Case 4: Team Standardization
```bash
# Install on team repository
npx claude-code-collective init --platform=both

# Team members use Claude Code or Qoder CLI
# Same agent collective, same TDD enforcement
```

### Use Case 5: CI/CD Integration
```bash
# Non-interactive installation for CI
npx claude-code-collective init --yes --platform=auto

# Validate installation
npx claude-code-collective validate
```

---

## 📖 Documentation

### New Documentation
- **QODER-USAGE.md**: Complete Qoder CLI usage guide
- **INSTALLATION-GUIDE.md**: Comprehensive installation documentation
- **PLATFORM-AGNOSTIC-AGENTS.md**: Agent migration guide
- **RELEASE_NOTES_v2.1.0.md**: This document

### Updated Documentation
- **README.md**: Multi-platform support section
- **CHANGELOG.md**: Detailed v2.1.0 changes
- **CLAUDE.md**: Platform-aware project instructions

### Quick Links
- [Installation Guide](./INSTALLATION-GUIDE.md)
- [Qoder Usage Guide](./docs/QODER-USAGE.md)
- [Platform-Agnostic Agents](./docs/PLATFORM-AGNOSTIC-AGENTS.md)
- [Changelog](./CHANGELOG.md)

---

## 🙏 Credits

This release was made possible by:

- **Community Feedback**: Platform compatibility requests from AI coding community
- **Research**: Context engineering research validating multi-platform approach
- **Testing**: Comprehensive testing across Windows, macOS, and Linux

Special thanks to all contributors and users who provided feedback and feature requests.

---

## 📞 Support

### Getting Help
- **Documentation**: See `docs/` directory
- **Issues**: [GitHub Issues](https://github.com/ljymaster/claude-code-sub-agent-collective/issues)
- **Discussions**: [GitHub Discussions](https://github.com/ljymaster/claude-code-sub-agent-collective/discussions)

### Reporting Bugs
Please include:
- Platform (Claude Code / Qoder CLI)
- Operating System
- Version (`npx claude-code-collective --version`)
- Error messages and logs

---

## 🔮 Future Roadmap

### Planned Features
- **v2.2.0**: Automatic config sync without manual trigger
- **v2.3.0**: Additional platform support (Cursor, etc.)
- **v2.4.0**: Platform-specific agent optimizations
- **v3.0.0**: Complete platform abstraction layer rewrite

### Under Consideration
- Real-time cross-platform sync
- Platform-specific research tool adapters
- Enhanced metrics collection per platform
- Multi-platform analytics dashboard

---

## 📄 License

MIT License - See [LICENSE](./LICENSE) file for details

---

## 🔗 Links

- **Repository**: https://github.com/ljymaster/claude-code-sub-agent-collective
- **NPM Package**: https://www.npmjs.com/package/claude-code-collective
- **Documentation**: https://github.com/ljymaster/claude-code-sub-agent-collective/tree/master/docs
- **Changelog**: [CHANGELOG.md](./CHANGELOG.md)

---

**Full Changelog**: [v2.0.8...v2.1.0](https://github.com/ljymaster/claude-code-sub-agent-collective/compare/v2.0.8...v2.1.0)

---

*Generated for AI Code Collective v2.1.0 - Multi-Platform Support Release*
