# 对齐 inline/serial/parallel 三种模式完成流程设计

## 需求背景

用户要求验证并对齐三种执行模式，使其符合以下要求：

1. `finishing-a-development-branch` 尽量复用官方 `superpowers` 版本
2. 串行模式、并行模式 **100% 在开发分支下进行开发**，同时**基于开发分支创建子工作区**
3. 并行模式下，**所有 task 完成后，最后保留一个唯一的 merge worktree**
4. `finishing-a-development-branch` **正确处理：worktree 合并到开发分支 + worktree 清理**

## 当前状态分析

| 项目 | 原实现 | 问题 |
|------|--------|------|
| `finishing-a-development-branch` | 自动统一流程 `验证测试 → 清理`，无用户交互 | 没有复用官方版本，官方版本提供 4 选项交互 |
| 串行模式 | 全局 review 通过后自动合并回开发分支，再调用 finishing | 不符合要求：应该保留 worktree，由 finishing 处理合并 |
| 并行模式 | 每层 tasks 完成后就合并到开发分支，所有完成后已经全部合并好再调用 finishing | 不符合要求：没有保留唯一 merge worktree，应该保留到 finishing 阶段 |

## 设计方案

### 总体流程对齐

| 模式 | 开发位置 | 完成流程 | 合并时机 |
|------|----------|----------|----------|
| **inline** (`nbl.executing-plans`) | 单个顶级 worktree（基于开发分支） | 所有 tasks 完成 → 调用 finishing | finishing 处理合并 |
| **serial** (`nbl.subagent-driven-development`) | 单个顶级 worktree（基于开发分支） | 所有 tasks 完成 → 全局 review → 调用 finishing | finishing 处理合并 |
| **parallel** (`nbl.parallel-subagent-driven-development`) | 顶层创建 merge worktree，每个 task 独立子 worktree（基于开发分支） | 所有 tasks 完成 → 全局 review → 调用 finishing | **保留 merge worktree 到 finishing 阶段**，由 finishing 处理合并 |

### 1. `finishing-a-development-branch` 完全复用官方版本

完全复制官方 `D:\workspace-script\superpowers\skills\finishing-a-development-branch\SKILL.md` 内容，保持：

- 流程：`验证测试 → 确定基分支 → 展示 4 选项 → 执行选择 → 清理 worktree`
- 四个选项：
  1. 合并回基分支本地
  2. Push 并创建 Pull Request
  3. 保留分支
  4. 丢弃工作
- 官方原生的 worktree 清理逻辑

### 2. 串行模式流程调整 (`nbl.subagent-driven-development`)

**原流程：**
```
全局 review 通过 → 自动合并 worktree 到开发分支 → 调用 finishing → finishing 只清理
```

**修改为：**
```
全局 review 通过 → 不自动合并 → 切换到 worktree → 调用 finishing
```

finishing 会：
1. 验证测试
2. 确定基分支（就是主开发分支）
3. 提供选项给用户
4. 根据用户选择执行合并 + 清理

### 3. 并行模式流程调整 (`nbl.parallel-subagent-driven-development`)

**保持现有的 task 级 pipeline 处理不变：**
```
Setup:
  1. 如果在 main/master → 自动创建开发分支 feature/{name}（主空间）
  2. 基于开发分支，创建一个顶层 merge worktree
     - 分支：feature/{name}-merge
     - 路径：.worktrees/{name}-merge/
  3. 后续 tasks 都基于这个 merge worktree

For each level:
  对于 level 中每个 task：
    - 基于 merge 分支创建 task worktree (feature/{name}-taskN)
  并行 dispatch 所有 tasks
  每完成一个 task：
    1. rebase task 分支到 merge 分支
    2. merge 到 merge 分支（在 merge worktree 中）
    3. 删除 task worktree
  所有 tasks 完成 → 下一层

After all levels:
  1. 全局 spec review（所有变更）
  2. 全局 code quality review（所有变更）
  ↓
  **保持：只剩唯一 merge worktree (feature/{name}-merge)，包含所有变更**
  ↓
  切换到 merge worktree → 调用 finishing-a-development-branch（官方版本）
  ↓
  finishing 处理合并回开发分支 + 清理
```

**关键点：**
- ✅ 所有 tasks 完成后，**保留唯一 merge worktree** 直到 finishing 阶段
- ✅ 由 finishing 官方版本处理合并回开发分支
- ✅ 由 finishing 官方版本处理 worktree 清理
- ✅ 每个 task 还是完成即清理，不累积

### 4. 分支和 worktree 结构最终状态（并行模式）

```
主仓库（主 workspace）:
  └── 当前分支: feature/{name}  (开发分支，基于 main/master 创建)

.worktrees/
  └── {name}-merge/        ← 唯一保留到最后的 merge worktree
        └── 当前分支: feature/{name}-merge
              └── 包含所有 tasks 合并后的完整代码

所有 task worktree (feature/{name}-task1, task2, ...) 在任务完成后立即删除
```

finishing 执行合并（选项1）后：
```
主开发分支 feature/{name} 得到合并结果
merge worktree 被删除
feature/{name}-merge 分支被删除
```

### 5. 依赖关系

| 模块 | 改动 |
|------|------|
| `nbl.finishing-a-development-branch` | 完全替换为官方版本内容 |
| `nbl.subagent-driven-development` | 移除提前自动合并步骤，改为调用 finishing 时由 finishing 处理 |
| `nbl.parallel-subagent-driven-development` | 保持现有 task pipeline 结构不变，修改最后一步，不提前合并到主开发分支 |

## 验证需求满足

| 需求 | 是否满足 |
|------|----------|
| 1. finishing 尽量复用官方 | ✅ 完全复用官方 SKILL.md，无修改 |
| 2. 串行/并行都在开发分支下，基于开发分支创建子工作区 | ✅ 串行：开发分支 → 创建单个子工作区；并行：开发分支 → 创建 merge 子工作区 → 每个 task 再创建子工作区 |
| 3. 并行最后保留唯一 merge worktree | ✅ 所有 tasks 完成后只留 merge worktree，进入 finishing |
| 4. finishing 正确处理合并 + 清理 | ✅ 官方版本原生支持，直接使用 |

## 总结

这个方案：
- 完全满足用户提出的四项要求
- 三种模式都遵循"子工作区开发 → 完成后由 finishing 处理合并"统一流程
- 最大化复用官方 finishing 实现，减少维护成本
- 并行模式的 task 级 pipeline 优化保持不变，只调整最后一步
