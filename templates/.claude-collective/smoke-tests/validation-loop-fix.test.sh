#!/bin/bash
# validation-loop-fix.test.sh - Test agent extraction for validation loop resolution

MEMORY_DIR=".claude/memory"
HOOKS_DIR=".claude/hooks"
MARKERS_DIR="$MEMORY_DIR/markers"
HOOK="$HOOKS_DIR/pre-agent-deploy.sh"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🧪 Validation Loop Fix Smoke Test${NC}"
echo ""

PASS_COUNT=0
FAIL_COUNT=0

# Setup
mkdir -p "$MARKERS_DIR"

# TEST 1: Extract agent from subagent_type field
echo "TEST 1: Agent extraction from subagent_type field"

# Create validation marker
touch "$MARKERS_DIR/.needs-validation-1.1"

# Test with subagent_type field (what Claude Code actually sends)
TOOL_INPUT=$(cat <<'JSON'
{
  "tool_name": "Task",
  "tool_input": {
    "subagent_type": "tdd-validation-agent",
    "description": "Validate feature 1.1",
    "prompt": "Run validation for feature 1.1"
  }
}
JSON
)

RESULT=$(echo "$TOOL_INPUT" | "$HOOK" 2>&1)
DECISION=$(echo "$RESULT" | jq -r '.hookSpecificOutput.permissionDecision' 2>/dev/null)

echo -n "  Testing: subagent_type extraction allows tdd-validation-agent ... "
if [[ "$DECISION" == "allow" ]] && [[ ! -f "$MARKERS_DIR/.needs-validation-1.1" ]]; then
  echo -e "${GREEN}✅ PASS${NC}"
  PASS_COUNT=$((PASS_COUNT + 1))
else
  echo -e "${RED}❌ FAIL (decision: $DECISION, marker removed: $([ ! -f "$MARKERS_DIR/.needs-validation-1.1" ] && echo "yes" || echo "no"))${NC}"
  FAIL_COUNT=$((FAIL_COUNT + 1))
fi

# TEST 2: Block wrong agent when marker exists
echo ""
echo "TEST 2: Block non-validation agent when marker exists"

# Recreate marker
touch "$MARKERS_DIR/.needs-validation-1.1"

# Test with wrong agent
TOOL_INPUT=$(cat <<'JSON'
{
  "tool_name": "Task",
  "tool_input": {
    "subagent_type": "component-implementation-agent",
    "description": "Implement component",
    "prompt": "Build the component"
  }
}
JSON
)

RESULT=$(echo "$TOOL_INPUT" | "$HOOK" 2>&1)
DECISION=$(echo "$RESULT" | jq -r '.hookSpecificOutput.permissionDecision' 2>/dev/null)

echo -n "  Testing: Wrong agent blocked by validation marker ... "
if [[ "$DECISION" == "deny" ]] && [[ -f "$MARKERS_DIR/.needs-validation-1.1" ]]; then
  echo -e "${GREEN}✅ PASS${NC}"
  PASS_COUNT=$((PASS_COUNT + 1))
else
  echo -e "${RED}❌ FAIL (decision: $DECISION, marker exists: $([ -f "$MARKERS_DIR/.needs-validation-1.1" ] && echo "yes" || echo "no"))${NC}"
  FAIL_COUNT=$((FAIL_COUNT + 1))
fi

# TEST 3: Extract from description field (fallback)
echo ""
echo "TEST 3: Agent extraction from description field"

# Marker should still exist from TEST 2
TOOL_INPUT=$(cat <<'JSON'
{
  "tool_name": "Task",
  "tool_input": {
    "description": "tdd-validation-agent(Validate feature 1.1)",
    "prompt": "Validate feature"
  }
}
JSON
)

RESULT=$(echo "$TOOL_INPUT" | "$HOOK" 2>&1)
DECISION=$(echo "$RESULT" | jq -r '.hookSpecificOutput.permissionDecision' 2>/dev/null)

echo -n "  Testing: Description field extraction works ... "
if [[ "$DECISION" == "allow" ]] && [[ ! -f "$MARKERS_DIR/.needs-validation-1.1" ]]; then
  echo -e "${GREEN}✅ PASS${NC}"
  PASS_COUNT=$((PASS_COUNT + 1))
else
  echo -e "${RED}❌ FAIL (decision: $DECISION)${NC}"
  FAIL_COUNT=$((FAIL_COUNT + 1))
fi

# TEST 4: Extract from @ symbol in prompt (legacy)
echo ""
echo "TEST 4: Agent extraction from @ symbol in prompt"

# Recreate marker
touch "$MARKERS_DIR/.needs-validation-1.1"

TOOL_INPUT=$(cat <<'JSON'
{
  "tool_name": "Task",
  "tool_input": {
    "prompt": "Deploy @tdd-validation-agent for feature 1.1"
  }
}
JSON
)

RESULT=$(echo "$TOOL_INPUT" | "$HOOK" 2>&1)
DECISION=$(echo "$RESULT" | jq -r '.hookSpecificOutput.permissionDecision' 2>/dev/null)

echo -n "  Testing: @ symbol extraction works ... "
if [[ "$DECISION" == "allow" ]] && [[ ! -f "$MARKERS_DIR/.needs-validation-1.1" ]]; then
  echo -e "${GREEN}✅ PASS${NC}"
  PASS_COUNT=$((PASS_COUNT + 1))
else
  echo -e "${RED}❌ FAIL (decision: $DECISION)${NC}"
  FAIL_COUNT=$((FAIL_COUNT + 1))
fi

# TEST 5: Deliverables validation agent extraction
echo ""
echo "TEST 5: Deliverables validation agent extraction"

# Create deliverables marker
touch "$MARKERS_DIR/.needs-deliverables-validation-1.1"

TOOL_INPUT=$(cat <<'JSON'
{
  "tool_name": "Task",
  "tool_input": {
    "subagent_type": "deliverables-validation-agent",
    "description": "Validate deliverables for feature 1.1",
    "prompt": "Check deliverables"
  }
}
JSON
)

RESULT=$(echo "$TOOL_INPUT" | "$HOOK" 2>&1)
DECISION=$(echo "$RESULT" | jq -r '.hookSpecificOutput.permissionDecision' 2>/dev/null)

echo -n "  Testing: Deliverables validation agent allowed ... "
if [[ "$DECISION" == "allow" ]] && [[ ! -f "$MARKERS_DIR/.needs-deliverables-validation-1.1" ]]; then
  echo -e "${GREEN}✅ PASS${NC}"
  PASS_COUNT=$((PASS_COUNT + 1))
else
  echo -e "${RED}❌ FAIL (decision: $DECISION)${NC}"
  FAIL_COUNT=$((FAIL_COUNT + 1))
fi

# TEST 6: Empty extraction doesn't break (no agent in input)
echo ""
echo "TEST 6: No agent in input (should allow non-agent operations)"

# No markers present
rm -f "$MARKERS_DIR"/.needs-*

TOOL_INPUT=$(cat <<'JSON'
{
  "tool_name": "Task",
  "tool_input": {
    "prompt": "Do some task"
  }
}
JSON
)

RESULT=$(echo "$TOOL_INPUT" | "$HOOK" 2>&1)
DECISION=$(echo "$RESULT" | jq -r '.hookSpecificOutput.permissionDecision' 2>/dev/null)

echo -n "  Testing: No agent extraction allows operation ... "
if [[ "$DECISION" == "allow" ]] || [[ -z "$DECISION" ]]; then
  echo -e "${GREEN}✅ PASS${NC}"
  PASS_COUNT=$((PASS_COUNT + 1))
else
  echo -e "${RED}❌ FAIL (decision: $DECISION)${NC}"
  FAIL_COUNT=$((FAIL_COUNT + 1))
fi

# Cleanup
rm -rf "$MARKERS_DIR"

echo ""
echo "═══════════════════════════════"
echo "Test Results:"
echo -e "${GREEN}✅ Passed: $PASS_COUNT${NC}"
if [ $FAIL_COUNT -gt 0 ]; then
  echo -e "${RED}❌ Failed: $FAIL_COUNT${NC}"
else
  echo "❌ Failed: 0"
fi
echo ""

if [ $FAIL_COUNT -eq 0 ]; then
  echo -e "${GREEN}✅ All validation loop fix tests passed${NC}"
  exit 0
else
  echo -e "${RED}❌ Some validation loop fix tests failed${NC}"
  exit 1
fi
