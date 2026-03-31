# 并行模式 Worktree 优化设计

## 背景

当前 `nbl.parallel-subagent-driven-development` 实现每层完成后立即 rebase + merge 到主开发分支，最终直接完成后无法使用原始 `finishing-a-development-branch` 的"验证测试 → 提供选项 → 执行选择 → 清理四步流程。

需要对齐原始 superpowers 设计，让并行模式也能提供完整的 4 步完成流程。

## 问题分析

| 当前实现：
```
主空间: feature/xxx (开发分支)
  ├─ Level 0:
  │   task1 → 完成 → rebase → merge → 删除 task1
  ├─ Level 1:
  │   task2 → 完成 → rebase → merge → 删除 task2
  │   task3 → 完成 → rebase → merge → 删除 task3
  └─ Level 2:
      task4 → 完成 → rebase → merge → 删除 task4

所有变更已经全部分层合并到主开发分支
→ 直接调用 nbl.finishing-a-development-branch
```

问题：所有变更已经在开发分支，finishing 没有机会让用户选择合并策略。

## 设计目标

- 让并行模式也能遵循原始 superpowers 的完成流程：
  1. 验证测试
  2. 提供选项（合并本地/创建 PR/保留/丢弃）
  3. 执行选择
  4. 清理
- 复用 `finishing-a-development-branch 保持单一职责

## 方案设计

### 新增 merge 子工作区

新增一个中间合并缓冲区：

```
主空间: feature/xxx (开发分支)
  └── merge 子工作区: .worktrees/{name}-merge/ (分支: feature/{name}-merge)
        ├── 基于主开发分支创建
        ├── 所有任务合并到此，完成后保留
        └── 作为 finishing 的起点
```

### 完整执行流程

```
Setup Phase:
1. 检查当前分支，如果在 main/master → 自动创建 feature/{name} 开发分支
2. 基于 feature/{name} 创建 merge 子工作区 → .worktrees/{name}-merge/
3. 分支名: feature/{name}-merge

For Each Level (sequential):
1. 对 level 中每个 task，并行创建 task 子工作区
   - 每个 task: .worktrees/{name}-task{id}/
   - 分支名: feature/{name}-task{id}
   - 基于 merge 分支创建
2. 并行 dispatch 多个 implementer 子代理
3. 任务完成一个处理一个（pipeline 模式）:
   a. implementer 报告 DONE（内置 self-review 通过）
   b. 在 task 工作区执行: `git rebase {merge-branch}`
   c. 切回 main workspace: `git merge --ff-only {task-branch}` → 合并到 merge 分支
   d. 调用 cleanup 脚本删除 task 工作区
   e. 任务标记完成
4. level 所有任务完成 → 进入下一层

After All Levels Complete:
1. 全局 spec review（所有变更）
2. 全局 code quality review（所有变更）
3. 进入 finishing 流程:
   - 在 merge 子工作区执行 finishing
   - base 分支 = 主开发分支 feature/{name}
   - finishing 提供原始 4 选项给用户:
     1. 合并回主开发分支本地
     2. Push 并创建 PR
     3. 保留分支
     4. 丢弃工作
   - 用户选择后执行清理

错误处理：
- 如果某层失败，停止处理，merge 分支保留已完成层
- 不自动回滚，用户决定下一步
```

### 分支命名规范

| 类型 | 分支名 | 工作区路径 |
|------|--------|------------|
| 开发分支 | `feature/{name}` | 主空间 |
| merge 分支 | `feature/{name}-merge` | `.worktrees/{name}-merge/` |
| task 分支 | `feature/{name}-task{id}` | `.worktrees/{name}-task{id}/` |

### 任务失败处理

| 场景 | 处理方式 |
|------|----------|
| task 失败（BLOCKED/NEEDS_CONTEXT） | 停止流水线，merge 分支保留已完成层，等待用户指示 |
| rebase 冲突 | 自动尝试解析，解析失败提示用户手动处理 |
| merge 失败 | 回滚 merge，提示用户 |
| 某层失败不影响已完成层 | 保留已完成层，用户可以修复失败任务后继续 |

### 工作区清理时机

| 工作区 | 清理时机 |
|--------|----------|
| task 工作区 | 完成 merge 后立即清理 |
| merge 工作区 | 由 finishing 流程根据用户选择决定是否清理 |

## 模块依赖

| 模块 | 改动 |
|------|------|
| `nbl.parallel-subagent-driven-development` | 重构 pipeline 流程，增加 merge 子工作区创建，每层 task 合并流程 |
| `nbl.finishing-a-development-branch` | 恢复为原始 superpowers 设计（验证测试 → 提供选项 → 执行选择 → 清理），串行/inline/并行通用 |
| `nbl.using-git-worktrees` | 增加支持创建 merge 子工作区，不需要改变接口 |

## 对齐原有设计保持不变

串行模式 (subagent-driven-development):
- 创建一个 worktree，所有任务在其中完成，最后合并到开发分支，调用 finishing

Inline 模式 (executing-plans):
- 创建一个 worktree，所有任务在其中完成，调用 finishing

并行模式:
- 创建一个 merge worktree，所有任务依次创建自己的 worktree，完成后合并到 merge worktree，最后调用 finishing

## 风险评估

| 风险 |  mitigation |
|-----|-------------|
| 额外的 worktree 创建开销 | 任务完成后立即清理 task worktree，不会累积空间占用小 |
| 合并冲突风险 | 每层任务基于最新 merge 分支创建，冲突早发现早处理 |
| 实现复杂度 | 每层 pipeline 流程清晰，只改动并行模式，不影响串行和 inline |

## 总结

这个方案：
- ✅ 完全符合原始 superpowers 设计对齐
- ✅ 复用 finishing 流程，提供完整选择
- ✅ 错误处理安全，不丢失已完成工作
- ✅ 不影响现有串行和 inline 模式
