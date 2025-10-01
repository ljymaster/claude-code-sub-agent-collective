# Phase 2: Testing Framework Implementation

## 🎯 Phase Objective

Implement Test-Driven Handoff (TDH) validation system using Jest, creating test contracts that validate agent handoffs and prove our research hypotheses.

## 📋 Prerequisites Checklist

- [ ] Phase 1 completed (Behavioral System active)
- [ ] Node.js and npm installed
- [ ] Hub successfully routing requests
- [ ] Zero direct implementation violations
- [ ] Git repository for version control

## 🚀 Implementation Steps

### Step 1: Initialize Testing Infrastructure

```bash
# Create testing directory structure
mkdir -p .claude-collective/tests/handoffs/templates
mkdir -p .claude-collective/tests/directives
mkdir -p .claude-collective/tests/research
mkdir -p .claude-collective/tests/contracts

# Initialize npm in collective directory
cd .claude-collective
npm init -y

# Install Jest and dependencies
npm install --save-dev jest @types/jest @testing-library/jest-dom
npm install --save-dev prettier eslint
```

### Step 2: Configure Jest

Create `.claude-collective/jest.config.js`:

```javascript
module.exports = {
  testEnvironment: 'node',
  roots: ['<rootDir>/tests'],
  testMatch: [
    '**/__tests__/**/*.js',
    '**/?(*.)+(spec|test).js'
  ],
  collectCoverageFrom: [
    'tests/**/*.js',
    '!tests/**/templates/**'
  ],
  coverageDirectory: 'coverage',
  coverageReporters: ['text', 'lcov', 'html'],
  verbose: true,
  testTimeout: 10000,
  globals: {
    COLLECTIVE_MODE: true,
    RESEARCH_METRICS: true
  }
};
```

### Step 3: Create Base Test Templates

Create `.claude-collective/tests/handoffs/templates/base-handoff.test.js`:

```javascript
/**
 * Base Handoff Test Contract Template
 * All agent handoffs must implement this contract
 */

describe('Agent Handoff Contract', () => {
  let handoffContext;
  
  beforeEach(() => {
    // Load handoff context from agent output
    handoffContext = require('../current-handoff.json');
  });

  describe('Output Validation', () => {
    test('should provide required output structure', () => {
      expect(handoffContext).toHaveProperty('agentId');
      expect(handoffContext).toHaveProperty('timestamp');
      expect(handoffContext).toHaveProperty('outputs');
      expect(handoffContext).toHaveProperty('nextAgent');
    });

    test('should include deliverables', () => {
      expect(handoffContext.outputs).toBeDefined();
      expect(Array.isArray(handoffContext.outputs)).toBe(true);
      expect(handoffContext.outputs.length).toBeGreaterThan(0);
    });

    test('should specify next agent if needed', () => {
      if (handoffContext.nextAgent) {
        expect(handoffContext.nextAgent).toMatch(/^[a-z-]+-agent$/);
      }
    });
  });

  describe('Collective Compliance', () => {
    test('should follow hub-and-spoke pattern', () => {
      expect(handoffContext.routedThrough).toBe('routing-agent');
      expect(handoffContext.hubValidated).toBe(true);
      expect(handoffContext.peerCommunication).toBe(false);
    });

    test('should not contain hub implementations', () => {
      expect(handoffContext.hubImplemented).toEqual([]);
      expect(handoffContext.directImplementation).toBe(false);
    });

    test('should include routing metadata', () => {
      expect(handoffContext.routingAnalysis).toBeDefined();
      expect(handoffContext.routingDecision).toBeDefined();
      expect(handoffContext.routingTime).toBeLessThan(5000);
    });
  });

  describe('Research Metrics', () => {
    test('should collect context metrics', () => {
      expect(handoffContext.metrics).toBeDefined();
      expect(handoffContext.metrics.contextSize).toBeGreaterThan(0);
      expect(handoffContext.metrics.tokenCount).toBeDefined();
    });

    test('should track hypothesis data', () => {
      expect(handoffContext.hypothesis).toBeDefined();
      expect(handoffContext.hypothesis.jitLoading).toBeDefined();
      expect(handoffContext.hypothesis.hubSpoke).toBe(true);
    });

    test('should measure performance', () => {
      expect(handoffContext.metrics.processingTime).toBeDefined();
      expect(handoffContext.metrics.processingTime).toBeLessThan(30000);
    });
  });
});
```

### Step 4: Create Directive Compliance Tests

Create `.claude-collective/tests/directives/collective-rules.test.js`:

```javascript
/**
 * Collective Directive Compliance Tests
 * Ensures all agents follow collective rules
 */

describe('Collective Directive Compliance', () => {
  describe('Directive 1: Never Implement Directly', () => {
    test('hub should never modify files', () => {
      const violations = checkHubImplementations();
      expect(violations).toEqual([]);
    });

    test('all code changes through agents', () => {
      const implementations = getImplementations();
      implementations.forEach(impl => {
        expect(impl.implementedBy).toMatch(/-agent$/);
        expect(impl.implementedBy).not.toBe('hub-controller');
      });
    });
  });

  describe('Directive 2: Collective Routing', () => {
    test('all requests route through routing-agent', () => {
      const routes = getRoutingHistory();
      routes.forEach(route => {
        expect(route.path).toContain('routing-agent');
      });
    });

    test('no peer-to-peer communication', () => {
      const communications = getCommunicationLog();
      const p2p = communications.filter(c => 
        c.from.includes('-agent') && 
        c.to.includes('-agent') &&
        !c.through.includes('hub')
      );
      expect(p2p).toEqual([]);
    });
  });

  describe('Directive 3: Test-Driven Validation', () => {
    test('all handoffs have test contracts', () => {
      const handoffs = getHandoffHistory();
      handoffs.forEach(handoff => {
        expect(handoff.testContract).toBeDefined();
        expect(handoff.testResults).toBeDefined();
      });
    });

    test('failed tests trigger re-routing', () => {
      const failures = getTestFailures();
      failures.forEach(failure => {
        expect(failure.action).toBe('rerouted');
        expect(failure.retryCount).toBeLessThanOrEqual(3);
      });
    });
  });
});

// Helper functions
function checkHubImplementations() {
  // Check for any direct implementations by hub
  const fs = require('fs');
  const log = fs.readFileSync('/tmp/collective.log', 'utf8');
  const violations = log.match(/HUB_IMPLEMENTATION:/g) || [];
  return violations;
}

function getImplementations() {
  // Return list of all implementations
  return require('/tmp/implementations.json');
}

function getRoutingHistory() {
  // Return routing history
  return require('/tmp/routing-history.json');
}

function getCommunicationLog() {
  // Return communication patterns
  return require('/tmp/communications.json');
}

function getHandoffHistory() {
  // Return handoff history
  return require('/tmp/handoffs.json');
}

function getTestFailures() {
  // Return test failure records
  return require('/tmp/test-failures.json');
}
```

### Step 5: Create Specific Agent Test Contracts

Create `.claude-collective/tests/contracts/component-agent.test.js`:

```javascript
/**
 * Component Implementation Agent Test Contract
 */

describe('Component Agent Handoff Contract', () => {
  let handoff;
  
  beforeEach(() => {
    handoff = require('../handoffs/current-handoff.json');
  });

  test('should provide component file paths', () => {
    expect(handoff.componentPaths).toBeDefined();
    expect(Array.isArray(handoff.componentPaths)).toBe(true);
    handoff.componentPaths.forEach(path => {
      expect(path).toMatch(/\.(jsx?|tsx?)$/);
    });
  });

  test('should include component documentation', () => {
    expect(handoff.documentation).toBeDefined();
    expect(handoff.documentation.props).toBeDefined();
    expect(handoff.documentation.usage).toBeDefined();
    expect(handoff.documentation.examples).toBeDefined();
  });

  test('should specify test requirements', () => {
    expect(handoff.testRequirements).toBeDefined();
    expect(handoff.testRequirements.unit).toBeArray();
    expect(handoff.testRequirements.integration).toBeArray();
  });

  test('should include styling information', () => {
    expect(handoff.styling).toBeDefined();
    expect(handoff.styling.approach).toMatch(/css|styled-components|tailwind/);
    expect(handoff.styling.files).toBeArray();
  });
});
```

### Step 6: Create Test Runner Utilities

Create `.claude-collective/tests/utils/test-runner.js`:

```javascript
/**
 * Test Runner Utilities for Collective
 */

const { exec } = require('child_process');
const fs = require('fs').promises;
const path = require('path');

class CollectiveTestRunner {
  constructor() {
    this.testDir = path.join(__dirname, '..');
    this.handoffDir = path.join(this.testDir, 'handoffs');
    this.resultsDir = path.join(this.testDir, 'results');
  }

  async runHandoffTest(handoffData) {
    // Save handoff data
    const handoffFile = path.join(this.handoffDir, 'current-handoff.json');
    await fs.writeFile(handoffFile, JSON.stringify(handoffData, null, 2));
    
    // Run tests
    return new Promise((resolve, reject) => {
      exec(
        'npm test -- --testPathPattern=handoffs/templates/base-handoff.test.js',
        { cwd: this.testDir },
        (error, stdout, stderr) => {
          if (error) {
            resolve({
              success: false,
              output: stdout,
              error: stderr,
              failedTests: this.parseFailures(stdout)
            });
          } else {
            resolve({
              success: true,
              output: stdout,
              metrics: this.parseMetrics(stdout)
            });
          }
        }
      );
    });
  }

  parseFailures(output) {
    // Extract failed test names
    const failures = [];
    const lines = output.split('\n');
    lines.forEach(line => {
      if (line.includes('✕') || line.includes('FAIL')) {
        failures.push(line.trim());
      }
    });
    return failures;
  }

  parseMetrics(output) {
    // Extract test metrics
    const metrics = {
      total: 0,
      passed: 0,
      failed: 0,
      time: 0
    };
    
    const summaryMatch = output.match(/Tests:\s+(\d+)\s+passed,\s+(\d+)\s+total/);
    if (summaryMatch) {
      metrics.passed = parseInt(summaryMatch[1]);
      metrics.total = parseInt(summaryMatch[2]);
      metrics.failed = metrics.total - metrics.passed;
    }
    
    const timeMatch = output.match(/Time:\s+([\d.]+)s/);
    if (timeMatch) {
      metrics.time = parseFloat(timeMatch[1]);
    }
    
    return metrics;
  }

  async generateTestReport(results) {
    const report = {
      timestamp: new Date().toISOString(),
      success: results.success,
      metrics: results.metrics || {},
      failures: results.failedTests || [],
      recommendations: this.generateRecommendations(results)
    };
    
    const reportFile = path.join(
      this.resultsDir, 
      `report-${Date.now()}.json`
    );
    await fs.writeFile(reportFile, JSON.stringify(report, null, 2));
    
    return report;
  }

  generateRecommendations(results) {
    const recommendations = [];
    
    if (!results.success) {
      results.failedTests.forEach(failure => {
        if (failure.includes('hub-and-spoke')) {
          recommendations.push('Review routing pattern - possible P2P communication');
        }
        if (failure.includes('context')) {
          recommendations.push('Check context preservation in handoff');
        }
        if (failure.includes('metrics')) {
          recommendations.push('Ensure metrics collection is enabled');
        }
      });
    }
    
    return recommendations;
  }
}

module.exports = CollectiveTestRunner;
```

### Step 7: Create NPM Scripts

Update `.claude-collective/package.json`:

```json
{
  "name": "claude-collective-tests",
  "version": "1.0.0",
  "scripts": {
    "test": "jest",
    "test:handoffs": "jest --testPathPattern=handoffs",
    "test:directives": "jest --testPathPattern=directives",
    "test:contracts": "jest --testPathPattern=contracts",
    "test:watch": "jest --watch",
    "test:coverage": "jest --coverage",
    "validate:handoff": "node tests/utils/validate-handoff.js",
    "report": "node tests/utils/generate-report.js"
  }
}
```

## ✅ Validation Criteria

### Testing Framework Success
- [ ] Jest installed and configured
- [ ] Test templates created
- [ ] Sample tests pass
- [ ] Test runner utilities work

### Contract Validation
- [ ] Base handoff contract defined
- [ ] Agent-specific contracts created
- [ ] Directive compliance tests written
- [ ] Research metrics tracked

### Integration Success
- [ ] Tests can be run manually
- [ ] Test results are parseable
- [ ] Metrics are collected
- [ ] Reports can be generated

## 🧪 Acceptance Tests

### Test 1: Run Base Tests
```bash
cd .claude-collective
npm test -- --testPathPattern=base-handoff
# Expected: Tests run (may fail without data)
```

### Test 2: Create Mock Handoff
```bash
# Create mock handoff data
cat > tests/handoffs/current-handoff.json << EOF
{
  "agentId": "component-implementation-agent",
  "timestamp": "2024-01-01T00:00:00Z",
  "outputs": ["Button.jsx"],
  "routedThrough": "routing-agent",
  "hubValidated": true,
  "peerCommunication": false,
  "metrics": {
    "contextSize": 1000,
    "tokenCount": 500,
    "processingTime": 2000
  },
  "hypothesis": {
    "jitLoading": true,
    "hubSpoke": true
  }
}
EOF

npm test -- --testPathPattern=base-handoff
# Expected: Tests pass with mock data
```

### Test 3: Generate Report
```bash
npm run report
# Expected: Report generated in results/
```

## 🚨 Troubleshooting

### Issue: Jest not found
**Solution**:
```bash
cd .claude-collective
npm install
export PATH=$PATH:./node_modules/.bin
```

### Issue: Tests timing out
**Solution**:
1. Increase timeout in jest.config.js
2. Check for async operations
3. Ensure mocks are properly configured

### Issue: Cannot find handoff data
**Solution**:
1. Verify file paths are correct
2. Ensure current-handoff.json exists
3. Check permissions on test directories

## 📊 Metrics to Track

### Testing Metrics
- Test creation time: <5 minutes per contract
- Test execution time: <10 seconds per suite
- Test pass rate: >80% target
- Coverage: >70% target

### Handoff Metrics
- Handoff success rate: Track percentage
- Failure patterns: Categorize by type
- Retry counts: Monitor re-routing
- Time to validation: Measure efficiency

## ✋ Handoff to Phase 3

### Deliverables
- [ ] Jest framework installed and configured
- [ ] Test templates created and documented
- [ ] Base handoff contract working
- [ ] Test runner utilities functional
- [ ] Sample tests passing with mock data

### Ready for Phase 3 When
1. Can run `npm test` successfully ✅
2. Test contracts defined clearly ✅
3. Metrics collection working ✅
4. Reports can be generated ✅

### Phase 3 Preview
Next, we'll integrate these tests with hooks so they run automatically on every agent handoff, creating a self-validating system.

---

**Phase 2 Duration**: 1-2 days  
**Critical Success Factor**: Working test framework with contracts  
**Next Phase**: [Phase 3 - Hook Integration](Phase-3-Hooks.md)