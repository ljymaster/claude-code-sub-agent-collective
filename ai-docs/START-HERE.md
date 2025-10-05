# START HERE - AI Documentation Guide

**Last Updated**: 2025-10-04

---

## What This Project Is

**Claude Code Collective** - NPX package that installs a TDD-focused AI agent framework into user projects.

**Architecture**: Hub Claude + File-based Memory + Hooks + Specialized Agents

---

## Read These Documents (In Order)

### 1. **V3-ARCHITECTURE-DESIGN.md** - The Big Picture
   - **What**: v3.0 architecture overview
   - **Why Read**: Understand how everything fits together
   - **Key Sections**: Hub Claude, Memory, Hooks, Agents

### 2. **Memory-System-Implementation-Strategy.md** - The Foundation
   - **What**: Deterministic file-based memory layer
   - **Why Read**: Everything builds on this
   - **Key Sections**: Atomic operations, memory.sh functions

### 3. **DETERMINISTIC-TASK-SYSTEM-DESIGN.md** - Task Management
   - **What**: Task system built on memory layer
   - **Why Read**: How tasks work, hooks enforce rules
   - **Key Sections**: task-index.json, hooks validation

### 4. **Phase-0-Test-Results-And-Fixes.md** - Phase 0 Results
   - **What**: Test results from Phase 0 validation
   - **Why Read**: Understand what was tested and found
   - **Key Sections**: Issues found, solutions being implemented

### 5. **V3-Cleanup-And-Final-Analysis.md** - CURRENT FOCUS ⭐
   - **What**: TaskMaster removal phases and execution plan
   - **Why Read**: This is what we're actively working on NOW
   - **Key Sections**: Phase 0 complete, Phase 0.5 (PRD workflow), Phase 1-5 plans

### 6. **PRD-Workflow-Gap-Analysis.md** - Critical Gap Found
   - **What**: Analysis of PRD workflow dependency on TaskMaster
   - **Why Read**: Explains why Phase 0.5 is needed before Phase 1
   - **Key Sections**: Gap identification, remediation options

### 7. **Phase-0.5-Implementation-Plan.md** - Next Action
   - **What**: Detailed plan for PRD workflow integration (4-5 hours)
   - **Why Read**: Understand exactly what needs to be built before Phase 1
   - **Key Sections**: Marker-based enforcement, three workflow paths, testing plan

---

## Supporting Documentation

### Research (ai-docs/research/)
- Memory-Tool-API-Analysis.md - Research on memory APIs
- Logging-System-Design.md - Logging specification
- Agent-TaskMaster-Cleanup-Analysis.md - Cleanup analysis

### Legacy v2.x (ai-docs/legacy/)
- V3-Migration-Plan.md - Old migration plan
- V3-IMPLEMENTATION-SUMMARY.md - Old summary
- TESTING-GUIDE.md - v2 testing guide
- USER-GUIDE.md - v2 user guide
- HOOK-CONTRACTS.md - Old contracts
- MEMORY-SCHEMA.md - Old schema

---

## Quick Summary

**What We Built**:
1. File-based memory system (`.claude/memory/`)
2. Task system using `task-index.json` (single file, all tasks)
3. Hooks for TDD enforcement (PreToolUse, SubagentStop)
4. 30+ specialized agents (component, feature, testing, quality)
5. `/van` command for intelligent task breakdown

**Current Status**: Phase 0 complete, Phase 0.5 designed (PRD workflow integration needed)

**Next**: Execute Phase 0.5 (4-5 hours), then Phase 1 (Delete TaskMaster)

---

## What To Do

1. Read docs 1-5 above (start with V3-ARCHITECTURE-DESIGN.md for big picture)
2. **Read #6-7** - Critical gap found and remediation plan
3. **Focus on #7 (Phase-0.5-Implementation-Plan.md)** - Next action item
4. Don't get confused by supporting docs (they're reference only)

---

**If you're lost, just read V3-ARCHITECTURE-DESIGN.md first.**
