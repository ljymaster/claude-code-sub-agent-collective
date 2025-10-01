# Test Contracts Reference

## 🎯 Overview

Test contracts are the cornerstone of reliable agent handoffs. This reference provides comprehensive templates, patterns, and examples for implementing test-driven handoffs throughout the collective.

## 📋 Contract Structure

### Basic Contract Template

```javascript
const baseContract = {
  // Metadata
  id: 'contract-unique-id',
  name: 'Descriptive Contract Name',
  version: '1.0.0',
  agent: 'target-agent-name',
  
  // Preconditions - Must pass before handoff
  preconditions: [
    {
      name: 'Condition name',
      test: () => boolean,
      errorMessage: 'Helpful error message',
      critical: true // If true, stops on failure
    }
  ],
  
  // Postconditions - Must pass after handoff
  postconditions: [
    {
      name: 'Condition name',
      test: () => boolean,
      errorMessage: 'Helpful error message',
      critical: true
    }
  ],
  
  // Invariants - Must always be true
  invariants: [
    {
      name: 'Invariant name',
      test: () => boolean,
      errorMessage: 'Invariant violated'
    }
  ],
  
  // Recovery - Rollback on failure
  rollback: async (handoff, error) => {
    // Restoration logic
  }
};
```

## 🔧 Precondition Contracts

### Input Validation

```javascript
const inputValidation = {
  preconditions: [
    {
      name: 'Input exists',
      test: (handoff) => handoff.data !== null && handoff.data !== undefined,
      errorMessage: 'Input data is missing',
      critical: true
    },
    
    {
      name: 'Input type correct',
      test: (handoff) => typeof handoff.data === 'object',
      errorMessage: 'Input must be an object',
      critical: true
    },
    
    {
      name: 'Required fields present',
      test: (handoff) => {
        const required = ['id', 'type', 'content'];
        return required.every(field => field in handoff.data);
      },
      errorMessage: 'Missing required fields',
      critical: true
    },
    
    {
      name: 'Data schema valid',
      test: (handoff) => {
        const schema = {
          id: 'string',
          type: 'string',
          content: 'string',
          metadata: 'object'
        };
        
        return Object.entries(schema).every(([key, type]) => {
          if (!(key in handoff.data)) return !critical;
          return typeof handoff.data[key] === type;
        });
      },
      errorMessage: 'Data schema validation failed',
      critical: false
    }
  ]
};
```

### Agent Readiness

```javascript
const agentReadiness = {
  preconditions: [
    {
      name: 'Target agent exists',
      test: async (handoff) => {
        const registry = new AgentRegistry();
        const agent = await registry.getAgent(handoff.to);
        return agent !== null;
      },
      errorMessage: 'Target agent not found',
      critical: true
    },
    
    {
      name: 'Agent status active',
      test: async (handoff) => {
        const agent = await getAgent(handoff.to);
        return agent.status === 'active';
      },
      errorMessage: 'Target agent not active',
      critical: true
    },
    
    {
      name: 'Agent has required tools',
      test: async (handoff) => {
        const agent = await getAgent(handoff.to);
        const requiredTools = handoff.requiredTools || [];
        return requiredTools.every(tool => agent.tools.includes(tool));
      },
      errorMessage: 'Agent missing required tools',
      critical: false
    },
    
    {
      name: 'Agent capacity available',
      test: async (handoff) => {
        const metrics = await getAgentMetrics(handoff.to);
        return metrics.currentLoad < metrics.maxCapacity;
      },
      errorMessage: 'Agent at capacity',
      critical: false
    }
  ]
};
```

### Context Validation

```javascript
const contextValidation = {
  preconditions: [
    {
      name: 'Context provided',
      test: (handoff) => handoff.context !== undefined,
      errorMessage: 'No context provided',
      critical: true
    },
    
    {
      name: 'Context chain preserved',
      test: (handoff) => {
        if (!handoff.context.chain) return false;
        return handoff.context.chain.includes(handoff.from);
      },
      errorMessage: 'Context chain broken',
      critical: true
    },
    
    {
      name: 'Context size acceptable',
      test: (handoff) => {
        const contextSize = JSON.stringify(handoff.context).length;
        return contextSize < 10000; // 10KB limit
      },
      errorMessage: 'Context too large',
      critical: false
    },
    
    {
      name: 'No circular references',
      test: (handoff) => {
        try {
          JSON.stringify(handoff.context);
          return true;
        } catch (e) {
          return false;
        }
      },
      errorMessage: 'Context contains circular references',
      critical: true
    }
  ]
};
```

## ✅ Postcondition Contracts

### Output Validation

```javascript
const outputValidation = {
  postconditions: [
    {
      name: 'Output produced',
      test: (result) => result !== null && result !== undefined,
      errorMessage: 'No output produced',
      critical: true
    },
    
    {
      name: 'Success flag set',
      test: (result) => typeof result.success === 'boolean',
      errorMessage: 'Success flag not set',
      critical: true
    },
    
    {
      name: 'Result structure valid',
      test: (result) => {
        const required = ['success', 'data', 'metadata'];
        return required.every(field => field in result);
      },
      errorMessage: 'Invalid result structure',
      critical: true
    },
    
    {
      name: 'Error handling correct',
      test: (result) => {
        if (!result.success) {
          return result.error && typeof result.error === 'object';
        }
        return true;
      },
      errorMessage: 'Error not properly reported',
      critical: false
    }
  ]
};
```

### State Preservation

```javascript
const statePreservation = {
  postconditions: [
    {
      name: 'Context preserved',
      test: (result, handoff) => {
        const originalKeys = Object.keys(handoff.context);
        const resultKeys = Object.keys(result.context || {});
        return originalKeys.every(key => resultKeys.includes(key));
      },
      errorMessage: 'Context lost during handoff',
      critical: true
    },
    
    {
      name: 'Chain updated',
      test: (result, handoff) => {
        if (!result.context?.chain) return false;
        return result.context.chain.includes(handoff.to);
      },
      errorMessage: 'Chain not updated',
      critical: false
    },
    
    {
      name: 'Metadata preserved',
      test: (result, handoff) => {
        const originalMeta = handoff.metadata || {};
        const resultMeta = result.metadata || {};
        return Object.keys(originalMeta).every(key => key in resultMeta);
      },
      errorMessage: 'Metadata lost',
      critical: false
    },
    
    {
      name: 'No data corruption',
      test: (result, handoff) => {
        if (!handoff.data || !result.data) return true;
        
        // Check for data integrity
        const checksum = (data) => {
          return JSON.stringify(data).length; // Simple checksum
        };
        
        return checksum(result.data) >= checksum(handoff.data) * 0.9;
      },
      errorMessage: 'Possible data corruption detected',
      critical: false
    }
  ]
};
```

### Performance Contracts

```javascript
const performanceContract = {
  postconditions: [
    {
      name: 'Response time acceptable',
      test: (result) => {
        const duration = result.endTime - result.startTime;
        return duration < 5000; // 5 second limit
      },
      errorMessage: 'Response too slow',
      critical: false
    },
    
    {
      name: 'Token usage reasonable',
      test: (result) => {
        return result.tokensUsed < 5000;
      },
      errorMessage: 'Excessive token usage',
      critical: false
    },
    
    {
      name: 'Memory usage acceptable',
      test: (result) => {
        const memoryUsed = process.memoryUsage().heapUsed;
        return memoryUsed < 500 * 1024 * 1024; // 500MB
      },
      errorMessage: 'Memory usage too high',
      critical: false
    }
  ]
};
```

## 🔄 Invariant Contracts

### System Invariants

```javascript
const systemInvariants = {
  invariants: [
    {
      name: 'Hub routing maintained',
      test: () => {
        // All communication through hub
        const lastCommunication = getLastCommunication();
        return lastCommunication.from === 'routing-agent' ||
               lastCommunication.to === 'routing-agent';
      },
      errorMessage: 'Direct agent communication detected'
    },
    
    {
      name: 'No implementation by hub',
      test: () => {
        const hubAgent = getAgent('routing-agent');
        const lastAction = hubAgent.getLastAction();
        return lastAction.type !== 'implementation';
      },
      errorMessage: 'Hub attempted direct implementation'
    },
    
    {
      name: 'Context chain unbroken',
      test: () => {
        const currentContext = getCurrentContext();
        return currentContext.chain && 
               currentContext.chain.length > 0 &&
               !currentContext.chain.includes(null);
      },
      errorMessage: 'Context chain broken'
    },
    
    {
      name: 'Metrics collection active',
      test: () => {
        const lastMetric = getLastMetricTimestamp();
        return Date.now() - lastMetric < 60000; // Within last minute
      },
      errorMessage: 'Metrics collection stopped'
    }
  ]
};
```

## 🔄 Rollback Contracts

### Basic Rollback

```javascript
const basicRollback = {
  rollback: async (handoff, error) => {
    console.log(`Rolling back handoff ${handoff.id} due to: ${error.message}`);
    
    // Restore previous state
    await restoreState(handoff.previousState);
    
    // Notify source agent
    await notifyAgent(handoff.from, {
      type: 'rollback',
      handoff: handoff.id,
      reason: error.message
    });
    
    // Log rollback
    await logRollback({
      handoff: handoff.id,
      timestamp: Date.now(),
      error: error,
      restored: true
    });
    
    return { rolled_back: true };
  }
};
```

### Compensating Transaction

```javascript
const compensatingTransaction = {
  rollback: async (handoff, error) => {
    const compensations = [];
    
    // Undo each completed step
    for (const step of handoff.completedSteps) {
      const compensation = await undoStep(step);
      compensations.push(compensation);
    }
    
    // Verify compensation success
    const allCompensated = compensations.every(c => c.success);
    
    if (!allCompensated) {
      // Manual intervention required
      await alertAdmin({
        severity: 'critical',
        message: 'Automatic rollback failed',
        handoff: handoff.id,
        compensations
      });
    }
    
    return {
      rolled_back: allCompensated,
      compensations,
      manual_required: !allCompensated
    };
  }
};
```

## 🧪 Complex Contract Examples

### Multi-Stage Processing Contract

```javascript
const multiStageContract = {
  name: 'Multi-Stage Data Processing',
  
  stages: [
    {
      name: 'validation',
      preconditions: [
        {
          name: 'Data format valid',
          test: (data) => validateFormat(data),
          critical: true
        }
      ],
      postconditions: [
        {
          name: 'Validation complete',
          test: (result) => result.validated === true,
          critical: true
        }
      ]
    },
    
    {
      name: 'transformation',
      preconditions: [
        {
          name: 'Data validated',
          test: (data) => data.validated === true,
          critical: true
        }
      ],
      postconditions: [
        {
          name: 'Transformation complete',
          test: (result) => result.transformed === true,
          critical: true
        }
      ]
    },
    
    {
      name: 'storage',
      preconditions: [
        {
          name: 'Data transformed',
          test: (data) => data.transformed === true,
          critical: true
        }
      ],
      postconditions: [
        {
          name: 'Data stored',
          test: (result) => result.stored === true && result.id,
          critical: true
        }
      ]
    }
  ],
  
  rollback: async (handoff, error, failedStage) => {
    // Rollback from failed stage backwards
    const stages = handoff.completedStages.reverse();
    
    for (const stage of stages) {
      await rollbackStage(stage);
    }
  }
};
```

### Conditional Contract

```javascript
const conditionalContract = {
  name: 'Conditional Processing Contract',
  
  preconditions: [
    {
      name: 'Determine processing path',
      test: (handoff) => {
        // Dynamic preconditions based on data
        if (handoff.data.type === 'simple') {
          return handoff.data.size < 1000;
        } else if (handoff.data.type === 'complex') {
          return handoff.data.validator !== null;
        }
        return false;
      },
      errorMessage: 'Cannot determine processing path',
      critical: true
    }
  ],
  
  postconditions: function(handoff) {
    // Dynamic postconditions
    if (handoff.data.type === 'simple') {
      return [
        {
          name: 'Simple processing complete',
          test: (result) => result.processedSimple === true,
          critical: true
        }
      ];
    } else {
      return [
        {
          name: 'Complex processing complete',
          test: (result) => result.processedComplex === true,
          critical: true
        },
        {
          name: 'Validation report generated',
          test: (result) => result.validationReport !== null,
          critical: false
        }
      ];
    }
  }
};
```

### Retry Contract

```javascript
const retryContract = {
  name: 'Retry on Failure Contract',
  
  maxRetries: 3,
  retryDelay: 1000, // ms
  
  preconditions: [
    {
      name: 'Check retry count',
      test: (handoff) => {
        const retries = handoff.metadata?.retries || 0;
        return retries < retryContract.maxRetries;
      },
      errorMessage: 'Max retries exceeded',
      critical: true
    }
  ],
  
  postconditions: [
    {
      name: 'Success or retry',
      test: async (result, handoff) => {
        if (result.success) return true;
        
        // Retry logic
        if (result.retryable && handoff.metadata.retries < retryContract.maxRetries) {
          await sleep(retryContract.retryDelay);
          
          // Update retry count
          handoff.metadata.retries = (handoff.metadata.retries || 0) + 1;
          
          // Re-execute
          const retryResult = await executeHandoff(handoff);
          return retryResult.success;
        }
        
        return false;
      },
      errorMessage: 'Failed after retries',
      critical: true
    }
  ]
};
```

## 📝 Contract Templates

### Agent Handoff Template

```javascript
const agentHandoffTemplate = (fromAgent, toAgent) => ({
  name: `${fromAgent} → ${toAgent} Handoff`,
  
  preconditions: [
    {
      name: 'Source agent valid',
      test: () => validateAgent(fromAgent),
      critical: true
    },
    {
      name: 'Target agent valid',
      test: () => validateAgent(toAgent),
      critical: true
    },
    {
      name: 'Handoff allowed',
      test: () => isHandoffAllowed(fromAgent, toAgent),
      critical: true
    }
  ],
  
  postconditions: [
    {
      name: 'Handoff recorded',
      test: (result) => result.handoffId !== null,
      critical: true
    },
    {
      name: 'Context transferred',
      test: (result) => result.context.from === fromAgent,
      critical: true
    }
  ]
});
```

### Data Processing Template

```javascript
const dataProcessingTemplate = (dataType) => ({
  name: `${dataType} Processing Contract`,
  
  preconditions: [
    {
      name: `Valid ${dataType} data`,
      test: (handoff) => validateDataType(handoff.data, dataType),
      critical: true
    },
    {
      name: 'Processing requirements met',
      test: (handoff) => checkProcessingRequirements(dataType),
      critical: true
    }
  ],
  
  postconditions: [
    {
      name: 'Data processed',
      test: (result) => result.processed === true,
      critical: true
    },
    {
      name: `${dataType} specific validation`,
      test: (result) => validateProcessedData(result.data, dataType),
      critical: true
    }
  ]
});
```

## 🔍 Contract Testing

### Unit Testing Contracts

```javascript
// test-contract.test.js
describe('Handoff Contract', () => {
  let contract;
  let mockHandoff;
  
  beforeEach(() => {
    contract = require('./handoff-contract');
    mockHandoff = {
      from: 'agent-a',
      to: 'agent-b',
      data: { test: 'data' },
      context: { chain: ['agent-a'] }
    };
  });
  
  describe('Preconditions', () => {
    test('should pass with valid handoff', async () => {
      const results = await validatePreconditions(contract, mockHandoff);
      expect(results.every(r => r.passed)).toBe(true);
    });
    
    test('should fail with missing data', async () => {
      mockHandoff.data = null;
      const results = await validatePreconditions(contract, mockHandoff);
      expect(results.some(r => !r.passed)).toBe(true);
    });
  });
  
  describe('Postconditions', () => {
    test('should validate successful result', async () => {
      const result = {
        success: true,
        data: { processed: true },
        context: { chain: ['agent-a', 'agent-b'] }
      };
      
      const results = await validatePostconditions(contract, result, mockHandoff);
      expect(results.every(r => r.passed)).toBe(true);
    });
  });
  
  describe('Rollback', () => {
    test('should rollback on failure', async () => {
      const error = new Error('Test failure');
      const rollbackResult = await contract.rollback(mockHandoff, error);
      
      expect(rollbackResult.rolled_back).toBe(true);
    });
  });
});
```

### Integration Testing

```javascript
// integration-contract.test.js
describe('Contract Integration', () => {
  test('should handle complete handoff flow', async () => {
    const handoff = createHandoff('routing-agent', 'data-processor');
    const contract = getContract(handoff);
    
    // Validate preconditions
    const preValidation = await validatePreconditions(contract, handoff);
    expect(preValidation.passed).toBe(true);
    
    // Execute handoff
    const result = await executeHandoff(handoff);
    
    // Validate postconditions
    const postValidation = await validatePostconditions(contract, result);
    expect(postValidation.passed).toBe(true);
    
    // Check invariants
    const invariantCheck = await validateInvariants(contract);
    expect(invariantCheck.passed).toBe(true);
  });
});
```

## 📊 Contract Metrics

### Contract Performance Tracking

```javascript
class ContractMetrics {
  constructor() {
    this.metrics = {
      executions: 0,
      preconditionFailures: 0,
      postconditionFailures: 0,
      rollbacks: 0,
      avgValidationTime: 0
    };
  }
  
  recordExecution(contract, result) {
    this.metrics.executions++;
    
    if (result.preconditionFailed) {
      this.metrics.preconditionFailures++;
    }
    
    if (result.postconditionFailed) {
      this.metrics.postconditionFailures++;
    }
    
    if (result.rolledBack) {
      this.metrics.rollbacks++;
    }
    
    // Update average validation time
    const currentAvg = this.metrics.avgValidationTime;
    const newTime = result.validationTime;
    this.metrics.avgValidationTime = 
      (currentAvg * (this.metrics.executions - 1) + newTime) / 
      this.metrics.executions;
  }
  
  getSuccessRate() {
    const failures = this.metrics.preconditionFailures + 
                    this.metrics.postconditionFailures;
    return 1 - (failures / this.metrics.executions);
  }
  
  getReport() {
    return {
      ...this.metrics,
      successRate: this.getSuccessRate(),
      rollbackRate: this.metrics.rollbacks / this.metrics.executions
    };
  }
}
```

## 🛡 Contract Best Practices

### 1. Keep Contracts Simple
```javascript
// ❌ Bad - Too complex
{
  test: (handoff) => {
    return validateA(handoff) && 
           validateB(handoff) && 
           validateC(handoff) &&
           checkD(handoff) &&
           verifyE(handoff);
  }
}

// ✅ Good - Separate concerns
[
  { name: 'Validate A', test: (h) => validateA(h) },
  { name: 'Validate B', test: (h) => validateB(h) },
  { name: 'Validate C', test: (h) => validateC(h) },
  { name: 'Check D', test: (h) => checkD(h) },
  { name: 'Verify E', test: (h) => verifyE(h) }
]
```

### 2. Make Tests Deterministic
```javascript
// ❌ Bad - Non-deterministic
{
  test: () => Math.random() > 0.5
}

// ✅ Good - Deterministic
{
  test: (handoff) => handoff.value > threshold
}
```

### 3. Provide Clear Error Messages
```javascript
// ❌ Bad
{
  errorMessage: 'Failed'
}

// ✅ Good
{
  errorMessage: `Data size ${data.size} exceeds maximum allowed ${MAX_SIZE}`
}
```

### 4. Use Critical Flags Appropriately
```javascript
// Critical - Must pass for safety
{
  name: 'Valid authentication',
  test: (h) => h.authenticated,
  critical: true
}

// Non-critical - Nice to have
{
  name: 'Performance optimal',
  test: (h) => h.responseTime < 100,
  critical: false
}
```

### 5. Always Include Rollback
```javascript
// Every contract should have rollback
{
  rollback: async (handoff, error) => {
    // At minimum, log the failure
    await logFailure(handoff, error);
    
    // Attempt restoration if possible
    if (handoff.previousState) {
      await restoreState(handoff.previousState);
    }
    
    return { rolled_back: true };
  }
}
```

## 🔗 Contract Composition

### Combining Contracts

```javascript
function combineContracts(...contracts) {
  return {
    name: 'Combined Contract',
    
    preconditions: contracts.flatMap(c => c.preconditions || []),
    postconditions: contracts.flatMap(c => c.postconditions || []),
    invariants: contracts.flatMap(c => c.invariants || []),
    
    rollback: async (handoff, error) => {
      // Execute all rollbacks in reverse order
      const results = [];
      for (const contract of contracts.reverse()) {
        if (contract.rollback) {
          results.push(await contract.rollback(handoff, error));
        }
      }
      return results;
    }
  };
}

// Usage
const completeContract = combineContracts(
  inputValidation,
  agentReadiness,
  contextValidation,
  performanceContract
);
```

### Contract Inheritance

```javascript
class BaseContract {
  constructor() {
    this.preconditions = [
      this.createBasicValidation()
    ];
  }
  
  createBasicValidation() {
    return {
      name: 'Basic validation',
      test: (h) => h !== null,
      critical: true
    };
  }
}

class SpecializedContract extends BaseContract {
  constructor() {
    super();
    this.preconditions.push(
      this.createSpecializedValidation()
    );
  }
  
  createSpecializedValidation() {
    return {
      name: 'Specialized validation',
      test: (h) => h.specialField !== null,
      critical: true
    };
  }
}
```

---

**Remember**: Test contracts are your safety net. They prevent failures, enable recovery, and ensure reliable agent coordination.
**Golden Rule**: If it can fail, it needs a contract.
**Success Metric**: 100% of handoffs validated by contracts.