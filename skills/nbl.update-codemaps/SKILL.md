---
name: nbl.update-codemaps
description: >
  生成或更新项目的 CLAUDE.md 文件，帮助 AI 快速理解项目结构、技术栈、核心功能和关键入口点。
  触发条件：新建项目、项目结构变化、用户请求更新项目文档、用户说"更新CLAUDE.md"、"生成项目文档"、"让AI了解项目"。
  当用户提到 CLAUDE.md、项目概览、项目结构说明、核心功能时，主动使用此 skill。
---

# Update CLAUDE.md Skill

生成或更新项目根目录的 `CLAUDE.md` 文件，让 AI 助手快速理解当前项目。

## 激活时机

- 项目没有 CLAUDE.md 文件
- 项目结构发生重大变化
- 用户请求更新项目文档
- 用户通过 `/update-codemaps` 补充信息

## 执行流程

### 步骤 1：检查现有 CLAUDE.md

如果存在 CLAUDE.md：
1. 读取文件内容
2. 识别并**保留**以下用户自定义内容：
   - `<!-- user-custom -->` 和 `<!-- /user-custom -->` 之间的内容
   - 非标准章节的内容
3. 提取项目名称和概述作为基础

如果不存在，从头开始创建。

### 步骤 2：扫描项目结构

#### 技术栈检测（按文件存在判断）

| 文件 | 技术栈 |
|------|--------|
| `pom.xml` | Java/Maven |
| `build.gradle` / `build.gradle.kts` | Java/Groovy/Kotlin + Gradle |
| `package.json` | Node.js/JavaScript/TypeScript |
| `requirements.txt` / `pyproject.toml` / `setup.py` | Python |
| `go.mod` | Go |
| `Cargo.toml` | Rust |
| `Gemfile` | Ruby |
| `composer.json` | PHP |

#### 目录结构分析

识别并描述以下目录：
- 源码目录（`src/`, `lib/`, `app/`, `cmd/` 等）
- 测试目录（`test/`, `tests/`, `__tests__/` 等）
- 配置目录（`config/`, `configs/` 等）
- 资源目录（`resources/`, `assets/`, `static/` 等）
- 文档目录（`docs/`, `doc/` 等）

使用树形结构展示顶层目录，标注每个目录的用途。

#### 入口点识别

| 类型 | 文件 |
|------|------|
| 主入口 | `main.*`, `index.*`, `app.*`, `server.*` |
| 命令行入口 | `cmd/` 目录下的可执行入口 |
| 框架入口 | `manage.py`, `wsgi.py`, `Application.java` 等 |
| API 入口 | `routes/`, `api/`, `controllers/` 等 |

### 步骤 3：分析核心功能

扫描源码文件，识别项目的核心业务功能：

**分析策略**：
1. 读取主要模块/服务文件
2. 识别公开 API/接口/路由定义
3. 分析业务逻辑层的主要功能
4. 识别核心领域模型

**功能识别模式**：

| 语言/框架 | 扫描位置 |
|-----------|----------|
| REST API | 路由定义、Controller 方法 |
| GraphQL | schema 定义、resolver |
| CLI 工具 | 命令定义、flag 处理 |
| 前端应用 | 页面组件、路由配置 |
| 后端服务 | Service/UseCase 层 |

**输出格式**：
```markdown
## 核心功能

| 功能 | 说明 | 入口 |
|------|------|------|
| 用户认证 | 注册、登录、Token 管理 | auth/login, auth/register |
| 订单管理 | 创建、查询、取消订单 | orders/* |
| 支付处理 | 集成第三方支付 | payments/* |
```

### 步骤 4：提取核心依赖

从包管理文件提取关键依赖：

```markdown
## 核心依赖

| 依赖 | 版本 | 用途 |
|------|------|------|
| express | ^4.18 | Web 框架 |
| sequelize | ^6.32 | ORM |
| jsonwebtoken | ^9.0 | JWT 认证 |
```


### 步骤 5：生成完整 CLAUDE.md

使用以下结构：

```markdown
# 项目名称

> 一句话项目描述（从 README 或代码推断）

## 技术栈

- **语言**: [编程语言]
- **框架**: [主要框架]
- **构建工具**: [构建/包管理工具]
- **数据库**: [如有]

## 目录结构

```
project-root/
├── src/              # 源代码
│   ├── main/         # 主代码
│   └── test/         # 测试代码
├── config/           # 配置文件
├── docs/             # 文档
└── README.md
```

## 核心功能

| 功能 | 说明 | 入口 |
|------|------|------|
| 用户认证 | 注册、登录、Token 管理 | auth/* |
| 订单管理 | 创建、查询、取消订单 | orders/* |

## 关键入口点

| 入口 | 说明 |
|------|------|
| `src/main.py` | 应用主入口 |
| `src/api/users.py` | 用户相关 API |

## 核心依赖

| 依赖 | 用途 |
|------|------|
| express | Web 框架 |
| pg | PostgreSQL 客户端 |

<!-- user-custom -->
<!-- 在此标签之间添加自定义内容，更新时会被保留 -->
<!-- /user-custom -->
```

### 步骤 6：增量更新策略

对于已存在的 CLAUDE.md：

1. **保留** `<!-- user-custom -->` 区块内容
2. **更新** 以下标准章节：
   - 技术栈（重新检测）
   - 目录结构（重新扫描）
   - 核心功能（重新分析）
   - 关键入口点（重新识别）
   - 核心依赖（重新提取）
3. **合并** 项目名称和描述（优先保留用户描述）

### 步骤 7：处理用户补充信息

当用户通过 `/update-codemaps 添加xxx` 调用时：
1. 解析用户要添加的内容
2. 将内容添加到 `<!-- user-custom -->` 区块
3. 如果区块不存在，自动创建在文件末尾

## 用户自定义区块

使用特殊标记保护用户内容：

```markdown
<!-- user-custom -->
## 开发规范

### 命名约定
- 变量使用 camelCase
- 常量使用 UPPER_SNAKE_CASE

### API 约定
- RESTful 风格
- 使用 JSON 格式

<!-- /user-custom -->
```

**重要**：
- 此区块内容在更新时**始终保留**
- 用户可随时在此区块添加自定义信息
- AI 在更新 CLAUDE.md 时不应修改此区块

## 功能分析指南

### 如何识别核心功能

1. **API/路由层面**：统计路由，按功能分组
   ```python
   # 用户模块
   POST /api/users        # 创建用户
   GET  /api/users/:id   # 获取用户
   PUT  /api/users/:id   # 更新用户

   # 订单模块
   POST /api/orders       # 创建订单
   GET  /api/orders      # 列表订单
   ```

2. **业务逻辑层面**：查看 Service/Manager 层的主要方法
   - 按业务领域分组
   - 描述每个方法的核心职责

3. **前端应用**：查看页面/路由配置
   ```javascript
   /dashboard     # 仪表盘
   /users        # 用户管理
   /settings     # 系统设置
   ```

### 功能描述原则

- **简洁明了**：一句话说明功能
- **使用动词**：创建、查询、管理、处理等
- **包含范围**：用户管理包含增删改查
- **避免重复**：相同功能合并描述

### 示例

**输入**（代码片段）：
```python
# orders.py
class OrderService:
    def create_order(self, user_id, items):
        """创建订单"""
    def cancel_order(self, order_id):
        """取消订单"""
    def pay_order(self, order_id, payment_method):
        """支付订单"""
    def refund_order(self, order_id):
        """退款订单"""
```

**输出**：
```markdown
| 订单管理 | 创建、取消、支付、退款订单 | orders/* |
```

## 输出格式原则

- **简洁**：每个部分控制在合理长度
- **结构化**：使用表格和代码块提高可读性
- **AI 友好**：便于 AI 快速定位关键信息
- **Token 高效**：避免冗余描述

## 注意事项

- 不要扫描 `node_modules/`, `target/`, `build/` 等构建产物目录
- 不要包含敏感信息（密钥、密码等）
- 目录结构只展示 2-3 层，保持简洁
- 核心功能数量控制在 5-10 个，覆盖主要业务领域
- 如果项目过大，重点展示核心模块
