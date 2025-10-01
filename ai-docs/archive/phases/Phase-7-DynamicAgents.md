# Phase 7: Dynamic Agent Creation

## 🎯 Phase Objective

Implement on-demand agent spawning that allows the collective to dynamically create specialized agents based on task requirements, enabling infinite scalability and specialization without pre-defining every possible agent type.

## 📋 Prerequisites Checklist

- [ ] Command system (Phase 5) operational
- [ ] Research metrics (Phase 6) collecting data
- [ ] Template system established
- [ ] Registry pattern understood
- [ ] Agent lifecycle management ready

## 🚀 Implementation Steps

### Step 1: Create Agent Template System

Create `.claude-collective/lib/agent-templates.js`:

```javascript
const fs = require('fs-extra');
const path = require('path');
const chalk = require('chalk');
const Handlebars = require('handlebars');

class AgentTemplateSystem {
  constructor() {
    this.templatesDir = path.join(process.cwd(), '.claude-collective/templates/agents');
    this.agentsDir = path.join(process.cwd(), '.claude/agents');
    this.templates = new Map();
    this.loadTemplates();
  }

  loadTemplates() {
    // Base agent template
    this.templates.set('base', {
      name: 'base-agent',
      description: 'Base template for all agents',
      tools: ['Read', 'Write', 'Edit'],
      capabilities: ['basic-processing'],
      template: `# {{agentName}} Agent

## 🤖 Agent Profile
**Type**: {{agentType}}
**Specialization**: {{specialization}}
**Created**: {{createdDate}}
**Purpose**: {{purpose}}

## 🎯 Core Responsibilities
{{#each responsibilities}}
- {{this}}
{{/each}}

## 🛠 Available Tools
{{#each tools}}
- {{this}}
{{/each}}

## 📊 Success Metrics
{{#each metrics}}
- {{this.name}}: {{this.target}}
{{/each}}

## 🔄 Handoff Protocol

### Incoming Handoffs
Accepts handoffs from:
{{#each incomingHandoffs}}
- {{this.from}}: {{this.condition}}
{{/each}}

### Outgoing Handoffs
Routes to:
{{#each outgoingHandoffs}}
- {{this.to}}: {{this.condition}}
{{/each}}

## 🧪 Test Contracts
{{#each testContracts}}
### {{this.name}}
\`\`\`javascript
{{this.code}}
\`\`\`
{{/each}}

## 💡 Behavioral Directives

### PRIME DIRECTIVE
{{primeDirective}}

### Operating Principles
{{#each principles}}
{{@index}}. {{this}}
{{/each}}

## 🔧 Specialization Parameters
\`\`\`json
{{specializationParams}}
\`\`\`

## 📝 Implementation Notes
{{implementationNotes}}
`
    });

    // Specialized templates
    this.templates.set('data-processor', {
      name: 'data-processor',
      parent: 'base',
      tools: ['Read', 'Write', 'Bash', 'Grep'],
      specialization: {
        dataFormats: ['json', 'csv', 'xml'],
        transformations: ['filter', 'aggregate', 'normalize'],
        validations: ['schema', 'integrity', 'completeness']
      }
    });

    this.templates.set('api-integrator', {
      name: 'api-integrator',
      parent: 'base',
      tools: ['WebFetch', 'WebSearch', 'Read', 'Write'],
      specialization: {
        protocols: ['REST', 'GraphQL', 'WebSocket'],
        authentication: ['OAuth', 'JWT', 'API Key'],
        errorHandling: ['retry', 'circuit-breaker', 'fallback']
      }
    });

    this.templates.set('test-generator', {
      name: 'test-generator',
      parent: 'base',
      tools: ['Read', 'Write', 'Edit', 'Bash'],
      specialization: {
        frameworks: ['jest', 'mocha', 'playwright'],
        testTypes: ['unit', 'integration', 'e2e'],
        coverage: ['statements', 'branches', 'functions']
      }
    });

    this.templates.set('documentation-specialist', {
      name: 'documentation-specialist',
      parent: 'base',
      tools: ['Read', 'Write', 'Edit', 'WebSearch'],
      specialization: {
        formats: ['markdown', 'jsdoc', 'openapi'],
        sections: ['api', 'tutorials', 'guides'],
        audience: ['developers', 'users', 'contributors']
      }
    });

    this.templates.set('performance-optimizer', {
      name: 'performance-optimizer',
      parent: 'base',
      tools: ['Read', 'Edit', 'Bash', 'Grep'],
      specialization: {
        metrics: ['latency', 'throughput', 'memory'],
        techniques: ['caching', 'lazy-loading', 'debouncing'],
        profiling: ['cpu', 'memory', 'network']
      }
    });
  }

  async createAgentFromTemplate(templateName, parameters) {
    const template = this.templates.get(templateName);
    if (!template) {
      throw new Error(`Template '${templateName}' not found`);
    }

    // Merge with parent template if exists
    let fullTemplate = template;
    if (template.parent) {
      const parentTemplate = this.templates.get(template.parent);
      fullTemplate = this.mergeTemplates(parentTemplate, template);
    }

    // Compile template
    const compiled = Handlebars.compile(fullTemplate.template);
    
    // Generate agent content
    const agentContent = compiled({
      ...parameters,
      createdDate: new Date().toISOString(),
      tools: fullTemplate.tools,
      specializationParams: JSON.stringify(fullTemplate.specialization || {}, null, 2)
    });

    return {
      content: agentContent,
      metadata: {
        template: templateName,
        created: new Date().toISOString(),
        parameters
      }
    };
  }

  mergeTemplates(parent, child) {
    return {
      ...parent,
      ...child,
      tools: [...new Set([...parent.tools, ...child.tools])],
      capabilities: [...new Set([
        ...(parent.capabilities || []),
        ...(child.capabilities || [])
      ])]
    };
  }

  async registerCustomTemplate(name, templateConfig) {
    // Validate template
    this.validateTemplate(templateConfig);
    
    // Store template
    this.templates.set(name, templateConfig);
    
    // Persist to disk
    const customTemplatesPath = path.join(this.templatesDir, 'custom');
    await fs.ensureDir(customTemplatesPath);
    await fs.writeJson(
      path.join(customTemplatesPath, `${name}.json`),
      templateConfig,
      { spaces: 2 }
    );
    
    return { success: true, name };
  }

  validateTemplate(template) {
    const required = ['name', 'description', 'tools'];
    for (const field of required) {
      if (!template[field]) {
        throw new Error(`Template missing required field: ${field}`);
      }
    }
    
    if (template.parent && !this.templates.has(template.parent)) {
      throw new Error(`Parent template '${template.parent}' not found`);
    }
  }

  listTemplates() {
    return Array.from(this.templates.entries()).map(([name, template]) => ({
      name,
      description: template.description,
      parent: template.parent,
      tools: template.tools,
      specialization: template.specialization
    }));
  }
}

module.exports = AgentTemplateSystem;
```

### Step 2: Implement Agent Spawning

Create `.claude-collective/lib/agent-spawner.js`:

```javascript
const fs = require('fs-extra');
const path = require('path');
const crypto = require('crypto');
const AgentTemplateSystem = require('./agent-templates');
const AgentRegistry = require('./agent-registry');
const { MetricsCollector } = require('./metrics');

class AgentSpawner {
  constructor() {
    this.templateSystem = new AgentTemplateSystem();
    this.registry = new AgentRegistry();
    this.metrics = new MetricsCollector();
    this.spawnedAgents = new Map();
  }

  async spawnAgent(config) {
    const startTime = Date.now();
    
    try {
      // Generate unique agent ID
      const agentId = this.generateAgentId(config.name);
      
      // Determine template based on requirements
      const template = await this.selectTemplate(config);
      
      // Create agent from template
      const agent = await this.templateSystem.createAgentFromTemplate(
        template,
        {
          agentName: config.name || agentId,
          agentType: config.type || 'dynamic',
          specialization: config.specialization || 'general',
          purpose: config.purpose || 'Task-specific processing',
          responsibilities: config.responsibilities || [],
          metrics: config.metrics || [],
          incomingHandoffs: config.incomingHandoffs || [],
          outgoingHandoffs: config.outgoingHandoffs || [],
          testContracts: await this.generateTestContracts(config),
          primeDirective: config.primeDirective || 
            'Complete assigned tasks efficiently while maintaining quality',
          principles: config.principles || [
            'Follow hub coordination',
            'Validate inputs and outputs',
            'Report completion status'
          ],
          implementationNotes: config.notes || ''
        }
      );
      
      // Write agent file
      const agentPath = await this.writeAgentFile(agentId, agent);
      
      // Register agent
      await this.registry.registerAgent({
        id: agentId,
        name: config.name,
        type: 'dynamic',
        template,
        path: agentPath,
        created: new Date().toISOString(),
        status: 'active',
        metadata: agent.metadata
      });
      
      // Create test contracts
      await this.createTestContracts(agentId, config);
      
      // Track metrics
      this.metrics.recordEvent('agent_spawned', {
        agentId,
        template,
        duration: Date.now() - startTime,
        purpose: config.purpose
      });
      
      // Store in active agents
      this.spawnedAgents.set(agentId, {
        config,
        created: new Date().toISOString(),
        status: 'active',
        path: agentPath
      });
      
      return {
        success: true,
        agentId,
        path: agentPath,
        message: `Agent '${agentId}' spawned successfully`,
        invocation: `@${agentId} "your request"`
      };
      
    } catch (error) {
      this.metrics.recordEvent('agent_spawn_failed', {
        error: error.message,
        config
      });
      
      throw error;
    }
  }

  async selectTemplate(config) {
    // Intelligence to select best template based on requirements
    const templateScores = new Map();
    
    for (const [name, template] of this.templateSystem.templates) {
      let score = 0;
      
      // Check tool requirements
      if (config.requiredTools) {
        const toolMatch = config.requiredTools.filter(tool => 
          template.tools.includes(tool)
        ).length;
        score += toolMatch * 10;
      }
      
      // Check specialization match
      if (config.specialization && template.specialization) {
        const specKeys = Object.keys(template.specialization);
        const configKeys = Object.keys(config.specialization);
        const keyMatch = specKeys.filter(key => configKeys.includes(key)).length;
        score += keyMatch * 5;
      }
      
      // Check type match
      if (config.type && name.includes(config.type.toLowerCase())) {
        score += 15;
      }
      
      templateScores.set(name, score);
    }
    
    // Sort by score and return best match
    const sorted = Array.from(templateScores.entries())
      .sort((a, b) => b[1] - a[1]);
    
    // Return best match or default to base
    return sorted[0]?.[1] > 0 ? sorted[0][0] : 'base';
  }

  generateAgentId(name) {
    const timestamp = Date.now().toString(36);
    const random = crypto.randomBytes(4).toString('hex');
    const safeName = (name || 'agent')
      .toLowerCase()
      .replace(/[^a-z0-9]/g, '-')
      .substring(0, 20);
    
    return `${safeName}-${timestamp}-${random}`;
  }

  async writeAgentFile(agentId, agent) {
    const agentsDir = path.join(process.cwd(), '.claude/agents');
    await fs.ensureDir(agentsDir);
    
    const agentPath = path.join(agentsDir, `${agentId}.md`);
    await fs.writeFile(agentPath, agent.content);
    
    return agentPath;
  }

  async generateTestContracts(config) {
    const contracts = [];
    
    // Basic validation contract
    contracts.push({
      name: 'Input Validation',
      code: `
test('validates required inputs', () => {
  const input = { task: '${config.purpose || 'process data'}' };
  expect(input.task).toBeDefined();
  expect(typeof input.task).toBe('string');
});`
    });
    
    // Output contract
    contracts.push({
      name: 'Output Contract',
      code: `
test('produces expected output structure', () => {
  const output = agent.process(validInput);
  expect(output).toHaveProperty('success');
  expect(output).toHaveProperty('result');
  expect(output).toHaveProperty('metadata');
});`
    });
    
    // Add custom contracts
    if (config.testContracts) {
      contracts.push(...config.testContracts);
    }
    
    return contracts;
  }

  async createTestContracts(agentId, config) {
    const testsDir = path.join(
      process.cwd(),
      '.claude-collective/tests/agents',
      agentId
    );
    await fs.ensureDir(testsDir);
    
    // Create test file
    const testContent = `
const { validateAgent } = require('../../lib/agent-validator');

describe('${agentId} Agent Tests', () => {
  let agent;
  
  beforeAll(async () => {
    agent = await loadAgent('${agentId}');
  });
  
  test('agent loads successfully', () => {
    expect(agent).toBeDefined();
    expect(agent.id).toBe('${agentId}');
  });
  
  test('agent has required tools', () => {
    const requiredTools = ${JSON.stringify(config.requiredTools || [])};
    requiredTools.forEach(tool => {
      expect(agent.tools).toContain(tool);
    });
  });
  
  test('agent handles handoffs correctly', async () => {
    const handoffData = {
      from: 'routing-agent',
      to: '${agentId}',
      task: 'test task',
      context: {}
    };
    
    const result = await agent.receiveHandoff(handoffData);
    expect(result.success).toBe(true);
  });
  
  ${config.additionalTests || ''}
});
`;
    
    await fs.writeFile(
      path.join(testsDir, `${agentId}.test.js`),
      testContent
    );
  }

  async despawnAgent(agentId) {
    const agent = this.spawnedAgents.get(agentId);
    if (!agent) {
      throw new Error(`Agent '${agentId}' not found`);
    }
    
    // Update status
    agent.status = 'inactive';
    
    // Archive agent file
    const archiveDir = path.join(
      process.cwd(),
      '.claude-collective/archive/agents'
    );
    await fs.ensureDir(archiveDir);
    
    await fs.move(
      agent.path,
      path.join(archiveDir, `${agentId}.md`),
      { overwrite: true }
    );
    
    // Update registry
    await this.registry.updateAgentStatus(agentId, 'archived');
    
    // Remove from active agents
    this.spawnedAgents.delete(agentId);
    
    // Track metrics
    this.metrics.recordEvent('agent_despawned', { agentId });
    
    return {
      success: true,
      message: `Agent '${agentId}' despawned and archived`
    };
  }

  async recycleAgent(agentId, newConfig) {
    // Despawn existing
    await this.despawnAgent(agentId);
    
    // Spawn with new config
    return await this.spawnAgent({
      ...newConfig,
      name: `recycled-${agentId.split('-')[0]}`
    });
  }

  listActiveAgents() {
    return Array.from(this.spawnedAgents.entries()).map(([id, agent]) => ({
      id,
      name: agent.config.name,
      status: agent.status,
      created: agent.created,
      purpose: agent.config.purpose
    }));
  }

  async getAgentInfo(agentId) {
    const agent = this.spawnedAgents.get(agentId);
    if (!agent) {
      throw new Error(`Agent '${agentId}' not found`);
    }
    
    const registryInfo = await this.registry.getAgent(agentId);
    
    return {
      ...agent,
      registry: registryInfo,
      metrics: await this.metrics.getAgentMetrics(agentId)
    };
  }
}

module.exports = AgentSpawner;
```

### Step 3: Create Agent Registry

Create `.claude-collective/lib/agent-registry.js`:

```javascript
const fs = require('fs-extra');
const path = require('path');
const EventEmitter = require('events');

class AgentRegistry extends EventEmitter {
  constructor() {
    super();
    this.registryPath = path.join(
      process.cwd(),
      '.claude-collective/registry.json'
    );
    this.agents = new Map();
    this.loadRegistry();
  }

  async loadRegistry() {
    if (await fs.pathExists(this.registryPath)) {
      const data = await fs.readJson(this.registryPath);
      data.agents.forEach(agent => {
        this.agents.set(agent.id, agent);
      });
    }
  }

  async saveRegistry() {
    const data = {
      version: '1.0.0',
      updated: new Date().toISOString(),
      agents: Array.from(this.agents.values())
    };
    
    await fs.writeJson(this.registryPath, data, { spaces: 2 });
    this.emit('registry-updated', data);
  }

  async registerAgent(agentInfo) {
    // Validate agent info
    this.validateAgentInfo(agentInfo);
    
    // Check for duplicates
    if (this.agents.has(agentInfo.id)) {
      throw new Error(`Agent '${agentInfo.id}' already registered`);
    }
    
    // Add registration metadata
    const registration = {
      ...agentInfo,
      registered: new Date().toISOString(),
      version: '1.0.0',
      capabilities: await this.detectCapabilities(agentInfo),
      dependencies: await this.detectDependencies(agentInfo),
      performance: {
        invocations: 0,
        successRate: 1.0,
        avgDuration: 0
      }
    };
    
    // Store in registry
    this.agents.set(agentInfo.id, registration);
    await this.saveRegistry();
    
    // Emit event
    this.emit('agent-registered', registration);
    
    return registration;
  }

  validateAgentInfo(info) {
    const required = ['id', 'name', 'type', 'path'];
    for (const field of required) {
      if (!info[field]) {
        throw new Error(`Missing required field: ${field}`);
      }
    }
  }

  async detectCapabilities(agentInfo) {
    const capabilities = [];
    
    // Read agent file to detect capabilities
    if (await fs.pathExists(agentInfo.path)) {
      const content = await fs.readFile(agentInfo.path, 'utf8');
      
      // Detect tools
      const toolMatches = content.match(/## 🛠 Available Tools\n([\s\S]*?)##/);
      if (toolMatches) {
        const tools = toolMatches[1]
          .split('\n')
          .filter(line => line.startsWith('- '))
          .map(line => line.substring(2).trim());
        capabilities.push(...tools.map(tool => `tool:${tool}`));
      }
      
      // Detect specializations
      const specMatches = content.match(/## 🔧 Specialization Parameters\n```json\n([\s\S]*?)```/);
      if (specMatches) {
        try {
          const spec = JSON.parse(specMatches[1]);
          Object.keys(spec).forEach(key => {
            capabilities.push(`spec:${key}`);
          });
        } catch (e) {
          // Invalid JSON, skip
        }
      }
    }
    
    return capabilities;
  }

  async detectDependencies(agentInfo) {
    const dependencies = [];
    
    // Read agent file to detect dependencies
    if (await fs.pathExists(agentInfo.path)) {
      const content = await fs.readFile(agentInfo.path, 'utf8');
      
      // Detect handoff dependencies
      const handoffMatches = content.matchAll(/Routes to:\n([\s\S]*?)##/g);
      for (const match of handoffMatches) {
        const routes = match[1]
          .split('\n')
          .filter(line => line.startsWith('- '))
          .map(line => {
            const parts = line.substring(2).split(':');
            return parts[0].trim();
          });
        dependencies.push(...routes);
      }
    }
    
    return [...new Set(dependencies)];
  }

  async updateAgentStatus(agentId, status) {
    const agent = this.agents.get(agentId);
    if (!agent) {
      throw new Error(`Agent '${agentId}' not found in registry`);
    }
    
    agent.status = status;
    agent.statusUpdated = new Date().toISOString();
    
    await this.saveRegistry();
    this.emit('agent-status-changed', { agentId, status });
    
    return agent;
  }

  async updateAgentPerformance(agentId, metrics) {
    const agent = this.agents.get(agentId);
    if (!agent) {
      throw new Error(`Agent '${agentId}' not found in registry`);
    }
    
    // Update performance metrics
    const perf = agent.performance;
    perf.invocations++;
    
    if (metrics.success !== undefined) {
      perf.successRate = (
        (perf.successRate * (perf.invocations - 1) + (metrics.success ? 1 : 0)) /
        perf.invocations
      );
    }
    
    if (metrics.duration !== undefined) {
      perf.avgDuration = (
        (perf.avgDuration * (perf.invocations - 1) + metrics.duration) /
        perf.invocations
      );
    }
    
    await this.saveRegistry();
    
    return agent;
  }

  async getAgent(agentId) {
    return this.agents.get(agentId);
  }

  async findAgents(criteria) {
    const results = [];
    
    for (const agent of this.agents.values()) {
      let match = true;
      
      // Check status
      if (criteria.status && agent.status !== criteria.status) {
        match = false;
      }
      
      // Check type
      if (criteria.type && agent.type !== criteria.type) {
        match = false;
      }
      
      // Check capabilities
      if (criteria.capabilities) {
        const hasAll = criteria.capabilities.every(cap =>
          agent.capabilities.includes(cap)
        );
        if (!hasAll) match = false;
      }
      
      // Check template
      if (criteria.template && agent.template !== criteria.template) {
        match = false;
      }
      
      if (match) {
        results.push(agent);
      }
    }
    
    return results;
  }

  async getStatistics() {
    const stats = {
      total: this.agents.size,
      byStatus: {},
      byType: {},
      byTemplate: {},
      performance: {
        avgSuccessRate: 0,
        avgDuration: 0,
        totalInvocations: 0
      }
    };
    
    let totalSuccessRate = 0;
    let totalDuration = 0;
    
    for (const agent of this.agents.values()) {
      // Count by status
      stats.byStatus[agent.status] = (stats.byStatus[agent.status] || 0) + 1;
      
      // Count by type
      stats.byType[agent.type] = (stats.byType[agent.type] || 0) + 1;
      
      // Count by template
      if (agent.template) {
        stats.byTemplate[agent.template] = (stats.byTemplate[agent.template] || 0) + 1;
      }
      
      // Aggregate performance
      totalSuccessRate += agent.performance.successRate;
      totalDuration += agent.performance.avgDuration;
      stats.performance.totalInvocations += agent.performance.invocations;
    }
    
    if (this.agents.size > 0) {
      stats.performance.avgSuccessRate = totalSuccessRate / this.agents.size;
      stats.performance.avgDuration = totalDuration / this.agents.size;
    }
    
    return stats;
  }

  async cleanupInactive(daysOld = 7) {
    const cutoff = new Date();
    cutoff.setDate(cutoff.getDate() - daysOld);
    
    const toRemove = [];
    
    for (const [id, agent] of this.agents) {
      if (agent.status === 'archived' || agent.status === 'inactive') {
        const statusDate = new Date(agent.statusUpdated || agent.registered);
        if (statusDate < cutoff) {
          toRemove.push(id);
        }
      }
    }
    
    for (const id of toRemove) {
      this.agents.delete(id);
      this.emit('agent-removed', { agentId: id });
    }
    
    if (toRemove.length > 0) {
      await this.saveRegistry();
    }
    
    return {
      removed: toRemove.length,
      agents: toRemove
    };
  }

  exportRegistry() {
    return {
      version: '1.0.0',
      exported: new Date().toISOString(),
      agents: Array.from(this.agents.values()),
      statistics: this.getStatistics()
    };
  }

  async importRegistry(data) {
    // Validate import data
    if (!data.agents || !Array.isArray(data.agents)) {
      throw new Error('Invalid registry data');
    }
    
    // Clear existing registry
    this.agents.clear();
    
    // Import agents
    for (const agent of data.agents) {
      this.agents.set(agent.id, agent);
    }
    
    await this.saveRegistry();
    this.emit('registry-imported', { count: data.agents.length });
    
    return {
      imported: data.agents.length
    };
  }
}

module.exports = AgentRegistry;
```

### Step 4: Create Spawn Command

Add to `.claude-collective/lib/commands/spawn.js`:

```javascript
const chalk = require('chalk');
const inquirer = require('inquirer');
const AgentSpawner = require('../agent-spawner');

class SpawnCommand {
  constructor() {
    this.spawner = new AgentSpawner();
  }

  async execute(args) {
    console.log(chalk.bold('\n🧬 Dynamic Agent Spawning\n'));
    
    // Parse command
    const { mode, config } = this.parseArgs(args);
    
    switch (mode) {
      case 'quick':
        return await this.quickSpawn(config);
      case 'interactive':
        return await this.interactiveSpawn();
      case 'template':
        return await this.templateSpawn(config);
      case 'clone':
        return await this.cloneAgent(config);
      default:
        return await this.quickSpawn(config);
    }
  }

  parseArgs(args) {
    // Parse: /spawn quick data-processor "Process CSV files"
    // Or: /spawn interactive
    // Or: /spawn template api-integrator --auth=oauth
    
    const parts = args.split(' ');
    const mode = parts[0] || 'quick';
    
    if (mode === 'quick') {
      return {
        mode,
        config: {
          type: parts[1],
          purpose: parts.slice(2).join(' ')
        }
      };
    }
    
    if (mode === 'template') {
      return {
        mode,
        config: {
          template: parts[1],
          options: this.parseOptions(parts.slice(2))
        }
      };
    }
    
    if (mode === 'clone') {
      return {
        mode,
        config: {
          sourceId: parts[1],
          newName: parts[2]
        }
      };
    }
    
    return { mode, config: {} };
  }

  parseOptions(parts) {
    const options = {};
    parts.forEach(part => {
      if (part.startsWith('--')) {
        const [key, value] = part.substring(2).split('=');
        options[key] = value || true;
      }
    });
    return options;
  }

  async quickSpawn(config) {
    console.log(chalk.cyan('Quick spawning agent...'));
    
    const agentConfig = {
      name: config.type || 'dynamic-agent',
      type: config.type || 'general',
      purpose: config.purpose || 'General purpose processing',
      responsibilities: [
        'Process assigned tasks',
        'Validate inputs and outputs',
        'Report completion status'
      ],
      requiredTools: this.inferTools(config.type),
      metrics: [
        { name: 'Task Completion', target: '100%' },
        { name: 'Error Rate', target: '<5%' }
      ]
    };
    
    try {
      const result = await this.spawner.spawnAgent(agentConfig);
      
      console.log(chalk.green('\n✅ Agent spawned successfully!'));
      console.log(chalk.white(`ID: ${result.agentId}`));
      console.log(chalk.white(`Location: ${result.path}`));
      console.log(chalk.yellow(`\nInvoke with: ${result.invocation}`));
      
      return result;
    } catch (error) {
      console.error(chalk.red('❌ Spawn failed:'), error.message);
      throw error;
    }
  }

  async interactiveSpawn() {
    console.log(chalk.cyan('Interactive agent configuration...\n'));
    
    const answers = await inquirer.prompt([
      {
        type: 'input',
        name: 'name',
        message: 'Agent name:',
        default: 'custom-agent'
      },
      {
        type: 'list',
        name: 'template',
        message: 'Base template:',
        choices: [
          'base',
          'data-processor',
          'api-integrator',
          'test-generator',
          'documentation-specialist',
          'performance-optimizer'
        ]
      },
      {
        type: 'input',
        name: 'purpose',
        message: 'Primary purpose:',
        default: 'Specialized task processing'
      },
      {
        type: 'checkbox',
        name: 'tools',
        message: 'Required tools:',
        choices: [
          'Read', 'Write', 'Edit', 'MultiEdit',
          'Bash', 'Grep', 'Glob', 'LS',
          'WebFetch', 'WebSearch',
          'Task', 'TodoWrite'
        ],
        default: ['Read', 'Write', 'Edit']
      },
      {
        type: 'input',
        name: 'responsibilities',
        message: 'Key responsibilities (comma-separated):',
        filter: input => input.split(',').map(r => r.trim())
      },
      {
        type: 'confirm',
        name: 'addTests',
        message: 'Generate test contracts?',
        default: true
      },
      {
        type: 'confirm',
        name: 'addMetrics',
        message: 'Track performance metrics?',
        default: true
      }
    ]);
    
    const agentConfig = {
      name: answers.name,
      type: answers.template,
      purpose: answers.purpose,
      requiredTools: answers.tools,
      responsibilities: answers.responsibilities,
      metrics: answers.addMetrics ? [
        { name: 'Task Completion', target: '100%' },
        { name: 'Response Time', target: '<5s' },
        { name: 'Error Rate', target: '<5%' }
      ] : [],
      testContracts: answers.addTests ? [
        {
          name: 'Task Processing',
          code: `test('processes tasks successfully', async () => {
  const result = await agent.process(testTask);
  expect(result.success).toBe(true);
});`
        }
      ] : []
    };
    
    try {
      const result = await this.spawner.spawnAgent(agentConfig);
      
      console.log(chalk.green('\n✅ Agent configured and spawned!'));
      console.log(chalk.white(`ID: ${result.agentId}`));
      console.log(chalk.white(`Template: ${answers.template}`));
      console.log(chalk.white(`Location: ${result.path}`));
      console.log(chalk.yellow(`\nInvoke with: ${result.invocation}`));
      
      // Offer to test the agent
      const { testNow } = await inquirer.prompt([{
        type: 'confirm',
        name: 'testNow',
        message: 'Test the agent now?',
        default: true
      }]);
      
      if (testNow) {
        console.log(chalk.cyan('\nRunning agent tests...'));
        // Run tests
        const { exec } = require('child_process');
        exec(
          `npm test -- agents/${result.agentId}`,
          { cwd: '.claude-collective' },
          (error, stdout) => {
            if (error) {
              console.error(chalk.red('Tests failed:'), error);
            } else {
              console.log(chalk.green('Tests passed!'));
              console.log(stdout);
            }
          }
        );
      }
      
      return result;
    } catch (error) {
      console.error(chalk.red('❌ Spawn failed:'), error.message);
      throw error;
    }
  }

  async templateSpawn(config) {
    console.log(chalk.cyan(`Spawning from template: ${config.template}`));
    
    const agentConfig = {
      name: `${config.template}-${Date.now()}`,
      type: config.template,
      purpose: `Specialized ${config.template} operations`,
      ...config.options
    };
    
    try {
      const result = await this.spawner.spawnAgent(agentConfig);
      
      console.log(chalk.green('\n✅ Template agent spawned!'));
      console.log(chalk.white(`Template: ${config.template}`));
      console.log(chalk.white(`ID: ${result.agentId}`));
      console.log(chalk.yellow(`\nInvoke with: ${result.invocation}`));
      
      return result;
    } catch (error) {
      console.error(chalk.red('❌ Template spawn failed:'), error.message);
      throw error;
    }
  }

  async cloneAgent(config) {
    console.log(chalk.cyan(`Cloning agent: ${config.sourceId}`));
    
    try {
      // Get source agent info
      const sourceAgent = await this.spawner.getAgentInfo(config.sourceId);
      
      // Create clone config
      const cloneConfig = {
        ...sourceAgent.config,
        name: config.newName || `${sourceAgent.config.name}-clone`
      };
      
      // Spawn clone
      const result = await this.spawner.spawnAgent(cloneConfig);
      
      console.log(chalk.green('\n✅ Agent cloned successfully!'));
      console.log(chalk.white(`Source: ${config.sourceId}`));
      console.log(chalk.white(`Clone ID: ${result.agentId}`));
      console.log(chalk.yellow(`\nInvoke with: ${result.invocation}`));
      
      return result;
    } catch (error) {
      console.error(chalk.red('❌ Clone failed:'), error.message);
      throw error;
    }
  }

  inferTools(type) {
    const toolMap = {
      'data-processor': ['Read', 'Write', 'Bash', 'Grep'],
      'api-integrator': ['WebFetch', 'WebSearch', 'Read', 'Write'],
      'test-generator': ['Read', 'Write', 'Edit', 'Bash'],
      'documentation': ['Read', 'Write', 'Edit', 'WebSearch'],
      'performance': ['Read', 'Edit', 'Bash', 'Grep']
    };
    
    return toolMap[type] || ['Read', 'Write', 'Edit'];
  }
}

module.exports = SpawnCommand;
```

### Step 5: Lifecycle Management

Create `.claude-collective/lib/agent-lifecycle.js`:

```javascript
const EventEmitter = require('events');
const cron = require('node-cron');

class AgentLifecycleManager extends EventEmitter {
  constructor(spawner, registry) {
    super();
    this.spawner = spawner;
    this.registry = registry;
    this.policies = new Map();
    this.monitors = new Map();
    
    this.initializeDefaultPolicies();
    this.startMonitoring();
  }

  initializeDefaultPolicies() {
    // Auto-cleanup policy
    this.policies.set('auto-cleanup', {
      enabled: true,
      idleTimeout: 3600000, // 1 hour
      maxAge: 86400000, // 24 hours
      minPerformance: 0.7
    });
    
    // Auto-scale policy
    this.policies.set('auto-scale', {
      enabled: false,
      maxAgents: 10,
      scaleUpThreshold: 0.8,
      scaleDownThreshold: 0.2
    });
    
    // Health check policy
    this.policies.set('health-check', {
      enabled: true,
      interval: 300000, // 5 minutes
      maxFailures: 3
    });
  }

  startMonitoring() {
    // Run cleanup every hour
    cron.schedule('0 * * * *', () => {
      this.runCleanup();
    });
    
    // Run health checks every 5 minutes
    cron.schedule('*/5 * * * *', () => {
      this.runHealthChecks();
    });
    
    // Monitor performance
    this.registry.on('agent-status-changed', (event) => {
      this.handleStatusChange(event);
    });
  }

  async runCleanup() {
    const policy = this.policies.get('auto-cleanup');
    if (!policy.enabled) return;
    
    console.log('Running agent cleanup...');
    
    const agents = this.spawner.listActiveAgents();
    const now = Date.now();
    const toCleanup = [];
    
    for (const agent of agents) {
      const created = new Date(agent.created).getTime();
      const age = now - created;
      
      // Check age
      if (age > policy.maxAge) {
        toCleanup.push({
          id: agent.id,
          reason: 'max-age-exceeded'
        });
        continue;
      }
      
      // Check idle time
      const lastActive = this.monitors.get(agent.id)?.lastActive || created;
      const idleTime = now - lastActive;
      
      if (idleTime > policy.idleTimeout) {
        toCleanup.push({
          id: agent.id,
          reason: 'idle-timeout'
        });
        continue;
      }
      
      // Check performance
      const metrics = await this.registry.getAgent(agent.id);
      if (metrics?.performance?.successRate < policy.minPerformance) {
        toCleanup.push({
          id: agent.id,
          reason: 'low-performance'
        });
      }
    }
    
    // Cleanup agents
    for (const { id, reason } of toCleanup) {
      console.log(`Cleaning up agent ${id}: ${reason}`);
      await this.spawner.despawnAgent(id);
      this.emit('agent-cleaned-up', { id, reason });
    }
    
    return {
      checked: agents.length,
      cleaned: toCleanup.length,
      agents: toCleanup
    };
  }

  async runHealthChecks() {
    const policy = this.policies.get('health-check');
    if (!policy.enabled) return;
    
    const agents = this.spawner.listActiveAgents();
    const results = [];
    
    for (const agent of agents) {
      const health = await this.checkAgentHealth(agent.id);
      results.push(health);
      
      if (!health.healthy) {
        const failures = this.monitors.get(agent.id)?.failures || 0;
        this.monitors.set(agent.id, {
          ...this.monitors.get(agent.id),
          failures: failures + 1
        });
        
        if (failures + 1 >= policy.maxFailures) {
          console.log(`Agent ${agent.id} failed health checks, despawning...`);
          await this.spawner.despawnAgent(agent.id);
          this.emit('agent-health-failed', { id: agent.id, failures: failures + 1 });
        }
      } else {
        // Reset failure count
        this.monitors.set(agent.id, {
          ...this.monitors.get(agent.id),
          failures: 0
        });
      }
    }
    
    return results;
  }

  async checkAgentHealth(agentId) {
    try {
      const agent = await this.spawner.getAgentInfo(agentId);
      
      return {
        id: agentId,
        healthy: agent.status === 'active',
        status: agent.status,
        performance: agent.registry?.performance,
        lastCheck: new Date().toISOString()
      };
    } catch (error) {
      return {
        id: agentId,
        healthy: false,
        error: error.message,
        lastCheck: new Date().toISOString()
      };
    }
  }

  handleStatusChange(event) {
    // Update last active time
    if (event.status === 'active') {
      this.monitors.set(event.agentId, {
        ...this.monitors.get(event.agentId),
        lastActive: Date.now()
      });
    }
    
    // Check for scaling needs
    this.checkScaling();
  }

  async checkScaling() {
    const policy = this.policies.get('auto-scale');
    if (!policy.enabled) return;
    
    const agents = this.spawner.listActiveAgents();
    const activeCount = agents.filter(a => a.status === 'active').length;
    
    // Calculate load
    let totalLoad = 0;
    for (const agent of agents) {
      const metrics = await this.registry.getAgent(agent.id);
      if (metrics?.performance?.invocations) {
        totalLoad += metrics.performance.invocations;
      }
    }
    
    const avgLoad = activeCount > 0 ? totalLoad / activeCount : 0;
    
    // Scale up
    if (avgLoad > policy.scaleUpThreshold && activeCount < policy.maxAgents) {
      console.log('Scaling up: spawning additional agent');
      await this.spawner.spawnAgent({
        name: 'scaled-agent',
        type: 'general',
        purpose: 'Load balancing'
      });
      this.emit('scaled-up', { count: activeCount + 1 });
    }
    
    // Scale down
    if (avgLoad < policy.scaleDownThreshold && activeCount > 1) {
      console.log('Scaling down: removing idle agent');
      const idleAgent = agents.find(a => {
        const monitor = this.monitors.get(a.id);
        return monitor && Date.now() - monitor.lastActive > 600000; // 10 min idle
      });
      
      if (idleAgent) {
        await this.spawner.despawnAgent(idleAgent.id);
        this.emit('scaled-down', { count: activeCount - 1 });
      }
    }
  }

  updatePolicy(name, config) {
    if (!this.policies.has(name)) {
      throw new Error(`Policy '${name}' not found`);
    }
    
    this.policies.set(name, {
      ...this.policies.get(name),
      ...config
    });
    
    this.emit('policy-updated', { name, config });
  }

  getStatistics() {
    const stats = {
      policies: {},
      monitoring: {
        totalMonitored: this.monitors.size,
        healthyAgents: 0,
        failedAgents: 0
      }
    };
    
    // Policy stats
    for (const [name, policy] of this.policies) {
      stats.policies[name] = {
        enabled: policy.enabled,
        ...policy
      };
    }
    
    // Monitor stats
    for (const [id, monitor] of this.monitors) {
      if (monitor.failures > 0) {
        stats.monitoring.failedAgents++;
      } else {
        stats.monitoring.healthyAgents++;
      }
    }
    
    return stats;
  }
}

module.exports = AgentLifecycleManager;
```

## ✅ Validation Criteria

### Spawning Success
- [ ] Agents spawn in <2 seconds
- [ ] Templates generate correctly
- [ ] Test contracts created
- [ ] Registry updated
- [ ] Invocation command works

### Lifecycle Management
- [ ] Auto-cleanup removes old agents
- [ ] Health checks detect failures
- [ ] Scaling policies work
- [ ] Performance tracked
- [ ] Archive system functional

### Template System
- [ ] Base template works
- [ ] Specialized templates available
- [ ] Custom templates can be added
- [ ] Template inheritance works
- [ ] Validation catches errors

## 🧪 Acceptance Tests

### Test 1: Quick Spawn
```bash
/collective spawn quick data-processor "Process CSV files"

# Expected:
# - Agent spawned with ID
# - File created in .claude/agents/
# - Can invoke with @agent-id
```

### Test 2: Interactive Spawn
```bash
/collective spawn interactive

# Expected:
# - Interactive prompts appear
# - Configuration options work
# - Agent created with selections
# - Tests run if requested
```

### Test 3: Template Spawn
```bash
/collective spawn template api-integrator --auth=oauth

# Expected:
# - Uses api-integrator template
# - Includes OAuth configuration
# - Specialized for API work
```

### Test 4: Lifecycle
```bash
# Let agent idle for configured timeout
# Expected: Auto-cleanup removes agent

# Spawn multiple agents under load
# Expected: Auto-scaling activates
```

## 🚨 Troubleshooting

### Issue: Spawn fails
**Solution**:
1. Check template exists
2. Verify registry writable
3. Ensure unique agent names
4. Check error logs

### Issue: Agent not responding
**Solution**:
1. Verify agent file exists
2. Check registration status
3. Test with simple command
4. Review test contracts

### Issue: Cleanup too aggressive
**Solution**:
1. Adjust timeout policies
2. Increase idle threshold
3. Disable auto-cleanup
4. Monitor manually

## 📊 Metrics to Track

### Spawning Metrics
- Spawn success rate: >95%
- Average spawn time: <2s
- Template usage distribution
- Most common configurations

### Lifecycle Metrics
- Average agent lifespan
- Cleanup reasons breakdown
- Health check pass rate
- Scaling event frequency

### Performance Metrics
- Agent success rates by type
- Response times by template
- Resource usage patterns
- Error rates by specialization

## ✋ Handoff to Phase 8

### Deliverables
- [ ] Template system operational
- [ ] Spawning commands work
- [ ] Registry tracking agents
- [ ] Lifecycle management active
- [ ] Documentation complete

### Ready for Phase 8 When
1. Can spawn agents on-demand ✅
2. Templates generate properly ✅
3. Lifecycle policies enforced ✅
4. Registry maintains state ✅

### Phase 8 Preview
Next, we'll implement the van-maintenance system that keeps the entire collective ecosystem healthy, updated, and optimized.

---

**Phase 7 Duration**: 1 day  
**Critical Success Factor**: Dynamic agent creation  
**Next Phase**: [Phase 8 - Van Maintenance](Phase-8-VanMaintenance.md)