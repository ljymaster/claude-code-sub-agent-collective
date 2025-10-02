#!/bin/bash
# session-init.sh - One-time session initialization
# Displays welcome message when Claude Code starts

MEMORY_DIR=".claude/memory"
LIB_DIR="$MEMORY_DIR/lib"

# Source logging library
# shellcheck disable=SC1091
source "$LIB_DIR/logging.sh" 2>/dev/null || true

# Initialize session logging
init_session_logging

# Get logging status
LOGGING_STATUS=$(get_logging_status)

echo ""
echo "🚀 Claude Code Collective v3.0 Initialized"
echo ""
echo "📚 Active Systems:"
echo "   • Research Framework (Context7 + TaskMaster)"
echo "   • TDD Gate (Tests-first enforcement)"
echo "   • Quality Gates (Validation checkpoints)"
echo "   • Native Agent Routing (Automatic delegation)"
echo ""
echo "📊 Logging System: $LOGGING_STATUS"
if [[ "$LOGGING_STATUS" == "DISABLED" ]]; then
  echo "   Toggle: Run '/van logging enable' to start capturing system events"
else
  echo "   Toggle: Run '/van logging disable' to stop capturing events"
  echo "   Logs: .claude/memory/logs/current/"
fi
echo ""
echo "🚐 Use /van command to activate collective framework"
echo "📖 Memory System: Behavioral rules loaded from .claude/memory.md"
echo "🎯 Agent Catalog: 32 specialized agents available"
echo ""