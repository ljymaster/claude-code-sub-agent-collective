## Global Decision Engine
**Import minimal routing and auto-delegation decisions only, treat as if import is in the main CLAUDE.md file.**
@./.claude-collective/DECISION.md

## Task Master AI Instructions
**Import Task Master's development workflow commands and guidelines, treat as if import is in the main CLAUDE.md file.**
@./.taskmaster/CLAUDE.md

## Testing TDD Hooks

The Claude Code Collective uses PreToolUse hooks to enforce TDD workflow. To test that hooks are working correctly:

### Manual Hook Testing (Outside Claude Code Session)

Test hooks directly using bash and JSON input:

```bash
# Test TDD gate blocks implementation without tests
echo '{"tool_name": "Write", "tool_input": {"file_path": "src/MyService.js"}}' | ./.claude/hooks/tdd-gate.sh

# Expected output: permissionDecision = "deny" with TDD violation message

# Test TDD gate allows test file creation
echo '{"tool_name": "Write", "tool_input": {"file_path": "src/MyService.test.js"}}' | ./.claude/hooks/tdd-gate.sh

# Expected output: permissionDecision = "allow"

# Create test file, then test implementation is allowed
touch src/MyService.test.js
echo '{"tool_name": "Write", "tool_input": {"file_path": "src/MyService.js"}}' | ./.claude/hooks/tdd-gate.sh

# Expected output: permissionDecision = "allow" (tests exist)

# Test destructive command blocking
echo '{"tool_name": "Bash", "tool_input": {"command": "rm -rf /"}}' | ./.claude/hooks/block-destructive-commands.sh

# Expected output: permissionDecision = "deny" with blocked message
```

### Live Testing (Within Claude Code Session)

1. Start Claude Code in your project directory: `claude-code`
2. Request implementation WITHOUT tests first: "Create src/OrderService.js with order processing logic"
3. Hook should block with TDD violation message
4. Request test file: "Create src/OrderService.test.js with tests"
5. Hook should allow test creation
6. Request implementation again: "Now create src/OrderService.js implementation"
7. Hook should allow (tests exist)

### Hook Output Format

Hooks use Claude Code's native decision control with `hookSpecificOutput`:

```json
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "allow" | "deny" | "ask",
    "permissionDecisionReason": "Explanation message"
  }
}
```

### Troubleshooting Hooks

If hooks aren't blocking as expected:

1. **Check hook permissions**: Hooks must be executable (`chmod +x .claude/hooks/*.sh`)
2. **Verify settings.json**: Ensure PreToolUse hooks are configured for Edit/Write tools
3. **Test hook manually**: Run hook scripts directly with sample JSON input (see above)
4. **Check hook output format**: Hooks must output valid `hookSpecificOutput` JSON
5. **Review hook logs**: Check `/tmp/blocked-commands.log` for destructive command hook activity