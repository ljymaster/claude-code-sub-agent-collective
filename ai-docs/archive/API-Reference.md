# API Reference

## 📚 Overview

This document provides a complete API reference for the claude-code-sub-agent-collective system, including all classes, methods, commands, and interfaces.

## 🎯 Core APIs

### VanMaintenanceSystem

Main class for system health and maintenance.

```javascript
const VanMaintenanceSystem = require('.claude-collective/lib/van-maintenance');
```

#### Constructor
```javascript
const van = new VanMaintenanceSystem();
```

#### Methods

##### performMaintenance()
Runs complete maintenance cycle.

```javascript
async performMaintenance(): Promise<MaintenanceReport>
```

**Returns:**
```javascript
{
  timestamp: string,      // ISO-8601 timestamp
  health: HealthReport,   // System health status
  repairs: RepairReport[], // Repairs performed
  optimizations: OptimizationReport[], // Optimizations applied
  issues: Issue[],        // Unresolved issues
  recommendations: string[] // Suggested actions
}
```

**Example:**
```javascript
const report = await van.performMaintenance();
console.log(`Health Score: ${report.health.score}/100`);
```

##### runHealthChecks()
Checks system health without repairs.

```javascript
async runHealthChecks(): Promise<HealthReport>
```

**Returns:**
```javascript
{
  healthy: boolean,       // Overall health status
  score: number,         // 0-100 health score
  checks: HealthCheck[], // Individual check results
  issues: Issue[]        // Problems found
}
```

##### runAutoRepairs(issues)
Attempts to repair identified issues.

```javascript
async runAutoRepairs(issues: Issue[]): Promise<RepairReport[]>
```

**Parameters:**
- `issues`: Array of issues to repair

**Returns:**
```javascript
{
  type: string,          // Repair type
  name: string,          // Repair name
  success: boolean,      // Repair success
  fixed: number,         // Issues fixed
  details: string[]      // Repair details
}
```

##### runOptimizations()
Optimizes system performance.

```javascript
async runOptimizations(): Promise<OptimizationReport[]>
```

**Returns:**
```javascript
{
  id: string,            // Optimization ID
  name: string,          // Optimization name
  success: boolean,      // Success status
  improved: boolean,     // Performance improved
  metrics: object        // Improvement metrics
}
```

### AgentSpawner

Dynamic agent creation and management.

```javascript
const AgentSpawner = require('.claude-collective/lib/agent-spawner');
```

#### Constructor
```javascript
const spawner = new AgentSpawner();
```

#### Methods

##### spawnAgent(config)
Creates a new agent dynamically.

```javascript
async spawnAgent(config: AgentConfig): Promise<SpawnResult>
```

**Parameters:**
```javascript
{
  name?: string,         // Agent name (optional)
  type?: string,         // Agent type (optional)
  purpose: string,       // Agent purpose
  specialization?: string, // Specialization area
  requiredTools?: string[], // Required tools
  responsibilities?: string[], // Key responsibilities
  metrics?: MetricConfig[], // Success metrics
  testContracts?: TestContract[], // Validation tests
  principles?: string[]  // Operating principles
}
```

**Returns:**
```javascript
{
  success: boolean,      // Spawn success
  agentId: string,      // Unique agent ID
  path: string,         // Agent file path
  message: string,      // Status message
  invocation: string    // How to invoke agent
}
```

**Example:**
```javascript
const result = await spawner.spawnAgent({
  type: 'data-processor',
  purpose: 'Process CSV files',
  requiredTools: ['Read', 'Write', 'Bash']
});

console.log(`Invoke with: ${result.invocation}`);
```

##### despawnAgent(agentId)
Removes and archives an agent.

```javascript
async despawnAgent(agentId: string): Promise<DespawnResult>
```

##### listActiveAgents()
Lists all currently active agents.

```javascript
listActiveAgents(): AgentInfo[]
```

**Returns:**
```javascript
[{
  id: string,
  name: string,
  status: string,
  created: string,
  purpose: string
}]
```

### AgentRegistry

Agent registration and tracking.

```javascript
const AgentRegistry = require('.claude-collective/lib/agent-registry');
```

#### Methods

##### registerAgent(agentInfo)
Registers a new agent.

```javascript
async registerAgent(agentInfo: AgentInfo): Promise<Registration>
```

##### getAgent(agentId)
Retrieves agent information.

```javascript
async getAgent(agentId: string): Promise<AgentInfo>
```

##### findAgents(criteria)
Searches for agents matching criteria.

```javascript
async findAgents(criteria: SearchCriteria): Promise<AgentInfo[]>
```

**Parameters:**
```javascript
{
  status?: string,       // Agent status
  type?: string,        // Agent type
  template?: string,    // Template used
  capabilities?: string[] // Required capabilities
}
```

##### getStatistics()
Gets registry statistics.

```javascript
async getStatistics(): Promise<RegistryStats>
```

**Returns:**
```javascript
{
  total: number,
  byStatus: object,
  byType: object,
  byTemplate: object,
  performance: {
    avgSuccessRate: number,
    avgDuration: number,
    totalInvocations: number
  }
}
```

### MetricsCollector

Research metrics collection and analysis.

```javascript
const { MetricsCollector } = require('.claude-collective/lib/metrics');
```

#### Constructor
```javascript
const metrics = new MetricsCollector();
```

#### Methods

##### recordEvent(eventType, data)
Records a metric event.

```javascript
recordEvent(eventType: string, data: object): void
```

**Event Types:**
- `task_started`
- `task_completed`
- `handoff_initiated`
- `handoff_completed`
- `context_loaded`
- `agent_invoked`
- `test_executed`
- `error_occurred`

##### startExperiment(config)
Starts an A/B test experiment.

```javascript
async startExperiment(config: ExperimentConfig): Promise<Experiment>
```

**Parameters:**
```javascript
{
  name: string,
  hypothesis: string,
  duration: string,
  groups: {
    control: GroupConfig,
    treatment: GroupConfig
  },
  metrics: string[],
  successCriteria: object
}
```

##### getMetrics(hypothesis)
Gets metrics for a hypothesis.

```javascript
async getMetrics(hypothesis: string): Promise<HypothesisMetrics>
```

**Returns:**
```javascript
{
  hypothesis: string,
  collected: number,     // Data points collected
  metrics: {
    primary: object,
    secondary: object
  },
  validation: {
    supported: boolean,
    confidence: number,
    pValue: number
  }
}
```

##### generateReport()
Generates comprehensive metrics report.

```javascript
async generateReport(): Promise<MetricsReport>
```

### CommandParser

Natural language command processing.

```javascript
const CommandParser = require('.claude-collective/lib/command-parser');
```

#### Constructor
```javascript
const parser = new CommandParser();
```

#### Methods

##### parse(command)
Parses a command string.

```javascript
parse(command: string): ParsedCommand
```

**Returns:**
```javascript
{
  type: string,         // Command type
  subcommand: string,   // Subcommand
  args: string[],       // Arguments
  options: object       // Parsed options
}
```

##### execute(command)
Executes a parsed command.

```javascript
async execute(command: string): Promise<CommandResult>
```

##### registerCommand(pattern, handler)
Registers a custom command.

```javascript
registerCommand(pattern: RegExp, handler: Function): void
```

**Example:**
```javascript
parser.registerCommand(
  /^\/custom (.+)$/,
  async (args) => {
    return { message: `Custom command: ${args}` };
  }
);
```

### AgentTemplateSystem

Template management for dynamic agents.

```javascript
const AgentTemplateSystem = require('.claude-collective/lib/agent-templates');
```

#### Methods

##### createAgentFromTemplate(templateName, parameters)
Creates agent from template.

```javascript
async createAgentFromTemplate(
  templateName: string,
  parameters: object
): Promise<GeneratedAgent>
```

##### registerCustomTemplate(name, templateConfig)
Registers a custom template.

```javascript
async registerCustomTemplate(
  name: string,
  templateConfig: TemplateConfig
): Promise<RegistrationResult>
```

##### listTemplates()
Lists available templates.

```javascript
listTemplates(): TemplateInfo[]
```

## 🔌 Hook APIs

### Hook Configuration

Hooks are configured in `.claude/settings.json`:

```json
{
  "hooks": {
    "EventName": [
      {
        "matcher": "pattern",
        "hooks": [
          {
            "type": "command|prompt",
            "command": "script-path",
            "prompt": "prompt-text"
          }
        ]
      }
    ]
  }
}
```

### Hook Events

#### PreToolUse
Triggered before any tool execution.

**Event Data:**
```javascript
{
  tool: string,         // Tool name
  args: object,        // Tool arguments
  agent: string,       // Current agent
  task: string         // Current task
}
```

#### PostToolUse
Triggered after tool execution.

**Event Data:**
```javascript
{
  tool: string,
  args: object,
  result: any,         // Tool result
  success: boolean,
  duration: number
}
```

#### SubagentStop
Triggered when subagent completes.

**Event Data:**
```javascript
{
  agent: string,
  task: string,
  result: any,
  handoffTo: string    // Next agent
}
```

### Hook Scripts

Hook scripts receive data via environment variables:

```bash
#!/bin/bash
# Hook script example

TOOL_NAME="$CLAUDE_TOOL"
AGENT_NAME="$CLAUDE_AGENT"
TASK_DESC="$CLAUDE_TASK"

# Validate or modify behavior
if [[ "$AGENT_NAME" == "routing-agent" ]] && [[ "$TOOL_NAME" == "Write" ]]; then
  echo "BLOCKED: Routing agent cannot write files"
  exit 1
fi
```

## 🎮 Command APIs

### Collective Commands

#### /collective status
Shows system status.

```
/collective status
```

**Response:**
```javascript
{
  version: string,
  health: number,
  agents: number,
  metrics: boolean,
  hooks: boolean
}
```

#### /collective spawn
Spawns a new agent.

```
/collective spawn [mode] [options]
```

**Modes:**
- `quick`: Fast spawn with defaults
- `interactive`: Guided spawn
- `template`: From template
- `clone`: Clone existing

**Examples:**
```bash
/collective spawn quick data-processor "Process CSV"
/collective spawn interactive
/collective spawn template api-integrator --auth=oauth
/collective spawn clone agent-id new-name
```

### Agent Commands

#### /agent list
Lists all agents.

```
/agent list [--active] [--type=TYPE]
```

#### /agent info
Gets agent information.

```
/agent info <agent-id>
```

#### /agent invoke
Invokes an agent directly.

```
/agent invoke <agent-id> "task description"
```

### Gate Commands

#### /gate validate
Runs validation gates.

```
/gate validate [component]
```

**Components:**
- `all`: All validations
- `agents`: Agent validation
- `hooks`: Hook validation
- `tests`: Test validation
- `metrics`: Metrics validation

#### /gate health
Checks system health.

```
/gate health [--verbose]
```

### Van Commands

#### /van check
Runs health checks.

```
/van check
```

#### /van repair
Auto-repairs issues.

```
/van repair [--force]
```

#### /van optimize
Runs optimizations.

```
/van optimize [--component=COMPONENT]
```

#### /van full
Complete maintenance cycle.

```
/van full
```

## 📊 Metrics APIs

### Hypothesis Metrics

#### JIT Metrics
```javascript
{
  tokenReduction: number,      // Percentage reduced
  contextEfficiency: number,   // Used vs loaded
  loadLatency: number,         // Milliseconds
  taskSuccess: number          // Success rate
}
```

#### Hub-Spoke Metrics
```javascript
{
  routingCompliance: number,   // Through hub percentage
  coordinationSuccess: number, // Successful handoffs
  p2pViolations: number,       // Direct communications
  topologyType: string         // Detected topology
}
```

#### TDD Metrics
```javascript
{
  handoffReliability: number,  // Success rate
  contextPreservation: number, // Context retained
  contractViolations: number,  // Failed contracts
  recoveryRate: number         // Auto-recovery rate
}
```

### Metric Collection

```javascript
// Automatic collection
metrics.recordEvent('task_completed', {
  taskId: 'task-123',
  duration: 1500,
  success: true,
  tokensUsed: 2500
});

// Manual collection
metrics.recordCustomMetric('custom_metric', {
  value: 42,
  unit: 'items',
  timestamp: Date.now()
});
```

### Metric Queries

```javascript
// Get specific metric
const tokenMetrics = await metrics.getMetric('tokenUsage');

// Get time range
const lastHour = await metrics.getMetricsRange(
  Date.now() - 3600000,
  Date.now()
);

// Get aggregated
const aggregated = await metrics.getAggregated('daily');
```

## 🧪 Test APIs

### Test Contract Interface

```javascript
interface TestContract {
  name: string;
  description?: string;
  preconditions: Test[];
  postconditions: Test[];
  rollback?: Function;
}

interface Test {
  name: string;
  test: () => boolean | Promise<boolean>;
  errorMessage?: string;
}
```

### Contract Creation

```javascript
const contract = {
  name: 'Data Processing Handoff',
  
  preconditions: [
    {
      name: 'Valid input data',
      test: () => data !== null && data.length > 0,
      errorMessage: 'Input data is invalid'
    },
    {
      name: 'Agent available',
      test: async () => await checkAgentStatus(agentId),
      errorMessage: 'Target agent not available'
    }
  ],
  
  postconditions: [
    {
      name: 'Processing complete',
      test: () => result.processed === true,
      errorMessage: 'Processing failed'
    },
    {
      name: 'No data loss',
      test: () => result.count === data.length,
      errorMessage: 'Data items lost during processing'
    }
  ],
  
  rollback: async () => {
    await restoreState(previousState);
  }
};
```

### Contract Validation

```javascript
const validator = new ContractValidator();

// Validate contract
const validation = await validator.validate(contract, handoffData);

if (!validation.preconditionsPassed) {
  console.error('Preconditions failed:', validation.failures);
  return;
}

// Execute handoff
const result = await executeHandoff(handoffData);

// Validate postconditions
const postValidation = await validator.validatePost(contract, result);

if (!postValidation.passed) {
  await contract.rollback();
}
```

## 🔄 Event APIs

### Event Emitter

Most classes extend EventEmitter:

```javascript
van.on('maintenance-complete', (report) => {
  console.log('Maintenance finished:', report);
});

registry.on('agent-registered', (agent) => {
  console.log('New agent:', agent.id);
});

metrics.on('experiment-complete', (results) => {
  console.log('Experiment results:', results);
});
```

### Event Types

#### System Events
- `system-start`
- `system-stop`
- `system-error`
- `system-warning`

#### Agent Events
- `agent-spawned`
- `agent-despawned`
- `agent-invoked`
- `agent-completed`
- `agent-failed`

#### Handoff Events
- `handoff-initiated`
- `handoff-validated`
- `handoff-completed`
- `handoff-failed`
- `handoff-rollback`

#### Maintenance Events
- `maintenance-start`
- `maintenance-complete`
- `health-check-complete`
- `repair-complete`
- `optimization-complete`

## 🔧 Utility APIs

### ID Generation

```javascript
const { generateId } = require('.claude-collective/lib/utils');

const id = generateId(); // 'agent-1234abcd-5678'
const customId = generateId('custom'); // 'custom-1234abcd-5678'
```

### File Operations

```javascript
const { ensureDirectory, safeCopy } = require('.claude-collective/lib/utils');

await ensureDirectory('.claude-collective/custom');
await safeCopy('source.md', 'dest.md', { backup: true });
```

### Validation Utilities

```javascript
const { validateAgent, validateContract } = require('.claude-collective/lib/validators');

const agentValid = await validateAgent(agentConfig);
const contractValid = await validateContract(testContract);
```

## 📝 Configuration APIs

### System Configuration

```javascript
const config = require('.claude-collective/lib/config');

// Get configuration
const systemConfig = config.get();

// Update configuration
config.set('metrics.enabled', true);
config.set('maintenance.schedule', '0 2 * * *');

// Save configuration
await config.save();
```

### Environment Variables

```javascript
process.env.COLLECTIVE_DEBUG = 'true';
process.env.COLLECTIVE_METRICS = 'enabled';
process.env.COLLECTIVE_MAINTENANCE = 'auto';
```

## 🚨 Error APIs

### Error Types

```javascript
class CollectiveError extends Error {
  constructor(message, code, details) {
    super(message);
    this.code = code;
    this.details = details;
  }
}

class ValidationError extends CollectiveError {}
class HandoffError extends CollectiveError {}
class AgentError extends CollectiveError {}
class MaintenanceError extends CollectiveError {}
```

### Error Handling

```javascript
try {
  await spawner.spawnAgent(config);
} catch (error) {
  if (error instanceof ValidationError) {
    console.error('Validation failed:', error.details);
  } else if (error instanceof AgentError) {
    console.error('Agent error:', error.code);
  } else {
    console.error('Unknown error:', error);
  }
}
```

### Error Recovery

```javascript
const recovery = new ErrorRecovery();

recovery.registerHandler('HANDOFF_FAILED', async (error) => {
  // Attempt recovery
  await rollbackHandoff(error.handoffId);
  return { recovered: true };
});

const result = await recovery.attempt(async () => {
  return await riskyOperation();
});
```

## 📚 TypeScript Definitions

```typescript
// types.d.ts
export interface Agent {
  id: string;
  name: string;
  type: string;
  status: 'active' | 'inactive' | 'spawning';
  created: Date;
  tools: string[];
  capabilities: string[];
}

export interface Handoff {
  id: string;
  from: string;
  to: string;
  task: any;
  contract: TestContract;
  status: 'pending' | 'validated' | 'completed' | 'failed';
}

export interface Metrics {
  hypothesis: string;
  value: number;
  timestamp: Date;
  metadata?: object;
}

export interface MaintenanceReport {
  timestamp: Date;
  health: HealthReport;
  repairs: RepairReport[];
  optimizations: OptimizationReport[];
}
```

---

**Note**: All APIs are Promise-based and support async/await patterns.
**Version**: 1.0.0
**License**: MIT