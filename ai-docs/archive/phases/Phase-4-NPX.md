# Phase 4: NPX Package Implementation

## 🎯 Phase Objective

Create a distributable NPX package that enables single-command installation of the claude-code-sub-agent-collective, making it accessible to the community with zero friction onboarding.

## 📋 Prerequisites Checklist

- [ ] MVP phases (1-3) completed and validated
- [ ] Node.js and npm installed
- [ ] npm account created (for publishing)
- [ ] Understanding of npm package structure
- [ ] Git repository for version control

## 🚀 Implementation Steps

### Step 1: Create Package Structure

```bash
# Create package directory structure
mkdir -p claude-code-sub-agent-collective
cd claude-code-sub-agent-collective

# Create required directories
mkdir -p bin lib templates hooks tests docs

# Initialize package
npm init -y
```

Directory structure:
```
claude-code-sub-agent-collective/
├── bin/                    # CLI executables
│   └── collective.js       # Main CLI entry
├── lib/                    # Core libraries
│   ├── init-collective.js # Installation logic
│   ├── update.js          # Update mechanism
│   ├── rollback.js        # Rollback system
│   ├── command-parser.js  # Command handling
│   └── utils/             # Utility functions
├── templates/             # Template files
│   ├── CLAUDE.md          # Behavioral template
│   ├── agents/            # Agent templates
│   ├── hooks/             # Hook templates
│   └── tests/             # Test templates
├── hooks/                 # Default hooks
├── tests/                 # Package tests
└── docs/                  # Documentation
```

### Step 2: Configure package.json

Create comprehensive `package.json`:

```json
{
  "name": "claude-code-sub-agent-collective",
  "version": "1.0.0",
  "description": "Research framework for reliable multi-agent coordination using hub-and-spoke architecture with Context Engineering",
  "keywords": [
    "claude-code",
    "multi-agent",
    "coordination",
    "hub-and-spoke",
    "context-engineering",
    "test-driven-handoffs",
    "ai-agents",
    "orchestration"
  ],
  "homepage": "https://github.com/yourusername/claude-code-sub-agent-collective",
  "bugs": {
    "url": "https://github.com/yourusername/claude-code-sub-agent-collective/issues"
  },
  "repository": {
    "type": "git",
    "url": "git+https://github.com/yourusername/claude-code-sub-agent-collective.git"
  },
  "license": "MIT",
  "author": "Your Name",
  "main": "lib/index.js",
  "bin": {
    "claude-collective": "./bin/collective.js",
    "cc-collective": "./bin/collective.js"
  },
  "scripts": {
    "test": "jest",
    "test:coverage": "jest --coverage",
    "lint": "eslint .",
    "format": "prettier --write .",
    "prepublishOnly": "npm test && npm run lint",
    "version": "npm run format && git add -A src",
    "postversion": "git push && git push --tags",
    "update:check": "node lib/update.js --check",
    "update:run": "node lib/update.js --run",
    "rollback": "node lib/rollback.js"
  },
  "dependencies": {
    "chalk": "^5.3.0",
    "commander": "^11.1.0",
    "fs-extra": "^11.2.0",
    "inquirer": "^9.2.12",
    "ora": "^7.0.1",
    "semver": "^7.5.4",
    "update-notifier": "^6.0.2"
  },
  "devDependencies": {
    "eslint": "^8.55.0",
    "jest": "^29.7.0",
    "prettier": "^3.1.1"
  },
  "engines": {
    "node": ">=16.0.0",
    "npm": ">=8.0.0"
  },
  "files": [
    "bin/",
    "lib/",
    "templates/",
    "hooks/",
    "docs/README.md"
  ]
}
```

### Step 3: Create CLI Entry Point

Create `bin/collective.js`:

```javascript
#!/usr/bin/env node

const { program } = require('commander');
const chalk = require('chalk');
const { version } = require('../package.json');
const { initCollective } = require('../lib/init-collective');
const { updateCollective } = require('../lib/update');
const { rollbackCollective } = require('../lib/rollback');
const { runCommand } = require('../lib/command-parser');

// ASCII art banner
const banner = `
╔═══════════════════════════════════════════════════════╗
║   Claude Code Sub-Agent Collective                    ║
║   Hub-and-Spoke Coordination Framework                ║
║   Version ${version}                                         ║
╚═══════════════════════════════════════════════════════╝
`;

console.log(chalk.cyan(banner));

// Configure CLI
program
  .name('claude-collective')
  .description('Research framework for reliable multi-agent coordination')
  .version(version);

// Init command
program
  .command('init')
  .description('Initialize collective in current directory')
  .option('-f, --force', 'Overwrite existing installation')
  .option('-s, --skip-tests', 'Skip test installation')
  .option('-m, --minimal', 'Minimal installation (MVP only)')
  .option('-r, --research', 'Include research metrics')
  .action(async (options) => {
    try {
      await initCollective(options);
      console.log(chalk.green('✅ Collective initialized successfully!'));
      console.log(chalk.yellow('\nNext steps:'));
      console.log('1. Review CLAUDE.md for behavioral directives');
      console.log('2. Test with: @routing-agent "your request"');
      console.log('3. Check metrics: npm run metrics');
    } catch (error) {
      console.error(chalk.red('❌ Initialization failed:'), error.message);
      process.exit(1);
    }
  });

// Update command
program
  .command('update')
  .description('Update collective to latest version')
  .option('-c, --check', 'Check for updates only')
  .option('-f, --force', 'Force update even if current')
  .action(async (options) => {
    try {
      const result = await updateCollective(options);
      if (result.updated) {
        console.log(chalk.green(`✅ Updated to version ${result.version}`));
      } else {
        console.log(chalk.blue('ℹ️ Already on latest version'));
      }
    } catch (error) {
      console.error(chalk.red('❌ Update failed:'), error.message);
      process.exit(1);
    }
  });

// Rollback command
program
  .command('rollback')
  .description('Rollback to previous version')
  .option('-v, --version <version>', 'Specific version to rollback to')
  .action(async (options) => {
    try {
      const result = await rollbackCollective(options);
      console.log(chalk.green(`✅ Rolled back to version ${result.version}`));
    } catch (error) {
      console.error(chalk.red('❌ Rollback failed:'), error.message);
      process.exit(1);
    }
  });

// Status command
program
  .command('status')
  .description('Check collective status')
  .action(async () => {
    const { checkStatus } = require('../lib/status');
    const status = await checkStatus();
    
    console.log(chalk.bold('\n📊 Collective Status:\n'));
    console.log(`Version: ${status.version}`);
    console.log(`Behavioral System: ${status.behavioral ? '✅' : '❌'}`);
    console.log(`Testing Framework: ${status.testing ? '✅' : '❌'}`);
    console.log(`Hooks Active: ${status.hooks ? '✅' : '❌'}`);
    console.log(`Agents Available: ${status.agents.length}`);
    console.log(`Research Metrics: ${status.metrics ? '✅' : '❌'}`);
    
    if (status.issues.length > 0) {
      console.log(chalk.yellow('\n⚠️ Issues detected:'));
      status.issues.forEach(issue => console.log(`  - ${issue}`));
    }
  });

// Validate command
program
  .command('validate')
  .description('Validate collective installation')
  .action(async () => {
    const { validateInstallation } = require('../lib/validate');
    const results = await validateInstallation();
    
    console.log(chalk.bold('\n🧪 Validation Results:\n'));
    results.tests.forEach(test => {
      const icon = test.passed ? '✅' : '❌';
      console.log(`${icon} ${test.name}`);
      if (!test.passed && test.error) {
        console.log(chalk.red(`   Error: ${test.error}`));
      }
    });
    
    const passed = results.tests.filter(t => t.passed).length;
    const total = results.tests.length;
    
    if (passed === total) {
      console.log(chalk.green(`\n✅ All tests passed (${passed}/${total})`));
    } else {
      console.log(chalk.red(`\n❌ Some tests failed (${passed}/${total})`));
      process.exit(1);
    }
  });

// Run command (for testing)
program
  .command('run <command>')
  .description('Run collective command')
  .action(async (command) => {
    try {
      const result = await runCommand(command);
      console.log(result);
    } catch (error) {
      console.error(chalk.red('❌ Command failed:'), error.message);
      process.exit(1);
    }
  });

// Parse arguments
program.parse(process.argv);

// Show help if no command
if (!process.argv.slice(2).length) {
  program.outputHelp();
}
```

### Step 4: Create Installation Logic

Create `lib/init-collective.js`:

```javascript
const fs = require('fs-extra');
const path = require('path');
const inquirer = require('inquirer');
const ora = require('ora');
const chalk = require('chalk');
const { exec } = require('child_process');
const { promisify } = require('util');

const execAsync = promisify(exec);

class CollectiveInstaller {
  constructor(options = {}) {
    this.options = options;
    this.projectDir = process.cwd();
    this.collectiveDir = path.join(this.projectDir, '.claude-collective');
    this.claudeDir = path.join(this.projectDir, '.claude');
  }

  async initCollective() {
    console.log(chalk.bold('🚀 Initializing Claude Code Sub-Agent Collective\n'));

    // Check for existing installation
    if (!this.options.force && await this.checkExisting()) {
      const { overwrite } = await inquirer.prompt([{
        type: 'confirm',
        name: 'overwrite',
        message: 'Collective already installed. Overwrite?',
        default: false
      }]);
      
      if (!overwrite) {
        console.log(chalk.yellow('Installation cancelled'));
        return;
      }
    }

    // Installation steps
    await this.createDirectories();
    await this.copyTemplates();
    await this.installDependencies();
    await this.configureBehavioral();
    await this.setupHooks();
    await this.initializeTests();
    
    if (this.options.research) {
      await this.setupResearch();
    }
    
    await this.createGitIgnore();
    await this.validateInstallation();
    
    return {
      success: true,
      path: this.collectiveDir
    };
  }

  async checkExisting() {
    return await fs.pathExists(this.collectiveDir);
  }

  async createDirectories() {
    const spinner = ora('Creating collective structure...').start();
    
    const dirs = [
      '.claude-collective',
      '.claude-collective/tests/handoffs/templates',
      '.claude-collective/tests/directives',
      '.claude-collective/tests/research',
      '.claude-collective/tests/contracts',
      '.claude-collective/metrics',
      '.claude-collective/agents',
      '.claude/hooks',
      '.claude/agents',
      '.claude/commands'
    ];
    
    for (const dir of dirs) {
      await fs.ensureDir(path.join(this.projectDir, dir));
    }
    
    spinner.succeed('Collective structure created');
  }

  async copyTemplates() {
    const spinner = ora('Installing templates...').start();
    
    const templateDir = path.join(__dirname, '..', 'templates');
    
    // Copy CLAUDE.md
    await fs.copy(
      path.join(templateDir, 'CLAUDE.md'),
      path.join(this.projectDir, 'CLAUDE.md')
    );
    
    // Copy agents
    await fs.copy(
      path.join(templateDir, 'agents'),
      path.join(this.claudeDir, 'agents')
    );
    
    // Copy hooks
    await fs.copy(
      path.join(templateDir, 'hooks'),
      path.join(this.claudeDir, 'hooks')
    );
    
    // Copy tests
    await fs.copy(
      path.join(templateDir, 'tests'),
      path.join(this.collectiveDir, 'tests')
    );
    
    // Make hooks executable
    const hooksDir = path.join(this.claudeDir, 'hooks');
    const hooks = await fs.readdir(hooksDir);
    for (const hook of hooks) {
      if (hook.endsWith('.sh')) {
        await fs.chmod(path.join(hooksDir, hook), '755');
      }
    }
    
    spinner.succeed('Templates installed');
  }

  async installDependencies() {
    if (this.options.skipTests) {
      return;
    }
    
    const spinner = ora('Installing test framework...').start();
    
    // Create package.json in collective directory
    const packageJson = {
      name: 'claude-collective-tests',
      version: '1.0.0',
      private: true,
      scripts: {
        test: 'jest',
        'test:handoffs': 'jest --testPathPattern=handoffs',
        'test:directives': 'jest --testPathPattern=directives',
        'test:watch': 'jest --watch',
        'test:coverage': 'jest --coverage',
        'metrics': 'node lib/metrics.js',
        'report': 'node lib/report.js'
      },
      devDependencies: {
        jest: '^29.7.0',
        '@types/jest': '^29.5.10'
      }
    };
    
    await fs.writeJson(
      path.join(this.collectiveDir, 'package.json'),
      packageJson,
      { spaces: 2 }
    );
    
    // Install dependencies
    try {
      await execAsync('npm install', { cwd: this.collectiveDir });
      spinner.succeed('Test framework installed');
    } catch (error) {
      spinner.warn('Test framework installation failed (optional)');
    }
  }

  async configureBehavioral() {
    const spinner = ora('Configuring behavioral system...').start();
    
    // Update CLAUDE.md with project-specific information
    const claudeMdPath = path.join(this.projectDir, 'CLAUDE.md');
    let content = await fs.readFile(claudeMdPath, 'utf8');
    
    // Add timestamp and version
    content = content.replace(
      '{{INSTALLATION_DATE}}',
      new Date().toISOString()
    );
    content = content.replace(
      '{{VERSION}}',
      require('../package.json').version
    );
    
    await fs.writeFile(claudeMdPath, content);
    
    spinner.succeed('Behavioral system configured');
  }

  async setupHooks() {
    const spinner = ora('Setting up hooks...').start();
    
    // Create settings.json
    const settings = {
      hooks: {
        PreToolUse: [
          {
            matcher: '*',
            hooks: [{
              type: 'command',
              command: '$CLAUDE_PROJECT_DIR/.claude/hooks/directive-enforcer.sh'
            }]
          }
        ],
        PostToolUse: [
          {
            matcher: 'Task',
            hooks: [{
              type: 'command',
              command: '$CLAUDE_PROJECT_DIR/.claude/hooks/test-driven-handoff.sh'
            }]
          },
          {
            matcher: '*',
            hooks: [{
              type: 'command',
              command: '$CLAUDE_PROJECT_DIR/.claude/hooks/collective-metrics.sh'
            }]
          }
        ],
        SubagentStop: [
          {
            matcher: '*',
            hooks: [{
              type: 'command',
              command: '$CLAUDE_PROJECT_DIR/.claude/hooks/test-driven-handoff.sh'
            }]
          }
        ]
      }
    };
    
    await fs.writeJson(
      path.join(this.claudeDir, 'settings.json'),
      settings,
      { spaces: 2 }
    );
    
    spinner.succeed('Hooks configured');
  }

  async initializeTests() {
    const spinner = ora('Initializing test system...').start();
    
    // Create jest.config.js
    const jestConfig = `module.exports = {
  testEnvironment: 'node',
  roots: ['<rootDir>/tests'],
  testMatch: ['**/?(*.)+(spec|test).js'],
  collectCoverageFrom: ['tests/**/*.js'],
  coverageDirectory: 'coverage',
  verbose: true,
  testTimeout: 10000
};`;
    
    await fs.writeFile(
      path.join(this.collectiveDir, 'jest.config.js'),
      jestConfig
    );
    
    spinner.succeed('Test system initialized');
  }

  async setupResearch() {
    const spinner = ora('Setting up research metrics...').start();
    
    // Create research configuration
    const researchConfig = {
      hypotheses: {
        h1_jitLoading: {
          name: 'JIT Context Loading',
          metrics: ['contextSize', 'tokenReduction', 'loadTime'],
          baseline: null,
          target: { tokenReduction: 0.3 }
        },
        h2_hubSpoke: {
          name: 'Hub-and-Spoke Coordination',
          metrics: ['routingCompliance', 'coordinationSuccess', 'p2pViolations'],
          baseline: null,
          target: { routingCompliance: 0.9 }
        },
        h3_tddHandoff: {
          name: 'Test-Driven Handoffs',
          metrics: ['handoffSuccess', 'testPassRate', 'retryCount'],
          baseline: null,
          target: { handoffSuccess: 0.8 }
        }
      },
      collection: {
        automatic: true,
        interval: 'per-handoff',
        storage: 'local'
      }
    };
    
    await fs.writeJson(
      path.join(this.collectiveDir, 'research.config.json'),
      researchConfig,
      { spaces: 2 }
    );
    
    spinner.succeed('Research metrics configured');
  }

  async createGitIgnore() {
    const gitignorePath = path.join(this.projectDir, '.gitignore');
    const additions = [
      '',
      '# Claude Collective',
      '.claude-collective/metrics/',
      '.claude-collective/coverage/',
      '.claude-collective/node_modules/',
      '/tmp/collective*.log',
      '/tmp/handoff*.json'
    ];
    
    let content = '';
    if (await fs.pathExists(gitignorePath)) {
      content = await fs.readFile(gitignorePath, 'utf8');
    }
    
    if (!content.includes('Claude Collective')) {
      content += '\n' + additions.join('\n');
      await fs.writeFile(gitignorePath, content);
    }
  }

  async validateInstallation() {
    const spinner = ora('Validating installation...').start();
    
    const checks = [
      { name: 'CLAUDE.md exists', path: 'CLAUDE.md' },
      { name: 'Hooks directory', path: '.claude/hooks' },
      { name: 'Tests directory', path: '.claude-collective/tests' },
      { name: 'Settings configured', path: '.claude/settings.json' }
    ];
    
    let allPassed = true;
    for (const check of checks) {
      if (!await fs.pathExists(path.join(this.projectDir, check.path))) {
        spinner.fail(`Missing: ${check.name}`);
        allPassed = false;
      }
    }
    
    if (allPassed) {
      spinner.succeed('Installation validated');
    } else {
      throw new Error('Installation validation failed');
    }
  }
}

module.exports = {
  initCollective: async (options) => {
    const installer = new CollectiveInstaller(options);
    return await installer.initCollective();
  }
};
```

### Step 5: Create Update Mechanism

Create `lib/update.js`:

```javascript
const fs = require('fs-extra');
const path = require('path');
const semver = require('semver');
const ora = require('ora');
const chalk = require('chalk');
const { exec } = require('child_process');
const { promisify } = require('util');

const execAsync = promisify(exec);

class CollectiveUpdater {
  constructor(options = {}) {
    this.options = options;
    this.projectDir = process.cwd();
    this.backupDir = path.join(this.projectDir, '.collective-backup');
  }

  async updateCollective() {
    const spinner = ora('Checking for updates...').start();
    
    // Get current version
    const currentVersion = await this.getCurrentVersion();
    
    // Check for latest version
    const latestVersion = await this.getLatestVersion();
    
    if (!this.options.force && semver.gte(currentVersion, latestVersion)) {
      spinner.info('Already on latest version');
      return { updated: false, version: currentVersion };
    }
    
    spinner.text = `Updating from ${currentVersion} to ${latestVersion}...`;
    
    // Create backup
    await this.createBackup();
    
    try {
      // Download and install update
      await this.downloadUpdate(latestVersion);
      await this.applyUpdate();
      await this.runMigrations(currentVersion, latestVersion);
      
      spinner.succeed(`Updated to version ${latestVersion}`);
      
      // Clean up backup after successful update
      await this.cleanupBackup();
      
      return { updated: true, version: latestVersion };
    } catch (error) {
      spinner.fail('Update failed, rolling back...');
      await this.rollback();
      throw error;
    }
  }

  async getCurrentVersion() {
    const packagePath = path.join(this.projectDir, '.claude-collective', 'version.json');
    if (await fs.pathExists(packagePath)) {
      const { version } = await fs.readJson(packagePath);
      return version;
    }
    return '0.0.0';
  }

  async getLatestVersion() {
    try {
      const { stdout } = await execAsync('npm view claude-code-sub-agent-collective version');
      return stdout.trim();
    } catch (error) {
      throw new Error('Failed to check latest version');
    }
  }

  async createBackup() {
    const spinner = ora('Creating backup...').start();
    
    await fs.ensureDir(this.backupDir);
    
    // Backup critical files
    const filesToBackup = [
      'CLAUDE.md',
      '.claude',
      '.claude-collective'
    ];
    
    for (const file of filesToBackup) {
      const source = path.join(this.projectDir, file);
      const dest = path.join(this.backupDir, file);
      
      if (await fs.pathExists(source)) {
        await fs.copy(source, dest);
      }
    }
    
    // Save backup metadata
    await fs.writeJson(
      path.join(this.backupDir, 'backup.json'),
      {
        version: await this.getCurrentVersion(),
        date: new Date().toISOString(),
        files: filesToBackup
      },
      { spaces: 2 }
    );
    
    spinner.succeed('Backup created');
  }

  async downloadUpdate(version) {
    const spinner = ora(`Downloading version ${version}...`).start();
    
    // Create temp directory for update
    const tempDir = path.join(this.projectDir, '.collective-update-temp');
    await fs.ensureDir(tempDir);
    
    try {
      // Download package
      await execAsync(
        `npm pack claude-code-sub-agent-collective@${version}`,
        { cwd: tempDir }
      );
      
      // Extract package
      const tarball = `claude-code-sub-agent-collective-${version}.tgz`;
      await execAsync(
        `tar -xzf ${tarball}`,
        { cwd: tempDir }
      );
      
      spinner.succeed('Update downloaded');
      
      return path.join(tempDir, 'package');
    } catch (error) {
      await fs.remove(tempDir);
      throw new Error('Failed to download update');
    }
  }

  async applyUpdate() {
    const spinner = ora('Applying update...').start();
    
    const updateSource = path.join(this.projectDir, '.collective-update-temp', 'package');
    
    // Update templates
    await fs.copy(
      path.join(updateSource, 'templates'),
      path.join(this.projectDir, '.claude-collective', 'templates'),
      { overwrite: true }
    );
    
    // Update hooks (preserve custom hooks)
    const defaultHooks = await fs.readdir(path.join(updateSource, 'hooks'));
    for (const hook of defaultHooks) {
      const hookPath = path.join(this.projectDir, '.claude', 'hooks', hook);
      if (!await fs.pathExists(hookPath) || hook.startsWith('default-')) {
        await fs.copy(
          path.join(updateSource, 'hooks', hook),
          hookPath
        );
      }
    }
    
    // Update version
    await fs.writeJson(
      path.join(this.projectDir, '.claude-collective', 'version.json'),
      { version: require(path.join(updateSource, 'package.json')).version },
      { spaces: 2 }
    );
    
    // Clean up temp directory
    await fs.remove(path.join(this.projectDir, '.collective-update-temp'));
    
    spinner.succeed('Update applied');
  }

  async runMigrations(fromVersion, toVersion) {
    const spinner = ora('Running migrations...').start();
    
    // Define migrations
    const migrations = [
      {
        version: '1.1.0',
        run: async () => {
          // Migration for 1.1.0
          // Update hook configuration format
        }
      },
      {
        version: '1.2.0',
        run: async () => {
          // Migration for 1.2.0
          // Add new research metrics
        }
      }
    ];
    
    // Run applicable migrations
    for (const migration of migrations) {
      if (semver.gt(migration.version, fromVersion) && 
          semver.lte(migration.version, toVersion)) {
        await migration.run();
      }
    }
    
    spinner.succeed('Migrations completed');
  }

  async rollback() {
    const spinner = ora('Rolling back...').start();
    
    if (!await fs.pathExists(this.backupDir)) {
      throw new Error('No backup found');
    }
    
    // Restore backed up files
    const { files } = await fs.readJson(path.join(this.backupDir, 'backup.json'));
    
    for (const file of files) {
      const source = path.join(this.backupDir, file);
      const dest = path.join(this.projectDir, file);
      
      if (await fs.pathExists(source)) {
        await fs.copy(source, dest, { overwrite: true });
      }
    }
    
    spinner.succeed('Rolled back successfully');
  }

  async cleanupBackup() {
    await fs.remove(this.backupDir);
  }
}

module.exports = {
  updateCollective: async (options) => {
    const updater = new CollectiveUpdater(options);
    
    if (options.check) {
      const current = await updater.getCurrentVersion();
      const latest = await updater.getLatestVersion();
      
      if (semver.gt(latest, current)) {
        console.log(chalk.yellow(`Update available: ${current} → ${latest}`));
        console.log('Run: npx claude-collective update');
      } else {
        console.log(chalk.green('You are on the latest version'));
      }
      
      return { updated: false, version: current, latest };
    }
    
    return await updater.updateCollective();
  }
};
```

### Step 6: Create Templates

Create key template files:

#### templates/CLAUDE.md
(Full behavioral CLAUDE.md from Phase 1)

#### templates/hooks/test-driven-handoff.sh
(Complete hook from Phase 3)

#### templates/tests/handoffs/templates/base-handoff.test.js
(Test contract from Phase 2)

### Step 7: Create NPM Scripts

Add to main project `package.json`:

```json
{
  "scripts": {
    "collective:init": "npx claude-code-sub-agent-collective init",
    "collective:update": "npx claude-code-sub-agent-collective update",
    "collective:status": "npx claude-code-sub-agent-collective status",
    "collective:validate": "npx claude-code-sub-agent-collective validate"
  }
}
```

## ✅ Validation Criteria

### Package Success
- [ ] NPX installation works in <30 seconds
- [ ] All templates copy correctly
- [ ] Dependencies install properly
- [ ] Hooks are executable
- [ ] Update mechanism works

### User Experience
- [ ] Clear installation prompts
- [ ] Helpful error messages
- [ ] Progress indicators work
- [ ] Validation confirms success
- [ ] Documentation is accessible

### Distribution Ready
- [ ] Package.json complete
- [ ] README included
- [ ] LICENSE file present
- [ ] Tests pass
- [ ] Version management works

## 🧪 Acceptance Tests

### Test 1: Fresh Installation
```bash
# In new directory
npx claude-code-sub-agent-collective init

# Expected:
# - Installation completes
# - All files created
# - Validation passes
```

### Test 2: Update Check
```bash
npx claude-collective update --check

# Expected:
# - Shows current version
# - Checks for updates
# - Provides update command if needed
```

### Test 3: Status Check
```bash
npx claude-collective status

# Expected:
# - Shows installation status
# - Lists available agents
# - Reports any issues
```

### Test 4: Validation
```bash
npx claude-collective validate

# Expected:
# - Runs validation tests
# - Reports results
# - Exit code 0 if all pass
```

## 🚨 Troubleshooting

### Issue: NPX not found
**Solution**:
```bash
npm install -g npx
# Or use: npm exec claude-code-sub-agent-collective init
```

### Issue: Permission denied
**Solution**:
```bash
# Use sudo on Unix systems
sudo npx claude-code-sub-agent-collective init

# Or fix npm permissions
npm config set prefix ~/.npm-global
export PATH=~/.npm-global/bin:$PATH
```

### Issue: Installation fails
**Solution**:
1. Check Node.js version: `node --version` (needs >=16)
2. Clear npm cache: `npm cache clean --force`
3. Try minimal installation: `npx claude-collective init --minimal`
4. Check error logs in `/tmp/collective-install.log`

### Issue: Hooks not working
**Solution**:
1. Verify executable: `ls -la .claude/hooks/`
2. Check settings.json syntax
3. Restart Claude Code session
4. Run validation: `npx claude-collective validate`

## 📊 Metrics to Track

### Installation Metrics
- Installation time: <30 seconds target
- Success rate: >95% target
- Error frequency: Track common issues
- User drop-off: Monitor completion

### Usage Metrics
- Update frequency: Track version adoption
- Feature usage: Which commands used
- Error patterns: Common problems
- Support requests: FAQ needs

## 🚀 Publishing to NPM

### Pre-publication Checklist
- [ ] All tests passing
- [ ] Version bumped appropriately
- [ ] CHANGELOG updated
- [ ] README complete
- [ ] LICENSE confirmed
- [ ] Security audit: `npm audit`

### Publication Process
```bash
# Login to npm
npm login

# Run tests
npm test

# Bump version
npm version patch|minor|major

# Publish
npm publish

# Verify
npm view claude-code-sub-agent-collective
```

### Post-publication
- [ ] Test NPX installation
- [ ] Update documentation
- [ ] Announce release
- [ ] Monitor issues
- [ ] Gather feedback

## ✋ Handoff to Phase 5

### Deliverables
- [ ] Complete NPX package structure
- [ ] Installation logic working
- [ ] Update mechanism functional
- [ ] Templates included
- [ ] NPM publication ready

### Ready for Phase 5 When
1. NPX installation successful ✅
2. Update mechanism tested ✅
3. Validation passes ✅
4. Documentation complete ✅

### Phase 5 Preview
Next, we'll implement the command system that provides natural language interaction with the collective through /collective, /agent, and /gate commands.

---

**Phase 4 Duration**: 1 day  
**Critical Success Factor**: Single-command installation  
**Next Phase**: [Phase 5 - Command System](Phase-5-Commands.md)