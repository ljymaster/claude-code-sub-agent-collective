# AI Documentation

This directory contains all AI-assisted design documents, architecture specifications, and technical analysis for the Claude Code Sub-Agent Collective.

## Current Documentation

### Core Design Documents

- **[DETERMINISTIC-TASK-SYSTEM-DESIGN.md](./DETERMINISTIC-TASK-SYSTEM-DESIGN.md)** - Revolutionary deterministic task management system using Claude 4.5 + Hooks + Memory. Comprehensive analysis of existing systems (CCPM, Claude-Flow, Spec-Kit) and our innovative solution.

- **[Memory-Tool-API-Analysis.md](./Memory-Tool-API-Analysis.md)** - Complete analysis of Anthropic's memory tool API. Provides technical specifications, usage examples, and validation of our file-based approach.

### Architecture & Implementation

- **[V3-ARCHITECTURE-DESIGN.md](./V3-ARCHITECTURE-DESIGN.md)** - v3.0 intelligent agent orchestration architecture with TDD enforcement and browser testing integration.

- **[V3-IMPLEMENTATION-SUMMARY.md](./V3-IMPLEMENTATION-SUMMARY.md)** - Summary of v3.0 implementation including gate agents, TDD hooks, and Chrome DevTools testing.

- **[V3-Migration-Plan.md](./V3-Migration-Plan.md)** - Migration plan and strategy for transitioning to v3.0 architecture.

### User & Testing Documentation

- **[TESTING-GUIDE.md](./TESTING-GUIDE.md)** - Comprehensive testing procedures, workflows, and validation strategies.

- **[USER-GUIDE.md](./USER-GUIDE.md)** - User documentation for the collective framework.

## Document Status

This directory contains both finalized v3 design docs and legacy v2 user/testing docs. We are in a transition period while v3 user/testing guides are being written.

- CURRENT (v3 canonical):
  - `DETERMINISTIC-TASK-SYSTEM-DESIGN.md`
  - `Memory-System-Implementation-Strategy.md`
  - `Memory-Tool-API-Analysis.md`
  - `V3-ARCHITECTURE-DESIGN.md` (updated to use file-based memory in Claude Code)

- LEGACY (v2-era, to be replaced):
  - `USER-GUIDE.md`
  - `TESTING-GUIDE.md`

Historical and superseded documentation remains available in [archive/](./archive/).

## Document Conventions

- **Design Phase** - Documents marked as "Design Phase" are approved designs ready for implementation
- **Implementation Phase** - Documents marked as "Implementation" reflect completed features
- **Research Phase** - Documents marked as "Research" contain analysis and investigation

## Contributing

When creating new documentation:

1. Place new docs directly in `ai-docs/`
2. Use descriptive filenames with uppercase and hyphens (e.g., `NEW-FEATURE-DESIGN.md`)
3. Include status, date, and purpose in document header
4. Update this README with links to new documents
5. Move superseded docs to `archive/` when appropriate

---

**Last Updated**: 2025-10-01
