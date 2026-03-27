# Claude Code Skills 开发项目

## 项目概述

本项目是 Claude Code Skills 的设计与开发仓库，用于创建和维护服务于研发开发流程的 Claude Code Skills。

### 项目目标

- **标准化开发流程**：通过 Skills 定义规范的开发工作流，涵盖需求澄清、规划、开发、测试、代码审查等全流程
- **提升研发效率**：自动化重复性工作，减少人工决策成本
- **保证代码质量**：内置代码审查、测试驱动开发等质量保障机制

### 核心内容

| 类型 | 数量 | 说明 |
|------|------|------|
| Skills | 18+ | 覆盖完整开发生命周期的技能 |
| Rules | 12 | 编码规范、架构规范、命名规范等 |
| Agents | 1 | 代码审查代理 |

---

## 安装

在 Claude Code 中执行以下命令安装此插件：

```bash
# 添加插件市场
/plugin marketplace add https://github.com/icefrag/java-claude-code

# 安装插件
/plugin install nbl@nbl-dev
```

---

# 项目配置

此文件定义项目的开发规范和依赖关系。

## 统一入口

所有开发工作通过 `/orchestrate` 入口：

```
/orchestrate feature "<描述>"   # 新功能开发
/orchestrate bugfix "<描述>"    # Bug修复
```

## Skills

### 开发工作流

| Skill | 描述 | 阶段 |
|-------|------|------|
| **nbl.orchestrate** | 统一入口，编排工作流 | 入口 |
| **nbl.brainstorming** | 需求澄清和规格文档 | 需求 |
| **nbl.writing-plans** | 详细计划 | 规划 |
| **nbl.using-git-worktrees** | 隔离工作区 | 准备 |
| **nbl.executing-plans** | 主 agent 直接执行 | 执行 |
| **nbl.subagent-driven-development** | 子代理串行执行任务 | 执行 |
| **nbl.parallel-subagent-driven-development** | 子代理并行执行任务 | 执行 |
| **nbl.requesting-code-review** | 请求代码审查 | 审查 |
| **nbl.receiving-code-review** | 处理CR反馈 | 审查 |
| **nbl.finishing-a-development-branch** | 完成开发分支 | 收尾 |

### 独立工具 Skills

| Skill | 描述 | 触发场景 |
|-------|------|---------|
| **nbl.refactor-clean** | 死代码清理 | 清理未使用代码 |
| **nbl.test-coverage** | 测试覆盖率分析 | 分析测试缺口 |
| **nbl.tech-design** | 技术设计文档 | 生成技术方案 |
| **nbl.deep-research** | 深度研究 | 网络调研 |
| **nbl.update-codemaps** | 更新CLAUDE.md | 项目结构变化 |
| **nbl.update-rules** | 规则文件更新 | 修改编码规范 |
| **nbl.writing-skills** | 编写新skill | 创建/修改skill |

## Rules

| Rule文件 | 描述 |
|---------|------|
| **architecture.md** | 分层架构、模块化设计、包结构、URI规范 |
| **naming.md** | Entity/Service/枚举/参数命名规范 |
| **coding-conventions.md** | Spring注入、数据持久化、工具类使用等开发规范 |

## Agents

| Agent | 描述 | 调用方式 |
|-------|------|---------|
| **nbl:code-reviewer** | 代码审查，检查实现是否符合计划和规范 | Agent tool |

## 工作流

所有任务都遵循统一流程：

```
/orchestrate feature/bugfix
    ↓
brainstorming → design.md
    ↓
writing-plans → plan.md
    ↓
[执行模式选择]
    ├── parallel-subagent-driven-development (多任务并行)
    ├── subagent-driven-development (任务串行)
    └── executing-plans (简单任务/无子代理支持)
    ↓
code-review → finish
```

## 目录结构

```
agents/
└── code-reviewer.md          # 代码审查 agent

skills/
├── nbl.orchestrate/                 # 统一入口
├── nbl.brainstorming/               # 需求澄清
├── nbl.writing-plans/               # 详细计划
├── nbl.using-git-worktrees/         # 隔离工作区
├── nbl.executing-plans/             # 主 agent 执行
├── nbl.subagent-driven-development/ # 子代理串行执行
├── nbl.parallel-subagent-driven-development/ # 子代理并行执行
├── nbl.requesting-code-review/      # 请求CR
├── nbl.receiving-code-review/       # 处理CR
├── nbl.finishing-a-development-branch/ # 完成分支
├── nbl.refactor-clean/              # 死代码清理
├── nbl.test-coverage/               # 测试覆盖率
├── nbl.tech-design/                 # 技术设计
├── nbl.deep-research/               # 深度研究
├── nbl.update-codemaps/             # 更新代码地图
├── nbl.update-rules/                # 规则更新
└── nbl.writing-skills/              # 编写skill
```

## 注意事项 (NON-NEGOTIABLE)

### 规则文件路径区分

修改 rules 目录下的文件时，**必须**使用项目相对路径，**禁止**使用全局路径：

| 路径类型 | 路径 | 用途 |
|---------|------|------|
| ✅ 项目规则 | `rules/common/xxx.md` | 本项目专用规则 |
| ❌ 全局规则 | `~/.claude/rules/common/xxx.md` | 所有项目共享规则 |
