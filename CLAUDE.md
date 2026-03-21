# 项目配置

此文件定义项目的开发规范和依赖关系。

## Commands

| 命令 | 描述 | 依赖Agent | 依赖Skill | 依赖Rule |
|------|------|----------|----------|---------|
| `/plan` | 需求规划和实现计划 | planner | - | architecture, naming |
| `/tdd` | 测试驱动开发 | tdd-guide | springboot-tdd | architecture, naming, coding-conventions |
| `/code-review` | 代码审查 | code-reviewer | springboot-patterns | architecture, naming, coding-conventions |
| `/build-fix` | 构建错误修复 | build-error-resolver | springboot-patterns | architecture, naming, coding-conventions |
| `/refactor-clean` | 死代码清理 | refactor-cleaner | - | - |
| `/test-coverage` | 测试覆盖率分析 | - | springboot-tdd | architecture, naming, coding-conventions |
| `/orchestrate` | 多代理编排 | planner, tdd-guide, code-reviewer, security-reviewer | springboot-* | - |
| `/update-codemaps` | 更新代码地图 | - | - | - |
| `/prompt-optimize` | Prompt优化 | - | prompt-optimizer | - |

## Agents

| Agent | 描述 | 依赖Skill | 依赖Rule | 模型 |
|-------|------|----------|---------|------|
| **planner** | 复杂功能和重构规划 | - | architecture, naming | opus |
| **architect** | 系统设计和架构决策 | - | architecture, naming | opus |
| **tdd-guide** | 测试驱动开发 | springboot-tdd | architecture, naming, coding-conventions | sonnet |
| **code-reviewer** | Java/Spring Boot代码审查 | springboot-patterns | architecture, naming, coding-conventions | sonnet |
| **security-reviewer** | 安全漏洞检测与修复 | springboot-security | coding-conventions | sonnet |
| **build-error-resolver** | 构建错误修复 | springboot-patterns | architecture, naming, coding-conventions | sonnet |
| **refactor-cleaner** | 死代码清理 | - | - | sonnet |

## Skills (Spring Boot相关)

| Skill | 描述 | 依赖Rule |
|-------|------|---------|
| **springboot-patterns** | Spring Boot架构模式、REST API设计 | architecture, naming, coding-conventions |
| **springboot-security** | Spring Security最佳实践 | coding-conventions |
| **springboot-tdd** | 测试驱动开发工作流 | architecture, naming, coding-conventions |

## Rules

| Rule文件 | 描述 | 被谁使用 |
|---------|------|---------|
| **architecture.md** | 分层架构、模块化设计、包结构、URI规范 | planner, architect, tdd-guide, code-reviewer, build-error-resolver |
| **naming.md** | Entity/Service/枚举/参数命名规范 | planner, architect, tdd-guide, code-reviewer, build-error-resolver |
| **coding-conventions.md** | Spring注入、数据持久化、工具类使用等开发规范 | tdd-guide, code-reviewer, security-reviewer, build-error-resolver |

## 工作流依赖图

```
设计阶段:
  /plan ──────────> planner ──────────> architecture.md + naming.md
                                            │
                                            ▼
开发阶段:
  /tdd ───────────> tdd-guide ────────> springboot-tdd ──> all rules
                        │
                        ▼
  /build-fix ─────> build-error-resolver > springboot-patterns ──> all rules
                        │
                        ▼
审查阶段:
  /code-review ───> code-reviewer ─────> springboot-patterns ──> all rules
                        │
                        ▼
  /orchestrate ───> security-reviewer ─> springboot-security ──> coding-conventions.md
```

## 规则使用场景

| 场景 | 推荐Rule | 说明 |
|------|---------|------|
| 新功能设计 | architecture + naming | 确定包结构、类命名、接口设计 |
| 编码实现 | all rules | 完整的开发规范 |
| 代码审查 | all rules | 检查是否符合规范 |
| Bug修复 | coding-conventions | 主要关注数据持久化和异常处理规范 |
| 安全审计 | coding-conventions | 主要关注异常处理、JSON操作等规范 |

## Rule文件内容概览

### rules/common/architecture.md
- 分层架构原则 (Controller/Service/Manager/Mapper)
- 模块化设计原则 (app/api/config/assembly)
- 层间调用规范
- URI命名规范
- 包结构规范

### rules/common/naming.md
- Entity命名规范
- Service接口命名规范
- 枚举类命名规范
- 操作人参数命名规范
- 事件对象命名规范
- 分页参数命名规范

### rules/common/coding-conventions.md
- Spring依赖注入规范
- Lombok @Builder使用规范
- 数据持久化规范 (ID生成/更新/查询)
- JSON操作规范 (JsonUtil)
- 枚举工具类规范 (EnumUtil)
- 异常处理规范
- Controller返回值规范
- FeignClient接口规范
- 日期时间格式规范
- Swagger注解规范
