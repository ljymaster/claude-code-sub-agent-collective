# Validation Criteria Documentation

## 🎯 Overview

This document defines the specific, measurable criteria that determine success for each phase, component, and hypothesis of the claude-code-sub-agent-collective project.

## 📊 Validation Levels

### Level 1: Component Validation
Individual components working correctly

### Level 2: Integration Validation  
Components working together

### Level 3: System Validation
Full system meeting requirements

### Level 4: Hypothesis Validation
Research hypotheses proven/disproven

### Level 5: Production Validation
Ready for real-world deployment

## ✅ Phase Validation Criteria

### Phase 1: Behavioral CLAUDE.md

#### Success Criteria
```javascript
const phase1Validation = {
  required: {
    claudeMdExists: {
      test: 'fs.existsSync("CLAUDE.md")',
      expected: true
    },
    
    primeDirective: {
      test: 'content.includes("NEVER IMPLEMENT DIRECTLY")',
      expected: true
    },
    
    behavioralStructure: {
      test: 'content.includes("BEHAVIORAL OPERATING SYSTEM")',
      expected: true
    },
    
    hubIdentity: {
      test: 'content.includes("You are @routing-agent")',
      expected: true
    },
    
    hypothesesDefined: {
      test: 'content.match(/Hypothesis [1-3]/g).length',
      expected: 3
    }
  },
  
  quality: {
    noDirectImplementation: {
      test: 'Monitor for 10 tasks',
      measure: 'Hub never implements directly',
      target: '100% delegation'
    },
    
    routingSuccess: {
      test: 'Route 20 varied requests',
      measure: 'Correct agent selected',
      target: '>90% accuracy'
    }
  }
};
```

#### Validation Script
```bash
#!/bin/bash
# validate-phase1.sh

echo "🧪 Validating Phase 1: Behavioral System"

# Check file exists
if [ ! -f "CLAUDE.md" ]; then
  echo "❌ CLAUDE.md not found"
  exit 1
fi

# Check prime directive
if ! grep -q "NEVER IMPLEMENT DIRECTLY" CLAUDE.md; then
  echo "❌ Prime directive missing"
  exit 1
fi

# Check behavioral OS
if ! grep -q "BEHAVIORAL OPERATING SYSTEM" CLAUDE.md; then
  echo "❌ Behavioral structure missing"
  exit 1
fi

# Check routing agent identity
if ! grep -q "@routing-agent" CLAUDE.md; then
  echo "❌ Hub identity not established"
  exit 1
fi

echo "✅ Phase 1 validated successfully"
```

### Phase 2: Testing Framework

#### Success Criteria
```javascript
const phase2Validation = {
  required: {
    jestInstalled: {
      test: 'npm list jest',
      expected: 'jest@29.x found'
    },
    
    testStructure: {
      test: 'fs.existsSync(".claude-collective/tests")',
      expected: true
    },
    
    handoffTests: {
      test: 'countTestFiles("handoffs")',
      expected: '>=3 files'
    },
    
    contractTests: {
      test: 'countTestFiles("contracts")',
      expected: '>=3 files'
    },
    
    testsPass: {
      test: 'npm test',
      expected: 'All tests pass'
    }
  },
  
  quality: {
    coverage: {
      test: 'npm test -- --coverage',
      measure: 'Code coverage',
      target: '>80%'
    },
    
    contractValidation: {
      test: 'Execute 10 handoffs',
      measure: 'Contracts validate correctly',
      target: '100% accurate'
    }
  }
};
```

#### Validation Script
```javascript
// validate-phase2.js
const { exec } = require('child_process');
const fs = require('fs-extra');

async function validatePhase2() {
  console.log('🧪 Validating Phase 2: Testing Framework');
  
  const checks = [];
  
  // Check Jest installed
  try {
    await execPromise('cd .claude-collective && npm list jest');
    checks.push({ name: 'Jest installed', passed: true });
  } catch {
    checks.push({ name: 'Jest installed', passed: false });
  }
  
  // Check test structure
  const testsExist = await fs.pathExists('.claude-collective/tests');
  checks.push({ name: 'Test structure', passed: testsExist });
  
  // Check test files
  if (testsExist) {
    const handoffTests = await countFiles('.claude-collective/tests/handoffs', '.test.js');
    checks.push({ 
      name: 'Handoff tests', 
      passed: handoffTests >= 3,
      detail: `Found ${handoffTests} test files`
    });
  }
  
  // Run tests
  try {
    const result = await execPromise('cd .claude-collective && npm test');
    checks.push({ name: 'Tests pass', passed: true });
  } catch (error) {
    checks.push({ 
      name: 'Tests pass', 
      passed: false,
      error: error.message
    });
  }
  
  // Report
  const passed = checks.filter(c => c.passed).length;
  const total = checks.length;
  
  console.log(`\nResults: ${passed}/${total} checks passed`);
  checks.forEach(check => {
    console.log(`${check.passed ? '✅' : '❌'} ${check.name}`);
    if (check.detail) console.log(`   ${check.detail}`);
  });
  
  return passed === total;
}
```

### Phase 3: Hook Integration

#### Success Criteria
```javascript
const phase3Validation = {
  required: {
    hooksDirectory: {
      test: 'fs.existsSync(".claude/hooks")',
      expected: true
    },
    
    requiredHooks: {
      test: 'checkHooksExist(["test-driven-handoff.sh", "directive-enforcer.sh"])',
      expected: 'All exist'
    },
    
    hooksExecutable: {
      test: 'checkExecutable(".claude/hooks/*.sh")',
      expected: 'All executable (755)'
    },
    
    settingsConfigured: {
      test: 'validateSettings(".claude/settings.json")',
      expected: 'Valid hook configuration'
    },
    
    hooksTriggering: {
      test: 'monitorHookExecution()',
      expected: 'Hooks fire on events'
    }
  },
  
  quality: {
    handoffValidation: {
      test: 'Create 10 handoffs',
      measure: 'TDH hook validates',
      target: '100% validation'
    },
    
    directiveEnforcement: {
      test: 'Attempt direct implementation',
      measure: 'Directive hook blocks',
      target: '100% blocked'
    }
  }
};
```

#### Live Validation Test
```javascript
// validate-phase3-live.js
class HookValidator {
  async validateHooks() {
    console.log('🧪 Validating Phase 3: Hooks (Live Test)');
    
    // Test 1: Directive enforcement
    console.log('\nTest 1: Directive Enforcement');
    const directImplementation = await this.testDirectiveEnforcement();
    
    // Test 2: Handoff validation
    console.log('\nTest 2: Handoff Validation');
    const handoffValidation = await this.testHandoffValidation();
    
    // Test 3: Metrics collection
    console.log('\nTest 3: Metrics Collection');
    const metricsCollection = await this.testMetricsCollection();
    
    return {
      directiveEnforcement: directImplementation,
      handoffValidation: handoffValidation,
      metricsCollection: metricsCollection,
      allPassed: directImplementation && handoffValidation && metricsCollection
    };
  }
  
  async testDirectiveEnforcement() {
    // Simulate hub trying to implement directly
    const testTask = {
      action: 'implement',
      task: 'write code directly'
    };
    
    // Hook should block this
    const logBefore = await this.checkLog('/tmp/directive-violations.log');
    
    // Attempt violation
    // ... invoke routing-agent with implementation task
    
    const logAfter = await this.checkLog('/tmp/directive-violations.log');
    const blocked = logAfter.length > logBefore.length;
    
    console.log(blocked ? '✅ Directive enforced' : '❌ Directive not enforced');
    return blocked;
  }
  
  async testHandoffValidation() {
    // Create test handoff
    const handoff = {
      from: 'routing-agent',
      to: 'test-agent',
      contract: {
        preconditions: ['valid_input'],
        postconditions: ['processed_output']
      }
    };
    
    // Check if validation file created
    const handoffFile = `/tmp/handoff-${Date.now()}.json`;
    // ... trigger handoff
    
    const validated = await fs.pathExists(handoffFile);
    console.log(validated ? '✅ Handoff validated' : '❌ Handoff not validated');
    
    return validated;
  }
  
  async testMetricsCollection() {
    const metricsBefore = await this.getMetricsCount();
    
    // Trigger metric-generating action
    // ... perform task
    
    const metricsAfter = await this.getMetricsCount();
    const collected = metricsAfter > metricsBefore;
    
    console.log(collected ? '✅ Metrics collected' : '❌ Metrics not collected');
    return collected;
  }
}
```

### Phase 4: NPX Package

#### Success Criteria
```javascript
const phase4Validation = {
  required: {
    packageStructure: {
      test: 'validatePackageJson()',
      expected: 'Valid npm package'
    },
    
    npxInstallation: {
      test: 'npx claude-code-sub-agent-collective init',
      expected: 'Installs in <30 seconds'
    },
    
    filesCopied: {
      test: 'checkInstalledFiles()',
      expected: 'All templates copied'
    },
    
    updateMechanism: {
      test: 'npx claude-collective update --check',
      expected: 'Update check works'
    }
  },
  
  quality: {
    installationTime: {
      test: 'Time installation',
      measure: 'Duration',
      target: '<30 seconds'
    },
    
    crossPlatform: {
      test: 'Test on Windows/Mac/Linux',
      measure: 'Success rate',
      target: '100% compatibility'
    }
  }
};
```

### Phase 5: Command System

#### Success Criteria
```javascript
const phase5Validation = {
  required: {
    commandParsing: {
      test: 'parseCommand("/collective status")',
      expected: 'Correctly parsed'
    },
    
    commandExecution: {
      test: 'executeCommand("/collective help")',
      expected: 'Help displayed'
    },
    
    agentCommands: {
      test: 'executeCommand("/agent list")',
      expected: 'Agents listed'
    },
    
    gateCommands: {
      test: 'executeCommand("/gate validate")',
      expected: 'Validation runs'
    }
  },
  
  quality: {
    commandLatency: {
      test: 'Measure 50 commands',
      measure: 'Response time',
      target: '<200ms average'
    },
    
    errorHandling: {
      test: 'Invalid commands',
      measure: 'Graceful errors',
      target: '100% handled'
    }
  }
};
```

### Phase 6: Research Metrics

#### Success Criteria
```javascript
const phase6Validation = {
  required: {
    metricsCollection: {
      test: 'checkMetricsFiles()',
      expected: 'Metrics being written'
    },
    
    hypothesisTracking: {
      test: 'getHypothesisMetrics()',
      expected: 'All 3 hypotheses tracked'
    },
    
    abTesting: {
      test: 'runABTest()',
      expected: 'Groups properly split'
    },
    
    reporting: {
      test: 'generateReport()',
      expected: 'Report generated'
    }
  },
  
  quality: {
    dataCompleteness: {
      test: 'Analyze 100 tasks',
      measure: 'Missing data points',
      target: '<5% missing'
    },
    
    statisticalValidity: {
      test: 'Calculate significance',
      measure: 'P-values',
      target: 'p < 0.05 for improvements'
    }
  }
};
```

### Phase 7: Dynamic Agents

#### Success Criteria
```javascript
const phase7Validation = {
  required: {
    agentSpawning: {
      test: 'spawnAgent({type: "test"})',
      expected: 'Agent created'
    },
    
    templateSystem: {
      test: 'listTemplates()',
      expected: '>=5 templates available'
    },
    
    registry: {
      test: 'checkRegistry()',
      expected: 'Agents tracked'
    },
    
    lifecycle: {
      test: 'despawnAgent(agentId)',
      expected: 'Agent removed'
    }
  },
  
  quality: {
    spawnTime: {
      test: 'Time 10 spawns',
      measure: 'Average duration',
      target: '<2 seconds'
    },
    
    autoCleanup: {
      test: 'Wait for timeout',
      measure: 'Idle agents removed',
      target: '100% cleanup'
    }
  }
};
```

### Phase 8: Van Maintenance

#### Success Criteria
```javascript
const phase8Validation = {
  required: {
    healthChecks: {
      test: 'runHealthCheck()',
      expected: 'All checks complete'
    },
    
    autoRepair: {
      test: 'breakSomething() && runRepair()',
      expected: 'Issue fixed'
    },
    
    optimization: {
      test: 'runOptimization()',
      expected: 'Optimizations applied'
    },
    
    reporting: {
      test: 'generateMaintenanceReport()',
      expected: 'Report created'
    }
  },
  
  quality: {
    healthScore: {
      test: 'getHealthScore()',
      measure: 'System health',
      target: '>90%'
    },
    
    repairSuccess: {
      test: 'Track 50 repairs',
      measure: 'Success rate',
      target: '>95%'
    }
  }
};
```

## 🔬 Hypothesis Validation Criteria

### Hypothesis 1: JIT Context Loading

#### Statistical Validation
```javascript
const h1Validation = {
  primaryMetric: {
    name: 'Token Reduction',
    baseline: 'avgTokensTraditional',
    treatment: 'avgTokensJIT',
    calculation: '1 - (treatment / baseline)',
    requiredImprovement: 0.30, // 30%
    confidenceLevel: 0.95
  },
  
  constraints: {
    taskSuccess: {
      test: 'successRateJIT >= successRateBaseline',
      required: true
    },
    
    loadLatency: {
      test: 'p95Latency < 500ms',
      required: true
    }
  },
  
  sampleSize: {
    minimum: 1000,
    powerAnalysis: 0.80,
    effectSize: 0.30
  }
};
```

#### Validation Process
```javascript
class H1Validator {
  validate(baselineData, treatmentData) {
    // Calculate improvement
    const tokenReduction = this.calculateReduction(
      baselineData.avgTokens,
      treatmentData.avgTokens
    );
    
    // Statistical test
    const tTest = this.performTTest(
      baselineData.tokenSamples,
      treatmentData.tokenSamples
    );
    
    // Check constraints
    const constraints = {
      successMaintained: treatmentData.successRate >= 
                        baselineData.successRate * 0.95,
      latencyAcceptable: treatmentData.p95Latency < 500
    };
    
    return {
      hypothesis: 'JIT Context Loading',
      validated: tokenReduction >= 0.30 && 
                tTest.pValue < 0.05 &&
                constraints.successMaintained &&
                constraints.latencyAcceptable,
      
      metrics: {
        tokenReduction: `${(tokenReduction * 100).toFixed(1)}%`,
        pValue: tTest.pValue,
        successRate: treatmentData.successRate,
        latency: treatmentData.p95Latency
      }
    };
  }
}
```

### Hypothesis 2: Hub-and-Spoke

#### Statistical Validation
```javascript
const h2Validation = {
  primaryMetric: {
    name: 'Task Success Improvement',
    baseline: 'successRateP2P',
    treatment: 'successRateHubSpoke',
    calculation: '(treatment - baseline) / baseline',
    requiredImprovement: 0.25, // 25%
    confidenceLevel: 0.95
  },
  
  secondaryMetric: {
    name: 'Coordination Failure Reduction',
    baseline: 'failureRateP2P',
    treatment: 'failureRateHubSpoke',
    calculation: '1 - (treatment / baseline)',
    requiredReduction: 0.50, // 50%
  },
  
  constraints: {
    routingCompliance: {
      test: 'hubRoutedTasks / totalTasks >= 0.95',
      required: true
    },
    
    topologyCorrect: {
      test: 'topologyType === "star"',
      required: true
    }
  }
};
```

### Hypothesis 3: Test-Driven Handoffs

#### Statistical Validation
```javascript
const h3Validation = {
  primaryMetric: {
    name: 'Handoff Reliability Improvement',
    baseline: 'handoffSuccessUnvalidated',
    treatment: 'handoffSuccessTDD',
    calculation: '(treatment - baseline) / baseline',
    requiredImprovement: 0.40, // 40%
    confidenceLevel: 0.95
  },
  
  secondaryMetric: {
    name: 'Context Loss Reduction',
    baseline: 'contextLossUnvalidated',
    treatment: 'contextLossTDD',
    calculation: '1 - (treatment / baseline)',
    requiredReduction: 0.60, // 60%
  },
  
  constraints: {
    validationOverhead: {
      test: 'avgValidationTime < 200ms',
      required: true
    },
    
    recoveryRate: {
      test: 'autoRecoveryRate >= 0.80',
      required: true
    }
  }
};
```

## 🎯 System-Level Validation

### MVP Validation Criteria
```javascript
const mvpValidation = {
  functional: {
    allPhasesComplete: 'All 8 phases validated',
    coreAgentsWorking: 'Routing and van-maintenance operational',
    hooksTriggering: 'All hooks fire correctly',
    testsPass: 'All test suites green',
    commandsWork: 'All commands execute'
  },
  
  performance: {
    responseTime: 'P95 < 5 seconds',
    throughput: '>20 tasks/hour',
    errorRate: '<5%',
    availability: '>99%'
  },
  
  research: {
    metricsCollecting: 'All hypotheses tracked',
    baselineEstablished: '>100 task baseline',
    abTestingWork: 'Groups properly separated'
  }
};
```

### Production Validation Criteria
```javascript
const productionValidation = {
  stability: {
    uptime: '>99.9% over 7 days',
    errorRate: '<1%',
    recoveryTime: '<1 minute'
  },
  
  scalability: {
    agentLimit: 'Handle 50+ agents',
    taskThroughput: '>100 tasks/hour',
    concurrent: 'Handle 10+ concurrent tasks'
  },
  
  maintainability: {
    vanMaintenance: 'Self-healing working',
    autoUpdates: 'Update mechanism tested',
    monitoring: 'All metrics accessible'
  }
};
```

## 📋 Validation Checklist

### Pre-Release Checklist
- [ ] All phase validations passing
- [ ] Hypothesis baselines collected
- [ ] A/B testing configured
- [ ] Documentation complete
- [ ] Migration guide tested
- [ ] Troubleshooting guide verified
- [ ] NPX package publishable
- [ ] Community feedback incorporated

### Go-Live Checklist
- [ ] Production validation passed
- [ ] Performance benchmarks met
- [ ] Security audit completed
- [ ] Rollback plan tested
- [ ] Monitoring dashboards ready
- [ ] Support channels established
- [ ] Launch announcement prepared

## 🔄 Continuous Validation

```javascript
class ContinuousValidator {
  constructor() {
    this.schedule = {
      hourly: ['health-check', 'metrics-collection'],
      daily: ['full-validation', 'performance-check'],
      weekly: ['deep-validation', 'hypothesis-check'],
      monthly: ['security-audit', 'dependency-update']
    };
  }
  
  async runScheduledValidation(frequency) {
    const validators = this.schedule[frequency];
    const results = [];
    
    for (const validator of validators) {
      const result = await this.runValidator(validator);
      results.push(result);
      
      if (!result.passed) {
        await this.alertFailure(validator, result);
      }
    }
    
    return {
      frequency,
      timestamp: Date.now(),
      validators: results,
      overallPass: results.every(r => r.passed)
    };
  }
}
```

## 🚨 Validation Failure Protocol

### Immediate Actions
1. Log failure details
2. Attempt auto-recovery
3. Alert maintainers
4. Document in report

### Escalation Path
```javascript
const escalationPath = {
  level1: {
    trigger: 'Single validation failure',
    action: 'Auto-repair attempt',
    timeout: '5 minutes'
  },
  
  level2: {
    trigger: 'Auto-repair failed',
    action: 'Alert team',
    timeout: '30 minutes'
  },
  
  level3: {
    trigger: 'Critical system failure',
    action: 'Rollback to last known good',
    timeout: 'Immediate'
  }
};
```

---

**Remember**: Validation is not optional - it's the proof that the system works as designed.
**Automate**: All validations should be scriptable and runnable in CI/CD
**Document**: Failed validations should generate detailed reports for debugging