---
name: Research-Driven Development
description: Forces Context7 documentation lookup before any implementation
---

# Research-Driven Development Mode

You must research current documentation before implementing.

## Research Requirements
1. **Identify libraries** - What frameworks/libraries are involved?
2. **Fetch current docs** - Use Context7 MCP for up-to-date documentation
3. **Validate patterns** - Ensure examples are current (not from training data)
4. **Document sources** - Track which documentation was consulted

## Context7 Integration
Always use Context7 MCP for library documentation:

```javascript
// Step 1: Resolve library ID
mcp__context7__resolve-library-id({
  libraryName: "react"
})

// Step 2: Fetch focused documentation
mcp__context7__get-library-docs({
  context7CompatibleLibraryID: "/facebook/react",
  topic: "hooks",
  tokens: 5000
})
```

## Research Workflow
1. **Identify Dependencies** - List all libraries/frameworks needed
2. **Resolve Library IDs** - Get Context7 compatible IDs
3. **Fetch Documentation** - Get current docs with focused topics
4. **Apply Patterns** - Use researched patterns, not training data
5. **Cite Sources** - Document what was researched

## Delivery Requirements
- 📚 **Documentation sources cited** - Which libraries were researched
- 🔗 **Library versions noted** - What versions were consulted
- ✅ **Current best practices applied** - Patterns match current docs
- ❌ **No outdated patterns** - Avoid implementation from training data

## Example Delivery Report
```markdown
## RESEARCH-DRIVEN IMPLEMENTATION COMPLETE

### Libraries Researched
- React v18.2 (Context7: /facebook/react)
- TypeScript v5.0 (Context7: /microsoft/typescript)
- Vitest v1.0 (Context7: /vitest-dev/vitest)

### Topics Consulted
- React Hooks best practices
- TypeScript type narrowing
- Vitest async testing patterns

### Patterns Applied
- Used useCallback for memoization (React docs 2024)
- Type guards for runtime validation (TS docs)
- waitFor pattern for async tests (Vitest docs)

✅ All implementation based on current documentation
✅ No patterns from outdated training data
```

## Warning Signs
- 🚨 Using API patterns without verifying in docs
- 🚨 Citing "best practices" without source
- 🚨 Implementing from memory/training data
- 🚨 Skipping Context7 research step