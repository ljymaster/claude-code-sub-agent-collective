#!/bin/bash
# tdd-gate.sh - TDD enforcement using native decision control
# Uses Claude 4.5 native hook decision mechanism to block non-TDD changes

MEMORY_DIR=".claude/memory"
LIB_DIR="$MEMORY_DIR/lib"

# Source logging library
# shellcheck disable=SC1091
source "$LIB_DIR/logging.sh" 2>/dev/null || true

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name')
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // empty')

# Only gate Edit/Write operations
if [[ "$TOOL_NAME" != "Edit" && "$TOOL_NAME" != "Write" ]]; then
    log_hook_event "PreToolUse" "$TOOL_NAME" "" "allow" "Not an Edit/Write operation" "{\"tool\":\"$TOOL_NAME\"}"
    echo '{"hookSpecificOutput": {"hookEventName": "PreToolUse", "permissionDecision": "allow", "permissionDecisionReason": "Not an Edit/Write operation"}}'
    exit 0
fi

# If no file path, allow (might be other operation)
if [[ -z "$FILE_PATH" || "$FILE_PATH" == "null" ]]; then
    log_hook_event "PreToolUse" "$TOOL_NAME" "" "allow" "No file path specified" "{\"hasFilePath\":false}"
    echo '{"hookSpecificOutput": {"hookEventName": "PreToolUse", "permissionDecision": "allow", "permissionDecisionReason": "No file path specified"}}'
    exit 0
fi

# Check if this is a test file (allow test creation)
if [[ "$FILE_PATH" =~ \.test\.|\.spec\.|__tests__|\.test/|\.spec/|/tests/ ]]; then
    log_hook_event "PreToolUse" "$TOOL_NAME" "$FILE_PATH" "allow" "Test file modification allowed" "{\"fileType\":\"test\",\"file\":\"$FILE_PATH\"}"
    echo '{"hookSpecificOutput": {"hookEventName": "PreToolUse", "permissionDecision": "allow", "permissionDecisionReason": "Test file modification allowed"}}'
    exit 0
fi

# Check if this is a documentation file (allow docs)
if [[ "$FILE_PATH" =~ \.md$|\.txt$|/docs/|CLAUDE\.md|README ]]; then
    log_hook_event "PreToolUse" "$TOOL_NAME" "$FILE_PATH" "allow" "Documentation file allowed" "{\"fileType\":\"docs\",\"file\":\"$FILE_PATH\"}"
    echo '{"hookSpecificOutput": {"hookEventName": "PreToolUse", "permissionDecision": "allow", "permissionDecisionReason": "Documentation file allowed"}}'
    exit 0
fi

# Check if this is a configuration file (allow configs)
if [[ "$FILE_PATH" =~ package\.json|tsconfig\.json|\.config\.|\.rc$|\.yaml$|\.yml$ ]]; then
    log_hook_event "PreToolUse" "$TOOL_NAME" "$FILE_PATH" "allow" "Configuration file allowed" "{\"fileType\":\"config\",\"file\":\"$FILE_PATH\"}"
    echo '{"hookSpecificOutput": {"hookEventName": "PreToolUse", "permissionDecision": "allow", "permissionDecisionReason": "Configuration file allowed"}}'
    exit 0
fi

# Check if this is infrastructure: .claude/memory/ or .claude/hooks/ or shell scripts
if [[ "$FILE_PATH" =~ \.claude/memory/|\.claude/hooks/|\.sh$ ]]; then
    log_hook_event "PreToolUse" "$TOOL_NAME" "$FILE_PATH" "allow" "Infrastructure file allowed" "{\"fileType\":\"infrastructure\",\"file\":\"$FILE_PATH\"}"
    echo '{"hookSpecificOutput": {"hookEventName": "PreToolUse", "permissionDecision": "allow", "permissionDecisionReason": "Infrastructure file allowed"}}'
    exit 0
fi

# Extract file directory and base name
FILE_DIR=$(dirname "$FILE_PATH")
FILE_NAME=$(basename "$FILE_PATH")
FILE_BASE="${FILE_NAME%.*}"

# Look for test files matching this implementation file
TEST_FOUND=false

# TASK-AWARE APPROACH: Check if we're in a memory-based task workflow
TASK_INDEX="$MEMORY_DIR/task-index.json"

if [[ -f "$TASK_INDEX" ]]; then
    # Find task that has this file as a deliverable
    CURRENT_TASK=$(jq -r --arg file "$FILE_PATH" '.tasks[] | select(.deliverables[]? == $file) | .id' "$TASK_INDEX" 2>/dev/null | head -1)

    if [[ -n "$CURRENT_TASK" ]]; then
        # Task-aware: Check dependency tasks for test deliverables
        DEPENDENCIES=$(jq -r --arg taskid "$CURRENT_TASK" '.tasks[] | select(.id == $taskid) | .dependencies[]? // empty' "$TASK_INDEX" 2>/dev/null)

        if [[ -n "$DEPENDENCIES" ]]; then
            # Check if any dependency task deliverables exist (those are the tests)
            for dep_id in $DEPENDENCIES; do
                TEST_DELIVERABLES=$(jq -r --arg depid "$dep_id" '.tasks[] | select(.id == $depid) | .deliverables[]?' "$TASK_INDEX" 2>/dev/null)

                for test_file in $TEST_DELIVERABLES; do
                    if [[ -f "$test_file" ]]; then
                        TEST_FOUND=true
                        log_hook_event "PreToolUse" "$TOOL_NAME" "$FILE_PATH" "allow" "Task-aware: Tests exist from dependency task $dep_id" "{\"file\":\"$FILE_PATH\",\"testFile\":\"$test_file\",\"dependencyTask\":\"$dep_id\"}"
                        break 2
                    fi
                done
            done

            # If dependencies exist but no test files found, this is a task structure problem
            if [[ "$TEST_FOUND" = false ]]; then
                log_hook_event "PreToolUse" "$TOOL_NAME" "$FILE_PATH" "deny" "Task structure error: Dependency task deliverables don't exist" "{\"file\":\"$FILE_PATH\",\"currentTask\":\"$CURRENT_TASK\",\"dependencies\":\"$DEPENDENCIES\"}"
                echo "{
                    \"hookSpecificOutput\": {
                        \"hookEventName\": \"PreToolUse\",
                        \"permissionDecision\": \"deny\",
                        \"permissionDecisionReason\": \"🚨 TASK STRUCTURE ERROR\\n\\nTask ${CURRENT_TASK} has dependencies but test files don't exist.\\n\\nThis indicates a problem with task breakdown, not TDD compliance.\\n\\n❌ Cannot proceed - dependency task deliverables missing\\n\\n💡 Solution: Hub Claude should redeploy task-breakdown-agent to fix task structure\"
                    }
                }"
                exit 0
            fi
        else
            # No dependencies = this is a test task itself, allow
            TEST_FOUND=true
            log_hook_event "PreToolUse" "$TOOL_NAME" "$FILE_PATH" "allow" "Task-aware: Test task (no dependencies)" "{\"file\":\"$FILE_PATH\",\"currentTask\":\"$CURRENT_TASK\",\"taskType\":\"test\"}"
        fi
    fi
fi

# FALLBACK: Pattern-based matching (for non-task workflows)
if [[ "$TEST_FOUND" = false ]]; then
    # Pattern 1: Same directory with .test or .spec extension
    if [[ -f "${FILE_DIR}/${FILE_BASE}.test.ts" ]] || \
       [[ -f "${FILE_DIR}/${FILE_BASE}.test.js" ]] || \
       [[ -f "${FILE_DIR}/${FILE_BASE}.test.tsx" ]] || \
       [[ -f "${FILE_DIR}/${FILE_BASE}.test.jsx" ]] || \
       [[ -f "${FILE_DIR}/${FILE_BASE}.spec.ts" ]] || \
       [[ -f "${FILE_DIR}/${FILE_BASE}.spec.js" ]] || \
       [[ -f "${FILE_DIR}/${FILE_BASE}.spec.tsx" ]] || \
       [[ -f "${FILE_DIR}/${FILE_BASE}.spec.jsx" ]]; then
        TEST_FOUND=true
    fi

    # Pattern 2: __tests__ subdirectory
    if [[ -d "${FILE_DIR}/__tests__" ]]; then
        if [[ -f "${FILE_DIR}/__tests__/${FILE_BASE}.test.ts" ]] || \
           [[ -f "${FILE_DIR}/__tests__/${FILE_BASE}.test.js" ]] || \
           [[ -f "${FILE_DIR}/__tests__/${FILE_BASE}.ts" ]] || \
           [[ -f "${FILE_DIR}/__tests__/${FILE_BASE}.js" ]]; then
            TEST_FOUND=true
        fi
    fi

    # Pattern 3: tests directory at project root
    if [[ -d "tests" ]]; then
        # Find any test file containing the base name
        if find tests -name "*${FILE_BASE}*test*" -o -name "*${FILE_BASE}*spec*" 2>/dev/null | grep -q .; then
            TEST_FOUND=true
        fi
    fi

    # Pattern 4: Check for test directory parallel to source
    if [[ "$FILE_DIR" =~ ^(src|lib)/ ]]; then
        TEST_DIR=$(echo "$FILE_DIR" | sed 's/^src/tests/' | sed 's/^lib/tests/')
        if [[ -f "${TEST_DIR}/${FILE_BASE}.test.ts" ]] || \
           [[ -f "${TEST_DIR}/${FILE_BASE}.test.js" ]] || \
           [[ -f "${TEST_DIR}/${FILE_BASE}.spec.ts" ]] || \
           [[ -f "${TEST_DIR}/${FILE_BASE}.spec.js" ]]; then
            TEST_FOUND=true
        fi
    fi
fi

# Decision: Allow or block
if [ "$TEST_FOUND" = true ]; then
    log_hook_event "PreToolUse" "$TOOL_NAME" "$FILE_PATH" "allow" "Tests exist for this file" "{\"file\":\"$FILE_PATH\",\"testsFound\":true}"
    echo '{"hookSpecificOutput": {"hookEventName": "PreToolUse", "permissionDecision": "allow", "permissionDecisionReason": "Tests exist for this file"}}'
    exit 0
else
    # Block with helpful message (LOG this TDD violation)
    log_hook_event "PreToolUse" "$TOOL_NAME" "$FILE_PATH" "deny" "TDD violation: No tests found for $FILE_NAME" "{\"file\":\"$FILE_PATH\",\"testsFound\":false,\"fileBase\":\"$FILE_BASE\"}"
    echo "{
        \"hookSpecificOutput\": {
            \"hookEventName\": \"PreToolUse\",
            \"permissionDecision\": \"deny\",
            \"permissionDecisionReason\": \"🧪 TDD VIOLATION: No tests found for ${FILE_NAME}\\n\\nWrite tests first (RED phase):\\n\\nExpected test locations:\\n  • ${FILE_DIR}/${FILE_BASE}.test.{ts,js,tsx,jsx}\\n  • ${FILE_DIR}/__tests__/${FILE_BASE}.test.{ts,js}\\n  • tests/**/${FILE_BASE}.{test,spec}.{ts,js}\\n\\nTDD Workflow:\\n  1. RED: Write failing test\\n  2. GREEN: Write minimal code to pass\\n  3. REFACTOR: Clean up implementation\\n\\n💡 Tip: Use /output-style tdd-mode for strict TDD guidance\"
        }
    }"
    exit 0
fi