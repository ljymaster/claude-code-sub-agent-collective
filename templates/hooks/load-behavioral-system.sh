#!/bin/bash
# Load Collective Behavioral System
# Platform-agnostic SessionStart hook

# Platform detection
if [ -n "$QODER_PROJECT_DIR" ]; then
  PROJECT_DIR="$QODER_PROJECT_DIR"
  CONFIG_DIR=".qoder"
  PLATFORM="Qoder CLI"
elif [ -n "$CLAUDE_PROJECT_DIR" ]; then
  PROJECT_DIR="$CLAUDE_PROJECT_DIR"
  CONFIG_DIR=".claude"
  PLATFORM="Claude Code"
else
  PROJECT_DIR="$(pwd)"
  CONFIG_DIR=".claude"
  PLATFORM="Unknown"
fi

echo "🚀 AI CODE COLLECTIVE INITIALIZATION SEQUENCE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🤖 Activating Multi-Agent Behavioral Operating System..."
echo "⚡ Loading Hub-Spoke Coordination Protocols..."
echo "🧠 Initializing Context Engineering Framework..."
echo "🎯 Platform: $PLATFORM"
echo ""

if [ -f ".claude-collective/CLAUDE.md" ]; then
  echo "=== COLLECTIVE BEHAVIORAL RULES (.claude-collective/CLAUDE.md) ==="
  cat .claude-collective/CLAUDE.md
  echo ""
fi

if [ -f ".claude-collective/DECISION.md" ]; then
  echo "=== GLOBAL DECISION ENGINE (.claude-collective/DECISION.md) ==="
  cat .claude-collective/DECISION.md
  echo ""
fi

if [ -f ".claude-collective/agents.md" ]; then
  echo "=== SPECIALIZED AGENTS (.claude-collective/agents.md) ==="
  cat .claude-collective/agents.md
  echo ""
fi

if [ -f ".claude-collective/hooks.md" ]; then
  echo "=== HOOK INTEGRATION (.claude-collective/hooks.md) ==="
  cat .claude-collective/hooks.md
  echo ""
fi

if [ -f ".claude-collective/quality.md" ]; then
  echo "=== QUALITY ASSURANCE (.claude-collective/quality.md) ==="
  cat .claude-collective/quality.md
  echo ""
fi

if [ -f ".claude-collective/research.md" ]; then
  echo "=== RESEARCH FRAMEWORK (.claude-collective/research.md) ==="
  cat .claude-collective/research.md
  echo ""
fi

if [ -f ".taskmaster/CLAUDE.md" ]; then
  echo "=== TASKMASTER INTEGRATION (.taskmaster/CLAUDE.md) ==="
  cat .taskmaster/CLAUDE.md
  echo ""
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ BEHAVIORAL OPERATING SYSTEM ONLINE"
echo "🎯 Prime Directives: LOADED"
echo "🔗 Agent Network: 40+ Specialists ACTIVE"
echo "📊 TDD Framework: ENGAGED"
echo "🔄 Auto-Delegation: READY"
echo "📡 Hub-Spoke Coordination: OPERATIONAL"
echo "🌐 Platform: $PLATFORM"
echo "📁 Config Directory: $CONFIG_DIR"
echo ""
echo "🌟 AI Code Collective v2.1.0 - Multi-Platform Ready"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
