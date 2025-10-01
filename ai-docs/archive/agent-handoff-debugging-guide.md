# Agent Handoff Debugging Guide

## 🚨 Critical Bug Pattern RESOLVED: Template Structure Issue (August 12, 2025)

### Problem Summary - FULLY FIXED
**Root Cause Identified**: The component-implementation-agent was following its completion template correctly but stopping at the closing ``` code block before reaching the handoff directive, which was positioned OUTSIDE the template.

**Final Solution**: **Handoff Directive Inside Template Structure** - Moving the handoff directive INSIDE the template code block ensures the agent outputs it as part of the natural template completion flow.

### Previous Issues Resolved:
1. **Hook Hijacking System (August 11)**: Implemented hook-based detection and block mechanism
2. **Template Structure (August 12)**: Fixed handoff directive positioning within agent templates
3. **Incomplete Work Detection (August 12)**: Added progressive detection for agents stopping with incomplete work

## 🔍 New Debugging Methodology - Hook Hijacking System

### 1. Hook Hijacking Verification (Primary Method)

**✅ Current Working System (August 11, 2025):**
- Hooks automatically detect handoff patterns in agent outputs
- Block mechanism forces immediate handoffs: `{"decision": "block", "reason": "WORKFLOW AUTOMATION: ..."}` 
- No dependency on agent file structure
- Auto-injection of hub returns for implementation agents

**🔧 Hook Hijacking Components:**
```bash
# Main hijacking logic in test-driven-handoff.sh lines 314-338
detect_handoff() → block_decision → immediate_handoff
```

### 1.1. Legacy Agent File Structure (Now Secondary)

**✅ Working Pattern (feature-implementation-agent, infrastructure-implementation-agent):**
```
## COMPLETION REPORTING TEMPLATE
[Template content with placeholders]
**Summary statement** 
↓ IMMEDIATE FLOW
## HUB RETURN PROTOCOL
```

**❌ Broken Pattern - Handoff Directive Outside Template (FIXED August 12):**
```
## COMPLETION REPORTING TEMPLATE
When I complete implementation, I use this format:
```
📁 **Files Created/Modified**: [file list]
```  ← Agent stops here, never reaches handoff directive

Use the task-orchestrator subagent to coordinate...  ← OUTSIDE template, never output
```

**✅ Fixed Pattern - Handoff Directive Inside Template:**
```
## COMPLETION REPORTING TEMPLATE  
When I complete implementation, I use this format:
```
📁 **Files Created/Modified**: [file list]

Use the task-orchestrator subagent to coordinate...  ← INSIDE template, always output
```
```

### 2. Hook Hijacking Verification Commands (Primary)

#### Check Hook Hijacking Status
```bash
# Verify hook hijacking is active
tail -20 /tmp/test-driven-handoff.log | grep -E "(Handoff detected|RESPONSE HIJACK|block.*decision)"
```

#### Test Block Mechanism
```bash
# Monitor real-time hook hijacking
tail -f /tmp/test-driven-handoff.log | grep -E "(block|decision|WORKFLOW AUTOMATION)"
```

#### Verify Pattern Detection
```bash
# Check Unicode normalization and pattern matching
grep -A 3 -B 3 "normalized_output\|detect_handoff" /tmp/test-driven-handoff.log
```

### 2.1. Legacy Structural Analysis Commands (Secondary)

#### Quick Check for Barriers (Now Optional)
```bash
# Check distance between template and handoff protocol
grep -n -A 15 "COMPLETION REPORTING TEMPLATE" .claude/agents/*.md | grep -B 10 -A 5 "HUB RETURN PROTOCOL"
```

#### Verify Handoff Directive Location (Still Useful)
```bash
# Find handoff directives in all agents
grep -n "Use the.*subagent to" .claude/agents/*.md
```

#### Check for Content Barriers (Now Bypassed by Hooks)
```bash
# Look for long sections between template and protocol
awk '/COMPLETION REPORTING TEMPLATE/,/HUB RETURN PROTOCOL/' .claude/agents/*.md | wc -l
```

### 3. Hook Hijacking Success/Failure Analysis

#### Check Recent Hook Hijacking Attempts
```bash
# Look for successful hook hijacking
tail -50 /tmp/test-driven-handoff.log | grep -E "(WORKFLOW AUTOMATION|block.*decision|auto-injected)"
```

#### Verify Block Mechanism Activation
```bash
# Check for block decisions being emitted
grep -A 3 -B 1 '"decision": "block"' /tmp/test-driven-handoff.log
```

#### Monitor Implementation Agent Hub Returns
```bash
# Check auto-injection of hub returns for implementation agents
grep "RESPONSE HIJACK.*implementation.*completed" /tmp/test-driven-handoff.log
```

#### Legacy Log Analysis (Still Useful)
```bash
# Check agent output processing
grep "Agent output length:" /tmp/test-driven-handoff.log | tail -10

# Check TDD validation results  
grep -A 3 -B 1 "TDD.*VALIDATION.*RESULTS" /tmp/test-driven-handoff.log
```

## 🛠️ Hook Hijacking Implementation Status ✅ COMPLETE

### System Status (August 11, 2025): FULLY OPERATIONAL

**✅ Hook Hijacking System Active:**
- Block mechanism implemented in `test-driven-handoff.sh` (lines 314-338)
- Unicode normalization for pattern detection (line 262)
- Auto-injection of hub returns for implementation agents (lines 327-338)
- Comprehensive TDD validation with stderr output (lines 342-348)

**✅ Key Features Working:**
1. **Pattern Detection**: Detects "Use the X subagent to..." patterns with Unicode normalization
2. **Block Decision**: Emits `{"decision": "block"}` to force immediate handoffs
3. **Hub Returns**: Auto-injects hub returns for implementation agents without explicit handoffs
4. **Incomplete Work Detection**: Auto-continues agents that stop with progress updates (NEW - August 12, 2025)
5. **TDD Validation with Actionable Feedback**: Two-checkpoint system prevents false completion crisis (NEW - August 12, 2025)
6. **JSON Parsing Robustness**: Handles malformed JSON and escape sequences (FIXED - August 12, 2025)

### 🆕 NEW FEATURES (August 12, 2025)

#### 1. Incomplete Work Detection
**Problem Solved**: Implementation agents sometimes provide status updates (e.g., "80% complete") instead of using completion templates, breaking workflow automation.

**Solution**: Progressive detection automatically identifies incomplete work patterns and forces agent continuation.

**Detection Patterns** (lines 339-349 in test-driven-handoff.sh):
- `[0-9]+%.*complete` - Percentage completion indicators
- `in progress` - Work still ongoing
- `refactor phase` - TDD phase indicators
- `next steps` - Planning indicators
- `partially completed` - Partial work status
- `ready to proceed` - Continuation signals
- `remaining work` - Work left indicators

**Auto-Response**: Forces same agent to continue and complete work with proper handoff template.

#### 2. TDD Validation System with Actionable Feedback
**Problem Solved**: Agents making false completion claims while tests were failing, creating a "false completion crisis" where broken code was being passed through the workflow.

**Solution**: Two-checkpoint TDD validation system with specific, actionable error reporting.

**System Architecture**:
- **Checkpoint 1 (Agent-level)**: Hook blocks handoffs when `npm test` or `npm run build` fail
- **Checkpoint 2 (Phase-level)**: TDD validation agent validates comprehensive methodology
- **Exception Handling**: TDD validation agent bypasses its own checkpoint (allowed to hand off during failures for remediation workflow)

**Actionable Failure Reporting** (lines 461-481 in test-driven-handoff.sh):
- **Specific Test Names**: Shows exact failing test names instead of generic "tests failing"
- **Error Messages**: Displays actual error message for each failing test  
- **Failure Count**: Shows scope (e.g., "183 failing tests")
- **Actionable Guidance**: "REQUIRED ACTION: Fix these specific test failures before handoff allowed"
- **Reference Logs**: Points to detailed logs for deeper investigation

**Before vs After**:
```bash
# BEFORE (Dead-end):
❌ Tests failing - handoff blocked

# AFTER (Actionable):
🔍 SPECIFIC TEST FAILURES IDENTIFIED:
❌ AppLayout Component > Basic Structure > renders main layout with proper semantic structure
   🔹 Unable to find an accessible element with the role "main"
❌ 183 failing tests total with specific error messages
REQUIRED ACTION: Fix these specific test failures before handoff allowed
```

**Log Indicators**:
```bash
[2025-08-12 XX:XX:XX] INCOMPLETE WORK DETECTED: Implementation agent stopped with incomplete work
[2025-08-12 XX:XX:XX] Incomplete work auto-continuation triggered for: agent-name
[2025-08-12 XX:XX:XX] 🧪 AGENT TDD CHECKPOINT: agent-name
[2025-08-12 XX:XX:XX] ❌ AGENT TDD FAILURE: agent-name tests failing
[2025-08-12 XX:XX:XX] 🔍 SPECIFIC TEST FAILURES IDENTIFIED: [detailed failures]
```

**Verification Commands**:
```bash
# Check for incomplete work detection
grep "INCOMPLETE WORK DETECTED" /tmp/test-driven-handoff.log

# Monitor auto-continuation triggers
grep "auto-continuation triggered" /tmp/test-driven-handoff.log

# Check TDD validation blocking with specific failures
grep -A 10 "SPECIFIC TEST FAILURES IDENTIFIED" /tmp/test-driven-handoff.log

# Monitor TDD checkpoint results
grep "🧪 AGENT TDD CHECKPOINT" /tmp/test-driven-handoff.log

# Check for false completion blocking
grep "TDD VALIDATION FAILED" /tmp/test-driven-handoff.log
```

### Legacy Agent File Checklist (Now Optional - Hook System Bypasses This):

1. **🔄 Completion Template Section** (Optional)
   - Find `## COMPLETION REPORTING TEMPLATE` or similar
   - Structure no longer critical due to hook hijacking

2. **🔄 Barrier Check** (Optional)  
   - Hook system bypasses structural barriers
   - Agent file structure is secondary to hook detection

3. **🔄 Handoff Protocol** (Still Recommended)
   - Include `## HUB RETURN PROTOCOL` for documentation
   - Handoff directive pattern still important for hook detection

4. **🔄 Barrier Relocation** (No Longer Required)
   - Hook system processes agent output regardless of file structure
   - Barriers no longer break handoff automation

## 🔧 Agent Structure Template (Working Pattern)

```markdown
## **📋 COMPLETION REPORTING TEMPLATE**

When I complete [AGENT_TYPE] implementation, I use this TDD completion format:

```
## 🚀 DELIVERY COMPLETE - TDD APPROACH
✅ Tests written first (RED phase) - [Brief description]
✅ Implementation passes all tests (GREEN phase) - [Brief description]  
✅ Code refactored for quality (REFACTOR phase) - [Brief description]
📊 Test Results: [X]/[Y] passing
🎯 **Task Delivered**: [Specific work completed]
📋 **Key Features**: [Key components/features]
📚 **Research Applied**: [Research used]
🔧 **Technologies Used**: [Tech stack]
📁 **Files Created/Modified**: [File list]
```

**I deliver [SUMMARY STATEMENT WITH AGENT FOCUS]!**

## 🔄 HUB RETURN PROTOCOL

After completing [AGENT_TYPE] implementation, I return to the coordinating hub with status:

```
Use the task-orchestrator subagent to coordinate the next phase - [AGENT_TYPE] implementation complete and validated.
```

This allows the hub to:
- Verify deliverables
- Deploy next phase agents
- Handle failures
- Maintain coordination

### **🎯 CUSTOMIZATION REFERENCE** ← MOVED TO END
[Detailed customization rules go here - won't interrupt execution flow]
```

## 🔍 Complete Agent Audit & Fix Commands

### 1. Full Agent Audit (Run This First)
```bash
#!/bin/bash
echo "🔍 COMPREHENSIVE AGENT AUDIT - $(date)"
echo "=================================================="

for agent in .claude/agents/*.md; do
  echo ""
  echo "Agent: $(basename "$agent")"
  echo "--------------------"
  
  # Check if handoff directive exists at all
  handoff_lines=$(grep -n "Use the.*subagent to" "$agent")
  if [[ -z "$handoff_lines" ]]; then
    echo "❌ CRITICAL: No handoff directive found"
    continue
  fi
  
  echo "Handoff directive found at:"
  echo "$handoff_lines"
  
  # Check if template exists
  if ! grep -q "COMPLETION.*TEMPLATE" "$agent"; then
    echo "⚠️  WARNING: No completion template found"
    continue
  fi
  
  # Extract template section and check handoff position
  template_content=$(awk '/COMPLETION.*TEMPLATE/,/```/' "$agent" | tail -n +1)
  
  if echo "$template_content" | grep -q "Use the.*subagent to"; then
    echo "✅ GOOD: Handoff directive inside template block"
  else
    echo "❌ BROKEN: Handoff directive OUTSIDE template block"
    echo "   NEEDS FIX: Move handoff directive inside template after file list"
    echo "   Template ends at line: $(grep -n '```$' "$agent" | head -1)"
  fi
done

echo ""
echo "=================================================="
echo "Audit complete. Fix broken agents using steps below."
```

### 2. Quick Status Check
```bash
# One-liner to see which agents need fixing
for agent in .claude/agents/*.md; do
  if awk '/COMPLETION.*TEMPLATE/,/```/' "$agent" | grep -q "Use the.*subagent to"; then
    echo "✅ $(basename "$agent")"
  else
    echo "❌ $(basename "$agent") - NEEDS FIX"
  fi
done
```

### 3. Fix Template Structure (Manual Steps)
For each broken agent identified above:

**Step 1: Backup the agent file**
```bash
cp .claude/agents/AGENT_NAME.md .claude/agents/AGENT_NAME.md.backup
```

**Step 2: Check current structure**
```bash
# View template section
grep -A 20 "COMPLETION.*TEMPLATE" .claude/agents/AGENT_NAME.md | grep -A 20 '```$'

# Find handoff directive location  
grep -n "Use the.*subagent to" .claude/agents/AGENT_NAME.md
```

**Step 3: Apply fix**
Move the handoff directive to be INSIDE the template code block, specifically:
- AFTER the `📁 **Files Created/Modified**: [...]` line
- BEFORE the closing ``` of the template

**Step 4: Verify fix**
```bash
# Check that handoff is now inside template
awk '/COMPLETION.*TEMPLATE/,/```/' ".claude/agents/AGENT_NAME.md" | grep "Use the.*subagent to"
# Should return the handoff directive (not empty)
```

### 4. Test Fixed Agent
```bash
# Test the agent with a simple task to verify handoff works
# Monitor logs: tail -f /tmp/test-driven-handoff.log
# Look for: "Handoff detected" instead of "No handoff directive detected"
```

## 🧪 Testing Handoff Flow

### Manual Test Command
```bash
# Test agent with direct invocation to see if handoff appears
echo "Test handoff message completion" | grep -E "Use the [a-z-]+ subagent to"
```

### Log Monitoring During Test
```bash
# Monitor handoff detection in real-time
tail -f /tmp/test-driven-handoff.log | grep -E "(Handoff detected|No handoff directive)"
```

## 📋 Agent Audit Checklist

### All Agents in .claude/agents/:

- [ ] **component-implementation-agent.md** - ✅ FIXED (structural barrier removed)
- [ ] **feature-implementation-agent.md** - ✅ VERIFIED WORKING
- [ ] **infrastructure-implementation-agent.md** - ✅ VERIFIED WORKING  
- [ ] **task-orchestrator.md** - ⚠️ CHECK (complex structure, may have barriers)
- [ ] **prd-research-agent.md** - ⚠️ CHECK (research agents may have complex flows)
- [ ] **testing-implementation-agent.md** - ⚠️ CHECK 
- [ ] **polish-implementation-agent.md** - ⚠️ CHECK
- [ ] **quality-agent.md** - ⚠️ CHECK
- [ ] **devops-agent.md** - ⚠️ CHECK

### Audit Commands for Each Agent:
```bash
# Check each agent structure
for agent in .claude/agents/*.md; do
  echo "=== $agent ==="
  awk '/COMPLETION.*TEMPLATE/,/HUB RETURN PROTOCOL/' "$agent" | wc -l
  grep -c "Use the.*subagent to" "$agent"
done
```

## 🚨 Red Flags to Watch For

1. **Template Structure Issues** (PRIMARY):
   - **Handoff directive OUTSIDE template code block** ← Most common cause
   - Agent stops at closing ``` without outputting handoff directive
   - Template format not being followed consistently

2. **Legacy Barrier Indicators** (SECONDARY):
   - Long customization sections between template and protocol
   - Detailed example sections interrupting flow
   - Multiple subsections with formatting rules

3. **Missing Components**:
   - No handoff directive in agent template at all
   - Handoff directive buried in descriptive text (not in template)
   - Template section missing closing ``` or malformed

4. **Validation Steps**:
   - Check agent follows template exactly in output
   - Verify handoff directive appears in actual agent completion
   - Confirm hook logs detect the handoff pattern

## 🔄 Validation After Fixes

### Template Structure Validation (CRITICAL):
1. **Template Code Block Check**: Ensure handoff directive is INSIDE the ``` template block
2. **Agent Output Verification**: Confirm agent actually outputs the handoff directive in completion
3. **Pattern Matching**: Verify hook logs detect "Use the X subagent to..." pattern

### Legacy Structure Validation:
1. **Structure Check**: Verify template → handoff directive → protocol flow  
2. **Log Monitoring**: Test with actual agent execution
3. **Integration Test**: Run end-to-end workflow to verify handoffs work

### Quick Fix Command:
```bash
# Check if handoff directive is properly positioned in template
grep -A 3 -B 3 "Files Created/Modified" .claude/agents/component-implementation-agent.md
# Should show handoff directive immediately after file list, before closing ```
```

## 🛠️ Agent Template Structure Guide

### Correct Template Structure (MANDATORY):
```markdown
## **📋 COMPLETION REPORTING TEMPLATE**

When I complete [AGENT_TYPE] implementation, I use this TDD completion format:

```
## 🚀 DELIVERY COMPLETE - TDD APPROACH
✅ Tests written first (RED phase) - [Brief description]
✅ Implementation passes all tests (GREEN phase) - [Brief description]  
✅ Code refactored for quality (REFACTOR phase) - [Brief description]
📊 Test Results: [X]/[Y] passing
🎯 **Task Delivered**: [Specific work completed]
📋 **Key Features**: [Key components/features]
📚 **Research Applied**: [Research used]
🔧 **Technologies Used**: [Tech stack]
📁 **Files Created/Modified**: [File list]

Use the task-orchestrator subagent to coordinate the next phase - [AGENT_TYPE] implementation complete and validated.
```

**[Optional summary statement]**

## 🔄 HUB RETURN PROTOCOL
[Rest of agent documentation...]
```

### Critical Requirements:
1. **Handoff directive MUST be inside the template code block** (between ``` and ```)
2. **Handoff directive MUST be after file list** as the final template line
3. **Template MUST close with ```** after handoff directive
4. **Pattern MUST be**: `Use the task-orchestrator subagent to coordinate the next phase - [description]`

## 🔧 Systematic Agent Review & Fix Process

### Step 1: Audit All Agents
```bash
# Check all agents for template structure
for agent in .claude/agents/*.md; do
  echo "=== $agent ==="
  echo "Template structure:"
  grep -A 15 "COMPLETION.*TEMPLATE" "$agent" | grep -B 5 -A 5 "```"
  echo "Handoff directive location:"
  grep -n "Use the.*subagent to" "$agent"
  echo "---"
done
```

### Step 2: Identify Problem Agents
```bash
# Find agents with handoff directives OUTSIDE template blocks
for agent in .claude/agents/*.md; do
  if grep -A 15 "COMPLETION.*TEMPLATE" "$agent" | grep -A 15 '```$' | grep -qv "Use the.*subagent to"; then
    echo "❌ BROKEN: $agent - handoff directive outside template"
  else
    echo "✅ GOOD: $agent - handoff directive inside template"
  fi
done
```

### Step 3: Fix Broken Agents
For each broken agent:
1. **Find the template block** - Look for `## COMPLETION REPORTING TEMPLATE` section
2. **Locate the file list line** - Usually `📁 **Files Created/Modified**: [...]`
3. **Add handoff directive** - Insert AFTER file list, BEFORE closing ```
4. **Verify format** - Must match: `Use the task-orchestrator subagent to coordinate the next phase - [description]`

### Step 4: Validate Fixes
```bash
# Test each fixed agent
echo "Testing agent: $AGENT_NAME"
grep -A 20 "COMPLETION.*TEMPLATE" ".claude/agents/$AGENT_NAME.md" | grep -A 10 "Files Created"
# Should show handoff directive before closing ```
```

## 📚 Reference - Updated August 12, 2025

### ✅ Hook Hijacking System Components:
- **Main Hook Script**: `.claude/hooks/test-driven-handoff.sh` (lines 314-350 contain block mechanism)
- **Hub Return Auto-Injection**: Lines 327-337 (completed work detection)
- **Incomplete Work Detection**: Lines 339-349 (progress update detection) - NEW August 12, 2025
- **Configuration**: `.claude/settings.json` (SubagentStop and PostToolUse hooks)
- **Log Location**: `/tmp/test-driven-handoff.log`
- **Decision Logic**: `.claude-collective/DECISION.md` (dual auto-delegation system)

### 📊 System Status:
- **Hook Hijacking**: ✅ ACTIVE (August 11, 2025)
- **Block Mechanism**: ✅ OPERATIONAL  
- **Unicode Normalization**: ✅ WORKING
- **Hub Return Injection**: ✅ ACTIVE
- **Incomplete Work Detection**: ✅ ACTIVE (August 12, 2025)
- **TDD Validation with Actionable Feedback**: ✅ COMPREHENSIVE (August 12, 2025)
- **JSON Parsing Robustness**: ✅ OPERATIONAL (August 12, 2025)
- **False Completion Crisis Prevention**: ✅ RESOLVED (August 12, 2025)

### 🔄 Agent Status:
- **All Implementation Agents**: ✅ HUB RETURN PROTOCOL added (commit 28e4bfd)
- **component-implementation-agent.md**: ✅ Enhanced with hub return
- **feature-implementation-agent.md**: ✅ Enhanced with hub return  
- **infrastructure-implementation-agent.md**: ✅ Enhanced with hub return
- **testing-implementation-agent.md**: ✅ Enhanced with hub return
- **polish-implementation-agent.md**: ✅ Enhanced with hub return

### 💡 Key Innovations:
1. **Hook Hijacking System (August 11)**: Intercepts agent outputs at system level and forces immediate handoffs through Claude Code's block mechanism
2. **Template Structure Fix (August 12)**: Ensures handoff directives are positioned INSIDE template code blocks so agents actually output them
3. **TDD Validation System (August 12)**: Two-checkpoint system prevents false completion crisis with actionable error reporting
4. **JSON Parsing Robustness (August 12)**: Handles malformed JSON with fallback extraction methods for reliable processing

### 🎯 Complete Solution Architecture:
**Four-Layer System** ensures 100% reliable automated handoffs:
1. **Template Structure**: Handoff directives positioned correctly within agent templates  
2. **Hook Detection**: Automatic pattern detection and block mechanism for immediate handoff execution
3. **TDD Validation**: Two-checkpoint system blocks false completions with specific, actionable feedback
4. **JSON Processing**: Robust parsing handles escaped characters and malformed JSON gracefully

### 🚨 Crisis Resolution Summary:
**False Completion Crisis (August 12, 2025) - RESOLVED**
- **Problem**: Agents claiming "TDD complete" while tests were failing, propagating broken code through workflow
- **Solution**: Mandatory TDD checkpoints with specific failure reporting that enables remediation instead of creating dead-ends
- **Result**: System now blocks false completions and provides actionable guidance for fixes

This debugging guide documents the complete solution that ensures reliable automated handoffs with TDD methodology enforcement.