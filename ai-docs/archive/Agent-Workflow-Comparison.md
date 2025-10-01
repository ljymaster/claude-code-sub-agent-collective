## Agent Workflow Comparison

Source reference: [Claude Sub-Agent Spec Workflow System](https://github.com/zhsama/claude-sub-agent)

### Current System (As-Is)

```mermaid
graph TD
    U["User / TaskMaster"] --> TE["task-executor (spec-developer)"]
    U --> PRD["prd-agent (enterprise PRD)"]
    U --> MVP["prd-mvp (lean MVP PRD)"]
    PRD --> TE
    MVP --> TE

    TE --> TC["task-checker (spec-tester)"]
    TC --> QA["quality-agent (spec-reviewer)"]
    QA --> RG["readiness-gate (spec-validator)"]
    RG --> DEVOPS["devops-agent (deploy)"]

    %% Failure/feedback loops
    TC -. "failures / gaps" .-> TE
    QA -. "quality issues" .-> TE
    RG -. "NOT READY" .-> TE

    %% Ad-hoc routing
    U -. "ad-hoc routing" .-> VAN["/van command"]
    VAN -.-> TE
```

### Proposed Specialized Framework (To-Be)

```mermaid
graph TD
    A["Project Idea / Task"] --> O["spec-orchestrator"]

    subgraph Planning
        SA["spec-analyst\nRequirements + User Stories"] --> AR["spec-architect\nArchitecture + API Spec"]
        AR --> PL["spec-planner\nTasks + Test Plan"]
    end

    O --> SA
    PL --> G1{"Quality Gate 1\n(Planning ≥ 95%)"}
    G1 -->|Pass| DEV["Development Phase"]
    G1 -->|Fail| SA

    subgraph Development
        SD["spec-developer\n(task-executor)"] --> ST["spec-tester\n(task-checker)"]
        %% Specialized implementation agents leveraged by spec-developer
        SD --> CI["component-implementation-agent"]
        SD --> FI["feature-implementation-agent"]
        SD --> II["infrastructure-implementation-agent"]
        SD --> TI["testing-implementation-agent"]
    end

    DEV --> SD
    ST --> G2{"Quality Gate 2\n(Development ≥ 80%)"}
    G2 -->|Pass| VAL["Validation Phase"]
    G2 -->|Fail| SD

    subgraph Validation
        SR["spec-reviewer\n(quality-agent)"] --> SV["spec-validator\n(readiness-gate)"]
    end

    VAL --> SR
    SV --> G3{"Quality Gate 3\n(Production ≥ 85%)"}
    G3 -->|Pass| DEP["devops-agent\nDeploy / Operate"]
    G3 -->|Fail| SD

    DEP --> PROD["Production Ready"]

    %% Styling (optional visual emphasis)
    style O fill:#1a73e8,color:#fff
    style G1 fill:#f9ab00,color:#fff
    style G2 fill:#f9ab00,color:#fff
    style G3 fill:#f9ab00,color:#fff
    style PROD fill:#34a853,color:#fff
```

Notes
- Current flow relies on generic execution and QA agents with ad-hoc routing; failures bounce back to implementation.
- Proposed framework introduces specialized planning agents and a strict orchestrator with phase gates, mirroring the reference system’s phases and quality thresholds.


