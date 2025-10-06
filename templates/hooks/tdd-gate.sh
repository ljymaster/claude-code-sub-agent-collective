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

    # Find in-progress task (agent is actively working)
    IN_PROGRESS_TASK=$(jq -r '.tasks[] | select(.status=="in-progress") | .id' "$TASK_INDEX" 2>/dev/null | head -1)

    if [[ -n "$IN_PROGRESS_TASK" ]]; then
        # Check if file is explicitly listed as deliverable
        TASK_HAS_FILE=$(jq -r --arg file "$FILE_PATH" --arg taskid "$IN_PROGRESS_TASK" '.tasks[] | select(.id == $taskid) | .deliverables[]? // empty | select(. == $file)' "$TASK_INDEX" 2>/dev/null)

        # Check if file is "related" to deliverables (same base name or directory)
        DELIVERABLE_FILES=$(jq -r --arg taskid "$IN_PROGRESS_TASK" '.tasks[] | select(.id == $taskid) | .deliverables[]? // empty' "$TASK_INDEX" 2>/dev/null)
        FILE_RELATED=false

        for deliverable in $DELIVERABLE_FILES; do
            DELIVERABLE_BASE=$(basename "$deliverable" | sed 's/\.[^.]*$//')
            FILE_BASE_CHECK=$(basename "$FILE_PATH" | sed 's/\.[^.]*$//')
            DELIVERABLE_DIR=$(dirname "$deliverable")
            FILE_DIR=$(dirname "$FILE_PATH")

            # Allow if same base name (e.g., index.html + style.css related to index.html)
            # OR same directory (e.g., src/App.js related to src/index.html)
            # OR CSS/assets for HTML deliverables
            if [[ "$FILE_PATH" =~ \.css$|\.scss$|\.sass$ ]] && [[ "$deliverable" =~ \.html$|\.jsx$|\.tsx$ ]]; then
                FILE_RELATED=true
                break
            elif [[ "$FILE_DIR" == "$DELIVERABLE_DIR" ]]; then
                FILE_RELATED=true
                break
            fi
        done

        # Get task dependencies (test tasks)
        DEPENDENCIES=$(jq -r --arg taskid "$IN_PROGRESS_TASK" '.tasks[] | select(.id == $taskid) | .dependencies[]? // empty' "$TASK_INDEX" 2>/dev/null)

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
                # All dependencies complete - allow if file in deliverables OR related
                if [[ -n "$TASK_HAS_FILE" ]] || [[ "$FILE_RELATED" = true ]]; then
                    TEST_FOUND=true
                    if [[ -n "$TASK_HAS_FILE" ]]; then
                        log_hook_event "PreToolUse" "$TOOL_NAME" "$FILE_PATH" "allow" "Task-aware: File in deliverables, dependencies complete" "{\"file\":\"$FILE_PATH\",\"currentTask\":\"$IN_PROGRESS_TASK\",\"dependencies\":\"$DEPENDENCIES\"}"
                    else
                        log_hook_event "PreToolUse" "$TOOL_NAME" "$FILE_PATH" "allow" "Task-aware: Related file, dependencies complete" "{\"file\":\"$FILE_PATH\",\"currentTask\":\"$IN_PROGRESS_TASK\",\"relatedTo\":\"deliverables\"}"
                    fi
                fi
            else
                # Dependencies not complete - deny
                log_hook_event "PreToolUse" "$TOOL_NAME" "$FILE_PATH" "deny" "Task dependencies not complete" "{\"file\":\"$FILE_PATH\",\"currentTask\":\"$IN_PROGRESS_TASK\",\"incompleteDeps\":\"$INCOMPLETE_DEPS\"}"
                echo "{
                    \"hookSpecificOutput\": {
                        \"hookEventName\": \"PreToolUse\",
                        \"permissionDecision\": \"deny\",
                        \"permissionDecisionReason\": \"🚨 TDD VIOLATION\\n\\nTask ${IN_PROGRESS_TASK} has incomplete dependencies:${INCOMPLETE_DEPS}\\n\\nThese dependency tasks must complete before implementation can proceed.\\n\\n❌ Cannot proceed - dependency tasks not done\\n\\n💡 Solution: Complete dependency tasks first (tests must be written before implementation)\"
                    }
                }"
                exit 0
            fi
        else
            # No dependencies = this is a test task itself, allow
            TEST_FOUND=true
            log_hook_event "PreToolUse" "$TOOL_NAME" "$FILE_PATH" "allow" "Task-aware: Test task (no dependencies)" "{\"file\":\"$FILE_PATH\",\"currentTask\":\"$IN_PROGRESS_TASK\",\"taskType\":\"test\"}"
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
    # Check if task index exists to provide better guidance
    if [[ -f "$TASK_INDEX" ]]; then
        # Task index exists but no in-progress task found
        AVAILABLE_TASKS=$(jq -r '.tasks[] | select(.status=="pending" and (.children | length) == 0) | .id' "$TASK_INDEX" 2>/dev/null | head -3 | tr '\n' ', ' | sed 's/,$//')

        if [[ -n "$AVAILABLE_TASKS" ]]; then
            log_hook_event "PreToolUse" "$TOOL_NAME" "$FILE_PATH" "deny" "No in-progress task - available tasks exist" "{\"file\":\"$FILE_PATH\",\"availableTasks\":\"$AVAILABLE_TASKS\"}"
            echo "{
                \"hookSpecificOutput\": {
                    \"hookEventName\": \"PreToolUse\",
                    \"permissionDecision\": \"deny\",
                    \"permissionDecisionReason\": \"⚠️ No active task for file: ${FILE_NAME}\\n\\nFile needs to be part of a task workflow.\\n\\nAvailable pending tasks: ${AVAILABLE_TASKS}\\n\\n💡 Next steps:\\n1. Deploy agent for next task via Task tool\\n2. OR add ${FILE_NAME} to existing task deliverables\\n3. OR ask Hub Claude to update task structure\"
                }
            }"
        else
            log_hook_event "PreToolUse" "$TOOL_NAME" "$FILE_PATH" "deny" "Task index exists but all tasks complete or in-progress" "{\"file\":\"$FILE_PATH\",\"taskWorkflow\":false}"
            echo "{
                \"hookSpecificOutput\": {
                    \"hookEventName\": \"PreToolUse\",
                    \"permissionDecision\": \"deny\",
                    \"permissionDecisionReason\": \"⚠️ No active task for file: ${FILE_NAME}\\n\\nAll tasks complete or no pending tasks available.\\n\\n💡 Next steps:\\n1. Check task status: source .claude/memory/lib/wbs-helpers.sh && find_next_available_task\\n2. Add new task if needed\\n3. OR this might be integration work after epic completion\"
                }
            }"
        fi
    else
        # No task index - workflow not initialized
        log_hook_event "PreToolUse" "$TOOL_NAME" "$FILE_PATH" "deny" "TDD violation: Task workflow not initialized" "{\"file\":\"$FILE_PATH\",\"taskWorkflow\":false,\"taskIndexExists\":false}"
        echo "{
            \"hookSpecificOutput\": {
                \"hookEventName\": \"PreToolUse\",
                \"permissionDecision\": \"deny\",
                \"permissionDecisionReason\": \"⚠️ Task workflow not initialized\\n\\nFile: ${FILE_NAME}\\n\\n💡 Solution: Use /van command to start task-based workflow with TDD enforcement\"
            }
        }"
    fi
    exit 0
fi