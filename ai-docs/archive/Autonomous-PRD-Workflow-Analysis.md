# Autonomous PRD-to-App Workflow Analysis

## Executive Summary

This document provides a comprehensive analysis of the complete autonomous workflow that should occur when the `/van` command is used to build an application from a Product Requirements Document (PRD). It details the ideal workflow, identifies current implementation gaps, and provides clear requirements for achieving true autonomous operation.

## 🔄 Complete Autonomous Workflow

### Phase 1: Request Entry & Initial Routing

```
User: "/van build me an app based on the prd in .taskmaster/docs folder"
         ↓
Van Hub: Analyzes "build app from PRD" pattern
         ↓  
Van Hub: Routes to @prd-research-agent (NOT task-orchestrator directly)
```

**Key Insight**: The PRD needs research and task generation FIRST before orchestration can begin. Direct routing to task-orchestrator without existing tasks causes failure.

### Phase 2: PRD Analysis & Task Generation

The `@prd-research-agent` performs the following operations:

```
1. Read PRD from .taskmaster/docs/prd.txt
2. Extract technologies: [React, TypeScript, PostgreSQL, Express, etc.]
3. For EACH technology:
   - Use Context7: mcp__context7__resolve-library-id
   - Get docs: mcp__context7__get-library-docs
   - Cache research: .taskmaster/docs/research/
4. Generate TaskMaster structure:
   - mcp__task-master__parse_prd → Create base tasks
   - mcp__task-master__analyze_project_complexity → Score complexity
   - mcp__task-master__expand_all → Generate subtasks
5. Apply Research-Task Template to each task
6. HANDOFF: Report completion back to Van Hub
```

#### Standard Task Template

Each generated task follows this research-enhanced template:

```json
{
  "id": "1.2",
  "title": "Setup Express.js REST API",
  "research_context": {
    "technologies": ["express", "cors", "helmet"],
    "context7_docs": ["Latest Express 5.x patterns", "Security middleware"],
    "cached_research": [".taskmaster/docs/research/express-patterns.md"]
  },
  "execution_routing": {
    "primary_agent": "@feature-implementation-agent",
    "support_agents": ["@testing-implementation-agent"],
    "tdd_requirements": {
      "test_first": true,
      "coverage_target": 90,
      "test_types": ["unit", "integration", "api"]
    }
  },
  "dependencies": ["1.1"],
  "validation_gates": {
    "must_pass_tests": true,
    "security_scan": true,
    "performance_check": true
  }
}
```

### Phase 3: Task Orchestration Deployment

The `@task-orchestrator` coordinates parallel execution:

```
1. mcp__task-master__get_tasks → Load all generated tasks
2. Build dependency graph:
   - Identify root tasks (no dependencies)
   - Map task relationships
   - Find parallelization opportunities
3. Deploy MULTIPLE task-executors simultaneously:
   - task-executor-1 → UI components (tasks 1.3, 1.5, 2.5)
   - task-executor-2 → Backend APIs (tasks 1.2, 1.4)
   - task-executor-3 → Infrastructure (task 1.1)
4. Monitor progress via TaskMaster status updates
5. As tasks complete, deploy executors for newly unblocked work
```

### Phase 4: Task Execution & Agent Delegation

Parallel execution streams operate simultaneously:

```
PARALLEL EXECUTION:

task-executor-1 (UI Track):              task-executor-2 (Backend Track):
    ↓                                             ↓
Gets task 1.3 "Login/Register UI"        Gets task 1.2 "JWT Auth API"
    ↓                                             ↓
Routes to @component-implementation      Routes to @feature-implementation
    ↓                                             ↓
Includes Context7 research               Includes Context7 research
```

### Phase 5: Implementation with TDD Methodology

Each implementation agent follows the RED-GREEN-REFACTOR cycle:

```
@component-implementation-agent:
    1. RED PHASE:
       - Create test file: LoginForm.test.tsx
       - Write failing tests for component behavior
       - Run tests → FAIL ✗
    
    2. GREEN PHASE:
       - Create component: LoginForm.tsx
       - Implement minimal code to pass tests
       - Run tests → PASS ✓
    
    3. REFACTOR PHASE:
       - Improve code structure
       - Add styling with Tailwind
       - Ensure tests still pass → PASS ✓
    
    4. COMPLETION REPORT:
       ## 🚀 DELIVERY COMPLETE - TDD APPROACH
       ✅ Tests written first (RED phase)
       ✅ Implementation passes all tests (GREEN phase)
       ✅ Code refactored for quality (REFACTOR phase)
       📊 Test Results: 12/12 passing
    
    5. HANDOFF: Report back to task-executor-1
```

### Phase 6: Quality Validation

The `@task-checker` validates all implementations:

```
task-executor → Routes to @task-checker
                        ↓
@task-checker:
    1. Verify test files exist
    2. Run test suites: npm test
    3. Check coverage: >90%
    4. Validate TDD compliance
    5. Update TaskMaster: set_task_status(id="1.3", status="done")
    6. HANDOFF: Report validation to task-orchestrator
```

### Phase 7: Technology Gap Detection & Dynamic Agent Creation

When new technologies are encountered:

```
IF task requires technology NOT covered by existing agents:
    
task-orchestrator: Detects gap (e.g., "GraphQL API needed")
         ↓
Routes to @dynamic-agent-creator
         ↓
@dynamic-agent-creator:
    1. Analyze technology requirements
    2. Generate agent template:
       - Name: graphql-implementation-agent
       - Tools: Read, Write, Edit, mcp__context7__*
       - Specialization: GraphQL schema and resolvers
    3. Register in AgentRegistry
    4. HANDOFF: New agent ready for use
         ↓
task-orchestrator: Routes task to new agent
```

### Phase 8: Continuous Orchestration Loop

The orchestrator maintains continuous operation:

```
WHILE tasks remain:
    task-orchestrator:
        1. Check completed tasks
        2. Update dependency graph
        3. Identify newly available work
        4. Deploy executors for parallel tasks
        5. Monitor progress
        
    IF all tasks complete:
        Final validation via @completion-gate
        Generate project completion report
        HANDOFF: Report success to Van Hub
```

## 🚨 Current Reality vs Ideal State

### What's Actually Happening

1. **Incorrect Initial Routing**: Van routes to task-orchestrator before tasks exist
2. **MCP Tool Execution Failure**: Agents describe what they would do instead of executing
3. **No Autonomous Continuation**: System stops after first agent response
4. **Analysis Instead of Implementation**: Agents write documents, not code
5. **Sequential Instead of Parallel**: No parallel execution deployment

### Root Causes of Failure

1. **MCP Connection Issue**: TaskMaster tools aren't actually accessible to agents
2. **Agent Behavioral Issue**: Agents trained to describe rather than execute
3. **Missing Handoff Protocol**: No clear mechanism for autonomous continuation
4. **No Feedback Loop**: Results don't trigger next actions automatically
5. **Tool Configuration Problems**: Agents missing critical tools or have wrong permissions

## 🎯 Critical Requirements for True Autonomy

### Technical Requirements

1. **Working MCP Tools**: Agents must be able to execute TaskMaster commands
2. **Proper Tool Configuration**: All agents need complete tool sets
3. **Error Handling**: Graceful fallbacks when tools aren't available
4. **State Management**: TaskMaster maintaining state across handoffs
5. **Progress Tracking**: Real-time status updates and dependency management

### Behavioral Requirements

1. **Execution Mindset**: Agents must DO, not describe
2. **Autonomous Handoffs**: Clear protocol for continuing work
3. **Parallel Deployment**: Multiple agents working simultaneously
4. **Quality Gates**: Mandatory validation before task completion
5. **Research Integration**: Context7 research embedded in every task

### System Architecture Requirements

1. **Hub-and-Spoke Pattern**: Van Hub as central coordinator, agents as spokes
2. **No Peer-to-Peer**: All communication through hub
3. **TDD Enforcement**: RED-GREEN-REFACTOR cycle mandatory
4. **Research-First**: Context7 research before implementation
5. **Metrics Collection**: Track routing accuracy, handoff success, TDD compliance

## Success Metrics

### Performance Metrics
- **Routing Accuracy**: >95% correct agent selection
- **Parallel Efficiency**: >50% reduction in total execution time
- **Context Retention**: >90% information preservation across handoffs
- **TDD Compliance**: 100% of implementations follow RED-GREEN-REFACTOR
- **Task Completion Rate**: >98% first-pass success

### Research Validation Metrics
- **JIT Loading Efficiency**: <2 second agent spawn time
- **Hub-Spoke Overhead**: <10% coordination overhead
- **Agent Coverage**: All 12+ agent types successfully exercised
- **Handoff Success Rate**: >98% successful transfers
- **Quality Gate Pass Rate**: >95% validation success

## Implementation Priority

### Immediate Fixes Required
1. Fix MCP tool connection/accessibility
2. Update agent behavior to execute rather than describe
3. Implement proper handoff mechanisms
4. Enable parallel agent deployment
5. Establish feedback loops for continuous operation

### Long-term Enhancements
1. Dynamic agent creation for new technologies
2. Advanced parallelization strategies
3. Machine learning for routing optimization
4. Automated performance tuning
5. Self-healing capabilities

## Conclusion

The system architecture for autonomous PRD-to-app development is well-designed with appropriate separation of concerns, research integration, and quality gates. However, the current implementation has critical gaps in tool execution, agent behavior, and handoff protocols that prevent true autonomous operation.

Fixing these issues will enable the claude-code-sub-agent-collective to achieve its research goals of validating JIT context loading, hub-and-spoke coordination, and TDD methodology at scale.

---

**Document Version**: 1.0  
**Date**: 2025-08-10  
**Author**: Claude Code Sub-Agent Collective Analysis  
**Status**: Current State Analysis with Improvement Requirements