#!/bin/bash
# browser-testing-preflight.sh - Simple browser testing setup prompt
# Called BEFORE task breakdown to ask user about browser testing

set -euo pipefail

# Source logging library
LIB_DIR="$(dirname "$0")"
# shellcheck disable=SC1091
source "$LIB_DIR/logging.sh" 2>/dev/null || true

# Log that preflight is starting
if command -v log_event &>/dev/null; then
  log_event "preflight" "start" "Browser testing preflight check started" "{}"
fi

# Check if config already exists (user already answered)
config_file=".claude/memory/config.json"
if [ -f "$config_file" ]; then
  browser_testing=$(jq -r '.browserTesting // true' "$config_file" 2>/dev/null || echo "true")

  echo ""
  if [ "$browser_testing" = "true" ]; then
    echo "✅ Browser testing: ENABLED (from previous session)"
  else
    echo "⚠️  Browser testing: DISABLED (from previous session)"
  fi
  echo ""
else
  # Interactive menu function with arrow key navigation
  menu_select() {
    local prompt="$1"
    local selected=0
    local options=("Enable" "Disable")

    while true; do
      # Clear previous menu
      tput cuu 3 2>/dev/null || true
      tput el 2>/dev/null || true

      # Display options
      for i in "${!options[@]}"; do
        if [ $i -eq $selected ]; then
          echo "  ● ${options[$i]}"
        else
          echo "  ○ ${options[$i]}"
        fi
      done
      echo ""
      echo "$prompt"

      # Read arrow keys
      read -rsn1 key
      case "$key" in
        $'\x1b')
          read -rsn2 key
          case "$key" in
            '[A') # Up arrow
              ((selected--))
              [ $selected -lt 0 ] && selected=$((${#options[@]} - 1))
              ;;
            '[B') # Down arrow
              ((selected++))
              [ $selected -ge ${#options[@]} ] && selected=0
              ;;
          esac
          ;;
        '') # Enter key
          [ $selected -eq 0 ] && echo "y" || echo "n"
          return
          ;;
      esac
    done
  }

  # First time - ask user
  echo ""
  echo "═══════════════════════════════════════════════════════════════"
  echo "  ⚙️  Workflow Configuration"
  echo "═══════════════════════════════════════════════════════════════"
  echo ""

  # Question 1: Logging
  echo "📊 Deterministic Logging"
  echo ""
  echo "Capture complete audit trail of all workflow decisions:"
  echo "  → Hook decisions (allow/deny/validation)"
  echo "  → Memory operations (task updates, rollups)"
  echo "  → Output: .claude/memory/logs/current/*.jsonl"
  echo ""
  echo "Useful for: Debugging, research, understanding workflow"
  echo ""
  echo "  ● Enable"
  echo "  ○ Disable"
  echo ""
  echo "Use ↑↓ arrows to select, press Enter to confirm"

  LOGGING_ENABLED=$(menu_select "Use ↑↓ arrows to select, press Enter to confirm")
  echo ""

  # Question 2: Browser Testing
  echo "🌐 Browser Testing with Chrome DevTools"
  echo ""
  echo "Automated validation in real browser environment:"
  echo "  → Validates CSS files load correctly"
  echo "  → Tests user interactions (clicks, forms, navigation)"
  echo "  → Verifies DOM state changes"
  echo "  → Captures screenshots for validation"
  echo "  → Checks JavaScript console for errors"
  echo ""
  echo "Performance: ~30-60s per UI task"
  echo "Best for: Web apps, UI components, dashboards"
  echo "Skip for: Backend APIs, CLI tools, libraries"
  echo ""
  echo "  ● Enable"
  echo "  ○ Disable"
  echo ""
  echo "Use ↑↓ arrows to select, press Enter to confirm"

  BROWSER_TESTING_ENABLED=$(menu_select "Use ↑↓ arrows to select, press Enter to confirm")
  echo ""

  # Save choices to config
  if [[ $BROWSER_TESTING_ENABLED =~ ^[Yy]$ ]]; then
    echo '{"browserTesting": true}' > "$config_file"
  else
    echo '{"browserTesting": false}' > "$config_file"
  fi

  # Enable/disable logging
  if [[ $LOGGING_ENABLED =~ ^[Yy]$ ]]; then
    touch .claude/memory/.logging-enabled
    echo "✅ Logging ENABLED"
  else
    rm -f .claude/memory/.logging-enabled
    echo "⚠️  Logging DISABLED"
  fi

  # Show browser testing status
  if [[ $BROWSER_TESTING_ENABLED =~ ^[Yy]$ ]]; then
    echo "✅ Browser testing ENABLED"
  else
    echo "⚠️  Browser testing DISABLED"
  fi
  echo ""
fi

# Create marker file to indicate preflight check completed
touch .claude/memory/.preflight-done

# Log completion
if command -v log_event &>/dev/null; then
  log_event "preflight" "completed" "Browser testing preflight check completed" "{\"uiDetected\":$ui_detected,\"browserTestingEnabled\":$browser_testing_enabled}"
fi

exit 0
