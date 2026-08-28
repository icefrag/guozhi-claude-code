---
name: tech-design
description: >-
  根据需求描述生成技术设计文档。包含需求背景、架构设计、技术设计、API设计、模型设计等章节。
  触发条件：用户请求技术方案、技术设计文档、API设计、数据库设计等。
rules:
  - rules/common/architecture.md
  - rules/common/naming.md
  - rules/common/coding-conventions.md
---

# 技术设计文档生成器

> **相关规则**: 此skill依赖项目规则文件，确保以下规则已加载：
> - `rules/common/architecture.md` - 分层架构、模块化设计、URI规范
> - `rules/common/naming.md` - Entity/Service/枚举等命名规范
> - `rules/common/coding-conventions.md` - API设计、数据持久化、工具类使用规范

根据用户需求描述，生成完整的技术设计文档。

## 激活时机

- 用户请求生成技术设计文档
- 用户需要设计新功能的技术方案
- 用户需要进行 API 和数据库设计
- 用户需要架构设计或技术评审文档

## 工作原理

1. **读取模板** — 读取 `skills/tech-design/template.md` 获取文档结构
2. **分析需求** — 理解用户的业务需求和技术要求
3. **应用规则** — 按照项目 rules 规范设计架构、命名、API 等
4. **生成文档** — 填充模板各章节，输出完整技术设计文档

## 输出结构

生成的技术设计文档包含以下章节：

### 1. 需求背景
- 业务背景描述
- 核心功能列表

### 2. 整体架构设计
- 系统架构图（Mermaid flowchart）
- 各层职责说明

### 3. 技术设计
- 功能流程图
- 时序图（调用关系复杂时）

### 4. API 设计
- 接口列表（方法、路径、说明）
- 接口详细设计（请求/响应参数）
- MQ 消息格式（如有）

### 5. 模型设计
- 新建表 SQL
- 更新表 SQL（如有）

## 设计规范

生成文档时必须遵循以下规范：

### URI 命名规范
- 格式：`/{功能}`
- 多单词使用 kebab-case：`/user-center`
- 禁止 camelCase 和 `/api` 前缀

### Entity 命名规范
- 使用 PascalCase，无需后缀
- 禁止添加 Entity、DO、PO 等后缀

### API 设计规范
- Controller 直接返回业务对象
- 分页使用 `IPage<T>` 类型
- 参数使用 `@RequestParam`，禁止 `@PathVariable`

### 数据库设计规范
- ID 使用 `IdWorker.getId()` 生成
- Entity 继承 `BaseEntity`
- 禁止重复定义 id、createTime、updateTime 字段

## 示例

### 输入

```
/tech-design 学期管理功能：需要实现学期的创建、编辑、删除和查询功能，每个学期包含名称、开始时间、结束时间等基本信息。
```

### 输出

生成包含以下内容的技术设计文档：
- 需求背景：学期管理的业务价值
- 架构图：前端 → gateway → app 服务 → 基础服务 → 数据库
- API 设计：POST /semesters/insert, GET /semesters 等
- 模型设计：semester 表的 DDL

## 注意事项

- 所有接口设计必须遵循项目的 URI 命名规范
- Entity 命名必须符合数据库表名转 PascalCase 的规则
- 复杂功能必须包含流程图和时序图
- SQL 语句必须符合 MySQL 语法
