# Baseline Metrics Documentation

## 📊 Overview

This document defines the baseline metrics that must be collected BEFORE implementing the collective system. These baselines are critical for validating the research hypotheses and demonstrating improvement.

## 🎯 Why Baselines Matter

Without accurate baselines, we cannot:
- Prove improvement claims
- Validate hypotheses
- Identify regressions
- Measure real impact
- Make scientific claims

## 📈 Baseline Collection Protocol

### Phase 1: Pre-Implementation Baseline (Week 0)

Collect these metrics on your CURRENT system before any collective changes:

```javascript
const baselineCollection = {
  duration: '1 week minimum',
  sampleSize: '>=100 tasks',
  environment: 'production-like',
  
  requirements: {
    noSystemChanges: true,
    consistentWorkload: true,
    documentedConditions: true,
    multipleOperators: true // If possible
  }
};
```

### Baseline Metrics Categories

## 1️⃣ Token Usage Baseline

### Metrics to Collect

```javascript
const tokenBaseline = {
  // Per-task metrics
  tokensPerTask: {
    definition: 'Total tokens used / task',
    collection: 'Claude Code token counter',
    segments: {
      input: 'Tokens in prompts',
      output: 'Tokens in responses',
      context: 'Tokens in loaded context',
      total: 'Sum of all token usage'
    }
  },
  
  // Context metrics
  contextWindowUsage: {
    definition: 'Average % of context window used',
    collection: 'Monitor context size',
    formula: 'context_tokens / max_window_size',
    expected: '80-95%' // Traditional approach
  },
  
  // Efficiency metrics
  wastedTokens: {
    definition: 'Tokens loaded but never used',
    collection: 'Track referenced vs loaded',
    formula: 'loaded_tokens - referenced_tokens',
    expected: '50-70%' // High waste typical
  }
};
```

### Collection Script

```javascript
// baseline-tokens.js
class TokenBaselineCollector {
  constructor() {
    this.tasks = [];
    this.startTime = Date.now();
  }
  
  startTask(taskId) {
    return {
      id: taskId,
      startTime: Date.now(),
      tokens: {
        input: 0,
        output: 0,
        context: 0,
        loaded: [],
        used: []
      }
    };
  }
  
  recordTokens(task, type, count, content) {
    task.tokens[type] += count;
    
    if (type === 'context') {
      task.tokens.loaded.push({
        content: content.substring(0, 100), // Sample
        tokens: count,
        timestamp: Date.now()
      });
    }
  }
  
  recordUsage(task, contentId) {
    task.tokens.used.push(contentId);
  }
  
  completeTask(task, success) {
    task.endTime = Date.now();
    task.duration = task.endTime - task.startTime;
    task.success = success;
    task.tokens.total = task.tokens.input + 
                       task.tokens.output + 
                       task.tokens.context;
    
    // Calculate waste
    const loadedTokens = task.tokens.loaded
      .reduce((sum, l) => sum + l.tokens, 0);
    const usedTokens = task.tokens.used.length * 100; // Estimate
    task.tokens.waste = loadedTokens - usedTokens;
    task.tokens.efficiency = usedTokens / loadedTokens;
    
    this.tasks.push(task);
    return task;
  }
  
  generateBaseline() {
    const successful = this.tasks.filter(t => t.success);
    
    return {
      period: {
        start: this.startTime,
        end: Date.now(),
        duration: Date.now() - this.startTime
      },
      
      sample: {
        total: this.tasks.length,
        successful: successful.length,
        failed: this.tasks.length - successful.length
      },
      
      tokens: {
        avgPerTask: average(this.tasks.map(t => t.tokens.total)),
        avgInput: average(this.tasks.map(t => t.tokens.input)),
        avgOutput: average(this.tasks.map(t => t.tokens.output)),
        avgContext: average(this.tasks.map(t => t.tokens.context)),
        avgWaste: average(this.tasks.map(t => t.tokens.waste)),
        efficiency: average(this.tasks.map(t => t.tokens.efficiency))
      },
      
      distribution: {
        p50: percentile(this.tasks.map(t => t.tokens.total), 50),
        p75: percentile(this.tasks.map(t => t.tokens.total), 75),
        p90: percentile(this.tasks.map(t => t.tokens.total), 90),
        p95: percentile(this.tasks.map(t => t.tokens.total), 95),
        p99: percentile(this.tasks.map(t => t.tokens.total), 99)
      }
    };
  }
}
```

### Expected Baseline Ranges

| Metric | Expected Range | Red Flag |
|--------|---------------|-----------|
| Tokens per task | 3000-8000 | >10000 |
| Context usage | 80-95% | >95% |
| Token efficiency | 30-50% | <20% |
| Waste ratio | 50-70% | >80% |

## 2️⃣ Task Success Baseline

### Metrics to Collect

```javascript
const successBaseline = {
  // Success rates
  overallSuccess: {
    definition: 'Tasks completed successfully',
    formula: 'successful_tasks / total_tasks',
    expected: '70-80%' // Without coordination
  },
  
  // Failure analysis
  failureReasons: {
    definition: 'Categorized failure causes',
    categories: [
      'coordination_failure',    // 20-30%
      'context_loss',           // 15-25%
      'wrong_agent',            // 10-20%
      'timeout',                // 5-10%
      'error',                  // 10-15%
      'user_cancelled',         // 5-10%
      'other'                   // 10-20%
    ]
  },
  
  // Complexity impact
  successByComplexity: {
    simple: '90-95%',    // Single step tasks
    moderate: '70-80%',  // 2-3 steps
    complex: '50-60%',   // 4+ steps
    veryComplex: '30-40%' // 7+ steps
  },
  
  // Retry patterns
  retryMetrics: {
    avgRetries: '0.3-0.5', // Per task
    retrySuccess: '60-70%', // Success after retry
    maxRetries: '2-3'      // Before giving up
  }
};
```

### Collection Script

```javascript
// baseline-success.js
class SuccessBaselineCollector {
  constructor() {
    this.tasks = [];
    this.failures = new Map();
  }
  
  recordTask(task) {
    const record = {
      id: task.id,
      type: task.type,
      complexity: this.assessComplexity(task),
      steps: task.steps || [],
      
      attempts: 1,
      success: false,
      failureReason: null,
      
      timing: {
        start: Date.now(),
        end: null,
        duration: null
      },
      
      context: {
        agentsInvolved: [],
        handoffs: 0,
        contextSize: 0
      }
    };
    
    this.tasks.push(record);
    return record;
  }
  
  assessComplexity(task) {
    const factors = {
      steps: task.steps?.length || 1,
      agents: task.requiredAgents?.length || 1,
      data: task.dataComplexity || 'simple',
      coordination: task.requiresCoordination || false
    };
    
    let score = factors.steps + factors.agents;
    if (factors.data === 'complex') score += 2;
    if (factors.coordination) score += 3;
    
    if (score <= 2) return 'simple';
    if (score <= 5) return 'moderate';
    if (score <= 8) return 'complex';
    return 'veryComplex';
  }
  
  recordFailure(taskId, reason, details) {
    const task = this.tasks.find(t => t.id === taskId);
    if (task) {
      task.success = false;
      task.failureReason = reason;
      task.failureDetails = details;
      
      // Track failure patterns
      const category = this.categorizeFailure(reason, details);
      this.failures.set(category, 
        (this.failures.get(category) || 0) + 1
      );
    }
  }
  
  categorizeFailure(reason, details) {
    if (reason.includes('handoff') || reason.includes('coordination')) {
      return 'coordination_failure';
    }
    if (reason.includes('context') || reason.includes('missing')) {
      return 'context_loss';
    }
    if (reason.includes('agent') || reason.includes('routing')) {
      return 'wrong_agent';
    }
    if (reason.includes('timeout') || reason.includes('time')) {
      return 'timeout';
    }
    if (reason.includes('error') || reason.includes('exception')) {
      return 'error';
    }
    if (reason.includes('cancel') || reason.includes('abort')) {
      return 'user_cancelled';
    }
    return 'other';
  }
  
  generateBaseline() {
    const byComplexity = {};
    const complexityLevels = ['simple', 'moderate', 'complex', 'veryComplex'];
    
    complexityLevels.forEach(level => {
      const levelTasks = this.tasks.filter(t => t.complexity === level);
      const successful = levelTasks.filter(t => t.success);
      
      byComplexity[level] = {
        total: levelTasks.length,
        successful: successful.length,
        rate: levelTasks.length > 0 ? 
          successful.length / levelTasks.length : 0
      };
    });
    
    return {
      overall: {
        total: this.tasks.length,
        successful: this.tasks.filter(t => t.success).length,
        rate: this.tasks.filter(t => t.success).length / this.tasks.length
      },
      
      byComplexity,
      
      failures: {
        total: this.tasks.filter(t => !t.success).length,
        categories: Object.fromEntries(this.failures),
        distribution: this.calculateFailureDistribution()
      },
      
      retries: {
        tasksWithRetries: this.tasks.filter(t => t.attempts > 1).length,
        avgRetries: average(this.tasks.map(t => t.attempts - 1)),
        maxRetries: Math.max(...this.tasks.map(t => t.attempts)),
        retrySuccessRate: this.calculateRetrySuccess()
      }
    };
  }
  
  calculateFailureDistribution() {
    const total = Array.from(this.failures.values())
      .reduce((sum, count) => sum + count, 0);
    
    const distribution = {};
    this.failures.forEach((count, category) => {
      distribution[category] = {
        count,
        percentage: (count / total * 100).toFixed(1) + '%'
      };
    });
    
    return distribution;
  }
  
  calculateRetrySuccess() {
    const retried = this.tasks.filter(t => t.attempts > 1);
    const retriedSuccess = retried.filter(t => t.success);
    
    return retried.length > 0 ?
      retriedSuccess.length / retried.length : 0;
  }
}
```

### Expected Baseline Ranges

| Metric | Simple Tasks | Complex Tasks |
|--------|-------------|---------------|
| Success rate | 90-95% | 50-60% |
| Avg retries | 0.1-0.2 | 0.5-1.0 |
| Coordination failures | 5-10% | 30-40% |
| Context loss | 5-10% | 20-30% |

## 3️⃣ Coordination Baseline

### Metrics to Collect

```javascript
const coordinationBaseline = {
  // Communication patterns
  communicationTopology: {
    definition: 'How agents communicate',
    expected: 'mesh/chaotic', // Before hub-spoke
    metrics: {
      uniquePaths: 'n*(n-1)/2', // Full mesh
      avgHops: '2-3',           // To reach target
      cycles: 'common'          // Circular deps
    }
  },
  
  // Handoff metrics
  handoffMetrics: {
    totalHandoffs: 'Per complex task',
    successfulHandoffs: '70-80%',
    failedHandoffs: '20-30%',
    lostContext: '15-25%',
    avgHandoffTime: '500-1000ms'
  },
  
  // Agent coordination
  agentCoordination: {
    p2pCommunication: '100%', // All direct
    wrongAgentCalls: '10-20%', // Misrouted
    deadlocks: '2-5%',        // Circular waits
    orphanedTasks: '5-10%'    // Lost tasks
  }
};
```

### Collection Script

```javascript
// baseline-coordination.js
class CoordinationBaselineCollector {
  constructor() {
    this.communications = [];
    this.handoffs = [];
    this.topology = new Map();
  }
  
  recordCommunication(from, to, type, payload) {
    const comm = {
      id: generateId(),
      timestamp: Date.now(),
      from,
      to,
      type,
      isDirect: from !== 'user' && to !== 'user',
      payloadSize: JSON.stringify(payload).length,
      path: `${from}->${to}`
    };
    
    this.communications.push(comm);
    
    // Track topology
    this.topology.set(comm.path,
      (this.topology.get(comm.path) || 0) + 1
    );
    
    return comm;
  }
  
  recordHandoff(handoff) {
    const record = {
      id: handoff.id,
      timestamp: Date.now(),
      from: handoff.from,
      to: handoff.to,
      
      contextBefore: Object.keys(handoff.context || {}).length,
      contextAfter: null,
      contextLost: null,
      
      success: null,
      duration: null,
      errors: []
    };
    
    this.handoffs.push(record);
    return record;
  }
  
  completeHandoff(handoffId, result) {
    const handoff = this.handoffs.find(h => h.id === handoffId);
    if (handoff) {
      handoff.success = result.success;
      handoff.duration = Date.now() - handoff.timestamp;
      handoff.contextAfter = Object.keys(result.context || {}).length;
      handoff.contextLost = Math.max(0,
        handoff.contextBefore - handoff.contextAfter
      );
      handoff.errors = result.errors || [];
    }
  }
  
  analyzeTopology() {
    const nodes = new Set();
    const edges = [];
    
    this.topology.forEach((count, path) => {
      const [from, to] = path.split('->');
      nodes.add(from);
      nodes.add(to);
      edges.push({ from, to, count });
    });
    
    // Detect patterns
    const patterns = {
      type: this.detectTopologyType(nodes, edges),
      nodes: nodes.size,
      edges: edges.length,
      density: edges.length / (nodes.size * (nodes.size - 1)),
      cycles: this.detectCycles(edges),
      centralNode: this.findMostConnected(edges)
    };
    
    return patterns;
  }
  
  detectTopologyType(nodes, edges) {
    const n = nodes.size;
    const e = edges.length;
    
    if (e >= n * (n - 1) / 2 * 0.7) return 'mesh';
    if (e === n - 1) return 'star';
    if (e === n) return 'ring';
    if (e < n - 1) return 'disconnected';
    return 'hybrid';
  }
  
  detectCycles(edges) {
    // Simple cycle detection
    const cycles = [];
    const visited = new Set();
    
    function dfs(node, path, adjList) {
      if (path.includes(node)) {
        cycles.push([...path.slice(path.indexOf(node)), node]);
        return;
      }
      
      if (visited.has(node)) return;
      visited.add(node);
      
      const neighbors = adjList.get(node) || [];
      for (const neighbor of neighbors) {
        dfs(neighbor, [...path, node], adjList);
      }
    }
    
    // Build adjacency list
    const adjList = new Map();
    edges.forEach(edge => {
      if (!adjList.has(edge.from)) adjList.set(edge.from, []);
      adjList.get(edge.from).push(edge.to);
    });
    
    // Find cycles
    adjList.forEach((_, node) => {
      if (!visited.has(node)) {
        dfs(node, [], adjList);
      }
    });
    
    return cycles;
  }
  
  findMostConnected(edges) {
    const connections = new Map();
    
    edges.forEach(edge => {
      connections.set(edge.from,
        (connections.get(edge.from) || 0) + edge.count);
      connections.set(edge.to,
        (connections.get(edge.to) || 0) + edge.count);
    });
    
    let maxNode = null;
    let maxCount = 0;
    
    connections.forEach((count, node) => {
      if (count > maxCount) {
        maxCount = count;
        maxNode = node;
      }
    });
    
    return { node: maxNode, connections: maxCount };
  }
  
  generateBaseline() {
    const successfulHandoffs = this.handoffs.filter(h => h.success);
    const failedHandoffs = this.handoffs.filter(h => !h.success);
    
    return {
      topology: this.analyzeTopology(),
      
      communications: {
        total: this.communications.length,
        direct: this.communications.filter(c => c.isDirect).length,
        userInitiated: this.communications.filter(c => c.from === 'user').length,
        uniquePaths: this.topology.size
      },
      
      handoffs: {
        total: this.handoffs.length,
        successful: successfulHandoffs.length,
        failed: failedHandoffs.length,
        successRate: successfulHandoffs.length / this.handoffs.length,
        
        avgDuration: average(this.handoffs.map(h => h.duration)),
        avgContextLoss: average(this.handoffs.map(h => h.contextLost)),
        
        failureReasons: this.analyzeFailures(failedHandoffs)
      },
      
      coordination: {
        p2pPercentage: this.communications.filter(c => c.isDirect).length /
                      this.communications.length,
        avgPathLength: this.calculateAvgPathLength(),
        deadlocks: this.detectDeadlocks(),
        orphanedTasks: this.findOrphanedTasks()
      }
    };
  }
  
  analyzeFailures(failedHandoffs) {
    const reasons = {};
    
    failedHandoffs.forEach(h => {
      h.errors.forEach(error => {
        reasons[error] = (reasons[error] || 0) + 1;
      });
    });
    
    return reasons;
  }
  
  calculateAvgPathLength() {
    // Simplified path length calculation
    return 2.5; // Typical for mesh topology
  }
  
  detectDeadlocks() {
    // Check for circular waits
    const cycles = this.analyzeTopology().cycles;
    return cycles.filter(c => c.length > 2).length;
  }
  
  findOrphanedTasks() {
    // Tasks with no completion
    return this.handoffs.filter(h => 
      h.success === null && 
      Date.now() - h.timestamp > 60000 // 1 minute old
    ).length;
  }
}
```

### Expected Baseline Ranges

| Metric | Expected Value | Concern Threshold |
|--------|---------------|-------------------|
| P2P communication | 90-100% | N/A (expected) |
| Handoff success | 70-80% | <60% |
| Context loss | 15-25% | >30% |
| Deadlocks | 2-5% | >10% |
| Wrong agent calls | 10-20% | >30% |

## 4️⃣ Performance Baseline

### Metrics to Collect

```javascript
const performanceBaseline = {
  // Response times
  responseTimes: {
    simple: '1-3 seconds',
    moderate: '5-10 seconds',
    complex: '15-30 seconds',
    veryComplex: '30-60 seconds'
  },
  
  // Resource usage
  resourceUsage: {
    avgCPU: '20-40%',
    peakCPU: '60-80%',
    memoryMB: '200-500',
    diskIOps: '10-50/s'
  },
  
  // Concurrency
  concurrency: {
    parallelTasks: '1-3',
    queueDepth: '0-5',
    blockingTime: '10-20%',
    throughput: '10-20 tasks/hour'
  }
};
```

## 📝 Baseline Report Template

```markdown
# Baseline Metrics Report

## Collection Period
- Start: [DATE]
- End: [DATE]
- Duration: [DAYS]
- Total Tasks: [COUNT]

## Token Usage Baseline
- Average per task: [TOKENS]
- Context efficiency: [PERCENTAGE]
- Waste ratio: [PERCENTAGE]

## Success Rate Baseline
- Overall: [PERCENTAGE]
- Simple tasks: [PERCENTAGE]
- Complex tasks: [PERCENTAGE]
- Primary failure: [REASON]

## Coordination Baseline
- Topology type: [TYPE]
- Handoff success: [PERCENTAGE]
- Context loss: [PERCENTAGE]
- P2P communication: [PERCENTAGE]

## Performance Baseline
- Avg response: [SECONDS]
- Throughput: [TASKS/HOUR]
- Resource usage: [CPU/MEM]

## Statistical Confidence
- Sample size: [COUNT]
- Confidence level: 95%
- Margin of error: ±[PERCENTAGE]

## Notes
[Any anomalies or considerations]

## Recommendation
[✅ Ready for collective implementation]
[⚠️ Address issues before proceeding]
```

## 🔄 Continuous Baseline Updates

Even after implementation, continue collecting baselines:

```javascript
const continuousBaseline = {
  preChange: 'Collect 1 week before any major change',
  postChange: 'Collect 1 week after change stabilizes',
  regular: 'Weekly baseline snapshots',
  
  comparison: {
    vsLastWeek: 'Detect trends',
    vsLastMonth: 'Identify patterns',
    vsInitial: 'Measure total improvement'
  }
};
```

## ⚠️ Common Baseline Mistakes

### Mistake 1: Insufficient Sample Size
```javascript
// ❌ Bad
const baseline = collectForTasks(10); // Too small

// ✅ Good
const baseline = collectForTasks(100); // Minimum
const baseline = collectForWeek(); // Better
```

### Mistake 2: Inconsistent Conditions
```javascript
// ❌ Bad
Monday: Light load baseline
Friday: Heavy load baseline

// ✅ Good
Consistent load pattern across collection period
Or: Explicitly separate light/heavy baselines
```

### Mistake 3: Not Collecting Failures
```javascript
// ❌ Bad
baseline = successfulTasks.only();

// ✅ Good
baseline = allTasks.includingFailures();
```

### Mistake 4: Aggregating Without Segments
```javascript
// ❌ Bad
avgResponseTime = 10s; // For all tasks

// ✅ Good
responseTime = {
  simple: 2s,
  moderate: 8s,
  complex: 25s
};
```

## 🎯 Using Baselines for Validation

```javascript
class BaselineComparator {
  constructor(baseline, current) {
    this.baseline = baseline;
    this.current = current;
  }
  
  validateImprovement(hypothesis, requiredImprovement) {
    const baselineValue = this.baseline[hypothesis.metric];
    const currentValue = this.current[hypothesis.metric];
    
    const improvement = (currentValue - baselineValue) / baselineValue;
    
    return {
      hypothesis: hypothesis.name,
      required: requiredImprovement,
      achieved: improvement,
      validated: improvement >= requiredImprovement,
      confidence: this.calculateConfidence(baselineValue, currentValue)
    };
  }
  
  calculateConfidence(baseline, current) {
    // Statistical significance test
    const tTest = this.performTTest(
      baseline.samples,
      current.samples
    );
    
    return {
      pValue: tTest.pValue,
      significant: tTest.pValue < 0.05,
      confidence: 1 - tTest.pValue
    };
  }
}
```

## 📊 Baseline Storage

```javascript
// baseline-storage.json
{
  "version": "1.0.0",
  "collected": "2024-01-15T10:00:00Z",
  "environment": {
    "system": "production",
    "load": "typical",
    "operators": 5
  },
  "metrics": {
    "tokens": { /* ... */ },
    "success": { /* ... */ },
    "coordination": { /* ... */ },
    "performance": { /* ... */ }
  },
  "statistical": {
    "sampleSize": 150,
    "confidence": 0.95,
    "marginOfError": 0.05
  },
  "notes": "Baseline before collective implementation"
}
```

---

**Critical**: No baseline = No proof of improvement
**Minimum Duration**: 1 week
**Minimum Sample**: 100 tasks
**Storage**: Keep all baseline data permanently