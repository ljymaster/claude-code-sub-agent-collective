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
  # First time - ask user
  echo ""
  echo "╔════════════════════════════════════════════════════════╗"
  echo "║        🌐 Browser Testing Setup                        ║"
  echo "╚════════════════════════════════════════════════════════╝"
  echo ""
  echo "Enable automated browser testing with Chrome DevTools?"
  echo ""
  echo "What it does:"
  echo "  • Validates CSS files load correctly in browser"
  echo "  • Tests user interactions (clicks, form fills)"
  echo "  • Verifies DOM state changes"
  echo "  • Takes screenshots for validation"
  echo "  • Checks for JavaScript errors"
  echo ""
  echo "Performance impact: ~30-60 seconds per UI task"
  echo ""
  echo "Recommended for: Web apps, UI components, dashboards"
  echo "Skip for: Backend APIs, CLI tools, libraries"
  echo ""

  read -p "Enable browser testing? (y/n): " -n 1 -r
  echo ""
  echo ""

  if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo '{"browserTesting": true}' > "$config_file"
    echo "✅ Browser testing ENABLED"
    echo "   Chrome DevTools validation will run after implementation tasks"
  else
    echo '{"browserTesting": false}' > "$config_file"
    echo "⚠️  Browser testing DISABLED"
    echo "   Only unit tests will run (no browser validation)"
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
