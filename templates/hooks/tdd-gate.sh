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
    # Check if epic is complete (all tasks done)
    EPIC_STATUS=$(jq -r '.tasks[] | select(.type=="epic") | .status' "$TASK_INDEX" 2>/dev/null | head -1)
    if [[ "$EPIC_STATUS" == "done" ]]; then
        # Epic complete - allow all writes (integration phase)
        log_hook_event "PreToolUse" "$TOOL_NAME" "$FILE_PATH" "allow" "Epic complete - integration phase allowed" "{\"file\":\"$FILE_PATH\",\"epicStatus\":\"done\"}"
        echo '{"hookSpecificOutput": {"hookEventName": "PreToolUse", "permissionDecision": "allow", "permissionDecisionReason": "Epic complete - integration phase allowed"}}'
        exit 0
    fi

    # Find task that has this file as a deliverable
    CURRENT_TASK=$(jq -r --arg file "$FILE_PATH" '.tasks[] | select(.deliverables[]? == $file) | .id' "$TASK_INDEX" 2>/dev/null | head -1)

    if [[ -n "$CURRENT_TASK" ]]; then
        # Task-aware: Check dependency tasks for test deliverables
        DEPENDENCIES=$(jq -r --arg taskid "$CURRENT_TASK" '.tasks[] | select(.id == $taskid) | .dependencies[]? // empty' "$TASK_INDEX" 2>/dev/null)

        if [[ -n "$DEPENDENCIES" ]]; then
            # Check if all dependency tasks are complete (status="done")
            # Trust SubagentStop hook to have validated deliverables exist
            ALL_DEPS_DONE=true
            INCOMPLETE_DEPS=""

            for dep_id in $DEPENDENCIES; do
                DEP_STATUS=$(jq -r --arg depid "$dep_id" '.tasks[] | select(.id == $depid) | .status' "$TASK_INDEX" 2>/dev/null)

                if [[ "$DEP_STATUS" != "done" ]]; then
                    ALL_DEPS_DONE=false
                    INCOMPLETE_DEPS="$INCOMPLETE_DEPS $dep_id"
                fi
            done

            if [[ "$ALL_DEPS_DONE" = true ]]; then
                # All dependencies complete - allow implementation
                TEST_FOUND=true
                log_hook_event "PreToolUse" "$TOOL_NAME" "$FILE_PATH" "allow" "Task-aware: All dependency tasks complete" "{\"file\":\"$FILE_PATH\",\"currentTask\":\"$CURRENT_TASK\",\"dependencies\":\"$DEPENDENCIES\"}"
            else
                # Dependencies not complete - deny
                log_hook_event "PreToolUse" "$TOOL_NAME" "$FILE_PATH" "deny" "Task dependencies not complete" "{\"file\":\"$FILE_PATH\",\"currentTask\":\"$CURRENT_TASK\",\"incompleteDeps\":\"$INCOMPLETE_DEPS\"}"
                echo "{
                    \"hookSpecificOutput\": {
                        \"hookEventName\": \"PreToolUse\",
                        \"permissionDecision\": \"deny\",
                        \"permissionDecisionReason\": \"🚨 TDD VIOLATION\\n\\nTask ${CURRENT_TASK} has incomplete dependencies:${INCOMPLETE_DEPS}\\n\\nThese dependency tasks must complete before implementation can proceed.\\n\\n❌ Cannot proceed - dependency tasks not done\\n\\n💡 Solution: Complete dependency tasks first (tests must be written before implementation)\"
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

# Decision: Task-aware workflow required
if [ "$TEST_FOUND" = true ]; then
    # Task dependencies validated - allow
    log_hook_event "PreToolUse" "$TOOL_NAME" "$FILE_PATH" "allow" "Task-aware: Dependencies validated" "{\"file\":\"$FILE_PATH\",\"taskWorkflow\":true}"
    echo '{"hookSpecificOutput": {"hookEventName": "PreToolUse", "permissionDecision": "allow", "permissionDecisionReason": "Task dependencies validated"}}'
    exit 0
else
    # Not in task workflow OR file not part of task structure
    log_hook_event "PreToolUse" "$TOOL_NAME" "$FILE_PATH" "deny" "TDD violation: Must use task-based workflow" "{\"file\":\"$FILE_PATH\",\"taskWorkflow\":false,\"taskIndexExists\":$(test -f \"$TASK_INDEX\" && echo true || echo false)}"
    echo "{
        \"hookSpecificOutput\": {
            \"hookEventName\": \"PreToolUse\",
            \"permissionDecision\": \"deny\",
            \"permissionDecisionReason\": \"🚨 TDD VIOLATION: Task-based workflow required\\n\\nFile: ${FILE_NAME}\\n\\nThis implementation file is not part of the current task structure.\\n\\nAll implementation must be part of a task-based workflow with proper dependencies.\\n\\n❌ Cannot proceed\\n\\n💡 Solution: Use /van command to create task-based workflow with proper test dependencies\"
        }
    }"
    exit 0
fi