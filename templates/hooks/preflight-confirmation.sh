#!/usr/bin/env bash
# PreToolUse hook for preflight user confirmation validation
# Prevents LLM from fabricating user responses by validating transcript

set -euo pipefail

MEMORY_DIR=".claude/memory"
LIB_DIR="$MEMORY_DIR/lib"

# Source logging library if available
# shellcheck disable=SC1091
source "$LIB_DIR/logging.sh" 2>/dev/null || true

# Read hook input from stdin
INPUT=$(cat)

# Extract tool info
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty' 2>/dev/null || echo "")
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null || echo "")

# Only validate Bash commands calling preflight.sh
if [[ "$TOOL_NAME" != "Bash" ]] || [[ ! "$COMMAND" =~ preflight\.sh ]]; then
  log_hook_event "PreToolUse" "Bash" "" "allow" "Not a preflight command" "{\"command\":\"$COMMAND\"}" 2>/dev/null || true
  cat <<JSON
{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"allow","permissionDecisionReason":"Not a preflight command"}}
JSON
  exit 0
fi

# Extract transcript path
TRANSCRIPT_PATH=$(echo "$INPUT" | jq -r '.transcript_path // empty' 2>/dev/null || echo "")

# DEBUG: Log what we received
echo "DEBUG: Full INPUT:" >> /tmp/preflight-debug.log
echo "$INPUT" >> /tmp/preflight-debug.log
echo "DEBUG: TRANSCRIPT_PATH=$TRANSCRIPT_PATH" >> /tmp/preflight-debug.log
echo "DEBUG: File exists check: $(test -f "$TRANSCRIPT_PATH" && echo 'YES' || echo 'NO')" >> /tmp/preflight-debug.log

if [[ -z "$TRANSCRIPT_PATH" || ! -f "$TRANSCRIPT_PATH" ]]; then
  log_hook_event "PreToolUse" "Bash" "" "deny" "No transcript available for validation" "{\"transcriptPath\":\"$TRANSCRIPT_PATH\"}" 2>/dev/null || true
  cat <<JSON
{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"⚠️ PREFLIGHT BLOCKED - No conversation transcript available for validation"}}
JSON
  exit 2
fi

# Parse logging and browserTesting answers from command
LOGGING_ARG=$(echo "$COMMAND" | grep -oP '(?<="logging":")[^"]*' || echo "")
BROWSER_ARG=$(echo "$COMMAND" | grep -oP '(?<="browserTesting":")[^"]*' || echo "")

# Read transcript and check for user messages
# Transcript is JSONL format - one JSON object per line
ASSISTANT_ASKED_LOGGING=false
ASSISTANT_ASKED_BROWSER=false
USER_ANSWERED_LOGGING=""
USER_ANSWERED_BROWSER=""

# Track state machine: assistant asks → user answers
WAITING_FOR_LOGGING_ANSWER=false
WAITING_FOR_BROWSER_ANSWER=false

while IFS= read -r line; do
  TYPE=$(echo "$line" | jq -r '.type // empty' 2>/dev/null || echo "")
  CONTENT=$(echo "$line" | jq -r '.content // empty' 2>/dev/null || echo "")

  # DEBUG: Log each message
  echo "DEBUG: LINE TYPE=$TYPE" >> /tmp/preflight-debug.log
  echo "DEBUG: LINE CONTENT=$CONTENT" >> /tmp/preflight-debug.log

  # Check if assistant asked about logging
  if [[ "$TYPE" == "assistant" ]] && echo "$CONTENT" | grep -qi "Enable deterministic logging"; then
    ASSISTANT_ASKED_LOGGING=true
    WAITING_FOR_LOGGING_ANSWER=true
  fi

  # Check if assistant asked about browser testing
  if [[ "$TYPE" == "assistant" ]] && echo "$CONTENT" | grep -qi "Enable browser testing"; then
    ASSISTANT_ASKED_BROWSER=true
    WAITING_FOR_BROWSER_ANSWER=true
  fi

  # Capture user's answer to logging question
  if [[ "$TYPE" == "user" ]] && [[ "$WAITING_FOR_LOGGING_ANSWER" == true ]]; then
    # Extract y/n from user message (lenient - just check if y or n appears)
    if echo "$CONTENT" | grep -qiE '[yn]'; then
      USER_ANSWERED_LOGGING=$(echo "$CONTENT" | grep -oiE '[yn]' | head -1 | tr '[:upper:]' '[:lower:]')
      WAITING_FOR_LOGGING_ANSWER=false
    fi
  fi

  # Capture user's answer to browser testing question
  if [[ "$TYPE" == "user" ]] && [[ "$WAITING_FOR_BROWSER_ANSWER" == true ]]; then
    # Extract y/n from user message (lenient - just check if y or n appears)
    if echo "$CONTENT" | grep -qiE '[yn]'; then
      USER_ANSWERED_BROWSER=$(echo "$CONTENT" | grep -oiE '[yn]' | head -1 | tr '[:upper:]' '[:lower:]')
      WAITING_FOR_BROWSER_ANSWER=false
    fi
  fi
done < "$TRANSCRIPT_PATH"

# DEBUG: Log what we found
echo "DEBUG: ASSISTANT_ASKED_LOGGING=$ASSISTANT_ASKED_LOGGING" >> /tmp/preflight-debug.log
echo "DEBUG: ASSISTANT_ASKED_BROWSER=$ASSISTANT_ASKED_BROWSER" >> /tmp/preflight-debug.log
echo "DEBUG: USER_ANSWERED_LOGGING=$USER_ANSWERED_LOGGING" >> /tmp/preflight-debug.log
echo "DEBUG: USER_ANSWERED_BROWSER=$USER_ANSWERED_BROWSER" >> /tmp/preflight-debug.log
echo "DEBUG: LOGGING_ARG=$LOGGING_ARG" >> /tmp/preflight-debug.log
echo "DEBUG: BROWSER_ARG=$BROWSER_ARG" >> /tmp/preflight-debug.log

# Validation checks
DENIAL_REASON=""

# Check 1: Were questions asked by assistant?
if [[ "$ASSISTANT_ASKED_LOGGING" != true ]] || [[ "$ASSISTANT_ASKED_BROWSER" != true ]]; then
  DENIAL_REASON="Preflight questions were not asked in conversation"
fi

# Check 2: Did user actually answer?
if [[ -z "$DENIAL_REASON" ]]; then
  if [[ -z "$USER_ANSWERED_LOGGING" ]] || [[ -z "$USER_ANSWERED_BROWSER" ]]; then
    DENIAL_REASON="No user responses found in transcript (fabricated interaction detected)"
  fi
fi

# Check 3: Do command arguments match user's actual answers?
if [[ -z "$DENIAL_REASON" ]]; then
  # Convert y/n to expected argument format
  if [[ "$USER_ANSWERED_LOGGING" == "y" ]]; then
    EXPECTED_LOGGING="y"
  else
    EXPECTED_LOGGING="n"
  fi

  if [[ "$USER_ANSWERED_BROWSER" == "y" ]]; then
    EXPECTED_BROWSER="y"
  else
    EXPECTED_BROWSER="n"
  fi

  if [[ "$LOGGING_ARG" != "$EXPECTED_LOGGING" ]] || [[ "$BROWSER_ARG" != "$EXPECTED_BROWSER" ]]; then
    DENIAL_REASON="Command arguments don't match user's actual answers (logging: user=$USER_ANSWERED_LOGGING, command=$LOGGING_ARG; browser: user=$USER_ANSWERED_BROWSER, command=$BROWSER_ARG)"
  fi
fi

# Return decision
if [[ -n "$DENIAL_REASON" ]]; then
  log_hook_event "PreToolUse" "Bash" "" "deny" "$DENIAL_REASON" "{\"logging\":\"$LOGGING_ARG\",\"browserTesting\":\"$BROWSER_ARG\",\"userLogging\":\"$USER_ANSWERED_LOGGING\",\"userBrowser\":\"$USER_ANSWERED_BROWSER\"}" 2>/dev/null || true

  cat <<'JSON'
{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"⚠️ PREFLIGHT BLOCKED - Fabricated user interaction detected\n\nREQUIRED ACTION:\nYou MUST ask the user the preflight questions interactively:\n1. Output: '📊 Enable deterministic logging? (y/n)'\n2. WAIT for user's response\n3. Output: '🌐 Enable browser testing? (y/n)'\n4. WAIT for user's response\n5. THEN call preflight.sh with their actual answers\n\nDO NOT fabricate user responses. The hook validates the transcript."}}
JSON
  exit 2
else
  log_hook_event "PreToolUse" "Bash" "" "allow" "User confirmation validated in transcript" "{\"logging\":\"$LOGGING_ARG\",\"browserTesting\":\"$BROWSER_ARG\"}" 2>/dev/null || true

  cat <<'JSON'
{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"allow","permissionDecisionReason":"Preflight user confirmation validated"}}
JSON
  exit 0
fi
