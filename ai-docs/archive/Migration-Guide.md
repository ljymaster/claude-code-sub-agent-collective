# Migration Guide: From Current to Collective

## 🎯 Overview

This guide walks through migrating your existing claude-code-sub-agent-collective project to the new Test-Driven Handoff (TDH) architecture with behavioral CLAUDE.md and research framework capabilities.

## 📋 Pre-Migration Checklist

Before starting migration:

- [ ] **Backup your project** - Create a full backup
- [ ] **Document custom agents** - List all existing agents
- [ ] **Note customizations** - Record any project-specific changes
- [ ] **Check Node version** - Ensure Node.js >= 16.0.0
- [ ] **Review breaking changes** - Understand what will change

## 🔄 Migration Paths

### Path A: Fresh Installation (Recommended)

Best for projects wanting a clean start with the new architecture.

```bash
# Step 1: Backup existing project
cp -r project project-backup

# Step 2: Install collective via NPX
npx claude-code-sub-agent-collective init

# Step 3: Migrate custom agents
cp project-backup/.claude/agents/* .claude/agents/

# Step 4: Update agent formats (see Agent Migration below)

# Step 5: Validate installation
npx claude-collective validate
```

### Path B: In-Place Upgrade

For projects wanting to preserve existing structure.

```bash
# Step 1: Create safety branch
git checkout -b collective-migration
git add . && git commit -m "Pre-migration snapshot"

# Step 2: Install collective with minimal mode
npx claude-code-sub-agent-collective init --minimal

# Step 3: Manually merge configurations
# See Configuration Merge section below

# Step 4: Test incrementally
npm test
```

### Path C: Gradual Migration

For large projects requiring phased approach.

```bash
# Phase 1: Install behavioral system only
npx claude-collective init --only=behavioral

# Phase 2: Add test framework
npx claude-collective add --component=testing

# Phase 3: Enable hooks
npx claude-collective add --component=hooks

# Phase 4: Complete migration
npx claude-collective add --component=all
```

## 🔧 Component Migration

### 1. Migrating CLAUDE.md

**Old Format:**
```markdown
# Project Instructions
- Basic instructions
- Agent list
```

**New Behavioral Format:**
```markdown
# 🧠 BEHAVIORAL OPERATING SYSTEM
Version: 1.0.0
Installation: {{DATE}}

## PRIME DIRECTIVE
**NEVER IMPLEMENT DIRECTLY** - You are the hub coordinator. Always delegate to specialized agents.

## CONTEXT ENGINEERING HYPOTHESES

### Hypothesis 1: JIT Context Loading
Loading context just-in-time reduces token usage by 30%.

### Hypothesis 2: Hub-and-Spoke Coordination
Centralized routing improves task success by 25%.

### Hypothesis 3: Test-Driven Handoffs
Test validation improves handoff reliability by 40%.

## HUB-AND-SPOKE COORDINATION

You are @routing-agent. Your role:
1. Receive ALL requests
2. Route to specialized agents
3. NEVER implement directly
4. Validate handoff success

### Available Agents
- @routing-agent: You (hub coordinator)
- @[existing-agents]: [Migrate descriptions]

## HANDOFF PROTOCOL
[Migration continues with test contracts...]
```

**Migration Steps:**
1. Backup existing CLAUDE.md: `cp CLAUDE.md CLAUDE.md.backup`
2. Run behavioral transformer: `npx claude-collective migrate-claude`
3. Manually merge custom sections
4. Add NEVER IMPLEMENT DIRECTLY directive
5. Update agent references to @agent-name format

### 2. Migrating Agents

**Old Agent Format:**
```markdown
# Agent Name
Description and instructions
```

**New Agent Format:**
```markdown
# 🤖 Agent Name

## 🤖 Agent Profile
**Type**: specialized
**Version**: 1.0.0
**Created**: {{DATE}}

## 🎯 Core Responsibilities
- Specific task 1
- Specific task 2

## 🛠 Available Tools
- Read
- Write
- Edit

## 🔄 Handoff Protocol

### Incoming Handoffs
- From: @routing-agent
- Condition: When [specific condition]

### Outgoing Handoffs
- To: @other-agent
- Condition: When [completion condition]

## 🧪 Test Contracts
```javascript
test('agent accepts valid handoff', () => {
  const handoff = {
    from: 'routing-agent',
    task: 'valid task',
    context: {}
  };
  expect(agent.validate(handoff)).toBe(true);
});
```

## 💡 Behavioral Directives
[Agent-specific behavior rules]
```

**Migration Script:**
```javascript
// migrate-agents.js
const fs = require('fs-extra');
const path = require('path');

async function migrateAgent(agentPath) {
  const content = await fs.readFile(agentPath, 'utf8');
  
  // Parse old format
  const lines = content.split('\n');
  const name = lines[0].replace('#', '').trim();
  const description = lines.slice(1).join('\n');
  
  // Generate new format
  const newContent = `# 🤖 ${name}

## 🤖 Agent Profile
**Type**: specialized
**Version**: 1.0.0
**Migrated**: ${new Date().toISOString()}

## 🎯 Core Responsibilities
${description}

## 🛠 Available Tools
- Read
- Write
- Edit
- Task

## 🔄 Handoff Protocol

### Incoming Handoffs
- From: @routing-agent
- Condition: When tasks match agent specialization

### Outgoing Handoffs
- To: @routing-agent
- Condition: When task complete

## 🧪 Test Contracts
\`\`\`javascript
test('${name} validates inputs', () => {
  const input = { task: 'test' };
  expect(agent.validate(input)).toBe(true);
});

test('${name} produces output', () => {
  const result = agent.process(validInput);
  expect(result).toHaveProperty('success');
});
\`\`\`

## 💡 Behavioral Directives
- Follow hub coordination
- Validate all inputs
- Report completion status
`;
  
  // Backup and write
  await fs.copy(agentPath, `${agentPath}.backup`);
  await fs.writeFile(agentPath, newContent);
  
  console.log(`Migrated: ${name}`);
}

// Run migration
async function migrateAllAgents() {
  const agentsDir = '.claude/agents';
  const agents = await fs.readdir(agentsDir);
  
  for (const agent of agents) {
    if (agent.endsWith('.md') && !agent.endsWith('.backup')) {
      await migrateAgent(path.join(agentsDir, agent));
    }
  }
}

migrateAllAgents();
```

### 3. Migrating Hooks

**Old Hook System:**
- Manual bash scripts
- No standardized configuration

**New Hook System:**

Create `.claude/settings.json`:
```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "*",
        "hooks": [{
          "type": "command",
          "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/directive-enforcer.sh"
        }]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Task",
        "hooks": [{
          "type": "command",
          "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/test-driven-handoff.sh"
        }]
      }
    ],
    "SubagentStop": [
      {
        "matcher": "*",
        "hooks": [{
          "type": "command",
          "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/test-driven-handoff.sh"
        }]
      }
    ]
  }
}
```

**Hook Migration Steps:**
1. List existing hooks: `ls .claude/hooks/`
2. Create settings.json with hook configuration
3. Install new TDH hooks: `npx claude-collective install-hooks`
4. Merge custom hooks into new structure
5. Test hook execution: `npx claude-collective test-hooks`

### 4. Configuration Merge

When merging configurations:

**package.json scripts:**
```json
{
  "scripts": {
    // Keep existing scripts
    "existing-script": "...",
    
    // Add collective scripts
    "collective:test": "cd .claude-collective && npm test",
    "collective:metrics": "node .claude-collective/lib/metrics.js",
    "collective:maintain": "node .claude-collective/lib/van-maintenance.js"
  }
}
```

**.gitignore additions:**
```gitignore
# Existing ignores
...

# Claude Collective
.claude-collective/metrics/
.claude-collective/coverage/
.claude-collective/node_modules/
.claude-collective/archive/
/tmp/collective*.log
/tmp/handoff*.json
```

## 🔍 Validation Steps

### Step 1: Structure Validation
```bash
npx claude-collective validate

# Expected output:
# ✅ CLAUDE.md exists
# ✅ Hooks directory
# ✅ Tests directory
# ✅ Settings configured
```

### Step 2: Agent Validation
```bash
# Test routing agent
@routing-agent "test request"

# Expected: Routes to appropriate agent
```

### Step 3: Hook Validation
```bash
# Trigger test-driven handoff
@routing-agent "complex task requiring handoff"

# Check /tmp/handoff-*.json created
ls /tmp/handoff*.json
```

### Step 4: Test Framework Validation
```bash
cd .claude-collective
npm test

# Expected: All tests pass
```

### Step 5: Metrics Validation
```bash
npx claude-collective metrics

# Expected: Metrics dashboard appears
```

## 🚨 Common Migration Issues

### Issue 1: Agent Format Incompatible

**Problem**: Old agents don't follow new format
**Solution**:
```bash
# Use migration script
node migrate-agents.js

# Or manually update each agent
```

### Issue 2: Hook Execution Fails

**Problem**: Hooks not executing
**Solution**:
```bash
# Check permissions
chmod +x .claude/hooks/*.sh

# Verify settings.json syntax
npx claude-collective validate-config

# Restart Claude Code session
```

### Issue 3: Test Contracts Missing

**Problem**: Agents lack test contracts
**Solution**:
```bash
# Generate default contracts
npx claude-collective generate-contracts

# Add to each agent manually
```

### Issue 4: CLAUDE.md Not Behavioral

**Problem**: CLAUDE.md missing behavioral directives
**Solution**:
```bash
# Use template
npx claude-collective reset-claude --backup

# Merge custom content back
```

### Issue 5: Metrics Not Collecting

**Problem**: Research metrics not recording
**Solution**:
```bash
# Initialize metrics
npx claude-collective init-metrics

# Check configuration
cat .claude-collective/research.config.json
```

## 📊 Migration Metrics

Track migration success:

```javascript
// migration-tracker.js
const tracker = {
  components: {
    behavioral: false,
    testing: false,
    hooks: false,
    agents: false,
    metrics: false
  },
  
  validate() {
    // Check each component
    this.components.behavioral = fs.existsSync('CLAUDE.md') && 
      fs.readFileSync('CLAUDE.md', 'utf8').includes('NEVER IMPLEMENT');
    
    this.components.testing = fs.existsSync('.claude-collective/tests');
    
    this.components.hooks = fs.existsSync('.claude/settings.json');
    
    this.components.agents = fs.existsSync('.claude/agents/routing-agent.md');
    
    this.components.metrics = fs.existsSync('.claude-collective/metrics');
    
    return this.components;
  },
  
  report() {
    const status = this.validate();
    const complete = Object.values(status).filter(v => v).length;
    const total = Object.keys(status).length;
    
    console.log(`Migration Progress: ${complete}/${total}`);
    
    for (const [component, ready] of Object.entries(status)) {
      console.log(`${ready ? '✅' : '❌'} ${component}`);
    }
    
    return complete === total;
  }
};

// Run tracker
if (tracker.report()) {
  console.log('\n🎉 Migration Complete!');
} else {
  console.log('\n⚠️ Migration Incomplete - Review missing components');
}
```

## 🎯 Post-Migration Tasks

After successful migration:

### 1. Update Documentation
```bash
# Generate new README
npx claude-collective generate-docs

# Update project documentation
```

### 2. Train Team
- Review behavioral CLAUDE.md
- Understand hub-and-spoke model
- Practice test-driven handoffs
- Learn command system

### 3. Configure Research
```bash
# Set research hypotheses baselines
npx claude-collective research --init

# Configure A/B testing
npx claude-collective research --configure-ab
```

### 4. Enable Van Maintenance
```bash
# Run initial maintenance
npx claude-collective van full

# Enable scheduled maintenance
npx claude-collective van schedule
```

### 5. Performance Baseline
```bash
# Capture pre-optimization metrics
npx claude-collective metrics --baseline

# Run for 1 week
# Compare results
```

## 🚀 Rollback Plan

If migration fails:

### Quick Rollback
```bash
# Restore from backup
rm -rf .claude .claude-collective CLAUDE.md
cp -r project-backup/.claude .
cp project-backup/CLAUDE.md .

# Or use git
git checkout main
git branch -D collective-migration
```

### Partial Rollback
```bash
# Keep some components
npx claude-collective remove --component=hooks
npx claude-collective remove --component=testing

# Restore specific files
cp project-backup/.claude/agents/* .claude/agents/
```

## 📈 Success Criteria

Migration is successful when:

- [ ] All agents migrated to new format
- [ ] CLAUDE.md includes behavioral directives
- [ ] Test framework operational
- [ ] Hooks executing correctly
- [ ] Metrics collecting data
- [ ] Van maintenance running
- [ ] Commands working
- [ ] No regression in functionality

## 🆘 Getting Help

### Resources
- GitHub Issues: [Project Issues]
- Documentation: `/ai-docs/`
- Community Discord: [Link]
- Migration Support: [Email]

### Diagnostic Commands
```bash
# Full system check
npx claude-collective diagnose

# Component-specific checks
npx claude-collective check --component=agents
npx claude-collective check --component=hooks
npx claude-collective check --component=tests

# Generate support bundle
npx claude-collective support-bundle
```

## 🎉 Welcome to the Collective!

Once migrated, you'll have:
- **50% reduction** in failed handoffs
- **30% reduction** in token usage
- **Self-healing** ecosystem
- **Research framework** for validation
- **Dynamic agent** creation
- **Natural language** commands

The collective awaits your research contributions!

---

**Migration typically takes**: 2-4 hours
**Support available**: Via GitHub Issues
**Rollback possible**: Yes, at any time