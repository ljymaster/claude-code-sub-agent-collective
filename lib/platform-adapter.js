const fs = require('fs-extra');
const path = require('path');

class PlatformAdapter {
  constructor(options = {}) {
    this.forcePlatform = options.platform;
    this.detectedPlatform = this.detectPlatform();
    this.currentPlatform = this.forcePlatform || this.detectedPlatform;
  }

  detectPlatform() {
    if (process.env.QODER_CLI_VERSION || process.env.QODER_PROJECT_DIR) {
      return 'qoder';
    }
    
    if (process.env.CLAUDE_CODE_VERSION || process.env.CLAUDE_PROJECT_DIR) {
      return 'claude';
    }
    
    return 'claude';
  }

  getPlatform() {
    return this.currentPlatform;
  }

  isQoder() {
    return this.currentPlatform === 'qoder';
  }

  isClaude() {
    return this.currentPlatform === 'claude';
  }

  getConfigDirectory() {
    return this.isQoder() ? '.qoder' : '.claude';
  }

  getProjectDirEnvVar() {
    return this.isQoder() ? 'QODER_PROJECT_DIR' : 'CLAUDE_PROJECT_DIR';
  }

  getProjectDir() {
    const envVar = this.getProjectDirEnvVar();
    return process.env[envVar] || process.cwd();
  }

  getSettingsFileName() {
    return 'settings.json';
  }

  getSettingsPath(projectRoot) {
    return path.join(projectRoot, this.getConfigDirectory(), this.getSettingsFileName());
  }

  getHooksDirectory(projectRoot) {
    return path.join(projectRoot, this.getConfigDirectory(), 'hooks');
  }

  getAgentsDirectory(projectRoot) {
    return path.join(projectRoot, this.getConfigDirectory(), 'agents');
  }

  getCommandsDirectory(projectRoot) {
    return path.join(projectRoot, this.getConfigDirectory(), 'commands');
  }

  getPlatformSpecificEnvVars() {
    if (this.isQoder()) {
      return {
        PROJECT_DIR: process.env.QODER_PROJECT_DIR || process.cwd(),
        CLI_VERSION: process.env.QODER_CLI_VERSION || 'unknown',
        CONFIG_DIR: '.qoder'
      };
    } else {
      return {
        PROJECT_DIR: process.env.CLAUDE_PROJECT_DIR || process.cwd(),
        CLI_VERSION: process.env.CLAUDE_CODE_VERSION || 'unknown',
        CONFIG_DIR: '.claude'
      };
    }
  }

  async getPlatformInfo() {
    const envVars = this.getPlatformSpecificEnvVars();
    
    return {
      platform: this.currentPlatform,
      detected: this.detectedPlatform,
      forced: !!this.forcePlatform,
      configDir: this.getConfigDirectory(),
      projectDir: envVars.PROJECT_DIR,
      version: envVars.CLI_VERSION,
      envVarName: this.getProjectDirEnvVar()
    };
  }

  getToolMapping() {
    const commonTools = {
      READ: 'Read',
      WRITE: 'Write',
      EDIT: 'Edit',
      BASH: 'Bash',
      GLOB: 'Glob',
      GREP: 'Grep',
      TASK: 'Task'
    };

    if (this.isQoder()) {
      return {
        ...commonTools,
        WEB_FETCH: 'WebFetch',
        WEB_SEARCH: 'WebSearch'
      };
    } else {
      return {
        ...commonTools,
        WEB_FETCH: 'WebFetch',
        WEB_SEARCH: 'WebSearch'
      };
    }
  }

  getHookEventMapping() {
    if (this.isQoder()) {
      return {
        SESSION_START: 'SessionStart',
        PRE_TOOL_USE: 'PreToolUse',
        POST_TOOL_USE: 'PostToolUse',
        SUBAGENT_STOP: 'SubagentStop',
        USER_PROMPT_SUBMIT: 'UserPromptSubmit'
      };
    } else {
      return {
        SESSION_START: 'SessionStart',
        PRE_TOOL_USE: 'PreToolUse',
        POST_TOOL_USE: 'PostToolUse',
        SUBAGENT_STOP: 'SubagentStop',
        USER_PROMPT_SUBMIT: 'UserPromptSubmit'
      };
    }
  }

  async checkPlatformCompatibility(projectRoot) {
    const issues = [];
    const warnings = [];

    const claudeDir = path.join(projectRoot, '.claude');
    const qoderDir = path.join(projectRoot, '.qoder');

    const hasClaude = await fs.pathExists(claudeDir);
    const hasQoder = await fs.pathExists(qoderDir);

    if (this.isClaude() && !hasClaude) {
      warnings.push('Running on Claude Code but .claude directory not found');
    }

    if (this.isQoder() && !hasQoder) {
      warnings.push('Running on Qoder CLI but .qoder directory not found');
    }

    if (hasClaude && hasQoder) {
      warnings.push('Both .claude and .qoder directories exist - using: ' + this.getConfigDirectory());
    }

    const envVar = this.getProjectDirEnvVar();
    if (!process.env[envVar]) {
      warnings.push(`Environment variable ${envVar} not set, using current directory`);
    }

    return {
      compatible: issues.length === 0,
      issues,
      warnings,
      hasClaude,
      hasQoder,
      currentPlatform: this.currentPlatform
    };
  }

  resolveTemplatePath(basePath, templateType) {
    const platformSpecific = path.join(
      basePath,
      `${templateType}.${this.currentPlatform}.template`
    );
    
    const defaultTemplate = path.join(basePath, `${templateType}.template`);

    if (fs.existsSync(platformSpecific)) {
      return platformSpecific;
    }

    return defaultTemplate;
  }

  processTemplateVariables(content, additionalVars = {}) {
    const platformVars = {
      PLATFORM: this.currentPlatform,
      CONFIG_DIR: this.getConfigDirectory(),
      PROJECT_DIR_VAR: this.getProjectDirEnvVar(),
      IS_QODER: this.isQoder() ? 'true' : 'false',
      IS_CLAUDE: this.isClaude() ? 'true' : 'false',
      ...this.getPlatformSpecificEnvVars(),
      ...additionalVars
    };

    let processed = content;

    Object.keys(platformVars).forEach(key => {
      const regex = new RegExp(`{{${key}}}`, 'g');
      processed = processed.replace(regex, platformVars[key]);
    });

    return processed;
  }

  getShellScriptPrefix() {
    if (this.isQoder()) {
      return `#!/usr/bin/env bash
# Qoder CLI Hook Script
# Platform: Qoder CLI
# Generated by claude-code-collective

# Detect project directory
if [ -n "$QODER_PROJECT_DIR" ]; then
  PROJECT_DIR="$QODER_PROJECT_DIR"
elif [ -n "$CLAUDE_PROJECT_DIR" ]; then
  PROJECT_DIR="$CLAUDE_PROJECT_DIR"
else
  PROJECT_DIR="$(pwd)"
fi

CONFIG_DIR=".qoder"
`;
    } else {
      return `#!/usr/bin/env bash
# Claude Code Hook Script
# Platform: Claude Code
# Generated by claude-code-collective

# Detect project directory
if [ -n "$CLAUDE_PROJECT_DIR" ]; then
  PROJECT_DIR="$CLAUDE_PROJECT_DIR"
elif [ -n "$QODER_PROJECT_DIR" ]; then
  PROJECT_DIR="$QODER_PROJECT_DIR"
else
  PROJECT_DIR="$(pwd)"
fi

CONFIG_DIR=".claude"
`;
    }
  }

  async createPlatformSpecificDirectories(projectRoot) {
    const baseDir = path.join(projectRoot, this.getConfigDirectory());
    
    const directories = [
      baseDir,
      path.join(baseDir, 'agents'),
      path.join(baseDir, 'hooks'),
      path.join(baseDir, 'commands'),
      path.join(baseDir, 'commands', 'tm'),
      path.join(projectRoot, '.claude-collective'),
      path.join(projectRoot, '.claude-collective', 'tests'),
      path.join(projectRoot, '.claude-collective', 'metrics')
    ];

    for (const dir of directories) {
      await fs.ensureDir(dir);
    }

    return directories;
  }

  getSupportedPlatforms() {
    return ['claude', 'qoder'];
  }

  validatePlatform(platform) {
    return this.getSupportedPlatforms().includes(platform);
  }
}

module.exports = { PlatformAdapter };
