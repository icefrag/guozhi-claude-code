---
name: search-first
description: 编码前先研究的Java/Spring Boot工作流。在编写自定义代码之前，先搜索现有的工具、库和模式。调用researcher代理执行搜索。
origin: ECC
---

# /search-first — 编码前先研究

系统化"在实现前搜索现有解决方案"的工作流程。

## 触发条件

在以下场景使用此技能：
- 开始一个可能已有解决方案的新功能时
- 添加依赖或集成时
- 用户要求"添加X功能"而你准备写代码时
- 创建新的工具类、助手或抽象之前

## 工作流程

```
┌─────────────────────────────────────────────┐
│  1. 需求分析                                 │
│     定义所需功能，识别框架约束                  │
├─────────────────────────────────────────────┤
│  2. 并行搜索 (researcher代理)                │
│     ┌──────────┐ ┌──────────┐ ┌──────────┐  │
│     │  Maven  │ │  MCP /   │ │ GitHub /  │  │
│     │  Central│ │  Skills  │ │ 国内镜像  │  │
│     └──────────┘ └──────────┘ └──────────┘  │
├─────────────────────────────────────────────┤
│  3. 评估                                      │
│     对候选方案打分（功能性、维护性、社区、      │
│     文档、许可证、依赖兼容性）                 │
├─────────────────────────────────────────────┤
│  4. 决策                                      │
│     ┌─────────┐  ┌──────────┐  ┌─────────┐  │
│     │  采用   │  │  扩展    │  │  构建   │  │
│     │  现有   │  │  /包装   │  │  自定义 │  │
│     └─────────┘  └──────────┘  └─────────┘  │
├─────────────────────────────────────────────┤
│  5. 实施                                      │
│     添加依赖 / 配置MCP /                       │
│     编写最少自定义代码                         │
└─────────────────────────────────────────────┘
```

## 决策矩阵

| 信号 | 行动 |
|------|------|
| 完全匹配，维护良好，Apache 2.0/MIT许可 | **采用** — 直接添加依赖使用 |
| 部分匹配，良好基础 | **扩展** — 添加依赖 + 编写薄包装器 |
| 多个弱匹配 | **组合** — 组合2-3个小库 |
| 未找到合适的 | **构建** — 编写自定义，但受研究启发 |

## 使用方式

### 快速模式（内联）

在编写工具类或添加功能前，心中默过以下步骤：

0. 仓库中是否已存在？→ 先用 `grep` 搜索相关模块/测试
1. 这是常见问题吗？→ 搜索 Maven Central
2. 有MCP实现吗？→ 检查 `~/.claude/settings.json`
3. 有Skill吗？→ 检查 `skills/` 目录
4. GitHub上有实现/模板吗？→ 在编写全新代码前，先搜索维护良好的开源项目

### 完整模式（代理）

对于复杂功能，启动researcher代理：

```
Task(subagent_type="general-purpose", prompt="
  研究现有工具适用于: [功能描述]
  语言/框架: Java / Spring Boot
  约束条件: [如有]

  搜索: Maven Central、阿里云镜像、Maven仓库搜索
  返回: 结构化对比和推荐
")
```

## 搜索快捷方式（按类别）

### 开发工具链
- 代码规范 → `checkstyle`、`google-java-format`、`spotless`
- 单元测试 → `JUnit 5`、`TestNG`
- 断言库 → `assertj`、`hamcrest`
- Mock框架 → `Mockito`、`mockito-inline`
- 覆盖率 → `JaCoCo`、`Cobertura`
- 代码审查 → `SpotBugs`、`PMD`

### Spring Boot生态
- Web框架 → Spring Boot Starter Web
- 持久化 → MyBatis-Plus、Spring Data JPA
- 缓存 → Spring Cache、Redis (Redisson/Spring Data Redis)
- 消息队列 → RocketMQ、Kafka (Spring Kafka)、RabbitMQ
- 任务调度 → XXL-JOB、Quartz、Spring Task
- 认证授权 → Spring Security + OAuth2、JWT (jjwt)
- API文档 → springdoc-openapi (Swagger 3)、Knife4j
- 对象转换 → MapStruct、Hutool BeanUtil
- 日志处理 → Logback、SLF4J

### 工具类库
- 工具集 → `Hutool`（国产全能工具库）、Apache Commons Lang
- JSON处理 → `Jackson`（Spring默认）、`Fastjson2`
- HTTP客户端 → `OkHttp`、`Apache HttpClient`、`OpenFeign`
- 验证框架 → `Hibernate Validator`（Spring默认）
- Excel处理 → `EasyExcel`（阿里）、Apache POI
- PDF处理 → `iText`、`OpenPDF`
- 模板引擎 → `Thymeleaf`、`FreeMarker`

### 微服务生态
- 服务注册/发现 → Nacos、Sentinel
- 配置中心 → Nacos Config、Apollo
- API网关 → Spring Cloud Gateway、Kong
- 分布式事务 → Seata
- 链路追踪 → SkyWalking、Zipkin、Pinpoint

## 常用搜索源

| 类型 | 搜索源 | 网址 |
|------|--------|------|
| **Maven中央仓库** | Maven Central | search.maven.org |
| **国内镜像** | 阿里云 | maven.aliyun.com |
| **国内镜像** | 华为云 | repo.huaweicloud.com/repository/maven |
| **私有仓库** | Nexus | 私有Nexus服务器 |
| **版本查询** | Spring Initializr | start.spring.io |
| **依赖查询** | mvnrepository | mvnrepository.com |
| **GitHub搜索** | GitHub | github.com/search?q=java |

## 与其他代理的集成

### 与planner代理集成
planner应在第一阶段（架构评审）前调用researcher：
- Researcher识别可用工具
- Planner将其纳入实现计划
- 避免计划中"重复造轮子"

### 与architect代理集成
architect应咨询researcher：
- 技术栈决策
- 集成模式发现
- 现有参考架构

### 与search-first技能集成
与iterative-retrieval技能组合实现渐进式发现：
- 第一轮：广泛搜索（Maven Central、国内镜像、MCP）
- 第二轮：详细评估候选方案
- 第三轮：测试与项目约束的兼容性

## 示例

### 示例1："添加Redis缓存支持"
```
需求：为Spring Boot应用添加Redis缓存
搜索：mvnrepository "spring boot redis starter"
发现：spring-boot-starter-data-redis (官方维护，评分9/10)
      Redisson (功能更丰富，支持分布式锁)
决策：
  - 简单缓存需求：ADOPT — 直接引入 spring-boot-starter-data-redis
  - 需要分布式锁：ADOPT + EXTEND — 引入 Redisson + 封装工具类
结果：最小代码，Spring官方推荐方案
```

### 示例2："添加JWT认证"
```
需求：实现无状态JWT token认证
搜索：mvnrepository "java jwt library"
发现：jjwt (评分9/10，维护活跃，Apache 2.0)
      jose4j (评分8/10)
决策：ADOPT — 引入 jjwt + 配置JWT工具类
结果：Spring Security + JWT，生产验证方案
```

### 示例3："添加API文档Swagger"
```
需求：为REST API生成交互式文档
搜索：mvnrepository "springdoc openapi"
发现：springdoc-openapi-starter-webmvc-ui (评分9/10，OpenAPI 3标准)
      knife4j (评分8/10，国产增强版)
决策：
  - 标准需求：ADOPT — 直接引入 springdoc-openapi
  - 国内需求增强：ADOPT + EXTEND — 引入 knife4j
结果：几行配置，无自定义文档代码
```

### 示例4："添加Excel导入导出"
```
需求：支持大数据量Excel导出
搜索：mvnrepository "easyexcel"
发现：EasyExcel (阿里，评分9/10，专为大数据优化)
      Apache POI (评分8/10，功能全但内存消耗大)
决策：ADOPT — 引入 EasyExcel
结果：低内存高性能Excel处理
```

## 反模式

- **直接写代码**：不检查是否已存在就编写工具类
- **忽略MCP**：不检查MCP服务器是否已提供该功能
- **过度封装**：对库的封装过重，失去其原有优势
- **依赖膨胀**：为一个小功能引入大型依赖包
- **忽视版本兼容性**：不检查与Spring Boot主版本的兼容性
