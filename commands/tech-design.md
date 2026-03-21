---
description: 根据需求描述生成技术设计文档，包含架构设计、API设计、模型设计等章节。
---

## 用户输入

```text
$ARGUMENTS
```

在继续之前，您**必须**考虑用户输入（如果非空）。

## 概述

您正在根据用户的需求描述生成技术设计文档。文档将基于 `skills/tech-design/template.md` 模板，并遵循项目的 rules 规范。

请按以下执行流程操作：

## 执行流程

### 1. 读取模板和规则

首先读取以下文件：
- `skills/tech-design/template.md` - 技术设计文档模板
- `rules/common/architecture.md` - 分层架构、URI规范
- `rules/common/naming.md` - 命名规范
- `rules/common/coding-conventions.md` - API设计、数据持久化规范

### 2. 分析需求

分析用户输入的需求描述，识别：
- 业务背景和核心功能
- 涉及的系统模块和服务
- 需要设计的 API 接口
- 需要设计的数据库表

### 3. 生成文档

按照模板结构生成完整的技术设计文档：

#### 1. 需求背景
- 描述业务背景和价值
- 列出核心功能点

#### 2. 整体架构设计
- 绘制系统架构图（Mermaid flowchart）
- 说明各层职责和调用关系

#### 3. 技术设计
- 绘制功能流程图
- 绘制时序图（调用关系复杂时）

#### 4. API 设计
- 接口列表（遵循 URI 命名规范）
- 请求/响应参数定义
- MQ 消息格式（如有）

#### 5. 模型设计
- 新建表 DDL
- 更新表 DDL（如有）

## 设计规范检查清单

生成文档时必须确保：

- [ ] URI 使用 `/{功能}` 格式，多单词使用 kebab-case
- [ ] Entity 命名使用 PascalCase，无 Entity 后缀
- [ ] Controller 直接返回业务对象，不使用包装类型
- [ ] 分页接口返回 `IPage<T>` 类型
- [ ] ID 使用 `IdWorker.getId()` 生成
- [ ] Entity 继承 `BaseEntity`

## 输出格式

直接输出 Markdown 格式的技术设计文档，用户可复制保存。

## 示例

```
用户: /tech-design 学期管理功能：需要实现学期的创建、编辑、删除和查询功能

Agent: [生成完整的技术设计文档]
```
