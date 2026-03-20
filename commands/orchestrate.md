---
description: 多代理工作流的顺序和 tmux/worktree 编排指南。
---

# Orchestrate 命令

用于复杂任务的顺序agent工作流。

## 使用方法

`/orchestrate [工作流类型] [任务描述]`

## 工作流类型

### feature
完整功能实现工作流：
```
planner -> tdd-guide -> code-reviewer -> security-reviewer
```

### bugfix
Bug 调查和修复工作流：
```
planner -> tdd-guide -> code-reviewer
```

### refactor
安全重构工作流：
```
architect -> code-reviewer -> tdd-guide
```

### security
安全专注审查：
```
security-reviewer -> code-reviewer -> architect
```

## 执行模式

对于工作流中的每个代理：

1. **调用代理**，传入前一代理的上下文
2. **收集输出**为结构化交接文档
3. **传递给下一个代理**
4. **汇总结果**到最终报告

## 交接文档格式

代理之间创建交接文档：

```markdown
## HANDOFF: [前一代理] -> [下一代理]

### 上下文
[已完成工作的摘要]

### 发现
[关键发现或决策]

### 已修改文件
[涉及的文件列表]

### 待解决问题
[留给下一代理的未决项]

### 建议
[建议的后续步骤]
```

## 示例：功能工作流

```
/orchestrate feature "添加用户认证"
```

执行流程：

1. **Planner 代理**
   - 分析需求
   - 创建实现计划
   - 识别依赖
   - 输出：`HANDOFF: planner -> tdd-guide`

2. **TDD Guide 代理**
   - 读取 planner 交接文档
   - 先编写测试
   - 实现以通过测试
   - 输出：`HANDOFF: tdd-guide -> code-reviewer`

3. **Code Reviewer 代理**
   - 审查实现
   - 检查问题
   - 提出改进建议
   - 输出：`HANDOFF: code-reviewer -> security-reviewer`

4. **Security Reviewer 代理**
   - 安全审计
   - 漏洞检查
   - 最终审批
   - 输出：最终报告

## 最终报告格式

```
ORCHESTRATION REPORT
====================
Workflow: feature
Task: 添加用户认证
Agents: planner -> tdd-guide -> code-reviewer -> security-reviewer

SUMMARY
-------
[一段话摘要]

AGENT OUTPUTS
-------------
Planner: [摘要]
TDD Guide: [摘要]
Code Reviewer: [摘要]
Security Reviewer: [摘要]

FILES CHANGED
-------------
[所有已修改文件列表]

TEST RESULTS
------------
[测试通过/失败摘要]

SECURITY STATUS
---------------
[安全发现]

RECOMMENDATION
--------------
[可发布 / 需要修改 / 阻塞]
```

## 并行执行

对于独立检查，可并行运行代理：

```markdown
### 并行阶段
同时运行：
- code-reviewer（质量）
- security-reviewer（安全）
- architect（设计）

### 合并结果
将输出合并为单一报告
```

对于使用独立 git worktree 的外部 tmux-pane 工作器，使用 `node scripts/orchestrate-worktrees.js plan.json --execute`。内置编排模式保持在进程内；该辅助脚本用于长时间运行或跨 harness 会话的场景。

当工作器需要查看主检出中的脏文件或未跟踪文件时，在计划文件中添加 `seedPaths`。ECC 仅将这些选定路径覆盖到每个工作器 worktree 中（在 `git worktree add` 之后），这样既保持分支隔离，又能暴露进行中的本地脚本、计划或文档。

```json
{
  "sessionName": "workflow-e2e",
  "seedPaths": [
    "scripts/orchestrate-worktrees.js",
    "scripts/lib/tmux-worktree-orchestrator.js",
    ".claude/plan/workflow-e2e-test.json"
  ],
  "workers": [
    { "name": "docs", "task": "更新编排文档。" }
  ]
}
```

要导出实时 tmux/worktree 会话的控制平面快照，运行：

```bash
node scripts/orchestration-status.js .claude/plan/workflow-visual-proof.json
```

快照包含会话活动、tmux pane 元数据、工作器状态、目标、种子覆盖和最近的交接摘要，以 JSON 形式呈现。

## 操作员控制中心交接

当工作流跨越多个会话、worktree 或 tmux pane 时，在最终交接文档中附加控制面块：

```markdown
CONTROL PLANE
-------------
Sessions:
- 活动会话 ID 或别名
- 每个活动工作器的分支 + worktree 路径
- tmux pane 或分离会话名称（如适用）

Diffs:
- git status 摘要
- 涉及文件的 git diff --stat
- 合并/冲突风险说明

Approvals:
- 待用户审批项
- 等待确认的阻塞步骤

Telemetry:
- 最后活动时间戳或空闲信号
- 预估 token 或成本消耗
- hooks 或审查器触发的策略事件
```

这使 planner、implementer、reviewer 和循环工作器在操作员界面上清晰可见。

## 参数

$ARGUMENTS:
- `feature <描述>` - 完整功能工作流
- `bugfix <描述>` - Bug 修复工作流
- `refactor <描述>` - 重构工作流
- `security <描述>` - 安全审查工作流
- `custom <代理列表> <描述>` - 自定义代理序列

## 自定义工作流示例

```
/orchestrate custom "architect,tdd-guide,code-reviewer" "重新设计缓存层"
```

## 提示

1. **复杂功能从 planner 开始**
2. **合并前务必包含 code-reviewer**
3. **涉及认证/支付/PII 时使用 security-reviewer**
4. **保持交接文档简洁** - 聚焦下一代理所需内容
5. **如需要在代理间运行验证**
