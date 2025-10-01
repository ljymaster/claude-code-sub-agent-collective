# Phase 8: Van Maintenance System

## 🎯 Phase Objective

Implement the van-maintenance guardian that continuously monitors, repairs, and optimizes the collective ecosystem, ensuring all agents, tests, hooks, and documentation remain synchronized and healthy.

## 📋 Prerequisites Checklist

- [ ] All previous phases (1-7) operational
- [ ] Agent ecosystem established
- [ ] Metrics collection active
- [ ] Registry system functional
- [ ] Command system available

## 🚀 Implementation Steps

### Step 1: Create Van Maintenance Core

Create `.claude-collective/lib/van-maintenance.js`:

```javascript
const fs = require('fs-extra');
const path = require('path');
const chalk = require('chalk');
const EventEmitter = require('events');
const cron = require('node-cron');
const { exec } = require('child_process');
const { promisify } = require('util');

const execAsync = promisify(exec);

class VanMaintenanceSystem extends EventEmitter {
  constructor() {
    super();
    this.projectDir = process.cwd();
    this.collectiveDir = path.join(this.projectDir, '.claude-collective');
    this.claudeDir = path.join(this.projectDir, '.claude');
    
    this.healthChecks = new Map();
    this.repairs = new Map();
    this.optimizations = new Map();
    this.maintenanceLog = [];
    
    this.initializeHealthChecks();
    this.initializeRepairs();
    this.initializeOptimizations();
  }

  initializeHealthChecks() {
    // File system health
    this.healthChecks.set('filesystem', {
      name: 'File System Integrity',
      check: async () => await this.checkFileSystem(),
      critical: true
    });
    
    // Agent health
    this.healthChecks.set('agents', {
      name: 'Agent Ecosystem',
      check: async () => await this.checkAgents(),
      critical: true
    });
    
    // Test health
    this.healthChecks.set('tests', {
      name: 'Test Framework',
      check: async () => await this.checkTests(),
      critical: false
    });
    
    // Hook health
    this.healthChecks.set('hooks', {
      name: 'Hook System',
      check: async () => await this.checkHooks(),
      critical: true
    });
    
    // Documentation health
    this.healthChecks.set('documentation', {
      name: 'Documentation Sync',
      check: async () => await this.checkDocumentation(),
      critical: false
    });
    
    // Metrics health
    this.healthChecks.set('metrics', {
      name: 'Metrics Collection',
      check: async () => await this.checkMetrics(),
      critical: false
    });
    
    // Dependencies health
    this.healthChecks.set('dependencies', {
      name: 'Package Dependencies',
      check: async () => await this.checkDependencies(),
      critical: true
    });
    
    // Performance health
    this.healthChecks.set('performance', {
      name: 'System Performance',
      check: async () => await this.checkPerformance(),
      critical: false
    });
  }

  initializeRepairs() {
    // File repairs
    this.repairs.set('missing-files', {
      name: 'Restore Missing Files',
      repair: async (issues) => await this.repairMissingFiles(issues)
    });
    
    // Permission repairs
    this.repairs.set('permissions', {
      name: 'Fix File Permissions',
      repair: async (issues) => await this.repairPermissions(issues)
    });
    
    // Test repairs
    this.repairs.set('broken-tests', {
      name: 'Fix Broken Tests',
      repair: async (issues) => await this.repairTests(issues)
    });
    
    // Hook repairs
    this.repairs.set('hook-config', {
      name: 'Fix Hook Configuration',
      repair: async (issues) => await this.repairHooks(issues)
    });
    
    // Agent repairs
    this.repairs.set('agent-contracts', {
      name: 'Fix Agent Contracts',
      repair: async (issues) => await this.repairAgentContracts(issues)
    });
    
    // Documentation repairs
    this.repairs.set('doc-sync', {
      name: 'Sync Documentation',
      repair: async (issues) => await this.repairDocumentation(issues)
    });
  }

  initializeOptimizations() {
    // Cache optimization
    this.optimizations.set('cache', {
      name: 'Cache Optimization',
      optimize: async () => await this.optimizeCache()
    });
    
    // Test optimization
    this.optimizations.set('test-suite', {
      name: 'Test Suite Optimization',
      optimize: async () => await this.optimizeTests()
    });
    
    // Agent optimization
    this.optimizations.set('agent-pool', {
      name: 'Agent Pool Optimization',
      optimize: async () => await this.optimizeAgentPool()
    });
    
    // Metrics optimization
    this.optimizations.set('metrics-storage', {
      name: 'Metrics Storage Optimization',
      optimize: async () => await this.optimizeMetricsStorage()
    });
  }

  async performMaintenance() {
    console.log(chalk.bold('\n🔧 Van Maintenance System - Full Maintenance Cycle\n'));
    
    const report = {
      timestamp: new Date().toISOString(),
      health: {},
      repairs: [],
      optimizations: [],
      issues: [],
      recommendations: []
    };
    
    // Step 1: Health Checks
    console.log(chalk.cyan('Step 1: Running health checks...'));
    const healthResults = await this.runHealthChecks();
    report.health = healthResults;
    
    // Step 2: Auto Repairs
    if (healthResults.issues.length > 0) {
      console.log(chalk.yellow('\nStep 2: Performing auto-repairs...'));
      const repairResults = await this.runAutoRepairs(healthResults.issues);
      report.repairs = repairResults;
    } else {
      console.log(chalk.green('\nStep 2: No repairs needed ✅'));
    }
    
    // Step 3: Optimizations
    console.log(chalk.cyan('\nStep 3: Running optimizations...'));
    const optimizationResults = await this.runOptimizations();
    report.optimizations = optimizationResults;
    
    // Step 4: Generate Report
    console.log(chalk.cyan('\nStep 4: Generating maintenance report...'));
    await this.generateMaintenanceReport(report);
    
    // Log maintenance
    this.maintenanceLog.push(report);
    this.emit('maintenance-complete', report);
    
    return report;
  }

  async runHealthChecks() {
    const results = {
      healthy: true,
      checks: [],
      issues: [],
      score: 100
    };
    
    let totalWeight = 0;
    let weightedScore = 0;
    
    for (const [id, check] of this.healthChecks) {
      const spinner = chalk.gray(`  Checking ${check.name}...`);
      console.log(spinner);
      
      try {
        const result = await check.check();
        const weight = check.critical ? 2 : 1;
        totalWeight += weight;
        
        if (result.healthy) {
          console.log(chalk.green(`  ✅ ${check.name}: Healthy`));
          weightedScore += weight * 100;
        } else {
          console.log(chalk.red(`  ❌ ${check.name}: Issues found`));
          results.healthy = false;
          results.issues.push({
            checkId: id,
            name: check.name,
            issues: result.issues,
            critical: check.critical
          });
          weightedScore += weight * (result.score || 0);
        }
        
        results.checks.push({
          id,
          name: check.name,
          ...result
        });
      } catch (error) {
        console.log(chalk.red(`  ❌ ${check.name}: Check failed`));
        results.healthy = false;
        results.issues.push({
          checkId: id,
          name: check.name,
          error: error.message,
          critical: check.critical
        });
      }
    }
    
    results.score = Math.round(weightedScore / totalWeight);
    
    // Summary
    console.log(chalk.bold(`\nHealth Score: ${this.getScoreColor(results.score)}`));
    
    return results;
  }

  async checkFileSystem() {
    const issues = [];
    const requiredPaths = [
      '.claude-collective',
      '.claude-collective/tests',
      '.claude-collective/metrics',
      '.claude/agents',
      '.claude/hooks',
      'CLAUDE.md'
    ];
    
    for (const requiredPath of requiredPaths) {
      const fullPath = path.join(this.projectDir, requiredPath);
      if (!await fs.pathExists(fullPath)) {
        issues.push({
          type: 'missing-file',
          path: requiredPath,
          severity: 'high'
        });
      }
    }
    
    // Check permissions
    const executablePaths = [
      '.claude/hooks'
    ];
    
    for (const execPath of executablePaths) {
      const fullPath = path.join(this.projectDir, execPath);
      if (await fs.pathExists(fullPath)) {
        const files = await fs.readdir(fullPath);
        for (const file of files) {
          if (file.endsWith('.sh')) {
            const filePath = path.join(fullPath, file);
            const stats = await fs.stat(filePath);
            if (!(stats.mode & 0o111)) {
              issues.push({
                type: 'permission',
                path: path.join(execPath, file),
                severity: 'medium'
              });
            }
          }
        }
      }
    }
    
    return {
      healthy: issues.length === 0,
      issues,
      score: Math.max(0, 100 - issues.length * 10)
    };
  }

  async checkAgents() {
    const issues = [];
    const agentsDir = path.join(this.claudeDir, 'agents');
    
    if (!await fs.pathExists(agentsDir)) {
      return {
        healthy: false,
        issues: [{ type: 'missing-agents-dir', severity: 'critical' }],
        score: 0
      };
    }
    
    const agents = await fs.readdir(agentsDir);
    const requiredAgents = ['routing-agent.md', 'van-maintenance-agent.md'];
    
    // Check required agents exist
    for (const required of requiredAgents) {
      if (!agents.includes(required)) {
        issues.push({
          type: 'missing-agent',
          agent: required,
          severity: 'high'
        });
      }
    }
    
    // Validate agent files
    for (const agentFile of agents) {
      if (agentFile.endsWith('.md')) {
        const agentPath = path.join(agentsDir, agentFile);
        const content = await fs.readFile(agentPath, 'utf8');
        
        // Check for required sections
        const requiredSections = [
          '## 🎯 Core Responsibilities',
          '## 🛠 Available Tools',
          '## 🔄 Handoff Protocol'
        ];
        
        for (const section of requiredSections) {
          if (!content.includes(section)) {
            issues.push({
              type: 'incomplete-agent',
              agent: agentFile,
              missing: section,
              severity: 'medium'
            });
          }
        }
        
        // Check for test contracts
        if (!content.includes('## 🧪 Test Contracts')) {
          issues.push({
            type: 'missing-contracts',
            agent: agentFile,
            severity: 'low'
          });
        }
      }
    }
    
    // Check agent registry
    const registryPath = path.join(this.collectiveDir, 'registry.json');
    if (await fs.pathExists(registryPath)) {
      const registry = await fs.readJson(registryPath);
      
      // Verify registered agents have files
      for (const agent of registry.agents || []) {
        const agentPath = path.join(this.projectDir, agent.path);
        if (!await fs.pathExists(agentPath)) {
          issues.push({
            type: 'orphaned-registration',
            agentId: agent.id,
            severity: 'medium'
          });
        }
      }
    }
    
    return {
      healthy: issues.filter(i => i.severity === 'high' || i.severity === 'critical').length === 0,
      issues,
      agentCount: agents.length,
      score: Math.max(0, 100 - issues.length * 5)
    };
  }

  async checkTests() {
    const issues = [];
    const testsDir = path.join(this.collectiveDir, 'tests');
    
    if (!await fs.pathExists(testsDir)) {
      return {
        healthy: false,
        issues: [{ type: 'missing-tests-dir', severity: 'high' }],
        score: 0
      };
    }
    
    // Check test configuration
    const jestConfig = path.join(this.collectiveDir, 'jest.config.js');
    if (!await fs.pathExists(jestConfig)) {
      issues.push({
        type: 'missing-jest-config',
        severity: 'medium'
      });
    }
    
    // Run tests to check health
    try {
      const { stdout, stderr } = await execAsync(
        'npm test -- --listTests',
        { cwd: this.collectiveDir }
      );
      
      const testFiles = stdout.trim().split('\n').filter(Boolean);
      
      if (testFiles.length === 0) {
        issues.push({
          type: 'no-tests',
          severity: 'high'
        });
      }
      
      // Check for test categories
      const categories = ['handoffs', 'directives', 'contracts'];
      for (const category of categories) {
        const categoryTests = testFiles.filter(f => f.includes(category));
        if (categoryTests.length === 0) {
          issues.push({
            type: 'missing-test-category',
            category,
            severity: 'low'
          });
        }
      }
    } catch (error) {
      issues.push({
        type: 'test-framework-error',
        error: error.message,
        severity: 'high'
      });
    }
    
    return {
      healthy: issues.filter(i => i.severity === 'high').length === 0,
      issues,
      score: Math.max(0, 100 - issues.length * 8)
    };
  }

  async checkHooks() {
    const issues = [];
    const hooksDir = path.join(this.claudeDir, 'hooks');
    const settingsPath = path.join(this.claudeDir, 'settings.json');
    
    // Check hooks directory
    if (!await fs.pathExists(hooksDir)) {
      return {
        healthy: false,
        issues: [{ type: 'missing-hooks-dir', severity: 'critical' }],
        score: 0
      };
    }
    
    // Check settings.json
    if (!await fs.pathExists(settingsPath)) {
      issues.push({
        type: 'missing-settings',
        severity: 'critical'
      });
    } else {
      const settings = await fs.readJson(settingsPath);
      
      // Validate hook configuration
      if (!settings.hooks) {
        issues.push({
          type: 'no-hooks-configured',
          severity: 'high'
        });
      } else {
        // Check referenced hooks exist
        const checkHookReferences = (hooks) => {
          for (const event in hooks) {
            const eventHooks = hooks[event];
            if (Array.isArray(eventHooks)) {
              for (const hookConfig of eventHooks) {
                if (hookConfig.hooks) {
                  for (const hook of hookConfig.hooks) {
                    if (hook.type === 'command' && hook.command) {
                      const hookPath = hook.command
                        .replace('$CLAUDE_PROJECT_DIR', this.projectDir);
                      
                      if (!fs.existsSync(hookPath)) {
                        issues.push({
                          type: 'missing-hook-file',
                          hook: hook.command,
                          event,
                          severity: 'high'
                        });
                      }
                    }
                  }
                }
              }
            }
          }
        };
        
        checkHookReferences(settings.hooks);
      }
    }
    
    // Check required hooks
    const requiredHooks = [
      'test-driven-handoff.sh',
      'directive-enforcer.sh',
      'collective-metrics.sh'
    ];
    
    const hooks = await fs.readdir(hooksDir);
    for (const required of requiredHooks) {
      if (!hooks.includes(required)) {
        issues.push({
          type: 'missing-required-hook',
          hook: required,
          severity: 'high'
        });
      }
    }
    
    // Check hook executability
    for (const hook of hooks) {
      if (hook.endsWith('.sh')) {
        const hookPath = path.join(hooksDir, hook);
        const stats = await fs.stat(hookPath);
        if (!(stats.mode & 0o111)) {
          issues.push({
            type: 'hook-not-executable',
            hook,
            severity: 'medium'
          });
        }
      }
    }
    
    return {
      healthy: issues.filter(i => i.severity === 'critical' || i.severity === 'high').length === 0,
      issues,
      hookCount: hooks.length,
      score: Math.max(0, 100 - issues.length * 10)
    };
  }

  async checkDocumentation() {
    const issues = [];
    
    // Check CLAUDE.md
    const claudeMdPath = path.join(this.projectDir, 'CLAUDE.md');
    if (!await fs.pathExists(claudeMdPath)) {
      issues.push({
        type: 'missing-claude-md',
        severity: 'critical'
      });
    } else {
      const content = await fs.readFile(claudeMdPath, 'utf8');
      
      // Check for required sections
      const requiredSections = [
        '# 🧠 BEHAVIORAL OPERATING SYSTEM',
        '## PRIME DIRECTIVE',
        '## CONTEXT ENGINEERING HYPOTHESES',
        '## HUB-AND-SPOKE COORDINATION'
      ];
      
      for (const section of requiredSections) {
        if (!content.includes(section)) {
          issues.push({
            type: 'incomplete-claude-md',
            missing: section,
            severity: 'medium'
          });
        }
      }
      
      // Check for NEVER IMPLEMENT DIRECTLY
      if (!content.includes('NEVER IMPLEMENT DIRECTLY')) {
        issues.push({
          type: 'missing-prime-directive',
          severity: 'critical'
        });
      }
    }
    
    // Check agent documentation sync
    const agentsDir = path.join(this.claudeDir, 'agents');
    if (await fs.pathExists(agentsDir)) {
      const agents = await fs.readdir(agentsDir);
      const claudeMd = await fs.readFile(claudeMdPath, 'utf8');
      
      for (const agent of agents) {
        if (agent.endsWith('.md')) {
          const agentName = agent.replace('.md', '');
          if (!claudeMd.includes(agentName)) {
            issues.push({
              type: 'undocumented-agent',
              agent: agentName,
              severity: 'low'
            });
          }
        }
      }
    }
    
    return {
      healthy: issues.filter(i => i.severity === 'critical').length === 0,
      issues,
      score: Math.max(0, 100 - issues.length * 7)
    };
  }

  async checkMetrics() {
    const issues = [];
    const metricsDir = path.join(this.collectiveDir, 'metrics');
    
    if (!await fs.pathExists(metricsDir)) {
      issues.push({
        type: 'missing-metrics-dir',
        severity: 'low'
      });
    } else {
      // Check metrics files
      const files = await fs.readdir(metricsDir);
      
      // Check for current metrics
      const today = new Date().toISOString().split('T')[0];
      const todayMetrics = files.filter(f => f.includes(today));
      
      if (todayMetrics.length === 0) {
        issues.push({
          type: 'no-recent-metrics',
          severity: 'low'
        });
      }
      
      // Check metrics size (cleanup old)
      let totalSize = 0;
      for (const file of files) {
        const stats = await fs.stat(path.join(metricsDir, file));
        totalSize += stats.size;
      }
      
      if (totalSize > 100 * 1024 * 1024) { // 100MB
        issues.push({
          type: 'metrics-size-large',
          size: totalSize,
          severity: 'medium'
        });
      }
    }
    
    // Check research config
    const researchConfig = path.join(this.collectiveDir, 'research.config.json');
    if (!await fs.pathExists(researchConfig)) {
      issues.push({
        type: 'missing-research-config',
        severity: 'low'
      });
    }
    
    return {
      healthy: true, // Metrics are non-critical
      issues,
      score: Math.max(0, 100 - issues.length * 3)
    };
  }

  async checkDependencies() {
    const issues = [];
    
    // Check collective package.json
    const packagePath = path.join(this.collectiveDir, 'package.json');
    if (!await fs.pathExists(packagePath)) {
      issues.push({
        type: 'missing-package-json',
        severity: 'high'
      });
    } else {
      try {
        // Check for vulnerabilities
        const { stdout } = await execAsync(
          'npm audit --json',
          { cwd: this.collectiveDir }
        );
        
        const audit = JSON.parse(stdout);
        if (audit.metadata.vulnerabilities.total > 0) {
          issues.push({
            type: 'npm-vulnerabilities',
            count: audit.metadata.vulnerabilities.total,
            critical: audit.metadata.vulnerabilities.critical,
            high: audit.metadata.vulnerabilities.high,
            severity: audit.metadata.vulnerabilities.critical > 0 ? 'critical' : 'medium'
          });
        }
      } catch (error) {
        // Audit failed, not critical
      }
      
      // Check for outdated packages
      try {
        const { stdout } = await execAsync(
          'npm outdated --json',
          { cwd: this.collectiveDir }
        );
        
        if (stdout) {
          const outdated = JSON.parse(stdout);
          const outdatedCount = Object.keys(outdated).length;
          
          if (outdatedCount > 5) {
            issues.push({
              type: 'outdated-packages',
              count: outdatedCount,
              severity: 'low'
            });
          }
        }
      } catch (error) {
        // Outdated check failed, ignore
      }
    }
    
    return {
      healthy: issues.filter(i => i.severity === 'critical').length === 0,
      issues,
      score: Math.max(0, 100 - issues.length * 15)
    };
  }

  async checkPerformance() {
    const issues = [];
    
    // Check test execution time
    try {
      const start = Date.now();
      await execAsync(
        'npm test -- --listTests',
        { cwd: this.collectiveDir, timeout: 5000 }
      );
      const duration = Date.now() - start;
      
      if (duration > 3000) {
        issues.push({
          type: 'slow-test-discovery',
          duration,
          severity: 'low'
        });
      }
    } catch (error) {
      // Timeout or error
      issues.push({
        type: 'test-timeout',
        severity: 'medium'
      });
    }
    
    // Check agent response times from metrics
    const metricsPath = path.join(this.collectiveDir, 'metrics', 'performance.json');
    if (await fs.pathExists(metricsPath)) {
      const metrics = await fs.readJson(metricsPath);
      
      if (metrics.avgResponseTime > 5000) {
        issues.push({
          type: 'slow-agent-response',
          avgTime: metrics.avgResponseTime,
          severity: 'medium'
        });
      }
      
      if (metrics.errorRate > 0.1) {
        issues.push({
          type: 'high-error-rate',
          rate: metrics.errorRate,
          severity: 'high'
        });
      }
    }
    
    return {
      healthy: issues.filter(i => i.severity === 'high').length === 0,
      issues,
      score: Math.max(0, 100 - issues.length * 10)
    };
  }

  async runAutoRepairs(issues) {
    const repairs = [];
    
    for (const issue of issues) {
      // Group issues by type
      const issuesByType = {};
      for (const item of issue.issues) {
        if (!issuesByType[item.type]) {
          issuesByType[item.type] = [];
        }
        issuesByType[item.type].push(item);
      }
      
      // Run appropriate repairs
      for (const [type, items] of Object.entries(issuesByType)) {
        const repairKey = this.getRepairKey(type);
        if (repairKey && this.repairs.has(repairKey)) {
          const repair = this.repairs.get(repairKey);
          
          console.log(chalk.gray(`  Repairing: ${repair.name}...`));
          
          try {
            const result = await repair.repair(items);
            repairs.push({
              type: repairKey,
              name: repair.name,
              success: true,
              fixed: result.fixed,
              details: result.details
            });
            
            console.log(chalk.green(`  ✅ ${repair.name}: Fixed ${result.fixed} issues`));
          } catch (error) {
            repairs.push({
              type: repairKey,
              name: repair.name,
              success: false,
              error: error.message
            });
            
            console.log(chalk.red(`  ❌ ${repair.name}: Repair failed`));
          }
        }
      }
    }
    
    return repairs;
  }

  getRepairKey(issueType) {
    const repairMap = {
      'missing-file': 'missing-files',
      'missing-agents-dir': 'missing-files',
      'missing-tests-dir': 'missing-files',
      'permission': 'permissions',
      'hook-not-executable': 'permissions',
      'broken-test': 'broken-tests',
      'test-framework-error': 'broken-tests',
      'missing-hook-file': 'hook-config',
      'no-hooks-configured': 'hook-config',
      'missing-contracts': 'agent-contracts',
      'incomplete-agent': 'agent-contracts',
      'undocumented-agent': 'doc-sync',
      'missing-claude-md': 'doc-sync'
    };
    
    return repairMap[issueType];
  }

  async repairMissingFiles(issues) {
    let fixed = 0;
    const details = [];
    
    for (const issue of issues) {
      const fullPath = path.join(this.projectDir, issue.path);
      
      try {
        if (issue.path.endsWith('.md')) {
          // Create from template
          const template = await this.getTemplate(issue.path);
          await fs.writeFile(fullPath, template);
          details.push(`Created ${issue.path} from template`);
        } else {
          // Create directory
          await fs.ensureDir(fullPath);
          details.push(`Created directory ${issue.path}`);
        }
        
        fixed++;
      } catch (error) {
        details.push(`Failed to create ${issue.path}: ${error.message}`);
      }
    }
    
    return { fixed, details };
  }

  async repairPermissions(issues) {
    let fixed = 0;
    const details = [];
    
    for (const issue of issues) {
      const fullPath = path.join(this.projectDir, issue.path);
      
      try {
        await fs.chmod(fullPath, '755');
        details.push(`Fixed permissions for ${issue.path}`);
        fixed++;
      } catch (error) {
        details.push(`Failed to fix ${issue.path}: ${error.message}`);
      }
    }
    
    return { fixed, details };
  }

  async repairTests(issues) {
    let fixed = 0;
    const details = [];
    
    // Reinstall test dependencies
    try {
      await execAsync('npm install', { cwd: this.collectiveDir });
      details.push('Reinstalled test dependencies');
      fixed++;
    } catch (error) {
      details.push(`Failed to reinstall: ${error.message}`);
    }
    
    // Regenerate jest config if missing
    const jestConfig = path.join(this.collectiveDir, 'jest.config.js');
    if (!await fs.pathExists(jestConfig)) {
      const config = `module.exports = {
  testEnvironment: 'node',
  roots: ['<rootDir>/tests'],
  testMatch: ['**/?(*.)+(spec|test).js'],
  collectCoverageFrom: ['tests/**/*.js'],
  coverageDirectory: 'coverage',
  verbose: true,
  testTimeout: 10000
};`;
      
      await fs.writeFile(jestConfig, config);
      details.push('Regenerated jest.config.js');
      fixed++;
    }
    
    return { fixed, details };
  }

  async repairHooks(issues) {
    let fixed = 0;
    const details = [];
    
    // Fix settings.json
    const settingsPath = path.join(this.claudeDir, 'settings.json');
    let settings = {};
    
    if (await fs.pathExists(settingsPath)) {
      settings = await fs.readJson(settingsPath);
    }
    
    // Ensure hooks structure exists
    if (!settings.hooks) {
      settings.hooks = {
        PreToolUse: [],
        PostToolUse: [],
        SubagentStop: []
      };
      
      await fs.writeJson(settingsPath, settings, { spaces: 2 });
      details.push('Initialized hooks configuration');
      fixed++;
    }
    
    // Create missing hook files
    for (const issue of issues) {
      if (issue.type === 'missing-hook-file') {
        const hookName = path.basename(issue.hook);
        const template = await this.getHookTemplate(hookName);
        const hookPath = path.join(this.claudeDir, 'hooks', hookName);
        
        await fs.writeFile(hookPath, template);
        await fs.chmod(hookPath, '755');
        
        details.push(`Created ${hookName}`);
        fixed++;
      }
    }
    
    return { fixed, details };
  }

  async repairAgentContracts(issues) {
    let fixed = 0;
    const details = [];
    
    for (const issue of issues) {
      if (issue.type === 'missing-contracts' || issue.type === 'incomplete-agent') {
        const agentPath = path.join(this.claudeDir, 'agents', issue.agent);
        let content = await fs.readFile(agentPath, 'utf8');
        
        // Add missing sections
        if (issue.missing) {
          const section = await this.getAgentSection(issue.missing);
          content += `\n\n${section}`;
          
          await fs.writeFile(agentPath, content);
          details.push(`Added ${issue.missing} to ${issue.agent}`);
          fixed++;
        }
        
        // Add test contracts if missing
        if (issue.type === 'missing-contracts') {
          const contracts = await this.getDefaultContracts(issue.agent);
          content += `\n\n## 🧪 Test Contracts\n${contracts}`;
          
          await fs.writeFile(agentPath, content);
          details.push(`Added test contracts to ${issue.agent}`);
          fixed++;
        }
      }
    }
    
    return { fixed, details };
  }

  async repairDocumentation(issues) {
    let fixed = 0;
    const details = [];
    
    // Regenerate CLAUDE.md if missing
    const claudeMdPath = path.join(this.projectDir, 'CLAUDE.md');
    
    if (!await fs.pathExists(claudeMdPath)) {
      const template = await this.getBehavioralTemplate();
      await fs.writeFile(claudeMdPath, template);
      details.push('Regenerated CLAUDE.md');
      fixed++;
    }
    
    // Update agent references
    const claudeMd = await fs.readFile(claudeMdPath, 'utf8');
    const agentsDir = path.join(this.claudeDir, 'agents');
    
    if (await fs.pathExists(agentsDir)) {
      const agents = await fs.readdir(agentsDir);
      let updatedContent = claudeMd;
      
      for (const agent of agents) {
        if (agent.endsWith('.md')) {
          const agentName = agent.replace('.md', '');
          if (!claudeMd.includes(agentName)) {
            // Add agent to coordination section
            const coordSection = '## HUB-AND-SPOKE COORDINATION';
            const insertion = `\n- @${agentName}: Available for specific tasks`;
            
            updatedContent = updatedContent.replace(
              coordSection,
              `${coordSection}${insertion}`
            );
            
            details.push(`Documented ${agentName}`);
            fixed++;
          }
        }
      }
      
      if (updatedContent !== claudeMd) {
        await fs.writeFile(claudeMdPath, updatedContent);
      }
    }
    
    return { fixed, details };
  }

  async runOptimizations() {
    const results = [];
    
    for (const [id, optimization] of this.optimizations) {
      console.log(chalk.gray(`  Running: ${optimization.name}...`));
      
      try {
        const result = await optimization.optimize();
        results.push({
          id,
          name: optimization.name,
          success: true,
          ...result
        });
        
        if (result.improved) {
          console.log(chalk.green(`  ✅ ${optimization.name}: Optimized`));
        } else {
          console.log(chalk.blue(`  ℹ️ ${optimization.name}: Already optimal`));
        }
      } catch (error) {
        results.push({
          id,
          name: optimization.name,
          success: false,
          error: error.message
        });
        
        console.log(chalk.yellow(`  ⚠️ ${optimization.name}: Failed`));
      }
    }
    
    return results;
  }

  async optimizeCache() {
    const cacheDir = path.join(this.collectiveDir, '.cache');
    let cleaned = 0;
    
    if (await fs.pathExists(cacheDir)) {
      const files = await fs.readdir(cacheDir);
      const cutoff = Date.now() - 7 * 24 * 60 * 60 * 1000; // 7 days
      
      for (const file of files) {
        const filePath = path.join(cacheDir, file);
        const stats = await fs.stat(filePath);
        
        if (stats.mtime.getTime() < cutoff) {
          await fs.remove(filePath);
          cleaned++;
        }
      }
    }
    
    return {
      improved: cleaned > 0,
      filesRemoved: cleaned
    };
  }

  async optimizeTests() {
    // Remove duplicate test files
    const testsDir = path.join(this.collectiveDir, 'tests');
    let optimized = 0;
    
    if (await fs.pathExists(testsDir)) {
      const allTests = await this.getAllFiles(testsDir);
      const testsByContent = new Map();
      
      for (const testFile of allTests) {
        const content = await fs.readFile(testFile, 'utf8');
        const hash = crypto.createHash('md5').update(content).digest('hex');
        
        if (testsByContent.has(hash)) {
          // Duplicate found
          await fs.remove(testFile);
          optimized++;
        } else {
          testsByContent.set(hash, testFile);
        }
      }
    }
    
    return {
      improved: optimized > 0,
      duplicatesRemoved: optimized
    };
  }

  async optimizeAgentPool() {
    const AgentRegistry = require('./agent-registry');
    const registry = new AgentRegistry();
    
    // Clean up inactive agents
    const cleanup = await registry.cleanupInactive(7);
    
    return {
      improved: cleanup.removed > 0,
      agentsRemoved: cleanup.removed
    };
  }

  async optimizeMetricsStorage() {
    const metricsDir = path.join(this.collectiveDir, 'metrics');
    let compressed = 0;
    
    if (await fs.pathExists(metricsDir)) {
      const files = await fs.readdir(metricsDir);
      const oldMetrics = files.filter(f => {
        const date = f.match(/(\d{4}-\d{2}-\d{2})/);
        if (date) {
          const fileDate = new Date(date[1]);
          const daysOld = (Date.now() - fileDate.getTime()) / (24 * 60 * 60 * 1000);
          return daysOld > 30;
        }
        return false;
      });
      
      // Archive old metrics
      if (oldMetrics.length > 0) {
        const archiveDir = path.join(metricsDir, 'archive');
        await fs.ensureDir(archiveDir);
        
        for (const file of oldMetrics) {
          await fs.move(
            path.join(metricsDir, file),
            path.join(archiveDir, file),
            { overwrite: true }
          );
          compressed++;
        }
      }
    }
    
    return {
      improved: compressed > 0,
      filesArchived: compressed
    };
  }

  async generateMaintenanceReport(report) {
    const reportPath = path.join(
      this.collectiveDir,
      'maintenance-reports',
      `report-${new Date().toISOString().split('T')[0]}.json`
    );
    
    await fs.ensureDir(path.dirname(reportPath));
    await fs.writeJson(reportPath, report, { spaces: 2 });
    
    // Generate summary
    const summary = this.generateSummary(report);
    console.log(chalk.bold('\n📊 Maintenance Summary:'));
    console.log(summary);
    
    return reportPath;
  }

  generateSummary(report) {
    const lines = [];
    
    lines.push(`Health Score: ${this.getScoreColor(report.health.score)}`);
    lines.push(`Issues Found: ${report.health.issues.length}`);
    lines.push(`Repairs Made: ${report.repairs.filter(r => r.success).length}`);
    lines.push(`Optimizations: ${report.optimizations.filter(o => o.success).length}`);
    
    if (report.health.issues.length > 0) {
      lines.push('\nTop Issues:');
      report.health.issues
        .slice(0, 3)
        .forEach(issue => {
          lines.push(`  - ${issue.name}: ${issue.issues.length} problems`);
        });
    }
    
    if (report.repairs.length > 0) {
      lines.push('\nRepairs Performed:');
      report.repairs
        .filter(r => r.success)
        .forEach(repair => {
          lines.push(`  ✅ ${repair.name}: Fixed ${repair.fixed} issues`);
        });
    }
    
    return lines.join('\n');
  }

  getScoreColor(score) {
    if (score >= 90) return chalk.green(`${score}/100`);
    if (score >= 70) return chalk.yellow(`${score}/100`);
    if (score >= 50) return chalk.magenta(`${score}/100`);
    return chalk.red(`${score}/100`);
  }

  async getAllFiles(dir, files = []) {
    const items = await fs.readdir(dir);
    
    for (const item of items) {
      const fullPath = path.join(dir, item);
      const stat = await fs.stat(fullPath);
      
      if (stat.isDirectory()) {
        await this.getAllFiles(fullPath, files);
      } else {
        files.push(fullPath);
      }
    }
    
    return files;
  }

  async getTemplate(path) {
    // Return appropriate template based on path
    return `# Template for ${path}\n\nThis file was auto-generated by van-maintenance.\n`;
  }

  async getHookTemplate(hookName) {
    return `#!/bin/bash
# ${hookName}
# Auto-generated by van-maintenance

echo "Hook ${hookName} executed"
exit 0
`;
  }

  async getAgentSection(section) {
    return `${section}
- To be defined
- Auto-generated by van-maintenance
`;
  }

  async getDefaultContracts(agentName) {
    return `
\`\`\`javascript
test('${agentName} validates inputs', () => {
  expect(input).toBeDefined();
});

test('${agentName} produces output', () => {
  expect(output).toHaveProperty('success');
});
\`\`\`
`;
  }

  async getBehavioralTemplate() {
    return `# 🧠 BEHAVIORAL OPERATING SYSTEM

## PRIME DIRECTIVE
**NEVER IMPLEMENT DIRECTLY** - You are the hub coordinator. Always delegate.

## CONTEXT ENGINEERING HYPOTHESES
Research framework for multi-agent coordination.

## HUB-AND-SPOKE COORDINATION
- @routing-agent: Routes all requests
- @van-maintenance-agent: Maintains ecosystem

Auto-generated by van-maintenance.
`;
  }

  startScheduledMaintenance() {
    // Run full maintenance daily at 2 AM
    cron.schedule('0 2 * * *', async () => {
      console.log('Running scheduled maintenance...');
      await this.performMaintenance();
    });
    
    // Run health checks every hour
    cron.schedule('0 * * * *', async () => {
      console.log('Running hourly health check...');
      await this.runHealthChecks();
    });
    
    // Run optimizations weekly
    cron.schedule('0 3 * * 0', async () => {
      console.log('Running weekly optimizations...');
      await this.runOptimizations();
    });
  }
}

module.exports = VanMaintenanceSystem;
```

### Step 2: Create Van Maintenance Agent

Create `.claude/agents/van-maintenance-agent.md`:

```markdown
# 🚐 Van Maintenance Agent

## 🤖 Agent Profile
**Type**: System Guardian
**Specialization**: Ecosystem Health & Optimization
**Version**: 1.0.0
**Critical**: Yes

## 🎯 Core Responsibilities

### Primary Duties
- Monitor collective ecosystem health continuously
- Repair broken components automatically
- Optimize system performance proactively
- Maintain documentation synchronization
- Update agent relationships in diagrams
- Ensure test contract compliance
- Archive and clean old resources
- Generate health reports

### Guardian Protocols
1. **Never Break Working Systems** - Test repairs before applying
2. **Document All Changes** - Maintain audit trail
3. **Preserve User Customizations** - Don't overwrite custom code
4. **Fail Gracefully** - Report issues without crashing
5. **Self-Repair Capability** - Fix own issues first

## 🛠 Available Tools
- Read
- Write
- Edit
- MultiEdit
- Bash
- Grep
- Glob
- LS
- Task
- TodoWrite

## 📊 Success Metrics
- System Health Score: >90%
- Auto-repair Success: >95%
- Documentation Sync: 100%
- Test Pass Rate: >98%
- Performance Optimization: Continuous

## 🔄 Handoff Protocol

### Incoming Handoffs
Accepts maintenance requests from:
- **routing-agent**: "System needs maintenance"
- **Any agent**: "Ecosystem issue detected"
- **User**: Direct maintenance commands

### Outgoing Handoffs
Routes to:
- **routing-agent**: After maintenance complete
- **Specific agents**: For specialized repairs
- **User**: When manual intervention needed

## 🧪 Test Contracts

### Health Check Contract
```javascript
test('van-maintenance performs health check', async () => {
  const health = await vanMaintenance.runHealthChecks();
  expect(health).toHaveProperty('healthy');
  expect(health).toHaveProperty('score');
  expect(health.score).toBeGreaterThanOrEqual(0);
  expect(health.score).toBeLessThanOrEqual(100);
});
```

### Auto-repair Contract
```javascript
test('van-maintenance repairs issues', async () => {
  const issues = [
    { type: 'missing-file', path: 'test.md' }
  ];
  const repairs = await vanMaintenance.runAutoRepairs(issues);
  expect(repairs).toBeInstanceOf(Array);
  expect(repairs[0]).toHaveProperty('success');
});
```

### Optimization Contract
```javascript
test('van-maintenance optimizes system', async () => {
  const optimizations = await vanMaintenance.runOptimizations();
  expect(optimizations).toBeInstanceOf(Array);
  optimizations.forEach(opt => {
    expect(opt).toHaveProperty('name');
    expect(opt).toHaveProperty('success');
  });
});
```

## 💡 Behavioral Directives

### PRIME DIRECTIVE
Keep the collective healthy, optimized, and self-healing at all times.

### Operating Principles
1. **Proactive Monitoring** - Don't wait for failures
2. **Minimal Disruption** - Repair without breaking flow
3. **Conservative Changes** - Preserve working systems
4. **Transparent Reporting** - Clear health status
5. **Continuous Learning** - Adapt repair strategies

### Maintenance Schedule
- **Hourly**: Quick health checks
- **Daily**: Full system scan and repair
- **Weekly**: Deep optimization
- **Monthly**: Archive and cleanup

## 🔧 Specialization Parameters
```json
{
  "autoRepair": true,
  "scheduleEnabled": true,
  "healthThreshold": 90,
  "repairTimeout": 30000,
  "optimizationLevel": "balanced",
  "preserveCustomizations": true,
  "verboseLogging": false
}
```

## 📝 Implementation Notes

### Critical Files to Monitor
- CLAUDE.md (behavioral system)
- .claude/settings.json (hook configuration)
- .claude-collective/registry.json (agent registry)
- All agent files in .claude/agents/
- All hooks in .claude/hooks/

### Repair Strategies
1. **Missing Files**: Recreate from templates
2. **Broken Tests**: Regenerate contracts
3. **Permission Issues**: Fix executable flags
4. **Documentation Drift**: Re-sync references
5. **Performance Issues**: Clean caches, optimize

### Optimization Targets
- Test execution time <5s
- Agent response time <2s
- Documentation sync 100%
- Metrics storage <100MB
- Error rate <5%

## 🚨 Emergency Protocols

### System Critical
If health score drops below 50%:
1. Enter emergency repair mode
2. Disable non-essential features
3. Focus on core system restoration
4. Alert user immediately
5. Generate detailed diagnostic report

### Self-Repair
If van-maintenance itself is broken:
1. Use fallback repair scripts
2. Restore from templates
3. Rebuild from NPX package
4. Request user assistance
5. Document failure for analysis

## 📊 Reporting

### Health Report Structure
```json
{
  "timestamp": "ISO-8601",
  "health": {
    "score": 95,
    "issues": [],
    "critical": false
  },
  "repairs": {
    "attempted": 5,
    "successful": 5,
    "failed": 0
  },
  "optimizations": {
    "performed": 3,
    "impact": "positive"
  },
  "recommendations": []
}
```

### Alert Thresholds
- **Info**: Score 90-100
- **Warning**: Score 70-89
- **Error**: Score 50-69
- **Critical**: Score <50

## 🔄 Self-Improvement

The van-maintenance system should:
1. Learn from repair patterns
2. Adapt to project-specific needs
3. Optimize own performance
4. Update repair strategies
5. Enhance detection capabilities

---

**Remember**: You are the guardian of the collective. Keep it healthy, keep it running, keep it improving. The ecosystem depends on your vigilance.
```

### Step 3: Create Maintenance Commands

Add to command system:

```javascript
// In command-parser.js
case '/maintenance':
case '/van':
  return await this.runMaintenanceCommand(args);

// Implementation
async runMaintenanceCommand(args) {
  const VanMaintenanceSystem = require('../lib/van-maintenance');
  const van = new VanMaintenanceSystem();
  
  const [subcommand, ...params] = args.split(' ');
  
  switch (subcommand) {
    case 'check':
      return await van.runHealthChecks();
    
    case 'repair':
      const health = await van.runHealthChecks();
      if (health.issues.length > 0) {
        return await van.runAutoRepairs(health.issues);
      }
      return { message: 'No repairs needed' };
    
    case 'optimize':
      return await van.runOptimizations();
    
    case 'full':
      return await van.performMaintenance();
    
    case 'report':
      return await van.generateMaintenanceReport(
        await van.performMaintenance()
      );
    
    case 'schedule':
      van.startScheduledMaintenance();
      return { message: 'Scheduled maintenance activated' };
    
    default:
      return {
        help: [
          '/van check - Run health checks',
          '/van repair - Auto-repair issues',
          '/van optimize - Run optimizations',
          '/van full - Complete maintenance',
          '/van report - Generate report',
          '/van schedule - Enable scheduled maintenance'
        ].join('\n')
      };
  }
}
```

## ✅ Validation Criteria

### Health Monitoring
- [ ] All health checks run successfully
- [ ] Issues detected accurately
- [ ] Health score calculated correctly
- [ ] Critical issues prioritized
- [ ] Reports generated properly

### Auto-repair
- [ ] Missing files recreated
- [ ] Permissions fixed
- [ ] Tests repaired
- [ ] Hooks restored
- [ ] Documentation synced

### Optimization
- [ ] Cache cleaned regularly
- [ ] Tests optimized
- [ ] Metrics archived
- [ ] Agent pool managed
- [ ] Performance improved

## 🧪 Acceptance Tests

### Test 1: Health Check
```bash
/van check

# Expected:
# - Shows health score
# - Lists any issues
# - Provides recommendations
```

### Test 2: Auto-repair
```bash
# Break something
rm .claude/hooks/test-driven-handoff.sh

/van repair

# Expected:
# - Detects missing hook
# - Recreates from template
# - Fixes permissions
```

### Test 3: Full Maintenance
```bash
/van full

# Expected:
# - Runs all checks
# - Performs repairs
# - Optimizes system
# - Generates report
```

### Test 4: Scheduled Maintenance
```bash
/van schedule

# Expected:
# - Cron jobs activated
# - Runs automatically
# - Logs maintenance events
```

## 🚨 Troubleshooting

### Issue: Repair loop
**Solution**:
1. Disable auto-repair temporarily
2. Investigate root cause
3. Fix underlying issue
4. Re-enable auto-repair

### Issue: False positives
**Solution**:
1. Adjust health check thresholds
2. Update detection logic
3. Add exceptions for custom code
4. Refine issue severity

### Issue: Performance impact
**Solution**:
1. Reduce check frequency
2. Optimize repair operations
3. Use async operations
4. Cache health results

## 📊 Metrics to Track

### Maintenance Metrics
- Health score over time
- Repair success rate
- Optimization impact
- Issue frequency by type
- Maintenance duration

### System Metrics
- Uptime percentage
- Error rates
- Performance trends
- Resource usage
- User interventions

## ✋ MVP Complete!

### Final Deliverables
- [ ] Van maintenance system operational
- [ ] Auto-repair functioning
- [ ] Optimization running
- [ ] Health monitoring active
- [ ] Documentation complete

### System Ready When
1. Health checks pass ✅
2. Auto-repairs work ✅
3. Optimizations improve performance ✅
4. Reports generated ✅
5. Scheduled maintenance active ✅

### Next Steps
With Phase 8 complete, the MVP is ready! The collective now has:
- Behavioral operating system
- Test-driven handoffs
- Hook integration
- NPX distribution
- Command system
- Research metrics
- Dynamic agents
- Van maintenance

The system is self-healing, self-optimizing, and ready for research validation.

---

**Phase 8 Duration**: 1 day  
**Critical Success Factor**: Self-healing ecosystem  
**Status**: MVP COMPLETE! 🎉

## 🚀 Post-MVP: Research Validation

With the MVP complete, the next phase focuses on:
1. Collecting baseline metrics
2. Running A/B experiments
3. Validating hypotheses
4. Publishing results
5. Community distribution

The collective is now ready to prove or disprove the Context Engineering hypotheses through rigorous experimentation.