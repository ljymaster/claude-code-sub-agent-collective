#!/bin/bash
# browser-testing-preflight.sh - Deterministic browser testing notification
# Called BEFORE task breakdown to notify user of browser testing configuration

set -euo pipefail

# Source logging library
LIB_DIR="$(dirname "$0")"
# shellcheck disable=SC1091
source "$LIB_DIR/logging.sh" 2>/dev/null || true

# Get user request from argument
USER_REQUEST="${1:-}"

if [ -z "$USER_REQUEST" ]; then
  exit 0  # No request provided, skip
fi

# Log that preflight is starting
if command -v log_event &>/dev/null; then
  log_event "preflight" "start" "Browser testing preflight check started" "{\"userRequest\":\"$USER_REQUEST\"}"
fi

# UI/Browser keywords (deterministic detection)
UI_KEYWORDS=(
  # UI Frameworks
  "html" "css" "react" "vue" "svelte" "angular" "nextjs" "remix"
  # UI Elements
  "form" "button" "input" "component" "modal" "dropdown" "menu"
  # UI Concepts
  "ui" "interface" "dashboard" "page" "layout" "responsive"
  # User Actions
  "login" "signup" "authentication" "interactive" "click" "submit"
  # Styling
  "tailwind" "styled-components" "sass" "bootstrap" "material-ui"
)

# Convert request to lowercase for case-insensitive matching
request_lower=$(echo "$USER_REQUEST" | tr '[:upper:]' '[:lower:]')

# Check if any UI keyword is present
ui_detected=false
for keyword in "${UI_KEYWORDS[@]}"; do
  if echo "$request_lower" | grep -q "$keyword"; then
    ui_detected=true
    break
  fi
done

# Check if user has disabled browser testing
config_file=".claude/memory/config.json"
browser_testing_enabled=true

if [ -f "$config_file" ]; then
  # Check if browserTesting is explicitly set to false
  browser_testing=$(jq -r '.browserTesting // true' "$config_file" 2>/dev/null || echo "true")
  if [ "$browser_testing" = "false" ]; then
    browser_testing_enabled=false
  fi
fi

# Show notification if UI detected
if [ "$ui_detected" = true ]; then
  echo ""
  echo "🌐 Browser UI Detected"
  echo ""

  if [ "$browser_testing_enabled" = true ]; then
    echo "✅ Automated browser testing: ENABLED (default)"
    echo "   → Validates CSS loads correctly"
    echo "   → Tests user interactions (clicks, forms)"
    echo "   → Verifies DOM state changes"
    echo "   → Performance impact: ~30-60s per UI task"
    echo ""
    echo "📋 What gets validated:"
    echo "   • CSS files load in browser"
    echo "   • Styles apply correctly"
    echo "   • Form interactions work"
    echo "   • DOM updates as expected"
    echo "   • No JavaScript errors"
    echo ""
    echo "⚙️  To DISABLE browser testing:"
    echo "   echo '{\"browserTesting\": false}' > .claude/memory/config.json"
  else
    echo "⚠️  Automated browser testing: DISABLED (via config)"
    echo "   → Only unit/integration tests will run"
    echo "   → CSS and UI interactions not validated in browser"
    echo ""
    echo "⚙️  To RE-ENABLE browser testing:"
    echo "   rm .claude/memory/config.json"
    echo "   # Or set browserTesting: true in config"
  fi
  echo ""
else
  # No UI detected - backend/CLI/library project
  echo ""
  echo "ℹ️  No browser UI detected - browser testing not required"
  echo "   Proceeding with standard TDD workflow (unit tests only)"
  echo ""
fi

# Create marker file to indicate preflight check completed
touch .claude/memory/.preflight-done

# Log completion
if command -v log_event &>/dev/null; then
  log_event "preflight" "completed" "Browser testing preflight check completed" "{\"uiDetected\":$ui_detected,\"browserTestingEnabled\":$browser_testing_enabled}"
fi

exit 0
