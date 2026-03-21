# 命名规范

> Java Spring Boot项目的命名约定，包括类命名、方法命名、参数命名等。

## Entity命名规范 (NON-NEGOTIABLE)

- **命名规则**: Entity类名使用数据库表名的大驼峰(PascalCase)形式，**无需任何后缀**
- **表名转类名**: 数据库表名使用snake_case，Entity类名使用PascalCase
- **禁止**: Entity类名添加Entity、DO、PO、Model等后缀

| 数据库表名 | Entity类名 |
|-----------|-----------|
| user | User |
| order_info | OrderInfo |
| tenant_config | TenantConfig |
| user_login_log | UserLoginLog |

## Service接口命名规范 (NON-NEGOTIABLE)

- **命名规则**: Service接口使用业务名称+Service后缀
- **禁止**: 使用I前缀、使用缩写、添加不必要的中间词、添加Interface后缀

| 正确示例 | 错误示例 |
|---------|---------|
| OrderService | IOrderService |
| UserService | UsrSvc |
| TenantService | TenantInterface |

## 枚举类命名规范 (NON-NEGOTIABLE)

- **适用范围**: 所有包含code(编码)和desc(描述)字段的经典枚举类型
- **统一接口**: 必须实现`com.guozhi.api.framework.model.enums.IEnum<T>`接口
- **类名格式**: 类名使用`Enum`后缀，如`GenderEnum`、`UserStatusEnum`
- **常量名**: 使用全大写下划线分隔
- **字典类枚举**: 必须使用`XxxEnum`格式命名，禁止使用不带Enum后缀的命名(如`TenantStatus`)
- **禁止**: 枚举类内部提供静态工具方法

## 操作人参数命名规范 (NON-NEGOTIABLE)

- **统一命名**: 操作人字段必须命名为`operatorId`，类型为`Long`
- **适用场景**: 审批操作、数据修改、状态变更、删除操作
- **禁止**: 使用`operator`、`operateId`、`operUserId`、`auditBy`、`modifierId`等其他命名
- **禁止**: 使用String类型存储操作人名称，使用Integer类型操作人ID

## 事件对象命名规范 (NON-NEGOTIABLE)

- **命名格式**: 所有事件对象的类名必须以`Event`结尾，使用`[业务操作]Event`格式
- **无需继承**: 事件对象无需继承Spring的`ApplicationEvent`类
- **禁止**: 事件对象类名不以Event结尾，事件对象继承ApplicationEvent类

## 模块间模型命名规范

### api模块

- **Req对象**: 以`Req`结尾，批量操作添加`Batch`前缀
- **Resp对象**: 以`Resp`结尾，批量操作添加`Batch`前缀
- **Query对象**: 以`Query`结尾

### 分页参数命名 (NON-NEGOTIABLE)

- **pageNo**: 页码字段，第一页值为1
- **pageSize**: 每页条数字段
- **禁止**: 使用page、pageNum等其他命名

## 包命名规范

- **基础包名**: `com.guozhi.api.[服务名称].[模块名称]`
- **命名风格**: 遵循阿里巴巴Java开发手册
- **类名**: 大驼峰
- **方法名和变量名**: 小驼峰
- **常量**: 全大写下划线分隔
