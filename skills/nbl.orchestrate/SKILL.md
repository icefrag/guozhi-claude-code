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

    "7a. subagent-driven-development\n(per-task: implementer → spec review → quality review)" [fillcolor=lightpink];
    "7b. parallel-subagent-driven-development\n(per-task: implementer → spec review → quality review → rebase → merge)" [fillcolor=lightpink];
    "7c. executing-plans\n(no built-in review)" [fillcolor=lightpink];

    "8. All tasks complete?" [shape=diamond fillcolor=lightyellow];
    "9. Final global code review\n(requesting-code-review)" [fillcolor=lightpink];
    "10. receiving-code-review" [shape=diamond fillcolor=lightyellow];
    "11. finishing-a-development-branch" [fillcolor=lightpink];
    "12. Return to main window" [shape=doublecircle fillcolor=lightblue];

    "1. User starts /orchestrate feature" -> "2. brainstorming skill\n[Main Window]";
    "2. brainstorming skill\n[Main Window]" -> "3. Output: docs/nbl/specs/\n<date>-<topic>-design.md";
    "3. Output: docs/nbl/specs/\n<date>-<topic>-design.md" -> "4. writing-plans skill\n[Main Window]";

    "4. writing-plans skill\n[Main Window]" -> "5. Output: docs/nbl/plans/\n<date>-<feature>.md";
    "5. Output: docs/nbl/plans/\n<date>-<feature>.md" -> "6. Choose execution mode";

    "6. Choose execution mode" -> "7a. subagent-driven-development\n(per-task: implementer → spec review → quality review)" [label="subagents + tightly coupled"];
    "6. Choose execution mode" -> "7b. parallel-subagent-driven-development\n(per-task: implementer → spec review → quality review → rebase → merge)" [label="subagents + independent tasks"];
    "6. Choose execution mode" -> "7c. executing-plans\n(no built-in review)" [label="no subagent support"];

    "7a. subagent-driven-development\n(per-task: implementer → spec review → quality review)" -> "8. All tasks complete?";
    "7b. parallel-subagent-driven-development\n(per-task: implementer → spec review → quality review → rebase → merge)" -> "8. All tasks complete?";
    "7c. executing-plans\n(no built-in review)" -> "8. All tasks complete?";

    "8. All tasks complete?" -> "6. Choose execution mode" [label="no - issues"];
    "8. All tasks complete?" -> "9. Final global code review\n(requesting-code-review)" [label="yes"];

    "9. Final global code review\n(requesting-code-review)" -> "10. receiving-code-review";
    "10. receiving-code-review" -> "7a. subagent-driven-development\n(per-task: implementer → spec review → quality review)" [label="issues → fix"];
    "10. receiving-code-review" -> "11. finishing-a-development-branch" [label="passed"];

    "11. finishing-a-development-branch" -> "12. Return to main window";
}
```

### Code Review 出现在两个层级

| 层级 | 时机 | 内容 | 处理方式 |
|------|------|------|---------|
| **任务级**（内置在 7a/7b 中） | 每个任务完成后 | Stage 1: Spec Review → Stage 2: Quality Review | 实现子代理修复 → 重新审查 → 循环直到通过 |
| **全局级**（步骤 9-10） | 所有任务完成后 | 整体代码审查 | receiving-code-review 处理反馈 → 有问题则返回修复 → 通过则继续 |

**注意：** executing-plans（7c）没有内置任务级审查，因此全局审查（步骤 9）是其唯一的代码质量保障。

## Execution Mode Selection

到达此阶段时，brainstorming 和 writing-plans 已完成，已有实现计划在手。决策依据两个维度：**是否有子代理支持**、**任务间是否独立**。

```dot
digraph execution_mode_selection {
    rankdir=TB;

    "Subagent support available?" [shape=diamond];
    "Tasks can be grouped by\ndependency level?" [shape=diamond];
    "parallel-subagent-\ndriven-development" [shape=box style=filled fillcolor=lightpink];
    "subagent-driven-\ndevelopment" [shape=box style=filled fillcolor=lightpink];
    "executing-plans" [shape=box style=filled fillcolor=lightpink];

    "Subagent support available?" -> "Tasks can be grouped by\ndependency level?" [label="yes"];
    "Subagent support available?" -> "executing-plans" [label="no\n(fallback)"];
    "Tasks can be grouped by\ndependency level?" -> "parallel-subagent-\ndriven-development" [label="yes\n(independent tasks)"];
    "Tasks can be grouped by\ndependency level?" -> "subagent-driven-\ndevelopment" [label="no\n(tightly coupled)"];
}
```

### Mode Comparison

| 维度 | parallel-subagent-driven-development | subagent-driven-development | executing-plans |
|------|-------------------------------------|----------------------------|-----------------|
| **子代理** | 有（每任务一个） | 有（每任务一个） | **无**（主代理自行执行） |
| **并行度** | 同层并行（max 5） | 无（严格顺序） | 无（严格顺序） |
| **会话** | 同一会话 | 同一会话 | **独立会话** |
| **审查机制** | 两阶段（spec + quality） | 两阶段（spec + quality） | **无内置审查** |
| **worktree** | 批量创建（每层） | 单个创建 | 仅建议（非强制） |
| **rebase/merge** | 每任务 rebase → merge 到 base | 不需要（顺序无冲突） | 不需要 |
| **冲突处理** | 内置 LLM 自动解决 rebase 冲突 | 无冲突风险 | 无冲突风险 |
| **层级屏障** | 有（同层全部通过才进入下层） | 无 | 无 |
| **质量保障** | 最高（并行 + 两阶段审查 + 层级屏障） | 高（两阶段审查） | **最低**（无审查） |
| **成本** | 最高（多子代理 + 多次审查） | 中等 | 最低 |
| **适用平台** | Claude Code / Codex | Claude Code / Codex | **无子代理的平台（降级）** |
| **最佳场景** | 计划中有多个独立任务，追求速度 | 任务间紧耦合或计划较简单 | 子代理不可用时的降级方案 |

### Decision Logic

```
子代理可用？
├── YES → 任务能按依赖层级分组？
│   ├── YES → parallel-subagent-driven-development
│   │        （同层任务并行执行，层级屏障确保顺序）
│   └── NO  → subagent-driven-development
│             （任务紧耦合，顺序执行避免冲突）
└── NO  → executing-plans
          （降级方案：独立会话，主代理顺序执行）
```

**选择建议：**
- **默认选择并行模式** — 大多数计划都包含可并行的独立任务，层级屏障保证了依赖顺序，是质量和效率的最佳平衡
- **计划仅 1-2 个任务且紧耦合** → 顺序模式足够
- **子代理不可用** → executing-plans 是唯一选择，但质量保障显著降低

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
