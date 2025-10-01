# Phase 5: Command System Implementation

## 🎯 Phase Objective

Implement a natural language command system that provides intuitive interaction with the collective through `/collective`, `/agent`, and `/gate` command suites, enabling users to control and monitor the multi-agent orchestration system.

## 📋 Prerequisites Checklist

- [ ] Phase 4 completed (NPX package functional)
- [ ] Command parser library available
- [ ] Understanding of Claude Code command patterns
- [ ] Behavioral system preventing direct implementation
- [ ] Routing agent operational

## 🚀 Implementation Steps

### Step 1: Create Command Parser Architecture

Create `lib/command-parser.js`:

```javascript
const EventEmitter = require('events');
const chalk = require('chalk');

class CollectiveCommandParser extends EventEmitter {
  constructor() {
    super();
    this.commands = new Map();
    this.aliases = new Map();
    this.history = [];
    this.maxHistory = 100;
    
    this.initializeCommands();
  }

  initializeCommands() {
    // Collective commands
    this.registerCommand('collective', 'route', this.collectiveRoute);
    this.registerCommand('collective', 'status', this.collectiveStatus);
    this.registerCommand('collective', 'test', this.collectiveTest);
    this.registerCommand('collective', 'research', this.collectiveResearch);
    this.registerCommand('collective', 'coordinate', this.collectiveCoordinate);
    this.registerCommand('collective', 'maintain', this.collectiveMaintain);
    this.registerCommand('collective', 'metrics', this.collectiveMetrics);
    this.registerCommand('collective', 'history', this.collectiveHistory);
    
    // Agent commands
    this.registerCommand('agent', 'spawn', this.agentSpawn);
    this.registerCommand('agent', 'list', this.agentList);
    this.registerCommand('agent', 'health', this.agentHealth);
    this.registerCommand('agent', 'handoff', this.agentHandoff);
    this.registerCommand('agent', 'metrics', this.agentMetrics);
    this.registerCommand('agent', 'info', this.agentInfo);
    this.registerCommand('agent', 'test', this.agentTest);
    this.registerCommand('agent', 'kill', this.agentKill);
    
    // Gate commands
    this.registerCommand('gate', 'status', this.gateStatus);
    this.registerCommand('gate', 'enforce', this.gateEnforce);
    this.registerCommand('gate', 'report', this.gateReport);
    this.registerCommand('gate', 'override', this.gateOverride);
    this.registerCommand('gate', 'validate', this.gateValidate);
    this.registerCommand('gate', 'history', this.gateHistory);
    
    // Aliases for convenience
    this.registerAlias('/c', '/collective');
    this.registerAlias('/a', '/agent');
    this.registerAlias('/g', '/gate');
    this.registerAlias('/route', '/collective route');
    this.registerAlias('/spawn', '/agent spawn');
    this.registerAlias('/status', '/collective status');
  }

  registerCommand(namespace, command, handler) {
    const key = `${namespace}:${command}`;
    this.commands.set(key, handler.bind(this));
  }

  registerAlias(alias, command) {
    this.aliases.set(alias, command);
  }

  async parse(input) {
    // Add to history
    this.addToHistory(input);
    
    // Expand aliases
    input = this.expandAliases(input);
    
    // Parse command structure
    const parsed = this.parseCommandStructure(input);
    
    if (!parsed) {
      return {
        success: false,
        error: 'Invalid command format',
        suggestion: this.getSuggestion(input)
      };
    }
    
    const { namespace, command, args, flags } = parsed;
    
    // Find handler
    const handler = this.commands.get(`${namespace}:${command}`);
    
    if (!handler) {
      return {
        success: false,
        error: `Unknown command: /${namespace} ${command}`,
        availableCommands: this.getAvailableCommands(namespace)
      };
    }
    
    try {
      // Execute command
      const result = await handler(args, flags);
      
      // Emit event for metrics
      this.emit('command:executed', {
        namespace,
        command,
        args,
        flags,
        success: true,
        timestamp: Date.now()
      });
      
      return {
        success: true,
        result,
        namespace,
        command
      };
    } catch (error) {
      this.emit('command:error', {
        namespace,
        command,
        error: error.message,
        timestamp: Date.now()
      });
      
      return {
        success: false,
        error: error.message,
        namespace,
        command
      };
    }
  }

  parseCommandStructure(input) {
    // Pattern: /namespace command [args] [--flags]
    const pattern = /^\/(\w+)\s+(\w+)(?:\s+(.*))?$/;
    const match = input.match(pattern);
    
    if (!match) {
      return null;
    }
    
    const [, namespace, command, rest = ''] = match;
    
    // Parse args and flags
    const { args, flags } = this.parseArgsAndFlags(rest);
    
    return {
      namespace,
      command,
      args,
      flags
    };
  }

  parseArgsAndFlags(input) {
    const args = [];
    const flags = {};
    
    // Simple parsing - can be enhanced
    const tokens = input.match(/(?:[^\s"]+|"[^"]*")+/g) || [];
    
    for (const token of tokens) {
      if (token.startsWith('--')) {
        const [key, value = true] = token.slice(2).split('=');
        flags[key] = value === true ? true : value.replace(/^["']|["']$/g, '');
      } else {
        args.push(token.replace(/^["']|["']$/g, ''));
      }
    }
    
    return { args, flags };
  }

  expandAliases(input) {
    for (const [alias, expansion] of this.aliases) {
      if (input.startsWith(alias)) {
        return input.replace(alias, expansion);
      }
    }
    return input;
  }

  addToHistory(command) {
    this.history.unshift({
      command,
      timestamp: Date.now()
    });
    
    if (this.history.length > this.maxHistory) {
      this.history.pop();
    }
  }

  getHistory(limit = 10) {
    return this.history.slice(0, limit);
  }

  getSuggestion(input) {
    // Find closest matching command
    const allCommands = Array.from(this.commands.keys()).map(k => {
      const [ns, cmd] = k.split(':');
      return `/${ns} ${cmd}`;
    });
    
    // Simple Levenshtein distance for suggestions
    const distances = allCommands.map(cmd => ({
      command: cmd,
      distance: this.levenshteinDistance(input, cmd)
    }));
    
    distances.sort((a, b) => a.distance - b.distance);
    
    if (distances[0].distance < 5) {
      return `Did you mean: ${distances[0].command}?`;
    }
    
    return 'Type /collective help for available commands';
  }

  levenshteinDistance(str1, str2) {
    const matrix = [];
    
    for (let i = 0; i <= str2.length; i++) {
      matrix[i] = [i];
    }
    
    for (let j = 0; j <= str1.length; j++) {
      matrix[0][j] = j;
    }
    
    for (let i = 1; i <= str2.length; i++) {
      for (let j = 1; j <= str1.length; j++) {
        if (str2.charAt(i - 1) === str1.charAt(j - 1)) {
          matrix[i][j] = matrix[i - 1][j - 1];
        } else {
          matrix[i][j] = Math.min(
            matrix[i - 1][j - 1] + 1,
            matrix[i][j - 1] + 1,
            matrix[i - 1][j] + 1
          );
        }
      }
    }
    
    return matrix[str2.length][str1.length];
  }

  getAvailableCommands(namespace) {
    const commands = [];
    for (const key of this.commands.keys()) {
      if (key.startsWith(`${namespace}:`)) {
        commands.push(key.replace(`${namespace}:`, ''));
      }
    }
    return commands;
  }

  // Command Handlers - Collective
  async collectiveRoute(args, flags) {
    const request = args.join(' ');
    
    return {
      action: 'route',
      target: '@routing-agent',
      request,
      testRequired: !flags.skipTest,
      metrics: flags.metrics || false,
      output: `Routing to @routing-agent: "${request}"`
    };
  }

  async collectiveStatus(args, flags) {
    const status = await this.getCollectiveStatus();
    
    return {
      action: 'status',
      behavioral: status.behavioral,
      testing: status.testing,
      hooks: status.hooks,
      agents: status.agents,
      metrics: status.metrics,
      issues: status.issues,
      output: this.formatStatus(status, flags.verbose)
    };
  }

  async collectiveTest(args, flags) {
    const testType = args[0] || 'all';
    
    return {
      action: 'test',
      type: testType,
      coverage: flags.coverage || false,
      watch: flags.watch || false,
      output: `Running ${testType} tests...`
    };
  }

  async collectiveResearch(args, flags) {
    const hypothesis = args[0];
    
    if (!hypothesis) {
      return {
        action: 'research',
        error: 'Hypothesis ID required',
        available: ['h1_jitLoading', 'h2_hubSpoke', 'h3_tddHandoff']
      };
    }
    
    return {
      action: 'research',
      hypothesis,
      validate: true,
      metrics: await this.getHypothesisMetrics(hypothesis),
      output: `Validating hypothesis: ${hypothesis}`
    };
  }

  async collectiveCoordinate(args, flags) {
    const task = args.join(' ');
    
    return {
      action: 'coordinate',
      task,
      multiAgent: true,
      plan: await this.generateCoordinationPlan(task),
      output: `Coordinating multi-agent task: "${task}"`
    };
  }

  async collectiveMaintain(args, flags) {
    return {
      action: 'maintain',
      target: '@van-maintenance-agent',
      checkHealth: true,
      repair: flags.repair || false,
      output: 'Invoking van-maintenance-agent for ecosystem health check'
    };
  }

  async collectiveMetrics(args, flags) {
    const metrics = await this.getCollectiveMetrics();
    
    return {
      action: 'metrics',
      handoffs: metrics.handoffs,
      context: metrics.context,
      coordination: metrics.coordination,
      hypotheses: metrics.hypotheses,
      output: this.formatMetrics(metrics, flags.detailed)
    };
  }

  async collectiveHistory(args, flags) {
    const limit = parseInt(args[0]) || 10;
    const history = this.getHistory(limit);
    
    return {
      action: 'history',
      commands: history,
      output: this.formatHistory(history)
    };
  }

  // Command Handlers - Agent
  async agentSpawn(args, flags) {
    const [type, specialization = 'general'] = args;
    
    if (!type) {
      return {
        action: 'spawn',
        error: 'Agent type required',
        available: ['component', 'feature', 'testing', 'research', 'custom']
      };
    }
    
    return {
      action: 'spawn',
      type,
      specialization,
      template: flags.template || 'default',
      testContract: !flags.skipContract,
      output: `Spawning ${type} agent with ${specialization} specialization`
    };
  }

  async agentList(args, flags) {
    const agents = await this.getAvailableAgents();
    
    return {
      action: 'list',
      agents,
      count: agents.length,
      output: this.formatAgentList(agents, flags.detailed)
    };
  }

  async agentHealth(args, flags) {
    const agentId = args[0];
    const health = await this.checkAgentHealth(agentId);
    
    return {
      action: 'health',
      agentId,
      health,
      output: this.formatHealth(health, flags.verbose)
    };
  }

  async agentHandoff(args, flags) {
    const [from, to] = args;
    
    if (!from || !to) {
      return {
        action: 'handoff',
        error: 'Both source and target agents required',
        usage: '/agent handoff <from> <to>'
      };
    }
    
    return {
      action: 'handoff',
      from,
      to,
      manual: true,
      testValidation: !flags.skipTest,
      output: `Manual handoff from ${from} to ${to}`
    };
  }

  async agentMetrics(args, flags) {
    const agentId = args[0];
    const metrics = await this.getAgentMetrics(agentId);
    
    return {
      action: 'metrics',
      agentId,
      metrics,
      output: this.formatAgentMetrics(metrics, flags.detailed)
    };
  }

  async agentInfo(args, flags) {
    const agentId = args[0];
    
    if (!agentId) {
      return {
        action: 'info',
        error: 'Agent ID required'
      };
    }
    
    const info = await this.getAgentInfo(agentId);
    
    return {
      action: 'info',
      agentId,
      info,
      output: this.formatAgentInfo(info)
    };
  }

  async agentTest(args, flags) {
    const agentId = args[0];
    
    return {
      action: 'test',
      agentId,
      testContract: true,
      output: `Testing agent contract: ${agentId}`
    };
  }

  async agentKill(args, flags) {
    const agentId = args[0];
    
    if (!agentId) {
      return {
        action: 'kill',
        error: 'Agent ID required'
      };
    }
    
    return {
      action: 'kill',
      agentId,
      force: flags.force || false,
      output: `Terminating agent: ${agentId}`
    };
  }

  // Command Handlers - Gate
  async gateStatus(args, flags) {
    const status = await this.getGateStatus();
    
    return {
      action: 'status',
      gates: status.gates,
      compliance: status.compliance,
      violations: status.violations,
      output: this.formatGateStatus(status, flags.verbose)
    };
  }

  async gateEnforce(args, flags) {
    const phase = args[0];
    
    if (!phase) {
      return {
        action: 'enforce',
        error: 'Phase required',
        available: ['planning', 'infrastructure', 'implementation', 'testing', 'polish', 'completion']
      };
    }
    
    return {
      action: 'enforce',
      phase,
      strict: flags.strict || false,
      output: `Enforcing ${phase} gate validation`
    };
  }

  async gateReport(args, flags) {
    const report = await this.generateGateReport();
    
    return {
      action: 'report',
      report,
      export: flags.export || false,
      format: flags.format || 'json',
      output: this.formatGateReport(report)
    };
  }

  async gateOverride(args, flags) {
    return {
      action: 'override',
      error: '❌ COLLECTIVE: Gate override not allowed',
      message: 'Quality gates are mandatory and cannot be overridden',
      suggestion: 'Use /gate report to understand failures and fix issues'
    };
  }

  async gateValidate(args, flags) {
    const phase = args[0] || 'current';
    
    return {
      action: 'validate',
      phase,
      results: await this.validateGate(phase),
      output: `Validating ${phase} gate requirements`
    };
  }

  async gateHistory(args, flags) {
    const limit = parseInt(args[0]) || 10;
    const history = await this.getGateHistory(limit);
    
    return {
      action: 'history',
      history,
      output: this.formatGateHistory(history)
    };
  }

  // Helper methods
  async getCollectiveStatus() {
    // Implementation would check actual status
    return {
      behavioral: true,
      testing: true,
      hooks: true,
      agents: ['routing-agent', 'component-agent', 'feature-agent'],
      metrics: true,
      issues: []
    };
  }

  async getHypothesisMetrics(hypothesis) {
    // Implementation would fetch real metrics
    return {
      validated: 42,
      failed: 8,
      successRate: 0.84,
      confidence: 0.95
    };
  }

  async generateCoordinationPlan(task) {
    // Implementation would analyze task and create plan
    return {
      agents: ['component-agent', 'testing-agent'],
      sequence: 'parallel',
      estimatedTime: '5 minutes'
    };
  }

  async getCollectiveMetrics() {
    // Implementation would fetch real metrics
    return {
      handoffs: { total: 100, successful: 85, failed: 15 },
      context: { averageSize: 2500, reduction: 0.35 },
      coordination: { compliance: 0.92, violations: 3 },
      hypotheses: { h1: 0.85, h2: 0.90, h3: 0.82 }
    };
  }

  // Formatting methods
  formatStatus(status, verbose) {
    let output = '📊 Collective Status:\n';
    output += `Behavioral: ${status.behavioral ? '✅' : '❌'}\n`;
    output += `Testing: ${status.testing ? '✅' : '❌'}\n`;
    output += `Hooks: ${status.hooks ? '✅' : '❌'}\n`;
    output += `Agents: ${status.agents.length} active\n`;
    
    if (verbose) {
      output += `\nActive Agents:\n`;
      status.agents.forEach(agent => {
        output += `  - ${agent}\n`;
      });
    }
    
    if (status.issues.length > 0) {
      output += `\n⚠️ Issues:\n`;
      status.issues.forEach(issue => {
        output += `  - ${issue}\n`;
      });
    }
    
    return output;
  }

  formatMetrics(metrics, detailed) {
    let output = '📈 Collective Metrics:\n';
    output += `Handoff Success: ${(metrics.handoffs.successful / metrics.handoffs.total * 100).toFixed(1)}%\n`;
    output += `Context Reduction: ${(metrics.context.reduction * 100).toFixed(1)}%\n`;
    output += `Routing Compliance: ${(metrics.coordination.compliance * 100).toFixed(1)}%\n`;
    
    if (detailed) {
      output += `\nHypothesis Validation:\n`;
      output += `  H1 (JIT Loading): ${(metrics.hypotheses.h1 * 100).toFixed(1)}%\n`;
      output += `  H2 (Hub-Spoke): ${(metrics.hypotheses.h2 * 100).toFixed(1)}%\n`;
      output += `  H3 (TDD Handoff): ${(metrics.hypotheses.h3 * 100).toFixed(1)}%\n`;
    }
    
    return output;
  }

  formatHistory(history) {
    let output = '📜 Command History:\n';
    history.forEach((item, index) => {
      const time = new Date(item.timestamp).toLocaleTimeString();
      output += `${index + 1}. [${time}] ${item.command}\n`;
    });
    return output;
  }

  formatAgentList(agents, detailed) {
    let output = `🤖 Available Agents (${agents.length}):\n`;
    agents.forEach(agent => {
      output += `  - ${agent.id}`;
      if (detailed) {
        output += ` (${agent.type}, ${agent.status})`;
      }
      output += '\n';
    });
    return output;
  }

  formatHealth(health, verbose) {
    let output = '🏥 Agent Health:\n';
    output += `Status: ${health.status}\n`;
    output += `Uptime: ${health.uptime}\n`;
    output += `Memory: ${health.memory}MB\n`;
    
    if (verbose) {
      output += `Last Activity: ${health.lastActivity}\n`;
      output += `Handoffs: ${health.handoffs}\n`;
      output += `Errors: ${health.errors}\n`;
    }
    
    return output;
  }

  formatAgentMetrics(metrics, detailed) {
    let output = '📊 Agent Metrics:\n';
    output += `Tasks Completed: ${metrics.tasksCompleted}\n`;
    output += `Success Rate: ${(metrics.successRate * 100).toFixed(1)}%\n`;
    output += `Avg Response Time: ${metrics.avgResponseTime}ms\n`;
    
    if (detailed) {
      output += `\nHandoff Metrics:\n`;
      output += `  Sent: ${metrics.handoffs.sent}\n`;
      output += `  Received: ${metrics.handoffs.received}\n`;
      output += `  Test Pass Rate: ${(metrics.handoffs.testPassRate * 100).toFixed(1)}%\n`;
    }
    
    return output;
  }

  formatAgentInfo(info) {
    let output = `ℹ️ Agent Information:\n`;
    output += `ID: ${info.id}\n`;
    output += `Type: ${info.type}\n`;
    output += `Specialization: ${info.specialization}\n`;
    output += `Created: ${info.created}\n`;
    output += `Status: ${info.status}\n`;
    output += `Tools: ${info.tools.join(', ')}\n`;
    return output;
  }

  formatGateStatus(status, verbose) {
    let output = '🚪 Gate Status:\n';
    
    status.gates.forEach(gate => {
      const icon = gate.passed ? '✅' : '❌';
      output += `${icon} ${gate.name}`;
      if (verbose && !gate.passed) {
        output += ` - ${gate.reason}`;
      }
      output += '\n';
    });
    
    output += `\nCompliance: ${(status.compliance * 100).toFixed(1)}%\n`;
    
    if (status.violations > 0) {
      output += `⚠️ Violations: ${status.violations}\n`;
    }
    
    return output;
  }

  formatGateReport(report) {
    let output = '📋 Gate Compliance Report:\n';
    output += `Generated: ${report.timestamp}\n`;
    output += `Overall Compliance: ${(report.overallCompliance * 100).toFixed(1)}%\n\n`;
    
    report.phases.forEach(phase => {
      output += `${phase.name}: ${phase.status}\n`;
      if (phase.issues.length > 0) {
        phase.issues.forEach(issue => {
          output += `  - ${issue}\n`;
        });
      }
    });
    
    return output;
  }

  formatGateHistory(history) {
    let output = '📜 Gate History:\n';
    history.forEach(item => {
      const icon = item.passed ? '✅' : '❌';
      output += `${icon} ${item.phase} - ${item.timestamp}\n`;
    });
    return output;
  }
}

module.exports = CollectiveCommandParser;
```

### Step 2: Integrate with Claude Code

Create `.claude/commands/collective-commands.md`:

```markdown
# Collective Command System

The collective uses natural language commands for control and monitoring.

## Available Commands

### /collective Commands
- `/collective route <request>` - Route request to appropriate agent
- `/collective status` - Show system status
- `/collective test [type]` - Run tests
- `/collective research <hypothesis>` - Validate research hypothesis
- `/collective coordinate <task>` - Coordinate multi-agent task
- `/collective maintain` - Invoke van-maintenance
- `/collective metrics` - Show metrics
- `/collective history [limit]` - Show command history

### /agent Commands
- `/agent spawn <type> [specialization]` - Create new agent
- `/agent list` - List available agents
- `/agent health [id]` - Check agent health
- `/agent handoff <from> <to>` - Manual handoff
- `/agent metrics <id>` - Show agent metrics
- `/agent info <id>` - Get agent information
- `/agent test <id>` - Test agent contract
- `/agent kill <id>` - Terminate agent

### /gate Commands
- `/gate status` - Show gate status
- `/gate enforce <phase>` - Enforce gate validation
- `/gate report` - Generate compliance report
- `/gate validate [phase]` - Validate gate requirements
- `/gate history [limit]` - Show gate history

## Aliases
- `/c` → `/collective`
- `/a` → `/agent`
- `/g` → `/gate`
- `/route` → `/collective route`
- `/spawn` → `/agent spawn`
- `/status` → `/collective status`

## Examples

```bash
# Route a request
/collective route create a button component

# Check status
/status

# Spawn specialized agent
/agent spawn testing integration

# Validate hypothesis
/collective research h1_jitLoading

# Check gate compliance
/gate status
```
```

### Step 3: Create Command Integration Hook

Create `.claude/hooks/command-interceptor.sh`:

```bash
#!/bin/bash

# Command Interceptor Hook
# Detects and processes collective commands

set -e

# Read input
INPUT=$(cat)

# Extract message content
MESSAGE=$(echo "$INPUT" | jq -r '.message // ""' 2>/dev/null)

# Check if message starts with command
if [[ "$MESSAGE" =~ ^/[a-z]+ ]]; then
    # This is a command - process it
    
    # Log command
    echo "$(date): Command detected: $MESSAGE" >> /tmp/collective-commands.log
    
    # Parse command using Node.js
    RESULT=$(node -e "
    const CollectiveCommandParser = require('$CLAUDE_PROJECT_DIR/.claude-collective/lib/command-parser');
    const parser = new CollectiveCommandParser();
    
    (async () => {
        const result = await parser.parse('$MESSAGE');
        console.log(JSON.stringify(result));
    })();
    " 2>/dev/null)
    
    if [ $? -eq 0 ]; then
        # Command parsed successfully
        echo "📟 COLLECTIVE COMMAND: Processing..."
        echo "$RESULT" | jq -r '.output // ""'
        
        # Check if routing is needed
        if echo "$RESULT" | jq -e '.target' > /dev/null; then
            TARGET=$(echo "$RESULT" | jq -r '.target')
            REQUEST=$(echo "$RESULT" | jq -r '.request')
            echo "ROUTE_TO: $TARGET with request: $REQUEST" >&2
        fi
        
        # Record metrics
        echo "$RESULT" >> /tmp/collective-command-results.json
        
        exit 0
    else
        # Command parsing failed
        echo "❌ Command parsing failed" >&2
        echo "Use /collective help for available commands" >&2
        exit 1
    fi
fi

# Not a command - pass through
exit 0
```

### Step 4: Create Command Autocomplete

Create `lib/command-autocomplete.js`:

```javascript
class CommandAutocomplete {
  constructor(parser) {
    this.parser = parser;
    this.cache = new Map();
  }

  getSuggestions(partial) {
    // Check cache
    if (this.cache.has(partial)) {
      return this.cache.get(partial);
    }
    
    const suggestions = [];
    
    // Parse partial input
    const parts = partial.split(' ');
    
    if (parts.length === 1 && partial.startsWith('/')) {
      // Suggest namespaces
      suggestions.push(...this.getNamespaceSuggestions(partial));
    } else if (parts.length === 2) {
      // Suggest commands for namespace
      const namespace = parts[0].replace('/', '');
      suggestions.push(...this.getCommandSuggestions(namespace, parts[1]));
    } else if (parts.length > 2) {
      // Suggest arguments
      const namespace = parts[0].replace('/', '');
      const command = parts[1];
      suggestions.push(...this.getArgumentSuggestions(namespace, command, parts.slice(2)));
    }
    
    // Cache results
    this.cache.set(partial, suggestions);
    
    // Clear cache after 60 seconds
    setTimeout(() => this.cache.delete(partial), 60000);
    
    return suggestions;
  }

  getNamespaceSuggestions(partial) {
    const namespaces = ['collective', 'agent', 'gate'];
    const prefix = partial.replace('/', '');
    
    return namespaces
      .filter(ns => ns.startsWith(prefix))
      .map(ns => ({
        text: `/${ns}`,
        description: this.getNamespaceDescription(ns),
        type: 'namespace'
      }));
  }

  getCommandSuggestions(namespace, partial) {
    const commands = this.parser.getAvailableCommands(namespace);
    
    return commands
      .filter(cmd => cmd.startsWith(partial))
      .map(cmd => ({
        text: `/${namespace} ${cmd}`,
        description: this.getCommandDescription(namespace, cmd),
        type: 'command'
      }));
  }

  getArgumentSuggestions(namespace, command, partialArgs) {
    const suggestions = [];
    
    // Command-specific suggestions
    if (namespace === 'collective' && command === 'research') {
      suggestions.push(
        { text: 'h1_jitLoading', description: 'JIT Context Loading hypothesis', type: 'argument' },
        { text: 'h2_hubSpoke', description: 'Hub-and-Spoke Coordination hypothesis', type: 'argument' },
        { text: 'h3_tddHandoff', description: 'Test-Driven Handoffs hypothesis', type: 'argument' }
      );
    } else if (namespace === 'agent' && command === 'spawn') {
      if (partialArgs.length === 1) {
        suggestions.push(
          { text: 'component', description: 'UI component agent', type: 'argument' },
          { text: 'feature', description: 'Business logic agent', type: 'argument' },
          { text: 'testing', description: 'Test creation agent', type: 'argument' },
          { text: 'research', description: 'Research agent', type: 'argument' }
        );
      }
    } else if (namespace === 'gate' && command === 'enforce') {
      suggestions.push(
        { text: 'planning', description: 'Planning phase gate', type: 'argument' },
        { text: 'infrastructure', description: 'Infrastructure phase gate', type: 'argument' },
        { text: 'implementation', description: 'Implementation phase gate', type: 'argument' },
        { text: 'testing', description: 'Testing phase gate', type: 'argument' },
        { text: 'polish', description: 'Polish phase gate', type: 'argument' },
        { text: 'completion', description: 'Completion phase gate', type: 'argument' }
      );
    }
    
    const lastArg = partialArgs[partialArgs.length - 1] || '';
    return suggestions.filter(s => s.text.startsWith(lastArg));
  }

  getNamespaceDescription(namespace) {
    const descriptions = {
      collective: 'System coordination and control',
      agent: 'Agent management and monitoring',
      gate: 'Quality gate enforcement'
    };
    return descriptions[namespace] || '';
  }

  getCommandDescription(namespace, command) {
    const descriptions = {
      'collective:route': 'Route request to appropriate agent',
      'collective:status': 'Show system status',
      'collective:test': 'Run tests',
      'collective:research': 'Validate research hypothesis',
      'collective:coordinate': 'Coordinate multi-agent task',
      'collective:maintain': 'Invoke van-maintenance',
      'agent:spawn': 'Create new agent',
      'agent:list': 'List available agents',
      'agent:health': 'Check agent health',
      'gate:status': 'Show gate status',
      'gate:enforce': 'Enforce gate validation',
      'gate:report': 'Generate compliance report'
    };
    return descriptions[`${namespace}:${command}`] || '';
  }
}

module.exports = CommandAutocomplete;
```

### Step 5: Create Command History Manager

Create `lib/command-history.js`:

```javascript
const fs = require('fs-extra');
const path = require('path');

class CommandHistoryManager {
  constructor(historyFile) {
    this.historyFile = historyFile || path.join(process.cwd(), '.claude-collective', 'command-history.json');
    this.history = [];
    this.maxHistory = 1000;
    this.sessionHistory = [];
    
    this.loadHistory();
  }

  async loadHistory() {
    try {
      if (await fs.pathExists(this.historyFile)) {
        this.history = await fs.readJson(this.historyFile);
      }
    } catch (error) {
      console.error('Failed to load command history:', error);
      this.history = [];
    }
  }

  async saveHistory() {
    try {
      await fs.ensureDir(path.dirname(this.historyFile));
      await fs.writeJson(this.historyFile, this.history, { spaces: 2 });
    } catch (error) {
      console.error('Failed to save command history:', error);
    }
  }

  async addCommand(command, result) {
    const entry = {
      id: Date.now().toString(),
      command,
      result: {
        success: result.success,
        namespace: result.namespace,
        command: result.command,
        error: result.error
      },
      timestamp: new Date().toISOString(),
      session: process.pid
    };
    
    // Add to both histories
    this.history.unshift(entry);
    this.sessionHistory.unshift(entry);
    
    // Trim history
    if (this.history.length > this.maxHistory) {
      this.history = this.history.slice(0, this.maxHistory);
    }
    
    // Save to disk
    await this.saveHistory();
    
    return entry;
  }

  getHistory(limit = 10, filter = {}) {
    let filtered = this.history;
    
    // Apply filters
    if (filter.namespace) {
      filtered = filtered.filter(e => e.result.namespace === filter.namespace);
    }
    
    if (filter.success !== undefined) {
      filtered = filtered.filter(e => e.result.success === filter.success);
    }
    
    if (filter.session) {
      filtered = filtered.filter(e => e.session === filter.session);
    }
    
    if (filter.since) {
      const since = new Date(filter.since);
      filtered = filtered.filter(e => new Date(e.timestamp) > since);
    }
    
    return filtered.slice(0, limit);
  }

  getSessionHistory(limit = 10) {
    return this.sessionHistory.slice(0, limit);
  }

  searchHistory(query, limit = 10) {
    const results = this.history.filter(entry => 
      entry.command.toLowerCase().includes(query.toLowerCase())
    );
    
    return results.slice(0, limit);
  }

  getStatistics() {
    const stats = {
      total: this.history.length,
      successful: 0,
      failed: 0,
      byNamespace: {},
      byCommand: {},
      mostUsed: [],
      recentFailures: []
    };
    
    // Calculate statistics
    this.history.forEach(entry => {
      if (entry.result.success) {
        stats.successful++;
      } else {
        stats.failed++;
      }
      
      // By namespace
      const ns = entry.result.namespace;
      if (ns) {
        stats.byNamespace[ns] = (stats.byNamespace[ns] || 0) + 1;
      }
      
      // By command
      const cmd = `${ns}:${entry.result.command}`;
      if (entry.result.command) {
        stats.byCommand[cmd] = (stats.byCommand[cmd] || 0) + 1;
      }
    });
    
    // Most used commands
    stats.mostUsed = Object.entries(stats.byCommand)
      .sort((a, b) => b[1] - a[1])
      .slice(0, 5)
      .map(([cmd, count]) => ({ command: cmd, count }));
    
    // Recent failures
    stats.recentFailures = this.history
      .filter(e => !e.result.success)
      .slice(0, 5)
      .map(e => ({
        command: e.command,
        error: e.result.error,
        timestamp: e.timestamp
      }));
    
    return stats;
  }

  clearHistory() {
    this.history = [];
    this.sessionHistory = [];
    return this.saveHistory();
  }

  exportHistory(format = 'json') {
    if (format === 'json') {
      return JSON.stringify(this.history, null, 2);
    } else if (format === 'csv') {
      const headers = 'Timestamp,Command,Success,Namespace,Error\n';
      const rows = this.history.map(e => 
        `"${e.timestamp}","${e.command}",${e.result.success},"${e.result.namespace || ''}","${e.result.error || ''}"`
      ).join('\n');
      return headers + rows;
    } else if (format === 'markdown') {
      let md = '# Command History\n\n';
      md += '| Timestamp | Command | Success | Error |\n';
      md += '|-----------|---------|---------|-------|\n';
      this.history.forEach(e => {
        md += `| ${e.timestamp} | ${e.command} | ${e.result.success ? '✅' : '❌'} | ${e.result.error || '-'} |\n`;
      });
      return md;
    }
    
    throw new Error(`Unsupported format: ${format}`);
  }
}

module.exports = CommandHistoryManager;
```

### Step 6: Create Command Help System

Create `lib/command-help.js`:

```javascript
class CommandHelpSystem {
  constructor() {
    this.helpTopics = new Map();
    this.initializeHelp();
  }

  initializeHelp() {
    // Collective help
    this.addHelp('collective', {
      description: 'System coordination and control commands',
      commands: {
        route: {
          syntax: '/collective route <request>',
          description: 'Route request to appropriate agent',
          examples: ['/collective route create a button component'],
          flags: { '--skip-test': 'Skip test validation', '--metrics': 'Include metrics' }
        },
        status: {
          syntax: '/collective status [--verbose]',
          description: 'Show system status',
          examples: ['/collective status', '/collective status --verbose'],
          flags: { '--verbose': 'Show detailed status' }
        },
        test: {
          syntax: '/collective test [type] [--coverage] [--watch]',
          description: 'Run tests',
          examples: ['/collective test', '/collective test handoffs --coverage'],
          flags: { '--coverage': 'Include coverage report', '--watch': 'Watch mode' }
        },
        research: {
          syntax: '/collective research <hypothesis>',
          description: 'Validate research hypothesis',
          examples: ['/collective research h1_jitLoading'],
          arguments: { hypothesis: 'h1_jitLoading, h2_hubSpoke, h3_tddHandoff' }
        },
        coordinate: {
          syntax: '/collective coordinate <task>',
          description: 'Coordinate multi-agent task',
          examples: ['/collective coordinate build a todo app'],
          arguments: { task: 'Complex task description' }
        },
        maintain: {
          syntax: '/collective maintain [--repair]',
          description: 'Invoke van-maintenance-agent',
          examples: ['/collective maintain', '/collective maintain --repair'],
          flags: { '--repair': 'Attempt automatic repair' }
        }
      }
    });

    // Agent help
    this.addHelp('agent', {
      description: 'Agent management and monitoring commands',
      commands: {
        spawn: {
          syntax: '/agent spawn <type> [specialization] [--template]',
          description: 'Create new agent',
          examples: ['/agent spawn testing integration', '/agent spawn component --template=custom'],
          arguments: { 
            type: 'component, feature, testing, research, custom',
            specialization: 'Specific focus area'
          },
          flags: { '--template': 'Use specific template', '--skip-contract': 'Skip test contract' }
        },
        list: {
          syntax: '/agent list [--detailed]',
          description: 'List available agents',
          examples: ['/agent list', '/agent list --detailed'],
          flags: { '--detailed': 'Show detailed information' }
        },
        health: {
          syntax: '/agent health [id] [--verbose]',
          description: 'Check agent health',
          examples: ['/agent health component-agent --verbose'],
          flags: { '--verbose': 'Show detailed health metrics' }
        },
        handoff: {
          syntax: '/agent handoff <from> <to> [--skip-test]',
          description: 'Manual agent handoff',
          examples: ['/agent handoff component-agent testing-agent'],
          arguments: { from: 'Source agent ID', to: 'Target agent ID' },
          flags: { '--skip-test': 'Skip test validation' }
        }
      }
    });

    // Gate help
    this.addHelp('gate', {
      description: 'Quality gate enforcement commands',
      commands: {
        status: {
          syntax: '/gate status [--verbose]',
          description: 'Show gate status',
          examples: ['/gate status', '/gate status --verbose'],
          flags: { '--verbose': 'Show detailed status' }
        },
        enforce: {
          syntax: '/gate enforce <phase> [--strict]',
          description: 'Enforce gate validation',
          examples: ['/gate enforce implementation --strict'],
          arguments: { 
            phase: 'planning, infrastructure, implementation, testing, polish, completion'
          },
          flags: { '--strict': 'Strict enforcement mode' }
        },
        report: {
          syntax: '/gate report [--export] [--format]',
          description: 'Generate compliance report',
          examples: ['/gate report --export --format=json'],
          flags: { 
            '--export': 'Export report to file',
            '--format': 'Output format (json, markdown, html)'
          }
        }
      }
    });
  }

  addHelp(namespace, helpData) {
    this.helpTopics.set(namespace, helpData);
  }

  getHelp(query = '') {
    if (!query) {
      return this.getGeneralHelp();
    }
    
    const parts = query.split(' ');
    
    if (parts.length === 1) {
      // Namespace help
      return this.getNamespaceHelp(parts[0]);
    } else {
      // Command help
      return this.getCommandHelp(parts[0], parts[1]);
    }
  }

  getGeneralHelp() {
    let help = '# Claude Code Sub-Agent Collective - Command Help\n\n';
    help += '## Available Command Namespaces\n\n';
    
    for (const [namespace, data] of this.helpTopics) {
      help += `### /${namespace}\n`;
      help += `${data.description}\n\n`;
      
      const commands = Object.keys(data.commands);
      help += 'Commands: ' + commands.map(c => `\`${c}\``).join(', ') + '\n\n';
    }
    
    help += '## Usage\n';
    help += '- Type `/[namespace] [command] [args]` to execute a command\n';
    help += '- Type `/[namespace] help` for namespace-specific help\n';
    help += '- Type `/[namespace] [command] --help` for command-specific help\n\n';
    
    help += '## Aliases\n';
    help += '- `/c` → `/collective`\n';
    help += '- `/a` → `/agent`\n';
    help += '- `/g` → `/gate`\n';
    
    return help;
  }

  getNamespaceHelp(namespace) {
    const helpData = this.helpTopics.get(namespace);
    
    if (!helpData) {
      return `Unknown namespace: ${namespace}\n\nAvailable namespaces: ${Array.from(this.helpTopics.keys()).join(', ')}`;
    }
    
    let help = `# /${namespace} - ${helpData.description}\n\n`;
    help += '## Available Commands\n\n';
    
    for (const [command, cmdData] of Object.entries(helpData.commands)) {
      help += `### ${command}\n`;
      help += `**Syntax:** \`${cmdData.syntax}\`\n`;
      help += `**Description:** ${cmdData.description}\n`;
      
      if (cmdData.examples && cmdData.examples.length > 0) {
        help += `**Examples:**\n`;
        cmdData.examples.forEach(ex => {
          help += `  \`${ex}\`\n`;
        });
      }
      
      help += '\n';
    }
    
    return help;
  }

  getCommandHelp(namespace, command) {
    const helpData = this.helpTopics.get(namespace);
    
    if (!helpData) {
      return `Unknown namespace: ${namespace}`;
    }
    
    const cmdData = helpData.commands[command];
    
    if (!cmdData) {
      return `Unknown command: /${namespace} ${command}\n\nAvailable commands: ${Object.keys(helpData.commands).join(', ')}`;
    }
    
    let help = `# /${namespace} ${command}\n\n`;
    help += `**Description:** ${cmdData.description}\n\n`;
    help += `**Syntax:** \`${cmdData.syntax}\`\n\n`;
    
    if (cmdData.arguments) {
      help += '**Arguments:**\n';
      for (const [arg, desc] of Object.entries(cmdData.arguments)) {
        help += `  - \`${arg}\`: ${desc}\n`;
      }
      help += '\n';
    }
    
    if (cmdData.flags) {
      help += '**Flags:**\n';
      for (const [flag, desc] of Object.entries(cmdData.flags)) {
        help += `  - \`${flag}\`: ${desc}\n`;
      }
      help += '\n';
    }
    
    if (cmdData.examples && cmdData.examples.length > 0) {
      help += '**Examples:**\n';
      cmdData.examples.forEach(ex => {
        help += `  \`${ex}\`\n`;
      });
    }
    
    return help;
  }
}

module.exports = CommandHelpSystem;
```

## ✅ Validation Criteria

### Command System Success
- [ ] Commands parse correctly
- [ ] Routing works through commands
- [ ] History is tracked
- [ ] Autocomplete functions
- [ ] Help system accessible

### User Experience
- [ ] Commands feel natural
- [ ] Errors are helpful
- [ ] Suggestions work
- [ ] Response time <100ms
- [ ] Documentation clear

### Integration Success
- [ ] Hooks intercept commands
- [ ] Commands trigger agents
- [ ] Metrics collected
- [ ] Tests can be run via commands
- [ ] Gates enforced via commands

## 🧪 Acceptance Tests

### Test 1: Basic Command
```bash
/collective status

# Expected:
# - Status displayed
# - No errors
# - Quick response
```

### Test 2: Routing Command
```bash
/collective route create a button

# Expected:
# - Routes to @routing-agent
# - Shows routing decision
# - Triggers agent
```

### Test 3: Agent Management
```bash
/agent list
/agent spawn testing unit
/agent health testing-agent

# Expected:
# - Lists agents
# - Spawns new agent
# - Shows health status
```

### Test 4: Gate Enforcement
```bash
/gate status
/gate enforce implementation

# Expected:
# - Shows gate status
# - Enforces validation
# - Reports results
```

## 🚨 Troubleshooting

### Issue: Commands not recognized
**Solution**:
1. Check command syntax
2. Verify parser is loaded
3. Check for typos
4. Use help command

### Issue: Slow response
**Solution**:
1. Check parser performance
2. Optimize command matching
3. Cache common commands
4. Profile execution

### Issue: History not saved
**Solution**:
1. Check file permissions
2. Verify path exists
3. Check disk space
4. Review error logs

## 📊 Metrics to Track

### Command Metrics
- Command frequency by type
- Success/failure rates
- Response times
- Most used commands
- Error patterns

### User Metrics
- Command discovery rate
- Help usage frequency
- Autocomplete usage
- Error recovery success

## ✋ Handoff to Phase 6

### Deliverables
- [ ] Complete command parser
- [ ] All command handlers implemented
- [ ] History tracking functional
- [ ] Autocomplete working
- [ ] Help system complete

### Ready for Phase 6 When
1. Commands execute reliably ✅
2. Integration with agents works ✅
3. History and metrics tracked ✅
4. User experience smooth ✅

### Phase 6 Preview
Next, we'll implement the research metrics system that collects data to validate our Context Engineering hypotheses.

---

**Phase 5 Duration**: 1 day  
**Critical Success Factor**: Natural command interaction  
**Next Phase**: [Phase 6 - Research Metrics](Phase-6-Metrics.md)