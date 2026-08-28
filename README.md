# nbl.superpowers - Claude Code 扩展技能集

基于官方 [superpowers](https://github.com/obra/superpowers) 技能体系，与上游 **v6.3.0** 原样对齐（整目录同步，仅 spec/plan 落点调整为 `docs/nbl/`）。
同时整合了 [everything-claude-code](https://github.com/affaan-m/everything-claude-code) 项目中精选的实用技能（如 `/refactor-clean`、`/tech-design`），并沉淀了面向 guozhi 项目的 `deploy`、`k8s-logs` 等专属技能。

---

### 完整开发生命周期

```
需求澄清(brainstorming)
  → 输出设计文档
  → 详细计划(writing-plans)
  → 创建隔离工作区(using-git-worktrees)
  → subAgent 串行执行(subagent-driven-development) 或 主会话执行(executing-plans)
  → 代码审查(requesting-code-review)
  → 处理反馈(receiving-code-review)
  → 人工审核确认
  → 合并到主分支
  → 清理 worktree(finishing-a-development-branch)
```

---

## 📥 安装

在 Claude Code 中执行以下命令安装此插件：

```bash
# 添加插件市场
/plugin marketplace add https://github.com/icefrag/nbl-superpowers

# 安装插件
/plugin install nbl.superpowers@nbl.superpowers
```

---

## 🔄 更新方式

<img width="300" height="150" alt="image" src="https://github.com/user-attachments/assets/8ae38a00-d2de-4d16-a9ef-ca16cadf5548" />
<img width="300" height="150" alt="image" src="https://github.com/user-attachments/assets/23c7597b-fd15-4ff6-b729-ea4a0354c328" />
<img width="300" height="150" alt="image" src="https://github.com/user-attachments/assets/bc13ca8f-8c07-4c78-8415-ef539d14f6f7" />
<img width="300" height="150" alt="image" src="https://github.com/user-attachments/assets/98ed4f12-6f67-4364-afae-fe028cf06ff3" />
<img width="300" height="150" alt="image" src="https://github.com/user-attachments/assets/a66194de-570e-415d-9cd0-6d1060db49f7" />

---

## 🧩 Skills

插件内 skill 调用格式为 `/nbl.superpowers:<skill-name>`，如 `/nbl.superpowers:brainstorming`。

### 开发工作流（同步自上游 superpowers）

按开发阶段排列：

| Skill | 描述 | 阶段 |
|-------|------|------|
| **brainstorming** | 需求澄清和设计文档生成（三路径分级） | 📝 需求 |
| **writing-plans** | 分解任务生成详细执行计划 | 📋 规划 |
| **using-git-worktrees** | 创建 Git worktree 隔离工作区 | ⚙️ 准备 |
| **executing-plans** | 独立会话执行计划，带审查检查点 | ▶️ 执行 |
| **subagent-driven-development** | SubAgent 串行执行任务，单评审双裁决 | ▶️ 执行 |
| **requesting-code-review** | 请求代码审查 | 🔍 审查 |
| **receiving-code-review** | 处理代码审查反馈 | 🔍 审查 |
| **finishing-a-development-branch** | 合并清理，完成开发分支 | 🎬 收尾 |
| **test-driven-development** | 测试驱动开发（RED-GREEN-REFACTOR） | 🧪 测试 |
| **systematic-debugging** | 系统化调试，四阶段定位根因 | 🐛 调试 |
| **verification-before-completion** | 完成声明前必须先跑验证 | ✅ 验证 |
| **writing-skills** | 技能编写与测试工具 | ✍️ 技能开发 |

### 独立工具 Skills（nbl 自有）

这些是可独立使用的工具技能：

| Skill | 描述 | 触发场景 |
|-------|------|---------|
| **deploy** | 自动化发布 guozhi 系列服务到 dev 环境 | 部署、发布、deploy、上线 |
| **k8s-logs** | 排查 guozhi 项目 K8s 各环境服务日志 | 查日志、服务报错、环境排查 |
| **deep-research** | 多源深度网络研究，输出带引用的报告 | 需要调研收集信息 |
| **edit-rules** | 管理 rules/common/ 规则文件的编辑 | 修改规则、修改编码规范 |
| **install-rules** | 从 GitHub 安装最新规则到本地 ~/.claude/rules/ | 安装规则、更新本地规则 |
| **refactor-clean** | Java Web 死代码清理和重构专家 | 清理未使用代码、重构优化 |
| **tech-design** | 根据需求生成技术设计文档 | 技术方案、API 设计、数据库设计 |

---

## 📁 目录结构

```
skills/
├── brainstorming/                  # 需求澄清和设计
├── writing-plans/                  # 详细执行计划
├── using-git-worktrees/            # Git worktree 隔离工作区
├── executing-plans/                # 主会话执行计划
├── subagent-driven-development/    # SubAgent 串行执行
├── requesting-code-review/         # 请求代码审查
├── receiving-code-review/          # 处理审查反馈
├── finishing-a-development-branch/ # 完成开发分支
├── test-driven-development/        # 测试驱动开发
├── systematic-debugging/           # 系统化调试
├── verification-before-completion/ # 完成前验证
├── writing-skills/                 # 技能开发工具
├── deploy/                         # dev 环境自动化部署
├── k8s-logs/                       # K8s 日志排查
├── deep-research/                  # 多源深度研究
├── edit-rules/                     # 规则文件管理
├── install-rules/                  # 规则安装
├── refactor-clean/                 # Java Web 死代码清理
└── tech-design/                    # 技术设计文档生成

rules/
└── common/                         # 开发规范规则集（示例管理，需手动拷贝到 ~/.claude/rules/ 生效）
```

---

## 💡 核心优势

| 特性 | 说明 |
|------|------|
| **原样同步** | 与上游 superpowers 整目录对齐，diff 干净，后续同步成本≈零 |
| **物理隔离** | Git worktree 级别的隔离，多个任务完全不干扰 |
| **安全审核** | 代码在 worktree 开发完成，人工审核后才合并到主分支 |
| **兼容官方** | 所有技能遵循官方 superpowers 设计原则，学习成本低 |
| **生态整合** | 整合了 [everything-claude-code](https://github.com/affaan-m/everything-claude-code) 项目中精选的实用技能，如 `refactor-clean` 死代码清理、`tech-design` 技术文档生成等 |
| **领域沉淀** | 面向 guozhi 项目的专属技能：`deploy` 自动化部署、`k8s-logs` 日志排查 |

---

## 📄 许可证

遵循原项目许可证，扩展部分遵循相同协议。
