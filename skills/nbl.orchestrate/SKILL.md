---
name: nbl.orchestrate
description: >
  Unified workflow orchestration entry point for all development work (feature, bugfix, refactor).
  This is the ONLY entry point for development workflows. All implementation happens in subagents.
  Trigger: User starts any development work, complex tasks, multi-agent coordination.
---

# Orchestrate Skill

Unified workflow orchestration entry point. All implementation happens in subagents. Main window handles orchestration and user interaction only.

**Core principle:** One entry point, all execution in subagents.

## Entry Points

```
/orchestrate feature "<description>"  - Feature development workflow
/orchestrate bugfix "<description>"   - Bug fix workflow
/orchestrate refactor "<description>" - Refactoring workflow
```

## Complete Feature Workflow

```dot
digraph orchestrate_feature_workflow {
    rankdir=TB;
    node [shape=box style=filled fillcolor=lightyellow];

    "1. User starts /orchestrate feature" [shape=doublecircle fillcolor=lightblue];

    "2. brainstorming skill\n[Main Window]" [fillcolor=lightgreen];
    "3. Output: docs/nbl/specs/\n<date>-<topic>-design.md" [shape=note fillcolor=lightgray];

    "4. writing-plans skill\n[Main Window]" [fillcolor=lightgreen];
    "5. Output: docs/nbl/plans/\n<date>-<feature>.md" [shape=note fillcolor=lightgray];

    "6. Choose execution mode" [shape=diamond fillcolor=lightyellow];

    "7a. subagent-driven-development\n(Same session, sequential)" [fillcolor=lightpink];
    "7b. parallel-subagent-driven-development\n(Same session, parallel tasks)" [fillcolor=lightpink];
    "7c. executing-plans\n(Parallel session, no subagent support)" [fillcolor=lightpink];

    "8. All tasks complete?" [shape=diamond fillcolor=lightyellow];
    "9. requesting-code-review" [fillcolor=lightpink];
    "10. finishing-a-development-branch" [fillcolor=lightpink];
    "11. Return to main window" [shape=doublecircle fillcolor=lightblue];

    "1. User starts /orchestrate feature" -> "2. brainstorming skill\n[Main Window]";
    "2. brainstorming skill\n[Main Window]" -> "3. Output: docs/nbl/specs/\n<date>-<topic>-design.md";
    "3. Output: docs/nbl/specs/\n<date>-<topic>-design.md" -> "4. writing-plans skill\n[Main Window]";

    "4. writing-plans skill\n[Main Window]" -> "5. Output: docs/nbl/plans/\n<date>-<feature>.md";
    "5. Output: docs/nbl/plans/\n<date>-<feature>.md" -> "6. Choose execution mode";

    "6. Choose execution mode" -> "7a. subagent-driven-development\n(Same session, sequential)" [label="tasks sequential"];
    "6. Choose execution mode" -> "7b. parallel-subagent-driven-development\n(Same session, parallel tasks)" [label="tasks parallelizable"];
    "6. Choose execution mode" -> "7c. executing-plans\n(Parallel session, no subagent support)" [label="no subagent support"];

    "7a. subagent-driven-development\n(Same session, sequential)" -> "8. All tasks complete?";
    "7b. parallel-subagent-driven-development\n(Same session, parallel tasks)" -> "8. All tasks complete?";
    "7c. executing-plans\n(Parallel session, no subagent support)" -> "8. All tasks complete?";

    "8. All tasks complete?" -> "6. Choose execution mode" [label="no - issues"];
    "8. All tasks complete?" -> "9. requesting-code-review" [label="yes"];

    "9. requesting-code-review" -> "10. finishing-a-development-branch";
    "10. finishing-a-development-branch" -> "11. Return to main window";
}
```

## Execution Mode Selection

```dot
digraph execution_mode_selection {
    rankdir=TB;

    "Have implementation plan?" [shape=diamond];
    "Tasks mostly independent?" [shape=diamond];
    "Subagent support available?" [shape=diamond];
    "parallel-subagent-driven-development" [shape=box style=filled fillcolor=lightpink];
    "subagent-driven-development" [shape=box style=filled fillcolor=lightpink];
    "executing-plans" [shape=box style=filled fillcolor=lightpink];
    "Brainstorm first" [shape=box];

    "Have implementation plan?" -> "Tasks mostly independent?" [label="yes"];
    "Have implementation plan?" -> "Brainstorm first" [label="no"];

    "Tasks mostly independent?" -> "Subagent support available?" [label="yes"];
    "Tasks mostly independent?" -> "Brainstorm first" [label="no - tightly coupled"];

    "Subagent support available?" -> "parallel-subagent-driven-development" [label="yes"];
    "Subagent support available?" -> "executing-plans" [label="no"];
}
```

### Mode Comparison

| Mode | Session | Execution | Best For |
|------|---------|-----------|----------|
| **parallel-subagent-driven-development** | Same | Parallel (max 5) | Independent tasks, fast iteration |
| **subagent-driven-development** | Same | Sequential | Tightly coupled tasks |
| **executing-plans** | Parallel | Sequential | No subagent support |

## Bugfix Workflow

```dot
digraph orchestrate_bugfix_workflow {
    rankdir=TB;
    node [shape=box style=filled fillcolor=lightyellow];

    "1. User starts /orchestrate bugfix\n[Main Window - Orchestration]" [shape=doublecircle fillcolor=lightblue];

    "2. Quick bug reproduction\n[Main window or subagent]" [fillcolor=lightgreen];

    "3. Fix using TDD\n(test-driven-development)" [fillcolor=lightpink];
    "3. Each fix:\n- Write failing test\n- Verify RED\n- Minimal implementation\n- Verify GREEN\n- Refactor" [fillcolor=lightpink];

    "4. requesting-code-review\n[Subagent - Code Review]" [fillcolor=lightpink];
    "4b. receiving-code-review\n[Handle CR feedback]" [fillcolor=lightpink];

    "5. finishing-a-development-branch\n[Complete branch]" [fillcolor=lightpink];

    "1. User starts /orchestrate bugfix" -> "2. Quick bug reproduction";
    "2. Quick bug reproduction" -> "3. Fix using TDD";
    "3. Fix using TDD" -> "4. requesting-code-review";
    "4. requesting-code-review" -> "4b. receiving-code-review";
    "4b. receiving-code-review" -> "5. finishing-a-development-branch" [label="CR Passed"];
    "4b. receiving-code-review" -> "3. Fix using TDD" [label="CR Issues → Fix"];
}
```

## Refactor Workflow

```dot
digraph orchestrate_refactor_workflow {
    rankdir=TB;
    node [shape=box style=filled fillcolor=lightyellow];

    "1. User starts /orchestrate refactor\n[Main Window - Orchestration]" [shape=doublecircle fillcolor=lightblue];

    "2. Define refactor scope\n[Main Window - Clarify with user]" [fillcolor=lightgreen];

    "3. using-git-worktrees\n[Subagent - Create isolated workspace]" [fillcolor=lightpink];

    "4. TDD baseline\n(test-driven-development)" [fillcolor=lightpink];
    "4. Ensure tests exist\nbefore refactoring" [fillcolor=lightpink];

    "5. Refactor\n[Subagent per area]" [fillcolor=lightpink];

    "6. requesting-code-review\n[Subagent - Code Review]" [fillcolor=lightpink];

    "7. finishing-a-development-branch\n[Complete branch]" [fillcolor=lightpink];

    "1. User starts /orchestrate refactor" -> "2. Define refactor scope";
    "2. Define refactor scope" -> "3. using-git-worktrees";
    "3. using-git-worktrees" -> "4. TDD baseline";
    "4. TDD baseline" -> "5. Refactor";
    "5. Refactor" -> "6. requesting-code-review";
    "6. requesting-code-review" -> "7. finishing-a-development-branch";
}
```

## Skill Dependencies

| Skill | Execution | Purpose |
|-------|-----------|---------|
| **orchestrate** | Main window | Unified entry point |
| **brainstorming** | Main window | Requirements clarification |
| **writing-plans** | Main window | Detailed plan with task dependencies |
| **using-git-worktrees** | Subagent | Isolated workspace (single or batch mode) |
| **subagent-driven-development** | Subagent | Sequential task execution in same session |
| **parallel-subagent-driven-development** | Subagent | Parallel task execution (max 5) in same session |
| **executing-plans** | Parallel session | Sequential execution without subagent support |
| **test-driven-development** | Subagent | TDD cycle |
| **requesting-code-review** | Subagent | Code review |
| **receiving-code-review** | Subagent | Handle CR feedback |
| **finishing-a-development-branch** | Subagent | Complete branch |

## When to Use

| Scenario | Workflow | Execution Mode |
|----------|----------|----------------|
| New feature (complex) | feature | writing-plans → parallel-subagent-driven-development |
| New feature (simple) | feature | writing-plans → subagent-driven-development |
| Bug fix | bugfix | TDD → subagent |
| Safe refactoring | refactor | TDD baseline → subagent |
| Multi-subsystem project | feature (decomposed) | Separate plan per subsystem |
| No subagent support | any | executing-plans |

## Decision Logic

```
Is this a creative/implementation task?
  └── YES → Use brainstorming first (main window)
       └── After brainstorming:
            └── writing-plans (with task dependencies)
       └── After plan:
            ├── Build dependency graph from task dependencies
            ├── Analyze task independence
            └── Choose execution mode:
                 ├── Independent tasks + subagent support?
                 │   └── parallel-subagent-driven-development (max 5 parallel)
                 ├── Tightly coupled + subagent support?
                 │   └── subagent-driven-development (sequential)
                 └── No subagent support?
                     └── executing-plans (parallel session)
  └── NO (simple/known) → Skip brainstorming
       └── Direct to appropriate workflow
```

## Red Flags

**Never:**
- Implement in main window (all work in subagents)
- Skip brainstorming for creative tasks
- Skip TDD for bug fixes
- Skip code review
- Skip CR feedback handling
- Start implementation on main/master branch without worktree isolation

**Always:**
- Use orchestrate as single entry point
- Dispatch subagents for all implementation
- Handle CR feedback before proceeding
- Use worktree isolation before implementation
