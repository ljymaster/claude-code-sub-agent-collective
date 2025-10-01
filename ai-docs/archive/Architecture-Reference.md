# Architecture Reference

## 🏗 System Architecture Overview

The claude-code-sub-agent-collective implements a hub-and-spoke architecture with test-driven handoffs and just-in-time context loading.

```
┌─────────────────────────────────────────────────────────────┐
│                     BEHAVIORAL CLAUDE.md                     │
│                  (Operating System Layer)                    │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                      @routing-agent                          │
│                         (Hub)                                │
│  ┌────────────┐  ┌────────────┐  ┌────────────┐            │
│  │  Request   │  │   Route    │  │  Validate  │            │
│  │  Handler   │──│   Logic    │──│  Handoff   │            │
│  └────────────┘  └────────────┘  └────────────┘            │
└─────────────────────────────────────────────────────────────┘
         │              │              │              │
         ▼              ▼              ▼              ▼
┌──────────────┐ ┌──────────────┐ ┌──────────────┐ ┌──────────────┐
│ Specialized  │ │ Specialized  │ │ Specialized  │ │     Van      │
│   Agent 1    │ │   Agent 2    │ │   Agent N    │ │ Maintenance  │
└──────────────┘ └──────────────┘ └──────────────┘ └──────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                    Test-Driven Handoffs                      │
│  ┌────────────┐  ┌────────────┐  ┌────────────┐            │
│  │Precondition│  │  Execute   │  │Postcondition│           │
│  │   Tests    │──│  Handoff   │──│   Tests     │           │
│  └────────────┘  └────────────┘  └────────────┘            │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                      Metrics Collection                      │
│  ┌────────────┐  ┌────────────┐  ┌────────────┐            │
│  │    JIT     │  │ Hub-Spoke  │  │    TDD     │            │
│  │  Metrics   │  │  Metrics   │  │  Metrics   │            │
│  └────────────┘  └────────────┘  └────────────┘            │
└─────────────────────────────────────────────────────────────┘
```

## 🎯 Core Components

### 1. Behavioral Operating System (CLAUDE.md)

**Purpose**: Define system behavior and prime directives

**Architecture**:
```
CLAUDE.md
├── PRIME DIRECTIVE (Never implement directly)
├── CONTEXT ENGINEERING HYPOTHESES
├── HUB-AND-SPOKE COORDINATION
├── AGENT REGISTRY
└── HANDOFF PROTOCOLS
```

**Key Principles**:
- Single source of behavioral truth
- Loaded at session start
- Immutable during execution
- Enforced by hooks

### 2. Hub Component (@routing-agent)

**Purpose**: Central coordination and routing

**Architecture**:
```javascript
class RoutingAgent {
  constructor() {
    this.agents = new Map();      // Available agents
    this.routes = new Map();      // Routing rules
    this.handoffs = new Queue();  // Pending handoffs
    this.metrics = new Metrics(); // Performance tracking
  }
  
  async route(request) {
    // 1. Parse request
    const task = this.parseTask(request);
    
    // 2. Select agent
    const agent = this.selectAgent(task);
    
    // 3. Validate handoff
    const contract = this.createContract(task, agent);
    
    // 4. Execute handoff
    const result = await this.executeHandoff(agent, task, contract);
    
    // 5. Return to user
    return this.formatResponse(result);
  }
}
```

**Responsibilities**:
- ALL requests enter here
- NEVER implements directly
- Routes to specialized agents
- Validates handoffs
- Collects metrics

### 3. Specialized Agents (Spokes)

**Purpose**: Domain-specific task execution

**Standard Structure**:
```markdown
# Agent Name

## 🤖 Agent Profile
- Type, Version, Specialization

## 🎯 Core Responsibilities
- What this agent does

## 🛠 Available Tools
- Permitted Claude Code tools

## 🔄 Handoff Protocol
- Incoming conditions
- Outgoing conditions

## 🧪 Test Contracts
- Validation tests

## 💡 Behavioral Directives
- Agent-specific rules
```

**Key Principles**:
- Single responsibility
- Never communicate directly
- Always return to hub
- Validate inputs/outputs

### 4. Test-Driven Handoff System

**Purpose**: Ensure reliable agent communication

**Architecture**:
```javascript
class HandoffSystem {
  constructor() {
    this.contracts = new Map();
    this.validators = new Map();
    this.history = [];
  }
  
  createHandoff(from, to, task) {
    return {
      id: generateId(),
      timestamp: Date.now(),
      from,
      to,
      task,
      contract: this.generateContract(from, to, task),
      status: 'pending'
    };
  }
  
  async validate(handoff) {
    // 1. Check preconditions
    const preCheck = await this.checkPreconditions(handoff.contract);
    if (!preCheck.passed) {
      return { valid: false, reason: 'precondition-failed' };
    }
    
    // 2. Execute handoff
    const result = await this.execute(handoff);
    
    // 3. Check postconditions
    const postCheck = await this.checkPostconditions(handoff.contract, result);
    if (!postCheck.passed) {
      await this.rollback(handoff);
      return { valid: false, reason: 'postcondition-failed' };
    }
    
    return { valid: true, result };
  }
}
```

### 5. Hook System

**Purpose**: Enforce behaviors and collect metrics

**Architecture**:
```
.claude/
├── settings.json          # Hook configuration
└── hooks/
    ├── directive-enforcer.sh    # Enforce prime directive
    ├── test-driven-handoff.sh   # Validate handoffs
    └── collective-metrics.sh    # Collect metrics
```

**Hook Flow**:
```
Event Triggered
       │
       ▼
Match Event Pattern
       │
       ▼
Execute Hook Script
       │
       ▼
Process Hook Result
       │
       ▼
Continue or Block
```

### 6. Metrics Collection System

**Purpose**: Track research hypotheses

**Architecture**:
```javascript
class MetricsSystem {
  constructor() {
    this.collectors = {
      jit: new JITCollector(),
      hubSpoke: new HubSpokeCollector(),
      tdd: new TDDCollector()
    };
    
    this.storage = new MetricsStorage();
    this.reporter = new MetricsReporter();
  }
  
  collect(event) {
    // Route to appropriate collector
    Object.values(this.collectors).forEach(collector => {
      if (collector.shouldCollect(event)) {
        collector.collect(event);
      }
    });
  }
  
  async report() {
    const data = await this.storage.aggregate();
    return this.reporter.generate(data);
  }
}
```

### 7. Dynamic Agent System

**Purpose**: Create agents on-demand

**Architecture**:
```javascript
class DynamicAgentSystem {
  constructor() {
    this.templates = new TemplateManager();
    this.spawner = new AgentSpawner();
    this.registry = new AgentRegistry();
    this.lifecycle = new LifecycleManager();
  }
  
  async spawnAgent(requirements) {
    // 1. Select template
    const template = this.templates.select(requirements);
    
    // 2. Generate agent
    const agent = await this.spawner.spawn(template, requirements);
    
    // 3. Register agent
    await this.registry.register(agent);
    
    // 4. Start lifecycle monitoring
    this.lifecycle.monitor(agent);
    
    return agent;
  }
}
```

### 8. Van Maintenance System

**Purpose**: Keep ecosystem healthy

**Architecture**:
```javascript
class VanMaintenance {
  constructor() {
    this.healthChecks = new Map();
    this.repairs = new Map();
    this.optimizations = new Map();
    this.scheduler = new MaintenanceScheduler();
  }
  
  async performMaintenance() {
    // 1. Health checks
    const health = await this.runHealthChecks();
    
    // 2. Auto-repairs
    if (health.issues.length > 0) {
      await this.runRepairs(health.issues);
    }
    
    // 3. Optimizations
    await this.runOptimizations();
    
    // 4. Report
    return this.generateReport();
  }
}
```

## 🔄 Data Flow Architecture

### Request Flow
```
User Request
     │
     ▼
CLAUDE.md (Behavioral OS)
     │
     ▼
@routing-agent (Hub)
     │
     ├─► Agent Selection
     │
     ├─► Contract Creation
     │
     ├─► Handoff Validation
     │
     ▼
Specialized Agent
     │
     ├─► Task Execution
     │
     ├─► Result Validation
     │
     ▼
@routing-agent (Return)
     │
     ▼
User Response
```

### Context Loading Flow (JIT)
```
Initial State: Minimal Context
            │
            ▼
Task Requires Agent
            │
            ▼
Load Agent Context Only
            │
            ▼
Execute Task
            │
            ▼
Unload Agent Context
            │
            ▼
Return to Minimal
```

### Handoff Validation Flow
```
Handoff Initiated
        │
        ▼
Load Test Contract
        │
        ▼
Validate Preconditions
        │
        ├─► PASS ──► Execute Handoff
        │                    │
        │                    ▼
        │            Validate Postconditions
        │                    │
        │            ├─► PASS ──► Complete
        │            │
        │            └─► FAIL ──► Rollback
        │
        └─► FAIL ──► Reject Handoff
```

## 🏛 System Layers

### Layer 1: Behavioral Layer
- CLAUDE.md
- Prime directives
- Operating principles

### Layer 2: Coordination Layer
- Routing agent
- Handoff protocols
- Communication rules

### Layer 3: Execution Layer
- Specialized agents
- Task processing
- Tool usage

### Layer 4: Validation Layer
- Test contracts
- Hook system
- Enforcement

### Layer 5: Observation Layer
- Metrics collection
- Performance monitoring
- Research tracking

### Layer 6: Maintenance Layer
- Van maintenance
- Self-healing
- Optimization

## 📦 Directory Structure

```
project/
├── CLAUDE.md                      # Behavioral OS
├── .claude/
│   ├── settings.json             # Hook configuration
│   ├── agents/                   # Agent definitions
│   │   ├── routing-agent.md     # Hub agent
│   │   ├── van-maintenance.md   # Maintenance agent
│   │   └── *.md                 # Specialized agents
│   ├── hooks/                    # Hook scripts
│   │   ├── directive-enforcer.sh
│   │   ├── test-driven-handoff.sh
│   │   └── collective-metrics.sh
│   └── commands/                 # Custom commands
│       └── *.md
├── .claude-collective/
│   ├── package.json             # Test dependencies
│   ├── jest.config.js          # Test configuration
│   ├── tests/                   # Test suites
│   │   ├── handoffs/           # Handoff tests
│   │   ├── contracts/          # Contract tests
│   │   └── directives/         # Directive tests
│   ├── metrics/                # Metrics storage
│   │   └── *.json
│   ├── lib/                    # Core libraries
│   │   ├── van-maintenance.js
│   │   ├── agent-spawner.js
│   │   ├── metrics.js
│   │   └── command-parser.js
│   ├── templates/              # Agent templates
│   └── registry.json           # Agent registry
└── /tmp/
    ├── handoff-*.json          # Handoff records
    └── collective-*.log        # System logs
```

## 🔐 Security Architecture

### Principle of Least Privilege
```javascript
const agentPermissions = {
  'routing-agent': ['Read', 'Task'], // No Write
  'data-processor': ['Read', 'Write', 'Edit'],
  'api-integrator': ['WebFetch', 'WebSearch'],
  'van-maintenance': ['*'] // System agent
};
```

### Validation Boundaries
```
External Input
      │
      ▼
Input Validation
      │
      ▼
Sanitization
      │
      ▼
Contract Validation
      │
      ▼
Execution
      │
      ▼
Output Validation
      │
      ▼
Response
```

### Isolation Mechanisms
- Agents isolated in separate contexts
- No direct agent-to-agent communication
- Handoffs validated at boundaries
- Rollback on validation failure

## 🚀 Scalability Architecture

### Horizontal Scaling
```javascript
class ScalableArchitecture {
  constructor() {
    this.agentPools = new Map();
    this.loadBalancer = new LoadBalancer();
  }
  
  async scaleAgent(agentType, instances) {
    const pool = [];
    for (let i = 0; i < instances; i++) {
      const agent = await this.spawnAgent(agentType);
      pool.push(agent);
    }
    this.agentPools.set(agentType, pool);
  }
  
  async route(task) {
    const agentType = this.selectAgentType(task);
    const pool = this.agentPools.get(agentType);
    const agent = this.loadBalancer.select(pool);
    return await agent.process(task);
  }
}
```

### Performance Optimization
- JIT context loading reduces memory
- Lazy agent spawning
- Connection pooling for tools
- Cache frequently used contexts
- Async handoff processing

## 🔄 State Management

### System State
```javascript
const systemState = {
  agents: {
    active: Map,      // Currently active agents
    available: Map,   // Registered agents
    spawned: Map      // Dynamically created
  },
  
  handoffs: {
    pending: Queue,   // Waiting for processing
    active: Map,      // Currently executing
    completed: Array  // Historical record
  },
  
  metrics: {
    current: Object,  // Live metrics
    aggregated: Object, // Rolled up metrics
    baseline: Object  // Comparison baseline
  },
  
  health: {
    score: Number,    // 0-100
    issues: Array,    // Current problems
    repairs: Array    // Applied fixes
  }
};
```

### State Persistence
```javascript
class StatePersistence {
  async save() {
    const state = {
      timestamp: Date.now(),
      agents: this.serializeAgents(),
      metrics: this.serializeMetrics(),
      health: this.serializeHealth()
    };
    
    await fs.writeJson('.claude-collective/state.json', state);
  }
  
  async restore() {
    const state = await fs.readJson('.claude-collective/state.json');
    
    this.restoreAgents(state.agents);
    this.restoreMetrics(state.metrics);
    this.restoreHealth(state.health);
  }
}
```

## 🎭 Behavioral Enforcement

### Enforcement Points
1. **Load Time**: CLAUDE.md loaded
2. **Parse Time**: Request analyzed
3. **Route Time**: Agent selected
4. **Handoff Time**: Contract validated
5. **Execute Time**: Task processed
6. **Return Time**: Result validated

### Enforcement Mechanisms
```bash
# directive-enforcer.sh
#!/bin/bash

# Check for direct implementation attempt
if [[ "$CLAUDE_TASK" == *"implement"* ]] && [[ "$CLAUDE_AGENT" == "routing-agent" ]]; then
  echo "BLOCKED: Prime directive violation - routing-agent cannot implement directly"
  exit 1
fi
```

## 🔌 Extension Points

### Custom Agents
```javascript
// Extension point for custom agents
class CustomAgent extends BaseAgent {
  constructor() {
    super();
    this.type = 'custom';
    this.tools = ['Read', 'Write'];
  }
  
  async process(task) {
    // Custom processing logic
  }
}
```

### Custom Metrics
```javascript
// Extension point for custom metrics
class CustomMetricCollector extends BaseCollector {
  shouldCollect(event) {
    return event.type === 'custom-event';
  }
  
  collect(event) {
    // Custom collection logic
  }
}
```

### Custom Commands
```javascript
// Extension point for custom commands
class CustomCommand extends BaseCommand {
  get pattern() {
    return /^\/custom (.+)$/;
  }
  
  async execute(args) {
    // Custom command logic
  }
}
```

## 🏗 Design Patterns

### 1. Hub-and-Spoke Pattern
- Central coordination point
- No peer-to-peer communication
- Simplified debugging
- Clear responsibility boundaries

### 2. Contract-First Pattern
- Define contracts before implementation
- Validate at boundaries
- Fail fast on violations
- Enable rollback

### 3. Template Method Pattern
- Base agent template
- Specialized implementations
- Consistent structure
- Reusable components

### 4. Observer Pattern
- Metrics collection
- Event-driven hooks
- Loose coupling
- Extensible monitoring

### 5. Strategy Pattern
- Pluggable validators
- Swappable collectors
- Configurable repairs
- Dynamic optimization

## 🎯 Architecture Principles

### 1. Separation of Concerns
- Behavioral layer separate from execution
- Validation separate from processing
- Metrics separate from logic

### 2. Single Responsibility
- Each agent has one job
- Each hook has one trigger
- Each test has one assertion

### 3. Dependency Inversion
- Depend on abstractions
- Inject dependencies
- Mockable for testing

### 4. Open/Closed Principle
- Open for extension (new agents)
- Closed for modification (core system)

### 5. Interface Segregation
- Minimal tool sets per agent
- Specific contracts per handoff
- Focused metrics per hypothesis

---

**Architecture Mantra**: Simple components, sophisticated coordination
**Design Goal**: Provable improvement through research
**Success Metric**: Validated hypotheses with statistical significance