#!/bin/bash
# Smoke test: Preflight user confirmation via transcript validation
# Validates that preflight hook blocks fabricated responses by checking transcript

set -euo pipefail

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

TESTS_PASSED=0
TESTS_FAILED=0

echo "🧪 Preflight User Confirmation Smoke Test"
echo ""

# Test helper
test_confirmation() {
    local description="$1"
    local expected_result="$2"  # "pass" or "fail"
    local test_function="$3"

    echo -n "  Testing: $description ... "

    local actual_result
    if eval "$test_function" >/dev/null 2>&1; then
        actual_result="pass"
    else
        actual_result="fail"
    fi

    if [[ "$actual_result" == "$expected_result" ]]; then
        echo -e "${GREEN}✅ PASS${NC}"
        TESTS_PASSED=$((TESTS_PASSED+1))
        return 0
    else
        echo -e "${RED}❌ FAIL (expected: $expected_result, got: $actual_result)${NC}"
        TESTS_FAILED=$((TESTS_FAILED+1))
        return 1
    fi
}

# Setup test environment
setup() {
    mkdir -p .claude/memory/test-transcripts
    mkdir -p .claude/hooks
}

# Cleanup
cleanup() {
    rm -rf .claude/memory/test-transcripts
}

trap cleanup EXIT

setup

echo "TEST 1: Deny preflight with no transcript (fabricated)"

# Test that preflight is denied when no user messages in transcript
test_no_user_messages() {
    # Create fake transcript with only assistant messages (no user interaction)
    # Using real Claude Code transcript format
    local TRANSCRIPT=".claude/memory/test-transcripts/fabricated.jsonl"
    cat > "$TRANSCRIPT" << 'EOF'
{"type":"assistant","message":{"role":"assistant","content":[{"type":"text","text":"📊 Enable deterministic logging? (y/n)"}]}}
{"type":"assistant","message":{"role":"assistant","content":[{"type":"text","text":"User answered: n"}]}}
{"type":"assistant","message":{"role":"assistant","content":[{"type":"text","text":"🌐 Enable browser testing? (y/n)"}]}}
{"type":"assistant","message":{"role":"assistant","content":[{"type":"text","text":"User answered: y"}]}}
EOF

    # Try to run preflight - hook should DENY
    local INPUT=$(cat <<JSON
{
  "transcript_path": "$TRANSCRIPT",
  "hook_event_name": "PreToolUse",
  "tool_name": "Bash",
  "tool_input": {
    "command": "./.claude/memory/lib/preflight.sh '{\"logging\":\"n\",\"browserTesting\":\"y\",\"userConfirmed\":true}'"
  }
}
JSON
)

    # Hook should return deny
    local RESULT=$(echo "$INPUT" | ./.claude/hooks/preflight-confirmation.sh 2>&1)
    echo "$RESULT" | jq -e '.hookSpecificOutput.permissionDecision == "deny"' >/dev/null
}

test_confirmation "No user messages (fabricated)" "pass" "test_no_user_messages"

echo ""
echo "TEST 2: Allow preflight with actual user messages"

# Test that preflight is allowed when real user messages exist
test_real_user_messages() {
    # Create transcript with actual user messages
    # Using real Claude Code transcript format
    local TRANSCRIPT=".claude/memory/test-transcripts/real.jsonl"
    cat > "$TRANSCRIPT" << 'EOF'
{"type":"assistant","message":{"role":"assistant","content":[{"type":"text","text":"📊 Enable deterministic logging? (y/n)"}]}}
{"type":"user","message":{"role":"user","content":"n"}}
{"type":"assistant","message":{"role":"assistant","content":[{"type":"text","text":"🌐 Enable browser testing? (y/n)"}]}}
{"type":"user","message":{"role":"user","content":"y"}}
{"type":"assistant","message":{"role":"assistant","content":[{"type":"text","text":"Now running preflight with your answers..."}]}}
EOF

    # Try to run preflight - hook should ALLOW
    local INPUT=$(cat <<JSON
{
  "transcript_path": "$TRANSCRIPT",
  "hook_event_name": "PreToolUse",
  "tool_name": "Bash",
  "tool_input": {
    "command": "./.claude/memory/lib/preflight.sh '{\"logging\":\"n\",\"browserTesting\":\"y\",\"userConfirmed\":true}'"
  }
}
JSON
)

    # Hook should return allow
    local RESULT=$(echo "$INPUT" | ./.claude/hooks/preflight-confirmation.sh 2>&1)
    echo "$RESULT" | jq -e '.hookSpecificOutput.permissionDecision == "allow"' >/dev/null
}

test_confirmation "Real user messages present" "pass" "test_real_user_messages"

echo ""
echo "TEST 3: Deny preflight with wrong answer sequence"

# Test that preflight is denied when answers don't match transcript
test_wrong_answers() {
    # Create transcript where user said "y" for logging
    # Using real Claude Code transcript format
    local TRANSCRIPT=".claude/memory/test-transcripts/wrong.jsonl"
    cat > "$TRANSCRIPT" << 'EOF'
{"type":"assistant","message":{"role":"assistant","content":[{"type":"text","text":"📊 Enable deterministic logging? (y/n)"}]}}
{"type":"user","message":{"role":"user","content":"y"}}
{"type":"assistant","message":{"role":"assistant","content":[{"type":"text","text":"🌐 Enable browser testing? (y/n)"}]}}
{"type":"user","message":{"role":"user","content":"n"}}
EOF

    # Try to run preflight with DIFFERENT answers - hook should DENY
    local INPUT=$(cat <<JSON
{
  "transcript_path": "$TRANSCRIPT",
  "hook_event_name": "PreToolUse",
  "tool_name": "Bash",
  "tool_input": {
    "command": "./.claude/memory/lib/preflight.sh '{\"logging\":\"n\",\"browserTesting\":\"y\",\"userConfirmed\":true}'"
  }
}
JSON
)

    # Hook should return deny (answers don't match)
    local RESULT=$(echo "$INPUT" | ./.claude/hooks/preflight-confirmation.sh 2>&1)
    echo "$RESULT" | jq -e '.hookSpecificOutput.permissionDecision == "deny"' >/dev/null
}

test_confirmation "Answers don't match transcript" "pass" "test_wrong_answers"

echo ""
echo "TEST 4: Allow non-preflight bash commands"

# Test that other bash commands are not affected
test_other_bash_commands() {
    local TRANSCRIPT=".claude/memory/test-transcripts/other.jsonl"
    cat > "$TRANSCRIPT" << 'EOF'
{"type":"user","content":"list files"}
EOF

    local INPUT=$(cat <<JSON
{
  "transcript_path": "$TRANSCRIPT",
  "hook_event_name": "PreToolUse",
  "tool_name": "Bash",
  "tool_input": {
    "command": "ls -la"
  }
}
JSON
)

    # Hook should return allow (not a preflight command)
    local RESULT=$(echo "$INPUT" | ./.claude/hooks/preflight-confirmation.sh 2>&1)
    echo "$RESULT" | jq -e '.hookSpecificOutput.permissionDecision == "allow"' >/dev/null
}

test_confirmation "Non-preflight commands allowed" "pass" "test_other_bash_commands"

echo ""
echo "════════════════════════════════"
echo "Test Results:"
echo -e "${GREEN}✅ Passed: $TESTS_PASSED${NC}"

if [[ $TESTS_FAILED -gt 0 ]]; then
    echo -e "${RED}❌ Failed: $TESTS_FAILED${NC}"
    echo ""
    echo -e "${YELLOW}⚠️  Some tests failed - preflight confirmation hook has issues${NC}"
    exit 1
else
    echo -e "❌ Failed: $TESTS_FAILED"
    echo ""
    echo -e "${GREEN}✅ All preflight user confirmation tests passed${NC}"
    exit 0
fi
