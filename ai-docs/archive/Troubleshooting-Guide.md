# Troubleshooting Guide

## 🚨 Quick Diagnostics

Run these commands first to identify issues:

```bash
# Full system diagnostic
npx claude-collective diagnose

# Component-specific checks
npx claude-collective validate
npx claude-collective van check
npx claude-collective test-hooks

# Generate diagnostic report
npx claude-collective support-bundle
```

## 🔴 Critical Issues

### System Won't Start

**Symptoms:**
- Claude Code errors on startup
- Agents not responding
- Commands not recognized

**Diagnosis:**
```bash
# Check file structure
ls -la .claude/
ls -la .claude-collective/

# Verify CLAUDE.md
head -20 CLAUDE.md | grep "NEVER IMPLEMENT"

# Check settings.json
cat .claude/settings.json | jq .
```

**Solutions:**

1. **Missing CLAUDE.md**
```bash
# Restore from template
npx claude-collective repair --component=behavioral

# Or manually create
cat > CLAUDE.md << 'EOF'
# 🧠 BEHAVIORAL OPERATING SYSTEM

## PRIME DIRECTIVE
**NEVER IMPLEMENT DIRECTLY** - Always delegate to agents.

## HUB-AND-SPOKE COORDINATION
You are @routing-agent.
EOF
```

2. **Corrupted settings.json**
```bash
# Backup existing
mv .claude/settings.json .claude/settings.json.backup

# Regenerate
npx claude-collective init-config
```

3. **Missing directories**
```bash
# Create required structure
mkdir -p .claude/agents .claude/hooks .claude/commands
mkdir -p .claude-collective/tests .claude-collective/metrics
```

### Agents Not Working

**Symptoms:**
- @agent-name not recognized
- Handoffs failing
- "Agent not found" errors

**Diagnosis:**
```bash
# List agents
ls .claude/agents/

# Check registry
cat .claude-collective/registry.json | jq .agents

# Verify routing agent
cat .claude/agents/routing-agent.md | head -20
```

**Solutions:**

1. **Missing routing-agent**
```bash
# Install core agents
npx claude-collective install-agents --core

# Verify installation
test -f .claude/agents/routing-agent.md && echo "✅ Installed"
```

2. **Agent format incorrect**
```bash
# Migrate old format
npx claude-collective migrate-agents

# Or use migration script
node ai-docs/scripts/migrate-agents.js
```

3. **Registry out of sync**
```bash
# Rebuild registry
npx claude-collective rebuild-registry

# Or manually register
npx claude-collective register-agent --path=.claude/agents/my-agent.md
```

### Hooks Not Executing

**Symptoms:**
- Test contracts not validated
- Metrics not collected
- No handoff validation

**Diagnosis:**
```bash
# Check hook files
ls -la .claude/hooks/

# Verify executable
test -x .claude/hooks/test-driven-handoff.sh && echo "✅ Executable"

# Check configuration
cat .claude/settings.json | jq .hooks
```

**Solutions:**

1. **Permissions issue**
```bash
# Fix all hook permissions
chmod +x .claude/hooks/*.sh

# Verify
ls -la .claude/hooks/*.sh
```

2. **Path issues**
```bash
# Update paths in settings.json
sed -i 's|/old/path|$CLAUDE_PROJECT_DIR|g' .claude/settings.json
```

3. **Hook syntax errors**
```bash
# Validate hooks
for hook in .claude/hooks/*.sh; do
  bash -n "$hook" && echo "✅ $hook valid" || echo "❌ $hook has errors"
done
```

4. **Restart required**
```bash
# After hook changes, restart Claude Code
echo "⚠️ Restart Claude Code session for hook changes to take effect"
```

## 🟡 Common Issues

### Tests Failing

**Symptoms:**
- npm test errors
- Contract validation failures
- Jest not found

**Diagnosis:**
```bash
# Check test setup
cd .claude-collective
npm list jest

# Run specific test
npm test -- --testNamePattern="handoff"

# Check coverage
npm test -- --coverage
```

**Solutions:**

1. **Dependencies missing**
```bash
cd .claude-collective
npm install

# Or reinstall
rm -rf node_modules package-lock.json
npm install
```

2. **Jest configuration**
```bash
# Regenerate config
cat > jest.config.js << 'EOF'
module.exports = {
  testEnvironment: 'node',
  roots: ['<rootDir>/tests'],
  testMatch: ['**/?(*.)+(spec|test).js'],
  collectCoverageFrom: ['tests/**/*.js'],
  coverageDirectory: 'coverage',
  verbose: true,
  testTimeout: 10000
};
EOF
```

3. **Test file issues**
```bash
# Validate test syntax
npx jest --listTests

# Run with debug
DEBUG=* npm test
```

### Metrics Not Collecting

**Symptoms:**
- No metrics dashboard
- Empty metrics directory
- Research data missing

**Diagnosis:**
```bash
# Check metrics directory
ls -la .claude-collective/metrics/

# Verify configuration
cat .claude-collective/research.config.json

# Check metrics service
npx claude-collective metrics --status
```

**Solutions:**

1. **Initialize metrics**
```bash
# Setup metrics system
npx claude-collective init-metrics

# Create research config
npx claude-collective research --init
```

2. **Permissions issue**
```bash
# Fix directory permissions
chmod 755 .claude-collective/metrics
```

3. **Hook not triggering**
```bash
# Verify metrics hook in settings.json
grep -A5 "collective-metrics" .claude/settings.json

# Add if missing
npx claude-collective add-hook --name=collective-metrics
```

### Commands Not Working

**Symptoms:**
- /collective commands not recognized
- Command errors
- No response from commands

**Diagnosis:**
```bash
# Test command system
npx claude-collective run "/collective status"

# Check command parser
node -e "require('.claude-collective/lib/command-parser.js')"

# Verify command registration
ls .claude/commands/
```

**Solutions:**

1. **Parser not loaded**
```bash
# Reinstall command system
npx claude-collective install-commands
```

2. **Custom commands broken**
```bash
# Validate command files
for cmd in .claude/commands/*.md; do
  echo "Checking $cmd"
  head -1 "$cmd"
done
```

3. **Context not loaded**
```bash
# Ensure CLAUDE.md references commands
grep -i "command" CLAUDE.md || echo "⚠️ No command references"
```

### Performance Issues

**Symptoms:**
- Slow agent responses
- High token usage
- Timeouts

**Diagnosis:**
```bash
# Check performance metrics
npx claude-collective metrics --performance

# Monitor resource usage
npx claude-collective van check | grep -i performance

# Check cache size
du -sh .claude-collective/.cache
```

**Solutions:**

1. **Clear cache**
```bash
# Clean cache
rm -rf .claude-collective/.cache/*

# Or use optimization
npx claude-collective van optimize
```

2. **Reduce agent pool**
```bash
# List active agents
npx claude-collective list-agents --active

# Despawn unused
npx claude-collective despawn --inactive
```

3. **Optimize tests**
```bash
# Run only essential tests
npm test -- --testPathPattern=critical

# Disable coverage
npm test -- --coverage=false
```

## 🟢 Preventive Maintenance

### Daily Checks

```bash
#!/bin/bash
# daily-check.sh

echo "🔍 Running daily collective check..."

# 1. Health check
npx claude-collective van check

# 2. Test critical paths
cd .claude-collective && npm test -- --testNamePattern="critical"

# 3. Check metrics
npx claude-collective metrics --summary

# 4. Verify agents
npx claude-collective validate-agents

echo "✅ Daily check complete"
```

### Weekly Maintenance

```bash
#!/bin/bash
# weekly-maintenance.sh

echo "🔧 Running weekly maintenance..."

# 1. Full system maintenance
npx claude-collective van full

# 2. Update dependencies
cd .claude-collective && npm update

# 3. Clean old metrics
find .claude-collective/metrics -mtime +30 -delete

# 4. Optimize performance
npx claude-collective van optimize

# 5. Generate report
npx claude-collective van report

echo "✅ Weekly maintenance complete"
```

### Before Major Changes

```bash
#!/bin/bash
# pre-change-backup.sh

echo "💾 Creating pre-change backup..."

# 1. Create backup directory
BACKUP_DIR="collective-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"

# 2. Backup critical files
cp -r .claude "$BACKUP_DIR/"
cp -r .claude-collective "$BACKUP_DIR/"
cp CLAUDE.md "$BACKUP_DIR/"

# 3. Export registry
npx claude-collective export-registry > "$BACKUP_DIR/registry-export.json"

# 4. Save metrics
npx claude-collective metrics --export > "$BACKUP_DIR/metrics-export.json"

echo "✅ Backup created in $BACKUP_DIR"
```

## 🛠 Advanced Debugging

### Enable Debug Mode

```bash
# Set debug environment
export COLLECTIVE_DEBUG=true
export DEBUG=collective:*

# Run with verbose logging
npx claude-collective --verbose [command]

# Check debug logs
tail -f /tmp/collective-debug.log
```

### Trace Handoffs

```bash
# Enable handoff tracing
export TRACE_HANDOFFS=true

# Monitor handoff files
watch -n 1 'ls -la /tmp/handoff*.json | tail -5'

# Analyze handoff patterns
npx claude-collective analyze-handoffs
```

### Profile Performance

```bash
# Start profiling
npx claude-collective profile --start

# Run operations
@routing-agent "test task"

# Stop and analyze
npx claude-collective profile --stop --report
```

### Network Issues

```bash
# Test NPM connectivity
npm ping

# Check for proxy
echo $HTTP_PROXY $HTTPS_PROXY

# Test package installation
npm view claude-code-sub-agent-collective

# Use different registry
npm config set registry https://registry.npmjs.org/
```

## 📊 Diagnostic Scripts

### System Health Report

```javascript
// health-report.js
const { VanMaintenanceSystem } = require('.claude-collective/lib/van-maintenance');

async function generateHealthReport() {
  const van = new VanMaintenanceSystem();
  const health = await van.runHealthChecks();
  
  console.log('🏥 System Health Report');
  console.log('=' .repeat(50));
  console.log(`Overall Score: ${health.score}/100`);
  console.log(`Status: ${health.healthy ? '✅ Healthy' : '❌ Issues Detected'}`);
  
  if (health.issues.length > 0) {
    console.log('\n⚠️ Issues Found:');
    health.issues.forEach(issue => {
      console.log(`  - ${issue.name}: ${issue.issues.length} problems`);
      if (issue.critical) console.log('    🔴 CRITICAL');
    });
  }
  
  console.log('\n📋 Component Status:');
  health.checks.forEach(check => {
    const icon = check.healthy ? '✅' : '❌';
    console.log(`  ${icon} ${check.name}: ${check.score}/100`);
  });
  
  return health;
}

generateHealthReport();
```

### Handoff Analyzer

```javascript
// analyze-handoffs.js
const fs = require('fs-extra');
const path = require('path');

async function analyzeHandoffs() {
  const handoffDir = '/tmp';
  const files = await fs.readdir(handoffDir);
  const handoffs = files.filter(f => f.startsWith('handoff-'));
  
  const stats = {
    total: handoffs.length,
    successful: 0,
    failed: 0,
    agents: new Map(),
    errors: []
  };
  
  for (const file of handoffs) {
    try {
      const data = await fs.readJson(path.join(handoffDir, file));
      
      if (data.success) {
        stats.successful++;
      } else {
        stats.failed++;
        stats.errors.push({
          file,
          error: data.error,
          from: data.from,
          to: data.to
        });
      }
      
      // Track agent usage
      if (data.from) {
        stats.agents.set(data.from, 
          (stats.agents.get(data.from) || 0) + 1
        );
      }
      if (data.to) {
        stats.agents.set(data.to,
          (stats.agents.get(data.to) || 0) + 1
        );
      }
    } catch (error) {
      // Invalid handoff file
    }
  }
  
  console.log('🔄 Handoff Analysis');
  console.log('=' .repeat(50));
  console.log(`Total Handoffs: ${stats.total}`);
  console.log(`Success Rate: ${(stats.successful/stats.total*100).toFixed(1)}%`);
  
  console.log('\n📊 Agent Activity:');
  Array.from(stats.agents.entries())
    .sort((a, b) => b[1] - a[1])
    .forEach(([agent, count]) => {
      console.log(`  ${agent}: ${count} handoffs`);
    });
  
  if (stats.errors.length > 0) {
    console.log('\n❌ Recent Failures:');
    stats.errors.slice(-5).forEach(err => {
      console.log(`  ${err.from} → ${err.to}: ${err.error}`);
    });
  }
  
  return stats;
}

analyzeHandoffs();
```

## 🆘 Emergency Recovery

### Complete System Reset

```bash
#!/bin/bash
# emergency-reset.sh

echo "🚨 EMERGENCY RESET - This will destroy all collective data!"
echo "Press Ctrl+C to cancel, or wait 5 seconds..."
sleep 5

# 1. Backup everything first
EMERGENCY_BACKUP="emergency-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$EMERGENCY_BACKUP"
cp -r .claude "$EMERGENCY_BACKUP/" 2>/dev/null || true
cp -r .claude-collective "$EMERGENCY_BACKUP/" 2>/dev/null || true
cp CLAUDE.md "$EMERGENCY_BACKUP/" 2>/dev/null || true

echo "Backup created in $EMERGENCY_BACKUP"

# 2. Remove collective
rm -rf .claude-collective
rm -rf .claude/hooks/test-driven-handoff.sh
rm -rf .claude/hooks/directive-enforcer.sh
rm -rf .claude/hooks/collective-metrics.sh

# 3. Reinstall
npx claude-code-sub-agent-collective init --force

echo "✅ System reset complete"
echo "⚠️ Restore custom agents from $EMERGENCY_BACKUP if needed"
```

### Partial Recovery

```bash
#!/bin/bash
# partial-recovery.sh

COMPONENT=$1

case $COMPONENT in
  behavioral)
    npx claude-collective repair --component=behavioral
    ;;
  agents)
    npx claude-collective install-agents --core
    npx claude-collective rebuild-registry
    ;;
  hooks)
    npx claude-collective install-hooks
    chmod +x .claude/hooks/*.sh
    ;;
  tests)
    cd .claude-collective && npm install
    npx jest --clearCache
    ;;
  metrics)
    npx claude-collective init-metrics
    ;;
  *)
    echo "Usage: $0 [behavioral|agents|hooks|tests|metrics]"
    ;;
esac
```

## 📞 Getting Support

### Before Requesting Help

1. **Run diagnostics**
```bash
npx claude-collective diagnose > diagnostic-report.txt
```

2. **Collect logs**
```bash
tar -czf collective-logs.tar.gz \
  /tmp/collective*.log \
  /tmp/handoff*.json \
  .claude-collective/maintenance-reports/
```

3. **System info**
```bash
npx claude-collective support-bundle
```

### Support Channels

- **GitHub Issues**: [Create Issue] with diagnostic-report.txt
- **Discord**: #collective-help channel
- **Email**: support@collective.ai

### Information to Include

```markdown
## Issue Report

**System Information:**
- Node version: [node --version]
- NPM version: [npm --version]
- Collective version: [from package.json]
- OS: [Platform]

**Issue Description:**
[Clear description of the problem]

**Steps to Reproduce:**
1. [First step]
2. [Second step]
3. [Error occurs]

**Expected Behavior:**
[What should happen]

**Actual Behavior:**
[What actually happens]

**Diagnostic Output:**
[Attach diagnostic-report.txt]

**Attempted Solutions:**
- [ ] Tried solution 1
- [ ] Tried solution 2
```

## 🔄 Recovery Verification

After any recovery action:

```bash
#!/bin/bash
# verify-recovery.sh

echo "🔍 Verifying system recovery..."

CHECKS_PASSED=0
CHECKS_TOTAL=0

# Check 1: Structure
((CHECKS_TOTAL++))
if [ -f "CLAUDE.md" ] && [ -d ".claude" ] && [ -d ".claude-collective" ]; then
  echo "✅ File structure intact"
  ((CHECKS_PASSED++))
else
  echo "❌ File structure issues"
fi

# Check 2: Behavioral system
((CHECKS_TOTAL++))
if grep -q "NEVER IMPLEMENT DIRECTLY" CLAUDE.md 2>/dev/null; then
  echo "✅ Behavioral system configured"
  ((CHECKS_PASSED++))
else
  echo "❌ Behavioral system missing"
fi

# Check 3: Agents
((CHECKS_TOTAL++))
if [ -f ".claude/agents/routing-agent.md" ]; then
  echo "✅ Core agents present"
  ((CHECKS_PASSED++))
else
  echo "❌ Core agents missing"
fi

# Check 4: Hooks
((CHECKS_TOTAL++))
if [ -x ".claude/hooks/test-driven-handoff.sh" ]; then
  echo "✅ Hooks executable"
  ((CHECKS_PASSED++))
else
  echo "❌ Hooks not executable"
fi

# Check 5: Tests
((CHECKS_TOTAL++))
if cd .claude-collective && npm test -- --listTests > /dev/null 2>&1; then
  echo "✅ Test framework operational"
  ((CHECKS_PASSED++))
else
  echo "❌ Test framework issues"
fi

echo ""
echo "Recovery Status: $CHECKS_PASSED/$CHECKS_TOTAL checks passed"

if [ $CHECKS_PASSED -eq $CHECKS_TOTAL ]; then
  echo "✅ System fully recovered!"
  exit 0
else
  echo "⚠️ System partially recovered - manual intervention may be needed"
  exit 1
fi
```

---

**Remember**: Most issues can be resolved by:
1. Restarting Claude Code
2. Running van maintenance: `npx claude-collective van repair`
3. Checking file permissions
4. Verifying CLAUDE.md has behavioral directives

When in doubt, run: `npx claude-collective diagnose`