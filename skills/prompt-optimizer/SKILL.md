---
name: prompt-optimizer
description: >-
  分析原始prompt，识别意图和不足，匹配ECC组件（skills/commands/agents/hooks），
  并输出可直接复制粘贴的优化后prompt。仅承担顾问角色——不执行任何任务本身。
  触发条件：用户说"optimize prompt"、"improve my prompt"、"how to write a prompt for"、
  "help me prompt"、"rewrite this prompt"，或明确要求提升prompt质量。
  也适用于中文场景："优化prompt"、"改进prompt"、"怎么写prompt"、"帮我优化这个指令"。
  不触发条件：用户希望直接执行任务，或说"just do it" / "直接做"。
  不触发条件：用户说"优化代码"、"优化性能"、"optimize performance"、"optimize this code"——
  这些是重构/性能任务，不是prompt优化。
origin: community
metadata:
  author: YannJY02
  version: "1.0.0"
---

# Prompt 优化器

分析草稿prompt，对其进行批判性评估，匹配ECC生态系统组件，并输出用户可直接复制运行的完整优化prompt。

## 使用场景

- 用户说"optimize this prompt"、"improve my prompt"、"rewrite this prompt"
- 用户说"help me write a better prompt for..."
- 用户说"What's the best way to ask Claude Code to..."
- 用户说"优化prompt"、"改进prompt"、"怎么写prompt"、"帮我优化这个指令"
- 用户粘贴了一段草稿prompt并请求反馈或改进
- 用户说"I don't know how to prompt for this"
- 用户说"how should I use ECC for..."
- 用户明确调用了`/prompt-optimize`

### 不适用场景

- 用户希望直接完成任务（直接执行即可）
- 用户说"优化代码"、"优化性能"、"optimize this code"、"optimize performance"——这些是重构任务，不是prompt优化
- 用户询问ECC配置（改用`configure-ecc`）
- 用户想要技能清单（改用`skill-stocktake`）
- 用户说"just do it"或"直接做"

## 工作原理

**仅承担顾问角色——不执行用户的任务。**

不要编写代码、创建文件、运行命令或采取任何实现行动。你的唯一输出是分析结果加优化后的prompt。

如果用户说"just do it"、"直接做"或"don't optimize, just execute"，不要切换到实现模式。请告知用户此skill只生成优化prompt，并指示他们如果想要执行则提出正常的任务请求。

按顺序执行以下6阶段流程。按下方输出格式呈现结果。

### 分析流程

### 阶段0：项目检测

在分析prompt之前，检测当前项目上下文：

1. 检查工作目录中是否存在`CLAUDE.md`——如有则读取以了解项目规范
2. 从项目文件中检测技术栈：
   - `package.json` → Node.js / TypeScript / React / Next.js
   - `go.mod` → Go
   - `pyproject.toml` / `requirements.txt` → Python
   - `Cargo.toml` → Rust
   - `build.gradle` / `pom.xml` → Java / Kotlin / Spring Boot
   - `Package.swift` → Swift
   - `Gemfile` → Ruby
   - `composer.json` → PHP
   - `*.csproj` / `*.sln` → .NET
   - `Makefile` / `CMakeLists.txt` → C / C++
   - `cpanfile` / `Makefile.PL` → Perl
3. 记录检测到的技术栈，供阶段3和阶段4使用

如果未找到项目文件（例如prompt是抽象的或用于新项目），跳过检测并在阶段4中标记"技术栈未知"。

### 阶段1：意图检测

将用户的任务分类到一个或多个类别：

| 类别 | 关键词 | 示例 |
|------|--------|------|
| 新功能 | build, create, add, implement, 创建, 实现, 添加 | "Build a login page" |
| Bug修复 | fix, broken, not working, error, 修复, 报错 | "Fix the auth flow" |
| 重构 | refactor, clean up, restructure, 重构, 整理 | "Refactor the API layer" |
| 研究 | how to, what is, explore, investigate, 怎么, 如何 | "How to add SSO" |
| 测试 | test, coverage, verify, 测试, 覆盖率 | "Add tests for the cart" |
| 审查 | review, audit, check, 审查, 检查 | "Review my PR" |
| 文档 | document, update docs, 文档 | "Update the API docs" |
| 设计 | design, architecture, plan, 设计, 架构 | "Design the data model" |

### 阶段2：范围评估

如果阶段0检测到项目，使用代码库大小作为信号。否则仅根据prompt描述估算，并标记估算为不确定。

| 范围 | 启发式标准 | 编排方式 |
|------|-----------|----------|
| TRIVIAL（微小） | 单文件，< 50行 | 直接执行 |
| LOW（低） | 单个组件或模块 | 单命令或skill |
| MEDIUM（中） | 多个组件，同一领域 | 命令链 + /verify |
| HIGH（高） | 跨领域，5+文件 | 先/plan，再分阶段执行 |
| EPIC（巨型） | 多会话，多PR，架构变更 | 使用blueprint skill进行多会话规划 |

### 阶段3：ECC组件匹配

根据意图 + 范围 + 技术栈（来自阶段0）映射到具体ECC组件。

#### 按意图类型

| 意图 | Commands | Skills | Agents |
|------|----------|--------|--------|
| 新功能 | /plan, /tdd, /code-review, /verify | test-driven-development, verification-loop | planner, tdd-guide, code-reviewer |
| Bug修复 | /tdd, /build-fix, /verify | test-driven-development | tdd-guide, build-error-resolver |
| 重构 | /refactor-clean, /code-review, /verify | verification-loop | refactor-cleaner, code-reviewer |
| 研究 | /plan | search-first, iterative-retrieval | — |
| 测试 | /tdd, /test-coverage | test-driven-development | tdd-guide |
| 审查 | /code-review | — | code-reviewer |
| 文档 | /update-codemaps | — | doc-updater |
| 设计（MEDIUM-HIGH） | /plan | — | planner, architect |
| 设计（EPIC） | — | blueprint（作为skill调用） | planner, architect |

#### 按技术栈

| 技术栈 | 需要添加的Skills | Agent |
|--------|-----------------|-------|
| Spring Boot / Java | springboot-patterns, test-driven-development, springboot-security, springboot-verification, java-coding-standards, jpa-patterns | code-reviewer |
| 其他/未列出 | coding-standards（通用） | code-reviewer |

### 阶段4：缺失上下文检测

扫描prompt中缺失的关键信息。检查每个项目并标记阶段0是否自动检测到它，或用户是否必须提供：

- [ ] **技术栈** — 阶段0已检测，还是需要用户指定？
- [ ] **目标范围** — 是否提及了文件、目录或模块？
- [ ] **验收标准** — 如何知道任务完成了？
- [ ] **错误处理** — 是否处理了边缘情况和失败模式？
- [ ] **安全需求** — 认证、输入验证、密钥？
- [ ] **测试期望** — 单元测试、集成测试、E2E？
- [ ] **性能约束** — 负载、延迟、资源限制？
- [ ] **UI/UX需求** — 设计规范、响应式、无障碍访问？（前端场景）
- [ ] **数据库变更** — 模式、迁移、索引？（数据层场景）
- [ ] **现有模式** — 是否引用了要遵循的参考文件或规范？
- [ ] **范围边界** — 什么不要做？

**如果缺失3项或以上关键信息**，在生成优化prompt之前向用户提出最多3个澄清问题。然后将答案整合到优化prompt中。

### 阶段5：工作流和模型推荐

确定此prompt在开发生命周期中的位置：

```
研究 → 规划 → 实现（TDD） → 审查 → 验证 → 提交
```

对于MEDIUM+级别的任务，始终从/plan开始。对于EPIC级别的任务，使用blueprint skill。

**多prompt拆分**（适用于HIGH/EPIC范围）：

对于超出单个会话的任务，拆分为顺序执行的多个prompt：
- Prompt 1：研究 + 规划（使用search-first skill，然后/plan）
- Prompt 2-N：每个prompt实现一个阶段（每个阶段以/verify结束）
- 最终Prompt：集成测试 + 跨所有阶段的/code-review
- 使用/save-session和/resume-session在会话之间保留上下文

---

## 输出格式

按此确切结构呈现分析。使用与用户输入相同的语言回复。

### 第1部分：Prompt诊断

**优势：** 列出原始prompt做得好的地方。

**问题：**

| 问题 | 影响 | 建议修复 |
|------|------|---------|
| （问题描述） | （后果） | （如何修复） |

**需要澄清：** 用户应回答的编号问题列表。如果阶段0已自动检测到答案，则说明该答案而非提问。

### 第2部分：推荐的ECC组件

| 类型 | 组件 | 用途 |
|------|------|------|
| Command | /plan | 编码前先规划架构 |
| Skill | test-driven-development | TDD方法论指导 |
| Agent | code-reviewer | 实现后审查 |

### 第3部分：优化Prompt——完整版

将完整优化prompt放在单个代码块中。prompt必须是自包含的、可直接复制粘贴的。包含：
- 带上下文的清晰任务描述
- 技术栈（检测到或指定的）
- 在正确工作流阶段调用/command
- 验收标准
- 验证步骤
- 范围边界（什么不要做）

对于引用blueprint的项目，写："Use the blueprint skill to..."（使用blueprint skill来...）
（不是`/blueprint`，因为blueprint是一个skill，不是command）。

### 第4部分：优化Prompt——快捷版

面向有经验的ECC用户的紧凑版本。按意图类型变化：

| 意图 | 快捷模式 |
|------|---------|
| 新功能 | `/plan [feature]. /tdd to implement. /code-review. /verify.` |
| Bug修复 | `/tdd — write failing test for [bug]. Fix to green. /verify.` |
| 重构 | `/refactor-clean [scope]. /code-review. /verify.` |
| 研究 | `Use search-first skill for [topic]. /plan based on findings.` |
| 测试 | `/tdd [module]. /e2e for critical flows. /test-coverage.` |
| 审查 | `/code-review. Then use security-reviewer agent.` |
| 文档 | `/update-docs. /update-codemaps.` |
| EPIC | `Use blueprint skill for "[objective]". Execute phases with /verify gates.` |

### 第5部分：增强理由

| 增强项 | 理由 |
|--------|------|
| （添加了什么） | （为什么重要） |

### 页脚

> 不是你需要的内容？告诉我需要调整什么，或者如果你想要执行而非prompt优化，请提出正常的任务请求。

---

## 示例

### 触发示例

- "Optimize this prompt for ECC"
- "Rewrite this prompt so Claude Code uses the right commands"
- "帮我优化这个指令"
- "How should I prompt ECC for this task?"

### 示例1：模糊的中文Prompt（检测到项目）

**用户输入：**
```
帮我写一个用户登录页面
```

**阶段0检测到：** `package.json`，包含Next.js 15、TypeScript、Tailwind CSS

**优化后的Prompt（完整版）：**
```
使用项目现有技术栈（Next.js 15 + TypeScript + Tailwind CSS）实现用户登录页面。

技术要求：
- 沿用项目现有的组件结构和路由约定
- 表单验证使用项目中已有的验证方案（检查是否已用 Zod/Yup/其他）
- 认证方式：沿用项目现有认证方案（如无，默认 JWT）
- 包含：邮箱/密码登录表单、表单验证、错误提示、加载状态、响应式布局

工作流：
1. /plan 先规划组件结构和认证流程，参考现有页面的模式
2. /tdd 测试先行：编写登录表单的单元测试和认证流程的集成测试
3. 实现登录页面和认证逻辑
4. /code-review 审查实现
5. /verify 验证所有测试通过且页面正常渲染

安全要求：
- 密码不明文传输
- 防止暴力破解（rate limiting）
- XSS 防护
- CSRF token

验收标准：
- 所有测试通过，覆盖率 80%+
- 页面在移动端和桌面端正常渲染
- 登录成功跳转到 dashboard，失败显示错误信息

不要做：
- 不要实现注册页面
- 不要实现忘记密码功能
- 不要修改现有的路由结构
```

### 示例2：中等详细的英文Prompt

**用户输入：**
```
Add a REST API endpoint for user profile updates with validation
```

**阶段0检测到：** `go.mod`，包含Go 1.22、Chi router

**优化后的Prompt（完整版）：**
```
Add a REST API endpoint for user profile updates (PATCH /api/users/:id).

Tech stack: Go 1.22 + Chi router (detected from project)

Requirements:
- PATCH /api/users/:id — partial update of user profile
- Input validation for fields: name, email, avatar_url, bio
- Auth: require valid token, users can only update own profile
- Return 200 with updated user on success
- Return 400 with validation errors on invalid input
- Return 401/403 for auth failures
- Follow existing API patterns in the codebase

Workflow:
1. /plan the endpoint structure, middleware chain, and validation logic
2. /tdd — write table-driven tests for success, validation failure, auth failure, not-found
3. Implement following existing handler patterns
4. /go-review
5. /verify — run full test suite, confirm no regressions

Do not:
- Modify existing endpoints
- Change the database schema (use existing user table)
- Add new dependencies without checking existing ones first (use search-first skill)
```

### 示例3：EPIC级别项目

**用户输入：**
```
Migrate our monolith to microservices
```

**优化后的Prompt（完整版）：**
```
Use the blueprint skill to plan: "Migrate monolith to microservices architecture"

Before executing, answer these questions in the blueprint:
1. Which domain boundaries exist in the current monolith?
2. Which service should be extracted first (lowest coupling)?
3. Communication pattern: REST APIs, gRPC, or event-driven (Kafka/RabbitMQ)?
4. Database strategy: shared DB initially or database-per-service from start?
5. Deployment target: Kubernetes, Docker Compose, or serverless?

The blueprint should produce phases like:
- Phase 1: Identify service boundaries and create domain map
- Phase 2: Set up infrastructure (API gateway, service mesh, CI/CD per service)
- Phase 3: Extract first service (strangler fig pattern)
- Phase 4: Verify with integration tests, then extract next service
- Phase N: Decommission monolith

Each phase = 1 PR, with /verify gates between phases.
Use /save-session between phases. Use /resume-session to continue.
Use git worktrees for parallel service extraction when dependencies allow.

Recommended: Opus 4.6 for blueprint planning, Sonnet 4.6 for phase execution.
```

---

## 相关组件

| 组件 | 何时参考 |
|------|---------|
| `search-first` | 优化prompt中的研究阶段 |
| `blueprint` | EPIC范围的优化prompt（作为skill调用，非command） |
| `strategic-compact` | 长会话上下文管理 |
