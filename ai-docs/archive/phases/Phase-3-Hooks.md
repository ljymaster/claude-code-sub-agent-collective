# Phase 3: Hook Integration Implementation

## 🎯 Phase Objective

Integrate test execution with Claude Code hooks to automatically validate agent handoffs, collect metrics, and enforce collective directives without manual intervention.

## 📋 Prerequisites Checklist

- [ ] Phase 1 completed (Behavioral system active)
- [ ] Phase 2 completed (Testing framework installed)
- [ ] Jest tests running successfully
- [ ] `.claude/hooks/` directory accessible
- [ ] Understanding of Claude Code hook system

## 🚀 Implementation Steps

### Step 1: Create Test-Driven Handoff Hook

Create `.claude/hooks/test-driven-handoff.sh`:

```bash
#!/bin/bash

# Test-Driven Handoff Validation Hook
# Runs automatically after each agent completes work

set -e

# Configuration
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
COLLECTIVE_DIR="$PROJECT_DIR/.claude-collective"
TEST_DIR="$COLLECTIVE_DIR/tests"
LOG_FILE="/tmp/collective-handoff.log"
METRICS_FILE="/tmp/collective-metrics.json"

# Function to log with timestamp
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Function to extract handoff data from agent output
extract_handoff_data() {
    local agent_output="$1"
    
    # Parse agent output to extract handoff context
    # This will be provided by the agent in a specific format
    echo "$agent_output" | grep -A 1000 "HANDOFF_CONTEXT_START" | grep -B 1000 "HANDOFF_CONTEXT_END" | grep -v "HANDOFF_CONTEXT"
}

# Function to run handoff tests
run_handoff_tests() {
    local handoff_file="$TEST_DIR/handoffs/current-handoff.json"
    
    log "🧪 COLLECTIVE: Running Test-Driven Handoff Validation..."
    
    # Check if handoff file exists
    if [ ! -f "$handoff_file" ]; then
        log "⚠️ No handoff data found - skipping validation"
        return 0
    fi
    
    # Run tests
    cd "$COLLECTIVE_DIR"
    npm test -- --testPathPattern=handoffs/templates/base-handoff.test.js --json > /tmp/test-results.json 2>&1
    local test_exit_code=$?
    
    # Process results
    if [ $test_exit_code -eq 0 ]; then
        log "✅ COLLECTIVE: Handoff validated - all tests pass"
        
        # Extract and record metrics
        node -e "
        const results = require('/tmp/test-results.json');
        const metrics = {
            timestamp: new Date().toISOString(),
            success: true,
            testsPassed: results.numPassedTests,
            testsTotal: results.numTotalTests,
            duration: results.testResults[0].endTime - results.testResults[0].startTime
        };
        console.log(JSON.stringify(metrics));
        " > "$METRICS_FILE"
        
        # Archive successful handoff
        mv "$handoff_file" "$TEST_DIR/handoffs/validated/$(date +%s)-handoff.json"
        
        return 0
    else
        log "❌ COLLECTIVE: Handoff validation failed"
        
        # Extract failure details
        node -e "
        const results = require('/tmp/test-results.json');
        const failures = results.testResults[0].assertionResults
            .filter(r => r.status === 'failed')
            .map(r => ({
                test: r.title,
                reason: r.failureMessages[0]
            }));
        console.error('Failed Tests:');
        failures.forEach(f => console.error('  - ' + f.test));
        " >&2
        
        # Trigger re-routing
        echo "HANDOFF_FAILED: Tests failed - initiating re-route" >&2
        return 1
    fi
}

# Function to validate collective directives
validate_directives() {
    log "🔍 COLLECTIVE: Validating directive compliance..."
    
    # Check for hub implementation violations
    if grep -q "HUB_IMPLEMENTATION" /tmp/collective.log 2>/dev/null; then
        log "❌ DIRECTIVE VIOLATION: Hub attempted direct implementation"
        echo "VIOLATION: Directive 1 breached" >&2
        return 1
    fi
    
    # Check for peer-to-peer communication
    if [ -f /tmp/p2p-detected ]; then
        log "❌ DIRECTIVE VIOLATION: Peer-to-peer communication detected"
        echo "VIOLATION: Directive 2 breached" >&2
        return 1
    fi
    
    log "✅ COLLECTIVE: All directives validated"
    return 0
}

# Function to collect research metrics
collect_research_metrics() {
    log "📊 COLLECTIVE: Collecting research metrics..."
    
    node -e "
    const fs = require('fs');
    
    // Load existing metrics or create new
    let metrics = { handoffs: { total: 0, successful: 0, failed: 0 } };
    try {
        metrics = JSON.parse(fs.readFileSync('$COLLECTIVE_DIR/metrics/research.json'));
    } catch (e) {}
    
    // Update metrics
    metrics.handoffs.total++;
    const testPassed = !fs.existsSync('/tmp/handoff-failed');
    if (testPassed) {
        metrics.handoffs.successful++;
    } else {
        metrics.handoffs.failed++;
    }
    
    // Calculate success rate
    metrics.handoffs.successRate = metrics.handoffs.successful / metrics.handoffs.total;
    
    // Save metrics
    fs.mkdirSync('$COLLECTIVE_DIR/metrics', { recursive: true });
    fs.writeFileSync('$COLLECTIVE_DIR/metrics/research.json', JSON.stringify(metrics, null, 2));
    
    console.log('Handoff Success Rate: ' + (metrics.handoffs.successRate * 100).toFixed(1) + '%');
    " | tee -a "$LOG_FILE"
}

# Main execution
main() {
    log "============================================"
    log "COLLECTIVE HOOK: Processing agent handoff"
    log "============================================"
    
    # Read input from stdin
    INPUT=$(cat)
    
    # Extract tool response
    TOOL_OUTPUT=$(echo "$INPUT" | jq -r '.tool_response.content[0].text // ""' 2>/dev/null)
    
    # Check if this is an agent handoff
    if echo "$TOOL_OUTPUT" | grep -q "HANDOFF_CONTEXT_START"; then
        log "Handoff detected - initiating validation"
        
        # Extract and save handoff data
        extract_handoff_data "$TOOL_OUTPUT" > "$TEST_DIR/handoffs/current-handoff.json"
        
        # Run validation sequence
        if run_handoff_tests && validate_directives; then
            collect_research_metrics
            log "✅ COLLECTIVE: Handoff complete and validated"
            exit 0
        else
            log "🔄 COLLECTIVE: Initiating re-route due to validation failure"
            
            # Create re-route instruction
            echo "ROUTE_TO: @routing-agent with enhanced context from test failures" >&2
            exit 1
        fi
    else
        log "No handoff detected - skipping validation"
        exit 0
    fi
}

# Execute main function
main
```

### Step 2: Create Metrics Collection Hook

Create `.claude/hooks/collective-metrics.sh`:

```bash
#!/bin/bash

# Collective Metrics Collection Hook
# Gathers metrics after each tool use

set -e

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
METRICS_FILE="$PROJECT_DIR/.claude-collective/metrics/tool-usage.json"

# Read input
INPUT=$(cat)

# Extract tool information
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // ""')
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Update metrics
node -e "
const fs = require('fs');
const path = require('path');

// Load or create metrics
let metrics = { tools: {}, timeline: [] };
const metricsFile = '$METRICS_FILE';
const metricsDir = path.dirname(metricsFile);

try {
    fs.mkdirSync(metricsDir, { recursive: true });
    metrics = JSON.parse(fs.readFileSync(metricsFile));
} catch (e) {}

// Update tool usage count
const tool = '$TOOL_NAME';
if (!metrics.tools[tool]) {
    metrics.tools[tool] = { count: 0, lastUsed: null };
}
metrics.tools[tool].count++;
metrics.tools[tool].lastUsed = '$TIMESTAMP';

// Add to timeline
metrics.timeline.push({
    tool: tool,
    timestamp: '$TIMESTAMP'
});

// Keep only last 100 timeline entries
if (metrics.timeline.length > 100) {
    metrics.timeline = metrics.timeline.slice(-100);
}

// Calculate routing compliance
const routingTools = metrics.timeline.filter(t => t.tool === 'Task');
const totalTools = metrics.timeline.length;
metrics.routingCompliance = totalTools > 0 ? routingTools.length / totalTools : 0;

// Save metrics
fs.writeFileSync(metricsFile, JSON.stringify(metrics, null, 2));

// Output summary
console.log('Tool: ' + tool);
console.log('Total uses: ' + metrics.tools[tool].count);
console.log('Routing compliance: ' + (metrics.routingCompliance * 100).toFixed(1) + '%');
"

exit 0
```

### Step 3: Create Directive Enforcement Hook

Create `.claude/hooks/directive-enforcer.sh`:

```bash
#!/bin/bash

# Directive Enforcement Hook
# Prevents directive violations before they occur

set -e

# Read input
INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // ""')
TOOL_ARGS=$(echo "$INPUT" | jq -r '.tool_args // {}')

# Function to check for violations
check_violations() {
    # Check if hub is trying to implement directly
    if [[ "$TOOL_NAME" == "Edit" || "$TOOL_NAME" == "Write" || "$TOOL_NAME" == "MultiEdit" ]]; then
        # Check if this is coming from hub or an agent
        if ! grep -q "agent" /tmp/current-context 2>/dev/null; then
            echo "❌ DIRECTIVE VIOLATION PREVENTED: Hub attempting direct implementation" >&2
            echo "🔄 Redirecting to @routing-agent..." >&2
            
            # Log violation attempt
            echo "$(date): Hub tried to use $TOOL_NAME" >> /tmp/directive-violations.log
            
            # Block the operation
            echo "BLOCKED: Use @routing-agent for implementation tasks" >&2
            exit 1
        fi
    fi
    
    # Check for peer-to-peer communication attempts
    if [[ "$TOOL_NAME" == "Task" ]]; then
        # Extract target agent
        TARGET=$(echo "$TOOL_ARGS" | jq -r '.subagent_type // ""')
        
        # Check if routing through routing-agent
        if [[ "$TARGET" != "routing-agent" ]] && ! grep -q "routing-agent" /tmp/routing-stack 2>/dev/null; then
            echo "⚠️ WARNING: Direct agent invocation detected" >&2
            echo "Consider routing through @routing-agent for consistency" >&2
            
            # Log but don't block (warning only)
            echo "$(date): Direct invocation of $TARGET" >> /tmp/routing-warnings.log
        fi
    fi
    
    return 0
}

# Main execution
check_violations

# Pass through if no violations
exit 0
```

### Step 4: Update settings.json Configuration

Update `.claude/settings.json`:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "*",
        "hooks": [
          {
            "type": "command",
            "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/directive-enforcer.sh"
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Task",
        "hooks": [
          {
            "type": "command",
            "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/test-driven-handoff.sh"
          }
        ]
      },
      {
        "matcher": "*",
        "hooks": [
          {
            "type": "command",
            "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/collective-metrics.sh"
          }
        ]
      }
    ],
    "SubagentStop": [
      {
        "matcher": "*",
        "hooks": [
          {
            "type": "command",
            "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/test-driven-handoff.sh"
          },
          {
            "type": "prompt",
            "prompt": "Agent task complete. Validate handoff and check test results."
          }
        ]
      }
    ]
  }
}
```

### Step 5: Create Hook Testing Script

Create `.claude/hooks/test-hooks.sh`:

```bash
#!/bin/bash

# Test Hook Integration
# Verifies all hooks are working correctly

echo "🧪 Testing Hook Integration..."

# Test 1: Directive Enforcer
echo "Test 1: Directive Enforcement"
echo '{"tool_name": "Edit", "tool_args": {}}' | ./directive-enforcer.sh
if [ $? -ne 0 ]; then
    echo "✅ Directive enforcer blocks hub implementation"
else
    echo "❌ Directive enforcer failed to block"
fi

# Test 2: Metrics Collection
echo "Test 2: Metrics Collection"
echo '{"tool_name": "Task", "tool_args": {"subagent_type": "routing-agent"}}' | ./collective-metrics.sh
if [ -f "$PROJECT_DIR/.claude-collective/metrics/tool-usage.json" ]; then
    echo "✅ Metrics collected successfully"
else
    echo "❌ Metrics collection failed"
fi

# Test 3: Handoff Validation
echo "Test 3: Handoff Validation"
cat > /tmp/test-handoff.json << EOF
{
  "tool_response": {
    "content": [{
      "text": "HANDOFF_CONTEXT_START\n{\"agentId\":\"test\",\"outputs\":[]}\nHANDOFF_CONTEXT_END"
    }]
  }
}
EOF
cat /tmp/test-handoff.json | ./test-driven-handoff.sh
echo "✅ Handoff hook executed"

echo "Hook testing complete!"
```

### Step 6: Make Hooks Executable

```bash
chmod +x .claude/hooks/*.sh
```

## ✅ Validation Criteria

### Hook Integration Success
- [ ] All hooks are executable
- [ ] Hooks trigger on correct events
- [ ] Test validation runs automatically
- [ ] Metrics are collected

### Automation Success
- [ ] No manual test execution needed
- [ ] Failures trigger re-routing
- [ ] Violations are prevented
- [ ] Logs are generated

### Research Data Collection
- [ ] Handoff metrics recorded
- [ ] Success rates calculated
- [ ] Tool usage tracked
- [ ] Compliance measured

## 🧪 Acceptance Tests

### Test 1: Trigger Handoff Validation
```bash
# Create mock agent output with handoff
@routing-agent "create button component"
# Expected: Hook fires, tests run, validation logged
```

### Test 2: Test Directive Enforcement
```bash
# Try direct implementation from hub
echo "Edit file.js" | claude
# Expected: Blocked with violation warning
```

### Test 3: Check Metrics Collection
```bash
# After several operations
cat .claude-collective/metrics/tool-usage.json
# Expected: Tool usage counts and compliance rate
```

### Test 4: Verify Re-routing on Failure
```bash
# Create failing handoff
echo '{"invalid": "handoff"}' > .claude-collective/tests/handoffs/current-handoff.json
@routing-agent "test task"
# Expected: Tests fail, re-route triggered
```

## 🚨 Troubleshooting

### Issue: Hooks not firing
**Solution**:
1. Check hooks are executable: `chmod +x .claude/hooks/*.sh`
2. Verify settings.json is properly formatted
3. Restart Claude Code session
4. Check hook logs in /tmp/

### Issue: Permission denied
**Solution**:
```bash
chmod +x .claude/hooks/*.sh
chmod 755 .claude/hooks/
```

### Issue: Tests not found
**Solution**:
1. Verify .claude-collective/tests/ exists
2. Check npm is installed in collective directory
3. Ensure jest is in PATH

### Issue: Metrics not saving
**Solution**:
1. Create metrics directory: `mkdir -p .claude-collective/metrics`
2. Check write permissions
3. Verify Node.js is accessible

## 📊 Metrics to Track

### Hook Performance
- Hook execution time: <1 second
- Test validation time: <5 seconds
- Metric collection overhead: <100ms
- Failure detection rate: 100%

### Automation Metrics
- Manual interventions: 0
- Automatic re-routes: Track count
- Violation preventions: Track count
- Success rate improvement: Measure

## ✋ Handoff to Phase 4

### Deliverables
- [ ] All hooks created and executable
- [ ] Settings.json configured properly
- [ ] Automatic test validation working
- [ ] Metrics being collected
- [ ] Re-routing on failures active

### Ready for Phase 4 When
1. Hooks fire automatically ✅
2. Tests validate handoffs ✅
3. Violations are prevented ✅
4. Metrics show improvement ✅

### MVP Gate Checkpoint 🏁

**Congratulations! You've completed the MVP phases.**

Before proceeding to Phase 4, validate:
- [ ] Behavioral system prevents direct implementation
- [ ] Tests validate handoffs successfully
- [ ] Hooks automate the process
- [ ] Research metrics show measurable improvement

If all checks pass, proceed to Phase 4 for enhancement phases.

---

**Phase 3 Duration**: 1-2 days  
**Critical Success Factor**: Fully automated validation  
**Next Phase**: Phase 4 - NPX Package (coming soon) (After MVP Gate)