# 测试覆盖率

分析测试覆盖率，识别缺口，生成缺失的测试以达到80%+覆盖率。

## 步骤1：检测测试框架

| 标识 | 覆盖率命令 |
|------|-----------|
| `pom.xml` with JaCoCo | `mvn test jacoco:report` |
| `build.gradle` with JaCoCo | `./gradlew test jacocoTestReport` |

## 步骤2：分析覆盖率报告

1. 运行覆盖率命令
2. 解析输出（target/site/jacoco/jacoco.xml 或终端输出）
3. 列出**低于80%覆盖率**的文件，按最差优先排序
4. 对于每个覆盖率不足的文件，识别：
   - 未测试的方法
   - 缺失的分支覆盖（if/else、switch、异常路径）
   - 死代码（膨胀分母）

## 步骤3：生成缺失测试

对于每个覆盖率不足的文件，按以下优先级生成测试：

1. **成功路径** — 核心功能使用有效输入
2. **异常处理** — 无效输入、缺失数据、网络失败
3. **边界案例** — 空集合、null、边界值（0、-1、MAX_VALUE）
4. **分支覆盖** — 每个if/else、switch case

### 测试生成规则

- 测试放在对应目录：`src/main/java/.../Service.java` → `src/test/java/.../ServiceTest.java`
- 使用项目现有的测试模式（import风格、断言库、Mock方式）
- Mock外部依赖（数据库、外部API、文件系统）
- 每个测试应该独立 — 测试之间不共享可变状态
- 测试命名描述性：`should_return_discount_when_order_amount_exceeds_threshold`

## 步骤4：验证

1. 运行完整测试套件 — 所有测试必须通过
2. 重新运行覆盖率 — 验证改进
3. 如果仍低于80%，重复步骤3处理剩余缺口

## 步骤5：报告

显示前后对比：

```
覆盖率报告
──────────────────────────────────────
文件                          之前   之后
DiscountServiceImpl.java      45%    88%
OrderServiceImpl.java         32%    82%
UserServiceImpl.java          55%    85%
──────────────────────────────────────
总体覆盖率:                    67%    84%  ✅
```

## Java Web重点关注区域

### Service层测试

- 复杂分支的方法（高圈复杂度）
- 异常处理器和catch块
- 跨服务使用的工具方法
- 业务规则验证

### Controller层测试

- 请求参数校验
- 响应格式验证
- 异常情况处理

### Manager层测试

- 外部服务调用Mock
- 重试逻辑验证
- 超时处理

### 边界案例

- null
- 空字符串
- 空集合
- 零
- 负数
- 最大值/最小值

## JUnit 5 + Mockito测试模板

```java
@ExtendWith(MockitoExtension.class)
class XxxServiceImplTest {

    @InjectMocks
    private XxxServiceImpl xxxService;

    @Mock
    private DependencyService dependencyService;

    @Test
    void should_return_success_when_valid_input() {
        // Given
        InputDTO input = InputDTO.builder()
            .field("value")
            .build();
        when(dependencyService.method()).thenReturn(expected);

        // When
        OutputDTO result = xxxService.method(input);

        // Then
        assertNotNull(result);
        assertEquals("expected", result.getField());
    }

    @Test
    void should_throw_exception_when_input_is_null() {
        // When & Then
        assertThrows(IllegalArgumentException.class, () -> {
            xxxService.method(null);
        });
    }
}
```

## 覆盖率目标

- **最低80%** 适用于所有代码
- **必需100%** 适用于：
  - 财务计算
  - 认证逻辑
  - 安全关键代码
  - 核心业务逻辑

## JaCoCo报告位置

```bash
# HTML报告
target/site/jacoco/index.html

# XML报告
target/site/jacoco/jacoco.xml

# CSV报告
target/site/jacoco/jacoco.csv
```

## Maven命令

```bash
# 运行测试并生成覆盖率报告
mvn test jacoco:report

# 运行指定测试类
mvn test -Dtest=XxxServiceImplTest jacoco:report

# 查看覆盖率摘要
mvn jacoco:report
```
