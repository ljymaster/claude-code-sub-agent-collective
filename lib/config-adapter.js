const fs = require('fs-extra');
const path = require('path');
const deepmerge = require('deepmerge');

class ConfigAdapter {
  constructor(platformAdapter) {
    this.platform = platformAdapter;
  }

  createQoderSettings(baseSettings = {}) {
    return {
      deniedTools: baseSettings.deniedTools || [],
      hooks: {
        SessionStart: [
          {
            matcher: "startup",
            hooks: [
              {
                type: "command",
                command: "$QODER_PROJECT_DIR/.qoder/hooks/load-behavioral-system.sh"
              }
            ]
          },
          {
            matcher: "resume",
            hooks: [
              {
                type: "command",
                command: "$QODER_PROJECT_DIR/.qoder/hooks/load-behavioral-system.sh"
              }
            ]
          }
        ],
        PreToolUse: [
          {
            matcher: "Bash",
            hooks: [
              {
                type: "command",
                command: "$QODER_PROJECT_DIR/.qoder/hooks/block-destructive-commands.sh"
              }
            ]
          },
          {
            matcher: "Write|Edit",
            hooks: [
              {
                type: "command",
                command: "$QODER_PROJECT_DIR/.qoder/hooks/directive-enforcer.sh"
              },
              {
                type: "command",
                command: "$QODER_PROJECT_DIR/.qoder/hooks/collective-metrics.sh"
              }
            ]
          }
        ],
        PostToolUse: [
          {
            matcher: "Task",
            hooks: [
              {
                type: "command",
                command: "$QODER_PROJECT_DIR/.qoder/hooks/test-driven-handoff.sh"
              },
              {
                type: "command",
                command: "$QODER_PROJECT_DIR/.qoder/hooks/collective-metrics.sh"
              }
            ]
          }
        ]
      }
    };
  }

  createClaudeSettings(baseSettings = {}) {
    return {
      deniedTools: baseSettings.deniedTools || [
        "mcp__task-master__initialize_project"
      ],
      hooks: {
        SessionStart: [
          {
            matcher: "startup",
            hooks: [
              {
                type: "command",
                command: "$CLAUDE_PROJECT_DIR/.claude/hooks/load-behavioral-system.sh"
              }
            ]
          },
          {
            matcher: "resume",
            hooks: [
              {
                type: "command",
                command: "$CLAUDE_PROJECT_DIR/.claude/hooks/load-behavioral-system.sh"
              }
            ]
          },
          {
            matcher: "clear",
            hooks: [
              {
                type: "command",
                command: "$CLAUDE_PROJECT_DIR/.claude/hooks/load-behavioral-system.sh"
              }
            ]
          }
        ],
        PreToolUse: [
          {
            matcher: "Bash",
            hooks: [
              {
                type: "command",
                command: "$CLAUDE_PROJECT_DIR/.claude/hooks/block-destructive-commands.sh"
              }
            ]
          },
          {
            matcher: "Write|Edit|MultiEdit",
            hooks: [
              {
                type: "command",
                command: "$CLAUDE_PROJECT_DIR/.claude/hooks/directive-enforcer.sh"
              },
              {
                type: "command",
                command: "$CLAUDE_PROJECT_DIR/.claude/hooks/collective-metrics.sh"
              }
            ]
          },
          {
            matcher: ".*",
            hooks: [
              {
                type: "command",
                command: "$CLAUDE_PROJECT_DIR/.claude/hooks/collective-metrics.sh"
              }
            ]
          }
        ],
        PostToolUse: [
          {
            matcher: "Task",
            hooks: [
              {
                type: "command",
                command: "$CLAUDE_PROJECT_DIR/.claude/hooks/test-driven-handoff.sh"
              },
              {
                type: "command",
                command: "$CLAUDE_PROJECT_DIR/.claude/hooks/collective-metrics.sh"
              }
            ]
          },
          {
            matcher: "Write|Edit|MultiEdit",
            hooks: [
              {
                type: "command",
                command: "$CLAUDE_PROJECT_DIR/.claude/hooks/collective-metrics.sh"
              }
            ]
          }
        ],
        SubagentStop: [
          {
            matcher: "mock-.*",
            hooks: [
              {
                type: "command",
                command: "$CLAUDE_PROJECT_DIR/.claude/hooks/mock-deliverable-generator.sh"
              },
              {
                type: "command",
                command: "$CLAUDE_PROJECT_DIR/.claude/hooks/test-driven-handoff.sh"
              },
              {
                type: "command",
                command: "$CLAUDE_PROJECT_DIR/.claude/hooks/collective-metrics.sh"
              }
            ]
          },
          {
            matcher: ".*",
            hooks: [
              {
                type: "command",
                command: "$CLAUDE_PROJECT_DIR/.claude/hooks/test-driven-handoff.sh"
              },
              {
                type: "command",
                command: "$CLAUDE_PROJECT_DIR/.claude/hooks/collective-metrics.sh"
              }
            ]
          }
        ]
      }
    };
  }

  async createPlatformSettings(projectRoot, baseSettings = {}) {
    let settings;
    
    if (this.platform.isQoder()) {
      settings = this.createQoderSettings(baseSettings);
    } else {
      settings = this.createClaudeSettings(baseSettings);
    }

    const settingsPath = this.platform.getSettingsPath(projectRoot);
    await fs.ensureDir(path.dirname(settingsPath));
    await fs.writeJSON(settingsPath, settings, { spaces: 2 });

    return settingsPath;
  }

  async loadSettings(projectRoot) {
    const settingsPath = this.platform.getSettingsPath(projectRoot);
    
    if (await fs.pathExists(settingsPath)) {
      return await fs.readJSON(settingsPath);
    }
    
    return null;
  }

  convertClaudeToQoder(claudeSettings) {
    const qoderSettings = JSON.parse(JSON.stringify(claudeSettings));

    this.replacePathsInObject(qoderSettings, '$CLAUDE_PROJECT_DIR/.claude/', '$QODER_PROJECT_DIR/.qoder/');

    if (qoderSettings.deniedTools) {
      qoderSettings.deniedTools = qoderSettings.deniedTools.filter(
        tool => !tool.startsWith('mcp__')
      );
    }

    if (qoderSettings.hooks && qoderSettings.hooks.SubagentStop) {
      qoderSettings.hooks.SubagentStop = qoderSettings.hooks.SubagentStop.filter(
        hook => hook.matcher !== 'mock-.*'
      );
    }

    return qoderSettings;
  }

  convertQoderToClaude(qoderSettings) {
    const claudeSettings = JSON.parse(JSON.stringify(qoderSettings));

    this.replacePathsInObject(claudeSettings, '$QODER_PROJECT_DIR/.qoder/', '$CLAUDE_PROJECT_DIR/.claude/');

    if (!claudeSettings.deniedTools) {
      claudeSettings.deniedTools = [];
    }
    
    if (!claudeSettings.deniedTools.includes('mcp__task-master__initialize_project')) {
      claudeSettings.deniedTools.push('mcp__task-master__initialize_project');
    }

    if (!claudeSettings.hooks) {
      claudeSettings.hooks = {};
    }

    if (claudeSettings.hooks.SessionStart && claudeSettings.hooks.SessionStart.length > 0) {
      const hasCleanMatcher = claudeSettings.hooks.SessionStart.some(
        hook => hook.matcher === 'clear'
      );
      
      if (!hasCleanMatcher) {
        claudeSettings.hooks.SessionStart.push({
          matcher: "clear",
          hooks: [
            {
              type: "command",
              command: "$CLAUDE_PROJECT_DIR/.claude/hooks/load-behavioral-system.sh"
            }
          ]
        });
      }
    }

    return claudeSettings;
  }

  replacePathsInObject(obj, searchStr, replaceStr) {
    for (const key in obj) {
      if (typeof obj[key] === 'string') {
        obj[key] = obj[key].replace(new RegExp(searchStr.replace(/[.*+?^${}()|[\]\\]/g, '\\$&'), 'g'), replaceStr);
      } else if (typeof obj[key] === 'object' && obj[key] !== null) {
        this.replacePathsInObject(obj[key], searchStr, replaceStr);
      }
    }
  }

  async syncSettingsAcrossPlatforms(projectRoot) {
    const claudePath = path.join(projectRoot, '.claude', 'settings.json');
    const qoderPath = path.join(projectRoot, '.qoder', 'settings.json');

    const hasClaude = await fs.pathExists(claudePath);
    const hasQoder = await fs.pathExists(qoderPath);

    if (!hasClaude && !hasQoder) {
      return { synced: false, reason: 'No settings files found' };
    }

    if (hasClaude && !hasQoder) {
      const claudeSettings = await fs.readJSON(claudePath);
      const qoderSettings = this.convertClaudeToQoder(claudeSettings);
      await fs.ensureDir(path.dirname(qoderPath));
      await fs.writeJSON(qoderPath, qoderSettings, { spaces: 2 });
      return { synced: true, direction: 'claude->qoder' };
    }

    if (!hasClaude && hasQoder) {
      const qoderSettings = await fs.readJSON(qoderPath);
      const claudeSettings = this.convertQoderToClaude(qoderSettings);
      await fs.ensureDir(path.dirname(claudePath));
      await fs.writeJSON(claudePath, claudeSettings, { spaces: 2 });
      return { synced: true, direction: 'qoder->claude' };
    }

    const claudeStats = await fs.stat(claudePath);
    const qoderStats = await fs.stat(qoderPath);

    if (claudeStats.mtime > qoderStats.mtime) {
      const claudeSettings = await fs.readJSON(claudePath);
      const qoderSettings = this.convertClaudeToQoder(claudeSettings);
      await fs.writeJSON(qoderPath, qoderSettings, { spaces: 2 });
      return { synced: true, direction: 'claude->qoder (newer)' };
    } else {
      const qoderSettings = await fs.readJSON(qoderPath);
      const claudeSettings = this.convertQoderToClaude(qoderSettings);
      await fs.writeJSON(claudePath, claudeSettings, { spaces: 2 });
      return { synced: true, direction: 'qoder->claude (newer)' };
    }
  }

  async mergeWithExistingSettings(projectRoot, newSettings) {
    const existingSettings = await this.loadSettings(projectRoot);
    
    if (!existingSettings) {
      return newSettings;
    }

    const arrayMerge = (destinationArray, sourceArray) => {
      const seen = new Set();
      const result = [];
      
      for (const item of [...destinationArray, ...sourceArray]) {
        const key = JSON.stringify(item);
        if (!seen.has(key)) {
          seen.add(key);
          result.push(item);
        }
      }
      
      return result;
    };

    return deepmerge(existingSettings, newSettings, { arrayMerge });
  }

  async validateSettings(projectRoot) {
    const settings = await this.loadSettings(projectRoot);
    
    if (!settings) {
      return { valid: false, errors: ['Settings file not found'] };
    }

    const errors = [];
    const warnings = [];

    if (!settings.hooks) {
      errors.push('Missing hooks configuration');
    } else {
      const requiredHooks = ['SessionStart', 'PreToolUse', 'PostToolUse'];
      
      for (const hookType of requiredHooks) {
        if (!settings.hooks[hookType] || settings.hooks[hookType].length === 0) {
          warnings.push(`No ${hookType} hooks configured`);
        }
      }

      for (const [hookType, hooks] of Object.entries(settings.hooks)) {
        for (const hook of hooks) {
          if (hook.hooks) {
            for (const hookDef of hook.hooks) {
              if (hookDef.type === 'command') {
                const hookPath = hookDef.command.replace(/\$[A-Z_]+\//, '');
                const fullPath = path.join(projectRoot, hookPath);
                
                if (!(await fs.pathExists(fullPath))) {
                  warnings.push(`Hook script not found: ${hookPath}`);
                }
              }
            }
          }
        }
      }
    }

    return {
      valid: errors.length === 0,
      errors,
      warnings,
      settings
    };
  }
}

module.exports = { ConfigAdapter };
