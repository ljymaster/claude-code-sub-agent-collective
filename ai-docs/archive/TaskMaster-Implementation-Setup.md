# TaskMaster Implementation Setup

## 🎯 Overview

This document contains the complete TaskMaster configuration for implementing the claude-code-sub-agent-collective enhancement project. Use this to set up TaskMaster tracking for all 8 phases with proper dependencies, documentation links, and subtasks.

## 📋 Prerequisites

Ensure TaskMaster is initialized in the project:
```bash
# Initialize if not already done
mcp__task-master__initialize_project --projectRoot=/mnt/h/Active/taskmaster-agent-claude-code
```

## 🔧 Setup Commands

### Step 1: Parse Initial Tasks
```bash
# Create initial 8 phase tasks from MVP Roadmap
mcp__task-master__parse_prd \
  --input=/mnt/h/Active/taskmaster-agent-claude-code/ai-docs/MVP-Roadmap.md \
  --numTasks=8 \
  --projectRoot=/mnt/h/Active/taskmaster-agent-claude-code
```

### Step 2: Update Task Details
After parsing, update each task with the detailed information below using:
```bash
mcp__task-master__update_task --id=[TASK_ID] --prompt="[UPDATE_DETAILS]"
```

## 📊 Complete Task Structure

### Task 1: Phase 1 - Behavioral CLAUDE.md Transformation
```yaml
Description: Transform CLAUDE.md into behavioral operating system with prime directives and hub-and-spoke coordination
Details: See ai-docs/phases/Phase-1-Behavioral.md
Test Strategy: Validation script from ai-docs/Validation-Criteria.md#phase-1
Dependencies: None
Priority: High
Status: pending
Subtasks:
  1.1: Create backup of current CLAUDE.md in implementation/phase-1-behavioral/
  1.2: Write new behavioral OS structure with required sections
  1.3: Add PRIME DIRECTIVE with "NEVER IMPLEMENT DIRECTLY" enforcement
  1.4: Define hub-and-spoke coordination with @routing-agent as hub
  1.5: Document three research hypotheses (JIT, Hub-Spoke, TDD)
  1.6: Add agent registry and handoff protocols
  1.7: Run validation script to verify all requirements met
  1.8: Deploy validated CLAUDE.md to project root
```

### Task 2: Phase 2 - Testing Framework Setup
```yaml
Description: Set up Jest testing framework with test contracts for handoff validation
Details: See ai-docs/phases/Phase-2-Testing.md
Test Strategy: Validation script from ai-docs/Validation-Criteria.md#phase-2
Dependencies: Task 1 (requires behavioral CLAUDE.md)
Priority: High
Status: pending
Subtasks:
  2.1: Create .claude-collective directory structure
  2.2: Initialize npm and install Jest with required dependencies
  2.3: Configure jest.config.js for test environment
  2.4: Create test contract templates for preconditions/postconditions
  2.5: Write handoff validation test suite
  2.6: Write directive enforcement test suite
  2.7: Implement contract validation helpers
  2.8: Run full test suite and verify >80% coverage
```

### Task 3: Phase 3 - Hook Integration System
```yaml
Description: Implement hooks for directive enforcement and test-driven handoff validation
Details: See ai-docs/phases/Phase-3-Hooks.md
Test Strategy: Validation script from ai-docs/Validation-Criteria.md#phase-3
Dependencies: Task 1, Task 2 (needs behavioral system and tests)
Priority: High
Status: pending
Subtasks:
  3.1: Create .claude/hooks directory with proper permissions
  3.2: Write directive-enforcer.sh hook script
  3.3: Write test-driven-handoff.sh hook script
  3.4: Write collective-metrics.sh hook script
  3.5: Configure .claude/settings.json with hook mappings
  3.6: Test PreToolUse hook triggers for directive enforcement
  3.7: Test SubagentStop hook for handoff validation
  3.8: Verify all hooks execute with proper error handling
```

### Task 4: Phase 4 - NPX Package Distribution
```yaml
Description: Create NPX package for easy installation and updates of collective system
Details: See ai-docs/phases/Phase-4-NPX.md
Test Strategy: Validation script from ai-docs/Validation-Criteria.md#phase-4
Dependencies: Task 1, Task 2, Task 3 (core system must be complete)
Priority: Medium
Status: pending
Subtasks:
  4.1: Create package.json with proper metadata and dependencies
  4.2: Implement CollectiveInstaller class with template system
  4.3: Create file mapping for installation targets
  4.4: Build update mechanism with version checking
  4.5: Add rollback capability for failed updates
  4.6: Create CLI interface for npx commands
  4.7: Test installation on clean environment
  4.8: Publish to npm registry (or prepare for publishing)
```

### Task 5: Phase 5 - Natural Language Command System
```yaml
Description: Implement natural language commands for collective control and agent management
Details: See ai-docs/phases/Phase-5-Commands.md
Test Strategy: Validation script from ai-docs/Validation-Criteria.md#phase-5
Dependencies: Task 1 (needs routing agent)
Priority: Medium
Status: pending
Subtasks:
  5.1: Create CollectiveCommandParser class with pattern matching
  5.2: Implement /collective command namespace (status, spawn, etc.)
  5.3: Implement /agent command namespace (list, info, invoke)
  5.4: Implement /gate command namespace (validate, health)
  5.5: Add command autocomplete functionality
  5.6: Create command history tracking
  5.7: Build help system with examples
  5.8: Test all commands with edge cases
```

### Task 6: Phase 6 - Research Metrics Collection
```yaml
Description: Implement metrics collection for validating research hypotheses
Details: See ai-docs/phases/Phase-6-Metrics.md
Test Strategy: Validation script from ai-docs/Validation-Criteria.md#phase-6
Dependencies: Task 3 (needs hooks for collection)
Priority: High
Status: pending
Subtasks:
  6.1: Create MetricsCollector base class with storage
  6.2: Implement JITLoadingMetrics for hypothesis 1
  6.3: Implement HubSpokeMetrics for hypothesis 2
  6.4: Implement TDDHandoffMetrics for hypothesis 3
  6.5: Build A/B testing framework for experiments
  6.6: Create metrics aggregation and reporting
  6.7: Implement real-time metrics dashboard
  6.8: Verify metrics collection accuracy >95%
```

### Task 7: Phase 7 - Dynamic Agent Creation
```yaml
Description: Build system for on-demand agent spawning with templates and lifecycle management
Details: See ai-docs/phases/Phase-7-DynamicAgents.md
Test Strategy: Validation script from ai-docs/Validation-Criteria.md#phase-7
Dependencies: Task 1 (needs routing agent)
Priority: Low
Status: pending
Subtasks:
  7.1: Create AgentTemplateSystem with base templates
  7.2: Implement AgentSpawner for dynamic creation
  7.3: Build AgentRegistry for tracking and management
  7.4: Create lifecycle management with auto-cleanup
  7.5: Implement spawn command with quick/interactive modes
  7.6: Add template inheritance and customization
  7.7: Test spawning and despawning workflows
  7.8: Verify registry persistence and recovery
```

### Task 8: Phase 8 - Van Maintenance System
```yaml
Description: Implement self-healing ecosystem with health checks, auto-repair, and optimization
Details: See ai-docs/phases/Phase-8-VanMaintenance.md
Test Strategy: Validation script from ai-docs/Validation-Criteria.md#phase-8
Dependencies: All previous tasks (needs complete system)
Priority: Medium
Status: pending
Subtasks:
  8.1: Create VanMaintenanceSystem class with health checks
  8.2: Implement filesystem and structure validation
  8.3: Build auto-repair mechanisms for common issues
  8.4: Create optimization routines for performance
  8.5: Implement scheduled maintenance with cron
  8.6: Build maintenance reporting system
  8.7: Create van-maintenance-agent.md definition
  8.8: Test self-healing with induced failures
```

## 🔗 Dependency Configuration

Execute these commands to set up proper task dependencies:

```bash
# Phase 2 depends on Phase 1
mcp__task-master__add_dependency --id=2 --dependsOn=1 --projectRoot=/mnt/h/Active/taskmaster-agent-claude-code

# Phase 3 depends on Phases 1 and 2
mcp__task-master__add_dependency --id=3 --dependsOn=1 --projectRoot=/mnt/h/Active/taskmaster-agent-claude-code
mcp__task-master__add_dependency --id=3 --dependsOn=2 --projectRoot=/mnt/h/Active/taskmaster-agent-claude-code

# Phase 4 depends on Phases 1, 2, and 3 (full core system)
mcp__task-master__add_dependency --id=4 --dependsOn=1 --projectRoot=/mnt/h/Active/taskmaster-agent-claude-code
mcp__task-master__add_dependency --id=4 --dependsOn=2 --projectRoot=/mnt/h/Active/taskmaster-agent-claude-code
mcp__task-master__add_dependency --id=4 --dependsOn=3 --projectRoot=/mnt/h/Active/taskmaster-agent-claude-code

# Phase 5 depends on Phase 1
mcp__task-master__add_dependency --id=5 --dependsOn=1 --projectRoot=/mnt/h/Active/taskmaster-agent-claude-code

# Phase 6 depends on Phase 3 (needs hooks)
mcp__task-master__add_dependency --id=6 --dependsOn=3 --projectRoot=/mnt/h/Active/taskmaster-agent-claude-code

# Phase 7 depends on Phase 1
mcp__task-master__add_dependency --id=7 --dependsOn=1 --projectRoot=/mnt/h/Active/taskmaster-agent-claude-code

# Phase 8 depends on all previous phases
mcp__task-master__add_dependency --id=8 --dependsOn=1 --projectRoot=/mnt/h/Active/taskmaster-agent-claude-code
mcp__task-master__add_dependency --id=8 --dependsOn=2 --projectRoot=/mnt/h/Active/taskmaster-agent-claude-code
mcp__task-master__add_dependency --id=8 --dependsOn=3 --projectRoot=/mnt/h/Active/taskmaster-agent-claude-code
mcp__task-master__add_dependency --id=8 --dependsOn=4 --projectRoot=/mnt/h/Active/taskmaster-agent-claude-code
mcp__task-master__add_dependency --id=8 --dependsOn=5 --projectRoot=/mnt/h/Active/taskmaster-agent-claude-code
mcp__task-master__add_dependency --id=8 --dependsOn=6 --projectRoot=/mnt/h/Active/taskmaster-agent-claude-code
mcp__task-master__add_dependency --id=8 --dependsOn=7 --projectRoot=/mnt/h/Active/taskmaster-agent-claude-code
```

## 📈 Progress Tracking Commands

Use these commands throughout implementation:

```bash
# What to work on next
mcp__task-master__next_task --projectRoot=/mnt/h/Active/taskmaster-agent-claude-code

# Get all pending tasks
mcp__task-master__get_tasks --status=pending --withSubtasks --projectRoot=/mnt/h/Active/taskmaster-agent-claude-code

# Mark subtask complete
mcp__task-master__set_task_status --id=1.1 --status=done --projectRoot=/mnt/h/Active/taskmaster-agent-claude-code

# Get specific phase details
mcp__task-master__get_task --id=1 --projectRoot=/mnt/h/Active/taskmaster-agent-claude-code

# Check dependencies
mcp__task-master__validate_dependencies --projectRoot=/mnt/h/Active/taskmaster-agent-claude-code

# Generate task files for reference
mcp__task-master__generate --projectRoot=/mnt/h/Active/taskmaster-agent-claude-code
```

## 🎯 Implementation Workflow

For each task/phase:

1. **Start Phase**
   ```bash
   mcp__task-master__set_task_status --id=X --status=in-progress
   ```

2. **Work Through Subtasks**
   ```bash
   # Mark each subtask as complete
   mcp__task-master__set_task_status --id=X.1 --status=done
   mcp__task-master__set_task_status --id=X.2 --status=done
   # ... continue for all subtasks
   ```

3. **Complete Phase**
   ```bash
   mcp__task-master__set_task_status --id=X --status=done
   ```

4. **Check Next Task**
   ```bash
   mcp__task-master__next_task
   ```

## 📊 Success Metrics

Track these metrics as you complete phases:

- **Phase Completion Time**: Target 1-2 days per phase
- **Validation Pass Rate**: Must be 100% before marking done
- **Test Coverage**: Maintain >80% for Phase 2 onwards
- **Dependency Violations**: Should be 0
- **Rollback Count**: Track any required rollbacks

## 🚨 Important Notes

1. **Never skip validation**: Each phase has validation criteria that must pass
2. **Respect dependencies**: TaskMaster will enforce these
3. **Document issues**: Update task details with any blockers or changes
4. **Test incrementally**: Run tests after each subtask when possible
5. **Backup before deploy**: Subtask X.1 is always "Create backup"

## 🎉 Getting Started

1. Run the setup commands in order
2. Execute dependency configuration
3. Use `mcp__task-master__next_task` to get your first task
4. Begin with Task 1, Subtask 1.1: Create backup of current CLAUDE.md

---

**Remember**: TaskMaster is your single source of truth for implementation progress. Keep it updated!