# 原样同步上游 superpowers + 全量去前缀改名 设计文档

- 日期：2026-08-28
- 状态：待大王审阅
- 上游基线：`D:\workspace-script\superpowers` HEAD = v6.3.0（b36e082）
- 本地基线：v6.26.0（上次同步 2026-07-06，仅覆盖 v6.0.0 时代 7 项局部变更）

## 背景

并行执行（parallel subagent-driven development）经真实使用确认为伪需求：开发套餐不支持、且并不更快。借此做一次大版本整理：

1. 连根删除并行功能；
2. 与上游 v6.3.0 对齐；
3. 统一 skill 命名；
4. 导出个人行为准则到本仓库。

核心方法论（本次反思的结论）：上一轮同步采用「逐段补丁 + 深度本地化」，导致每次同步成本高、diff 无法对齐上游。本次改为**原样整目录复制**，把本地化压缩到一条机械规则，换取后续同步成本≈零。

## 已确认决策（大王逐项拍板）

| # | 决策 |
|---|------|
| D1 | 并行功能连根删除（含 skill、README/CLAUDE.md 引用） |
| D2 | 同源 skill 原样整目录复制上游，不做内容级本地化 |
| D3 | 同步范围 = SDD 全量重构 + TDD writing-good-tests + brainstorming 三路径 + 精简运动 + 杂项修复（render-graphs.js Windows 修复、find-polluter.sh 修复、finishing 修复包） |
| D4 | using-git-worktrees 原样拿上游（弃本地 scripts 与本地修复） |
| D5 | brainstorming 的 Visual Companion 原样带上（反转 CLAUDE.md 既有排除项） |
| D6 | skill 文内 `superpowers:` 调用前缀原样不动 |
| D7 | **所有 skill 名去掉 `nbl.` 前缀**：自有 skill `nbl.deploy` → `deploy`；同源 skill 用上游原名 |
| D8 | 插件名保持 `nbl.superpowers`（marketplace、安装路径、调用前缀不变） |
| D9 | AGENTS.md 导出：仅行为准则（`~/.zcode/AGENTS.md` 第 1–91 行），其余全不带 |
| D10 | 唯一内容规则：文内 `docs/superpowers/` → `docs/nbl/`（spec/plan 落点） |
| D11 | 删除 `nbl.status-line` 与 `nbl.evolve` 两个 skill（大王 2026-08-28 追加） |
| D12 | 删除 `nbl.java-spring-integration-testing` skill（大王 2026-08-28 追加） |
| D13 | 删除 `nbl.test-coverage` skill（大王 2026-08-28 追加；其对已删 java-spring-integration-testing 的引用随之消失） |

## Skill 清单终态（19 个，全部平名）

**上游原样复制（12 个）**：brainstorming、executing-plans、finishing-a-development-branch、receiving-code-review、requesting-code-review、subagent-driven-development、systematic-debugging、test-driven-development、using-git-worktrees、verification-before-completion、writing-plans、writing-skills

**nbl 自有改名（7 个）**：deploy、k8s-logs、deep-research、edit-rules、install-rules、refactor-clean、tech-design

**删除（5 个）**：nbl.parallel-subagent-driven-development、nbl.status-line、nbl.evolve、nbl.java-spring-integration-testing、nbl.test-coverage

## 设计

### Phase 1：skill 删除（5 个）

- 删除 `skills/nbl.parallel-subagent-driven-development/`、`skills/nbl.status-line/`、`skills/nbl.evolve/`、`skills/nbl.java-spring-integration-testing/`、`skills/nbl.test-coverage/` 五个整目录。
- 连带引用清理：
  - README.md：parallel 3 处（执行流程行、skill 总表行、目录树行，约 L19/L67/L111）；status-line 4 处（总表行 L82、「📊 nbl.status-line 效果展示」章节 L86–88、目录树行 L119）；test-coverage 4 处（开头介绍 L4、总表行 L79、目录树行 L116、生态整合行 L138——该行与 refactor-clean/tech-design 并列提及，需改写而非整行删）。evolve 与 java-spring-integration-testing 经 grep 确认 README 无引用；java-spring-integration-testing 在 test-coverage 内的引用随该 skill 删除自然消失。
- CLAUDE.md 中「子任务合并 (parallel mode)」行随 Phase 4 的 Worktree 章节重写一并处理，不单独手术。
- 说明：writing-plans / finishing / SDD / using-git-worktrees 里的 parallel 内容随 Phase 2 原样复制自然消失，不做重复手术。

### Phase 2：原样同步（12 个同源 skill 整目录替换）

删除本地 `skills/nbl.<name>/`，从上游 `D:\workspace-script\superpowers\skills\<name>\` 复制 `skills/<name>/`。

套用唯一内容规则（D10）：文内 `docs/superpowers/` → `docs/nbl/`。上游已知 8 处（brainstorming×3、requesting-code-review×1、subagent-driven-development×2、writing-plans×2），以复制后实际 grep 为准。

随复制自动获得：SDD 单 task-reviewer 双裁决 + plan-scoped 工作区（`.superpowers/sdd/<plan>/`，自忽略目录）+ resume 修复循环 + 五轮熔断 + scripts（sdd-workspace / task-brief / review-package）；TDD `writing-good-tests.md`；brainstorming 三路径路由 + Visual Companion；systematic-debugging `find-polluter.sh` 修复；finishing 无 discard 菜单 / forge-agnostic PR / untracked 文件保护 / worktree path 修复；writing-skills `render-graphs.js` Windows 修复。

本地物随之退役（属预期，见风险清单）：双评审 prompt 文件、`.nbl/sdd/progress.md` ledger 惯例、Execution Mode（inline/serial）路由、writing-plans 本地 Dependencies/Parallelizable 模板、worktree 全套本地脚本与 b209edb / 46bbaf0 修复、worktree-parent-branch 功能、detached HEAD 3 选项菜单（上游 2 选项取代）。

### Phase 3：全量去前缀改名

- 9 个自有 skill 目录 `git mv skills/nbl.<name> skills/<name>`；每个 SKILL.md frontmatter `name: nbl.<name>` → `name: <name>`。
- 全仓 sweep：精确匹配 **19 个旧名**（7 个自有旧名 + 12 个同源 skill 旧名，如 `nbl.using-git-worktrees`）`nbl.<name>` → `<name>`，覆盖 skills/ 交叉引用、README.md、CLAUDE.md、rules/common/*.md（如有）、scripts 内字符串（如调用格式 `/nbl.superpowers:nbl.k8s-logs` → `/nbl.superpowers:k8s-logs`）。
- 白名单（禁止改动）：插件名 `nbl.superpowers`、`docs/nbl/` 与 `.nbl` 形态路径（`nbl/` 不含点号，天然不匹配 `nbl.<name>` 模式，但仍列入白名单防误伤）。
- 历史文档（docs/nbl/specs、docs/nbl/plans 下的旧文档）中的旧 skill 名**不回改**，按项目惯例仅作历史线索。

### Phase 4：CLAUDE.md / README.md 重写

- CLAUDE.md：
  - 「Worktree 操作规范」：删 3 行命令表（上游无此 CLI 子命令），保留「worktree 操作必须通过 using-git-worktrees skill 执行」的原则表述，指向新 skill 名。
  - 「能力比对排除项」：删 Visual Companion 条目（D5 反转）。
  - 其余章节（本地开发参考、版本更新、Skill 开发规范）保留不动。
- README.md：**逐 skill 校准**（大王特别嘱咐）——skill 总表按两组重写（上游同步 12 个 + nbl 自有 7 个，全部新命名、描述与实际 SKILL.md description 一致），目录树更新，删除 parallel、status-line、test-coverage 相关内容（含「效果展示」章节），确保 README 与 skills/ 目录实际状态一一对应。

### Phase 5：AGENTS.md 导出

- 新建仓库根 `AGENTS.md`，内容 = `C:\Users\icefr\.zcode\AGENTS.md` 第 1–91 行，即行为准则全文，止于 "**These guidelines are working if:** ..." 一行。
- 不含：基本约定、Java 专项约定、历史文档参考、全局开发规范。

### Phase 6：收尾与验证

- 版本号 6.26.0 → **7.0.0**（skill 改名 + 功能删除，破坏性变更），`.claude-plugin/plugin.json` 与 `.claude-plugin/marketplace.json` 两处同步。
- 验证清单：
  1. `ls skills/` 共 19 个目录，全部无 `nbl.` 前缀；
  2. 每个 SKILL.md 的 `name:` 与目录名一致；
  3. 精确 grep 19 个旧名 `nbl.<name>`，skills/、README.md、CLAUDE.md、rules/、scripts 内命中数为 0；
  4. `grep -rni "parallel" skills/ README.md CLAUDE.md` 仅允许 legitimate 命中（如上游 SDD 中 "parallel session" 指另一会话执行 executing-plans，非并行执行功能）；deleted skill 名 `parallel-subagent-driven-development` 命中数为 0（历史文档除外）；
  5. 保留的 scripts 语法检查：`bash -n`（k8s-logs、SDD scripts 等），`node --check`（render-graphs.js）；
  6. 两处版本号一致且为 7.0.0。
- 提交：按 Phase 分 commit，约定式提交格式；实施时是否用 worktree 隔离由实施计划决定。

## 不同步清单（永久记录，后续能力比对不再输出）

- `dispatching-parallel-agents`（与 D1 方向相反）
- `using-superpowers`（bootstrap 类，本地体系不需要）
- `hooks/` 与多 harness 支持（Claude Code hook、Codex、Gemini、Kimi、Pi、Antigravity、Devin、Hermes、Grok）
- README TOC、evals 子模块、打包脚本（package-codex-plugin.sh 等）

## 风险与丢弃清单（大王已知悉，记录在案）

1. **Execution Mode 路由丢失**：plan 不再带 inline/serial 执行模式页脚，执行方式由人选 executing-plans 或 subagent-driven-development。上游生态本如此。
2. **worktree 本地资产丢失**（D4 后果）：create/cleanup/lib 脚本、b209edb（不误清 docs 目录）、46bbaf0（cleanup 失败降级）、worktree-parent-branch 功能全部退役；worktree 工作流变为上游「skill 指导 + 直接 git 命令」模式。存量 `.worktrees/` 不受影响。
3. **SDD scratch 目录变更**：`.nbl/sdd/progress.md` → `.superpowers/sdd/<plan>/`（上游 plan-scoped，目录自忽略，`git clean -fdx` 会清掉，可从 git log 重建）。
4. **detached HEAD 菜单收缩**：本地 3 选项（含 discard）→ 上游 2 选项（无 discard）。
5. **executing-plans 悬空引用**：文内指到 `../using-superpowers/references/`（我们不带该 skill），括号性质、无害，按 D6 精神原样保留。
6. **`superpowers:` 前缀字面不一致**：skill 文内前缀与插件名 `nbl.superpowers` 不一致，D6 接受，agent 按 skill 名解析无功能影响。
7. **平名撞名风险**：全平名后，bare name（如 deploy）理论上可与其他插件的 skill 撞名；ZCode 以 `nbl.superpowers:` 前缀消歧，无硬冲突。
8. **外部跟进项**：`~/.zcode/AGENTS.md` 全局开发规范头部「由 nbl.edit-rules 维护」字样为用户个人文件，不在本仓库范围；下次 edit-rules 同步时自然刷新。`~/.claude/` 中已安装的 statusline 脚本与 settings 配置为运行时残留，删除 skill 不影响其继续工作，是否清理由大王自行决定。

## 后续

大王审阅通过后，转入 writing-plans 输出实施计划。
