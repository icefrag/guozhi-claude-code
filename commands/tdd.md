---
description: 强制执行测试驱动开发工作流。搭建接口，首先生成测试，然后实现最小程序使测试通过。确保80%以上覆盖率。
---

# TDD命令

此命令调用**tdd-guide agent**来强制执行测试驱动开发方法论。

## 此命令的作用

1. **搭建接口** - 首先定义接口/契约
2. **首先生成测试** - 编写使测试失败（RED）
3. **实现最小程序** - 编写刚好使测试通过的程序（GREEN）
4. **重构** - 在保持测试通过的情况下改进代码（REFACTOR）
5. **验证覆盖率** - 确保80%以上测试覆盖率

## 何时使用

当以下情况使用`/tdd`：
- 实现新功能
- 添加新方法/服务
- 修复Bug（先编写重现Bug的测试）
- 重构现有代码
- 构建核心业务逻辑

## 工作原理

tdd-guide agent 将会：

1. **定义接口** 输入/输出
2. **编写将要失败的测试**（因为代码还不存在）
3. **运行测试** 并验证它们因正确原因失败
4. **编写最小实现** 使测试通过
5. **运行测试** 并验证通过
6. **重构** 代码同时保持测试绿色
7. **检查覆盖率** 如果低于80%则添加更多测试

## TDD循环

```
RED → GREEN → REFACTOR → REPEAT

RED:      编写一个失败的测试
GREEN:    编写最小代码使其通过
REFACTOR: 改进代码，保持测试通过
REPEAT:   下一个功能/场景
```

## 示例用法

```
用户: /tdd 我需要一个计算订单折扣的方法

代理 (tdd-guide):
# TDD会话: 订单折扣计算器

## 步骤1: 定义接口 (SCAFFOLD)

```java
// src/main/java/com/guozhi/order/service/DiscountService.java
package com.guozhi.order.service;

import com.guozhi.order.dto.OrderCalculateDTO;
import com.guozhi.order.model.entity.OrderEntity;

public interface DiscountService {
    /**
     * 计算订单折扣金额
     */
    Double calculateDiscount(OrderCalculateDTO orderCalculate);
}
```

## 步骤2: 编写失败测试 (RED)

```java
// src/test/java/com/guozhi/order/service/impl/DiscountServiceImplTest.java
package com.guozhi.order.service.impl;

import com.guozhi.order.dto.OrderCalculateDTO;
import com.guozhi.order.service.DiscountService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.Collections;

import static org.junit.jupiter.api.Assertions.*;

@ExtendWith(MockitoExtension.class)
class DiscountServiceImplTest {

    @InjectMocks
    private DiscountServiceImpl discountService;

    @Mock
    private SomeExternalService externalService;

    @BeforeEach
    void setUp() {
    }

    @Test
    void shouldReturnHighDiscountForLargeOrder() {
        // Given
        OrderCalculateDTO orderCalculate = new OrderCalculateDTO();
        orderCalculate.setTotalAmount(1000.0);
        orderCalculate.setProductCount(10);
        orderCalculate.setItemDetails(Collections.emptyList());

        // When
        Double discount = discountService.calculateDiscount(orderCalculate);

        // Then
        assertNotNull(discount);
        assertTrue(discount > 0);
        assertTrue(discount <= 100); // 折扣不超过总金额
    }

    @Test
    void shouldReturnNoDiscountForSmallOrder() {
        // Given
        OrderCalculateDTO orderCalculate = new OrderCalculateDTO();
        orderCalculate.setTotalAmount(50.0);
        orderCalculate.setProductCount(1);
        orderCalculate.setItemDetails(Collections.emptyList());

        // When
        Double discount = discountService.calculateDiscount(orderCalculate);

        // Then
        assertEquals(0.0, discount, 0.01);
    }

    @Test
    void shouldHandleNullInput() {
        // When
        Exception exception = assertThrows(IllegalArgumentException.class, () -> {
            discountService.calculateDiscount(null);
        });

        // Then
        assertTrue(exception.getMessage().contains("orderCalculate"));
    }
}
```

## 步骤3: 运行测试 - 验证失败

```bash
mvn test -Dtest=DiscountServiceImplTest
```

FAILURE DiscountServiceImplTest
  ✕ shouldReturnHighDiscountForLargeOrder
    java.lang.ClassNotFoundException: Class 'DiscountService' not found
1 test failed, 0 passed

✅ 测试按预期失败。准备实现。

## 步骤4: 实现最小代码 (GREEN)

```java
// src/main/java/com/guozhi/order/service/impl/DiscountServiceImpl.java
package com.guozhi.order.service.impl;

import com.guozhi.order.dto.OrderCalculateDTO;
import com.guozhi.order.service.DiscountService;
import com.guozhi.api.framework.utils.Assert;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class DiscountServiceImpl implements DiscountService {

    @Override
    public Double calculateDiscount(OrderCalculateDTO orderCalculate) {
        // 处理空输入异常
        Assert.notNull(orderCalculate, "orderCalculate不能为空");

        // 简单的折扣计算逻辑
        if (orderCalculate.getTotalAmount() == null || orderCalculate.getTotalAmount() <= 0) {
            return 0.0;
        }

        // 订单金额超过500才有折扣
        if (orderCalculate.getTotalAmount() >= 500) {
            return orderCalculate.getTotalAmount() * 0.1; // 10%折扣
        }

        return 0.0;
    }
}
```

## 步骤5: 运行测试 - 验证通过

```bash
mvn test -Dtest=DiscountServiceImplTest

PASS DiscountServiceImplTest
  ✓ shouldReturnHighDiscountForLargeOrder (15 ms)
  ✓ shouldReturnNoDiscountForSmallOrder (12 ms)
  ✓ shouldHandleNullInput (8 ms)

3 tests passed
```

✅ 所有测试通过！

## 步骤6: 重构 (改进)

```java
// src/main/java/com/guozhi/order/service/impl/DiscountServiceImpl.java - 重构为更好的结构
package com.guozhi.order.service.impl;

import com.guozhi.order.dto.OrderCalculateDTO;
import com.guozhi.order.service.DiscountService;
import com.guozhi.api.framework.utils.Assert;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class DiscountServiceImpl implements DiscountService {

    private static final double MIN_ORDER_AMOUNT_FOR_DISCOUNT = 500.0;
    private static final double DISCOUNT_RATE = 0.1;
    private static final double MAX_DISCOUNT_AMOUNT = 100.0;

    @Override
    public Double calculateDiscount(OrderCalculateDTO orderCalculate) {
        Assert.notNull(orderCalculate, "orderCalculate不能为空");
        validateInput(orderCalculate);

        double discount = calculateBaseDiscount(orderCalculate);
        return applyDiscountLimits(discount, orderCalculate.getTotalAmount());
    }

    private void validateInput(OrderCalculateDTO orderCalculate) {
        if (orderCalculate.getTotalAmount() == null || orderCalculate.getTotalAmount() < 0) {
            throw new IllegalArgumentException("订单金额不能为负数或null");
        }
    }

    private double calculateBaseDiscount(OrderCalculateDTO orderCalculate) {
        double totalAmount = orderCalculate.getTotalAmount();
        if (totalAmount < MIN_ORDER_AMOUNT_FOR_DISCOUNT) {
            return 0.0;
        }

        return totalAmount * DISCOUNT_RATE;
    }

    private double applyDiscountLimits(double discount, double totalAmount) {
        // 折扣不能超过订单金额且不超过最大折扣额
        return Math.min(discount, Math.min(totalAmount, MAX_DISCOUNT_AMOUNT));
    }
}
```

## 步骤7: 验证测试仍然通过

```bash
mvn test -Dtest=DiscountServiceImplTest

PASS DiscountServiceImplTest
  ✓ shouldReturnHighDiscountForLargeOrder (14 ms)
  ✓ shouldReturnNoDiscountForSmallOrder (11 ms)
  ✓ shouldHandleNullInput (9 ms)

3 tests passed
```

✅ 重构完成，测试仍然通过！

## 步骤8: 检查覆盖率

```bash
mvn test jacoco:report

File                    | % Stmts | % Branch | % Funcs | % Lines
------------------------|---------|----------|---------|--------
DiscountServiceImpl.java|  100    |   100    |  100    |  100

Coverage: 100% ✅ (目标: 80%)
```

✅ TDD会话完成！
```

## TDD最佳实践

**应该做:**
- ✅ 首先编写测试，在任何实现之前
- ✅ 运行测试并在实现前验证它们失败
- ✅ 编写使测试通过的最小程序
- ✅ 仅在测试绿色后重构
- ✅ 添加边界案例和错误场景
- ✅ 目标为80%+覆盖率（关键代码为100%）

**不要做:**
- ❌ 在测试之前编写实现
- ❌ 在每次更改后跳过运行测试
- ❌ 一次编写太多代码
- ❌ 忽略失败的测试
- ❌ 测试实现细节（测试行为）
- ❌ Mock所有内容（首选集成测试）

## 要包含的测试类型

**单元测试**（方法级）：
- 成功路径场景
- 边界案例（空、null、最大值）
- 错误条件
- 边界值

**集成测试**（组件级）：
- API端点
- 数据库操作
- 外部服务调用
- Spring事务测试

## 覆盖率要求

- **最低80%** 适用于所有代码
- **必需100%** 适用于：
  - 财务计算
  - 认证逻辑
  - 安全关键代码
  - 核心业务逻辑

## 重要注意事项

**强制执行**: 必须在实现前编写测试。TDD循环是：

1. **RED** - 编写失败的测试
2. **GREEN** - 实现使其通过
3. **REFACTOR** - 改进代码

永远不要跳过RED阶段。绝不在测试前编写代码。

## 与其他命令的集成

- 首先使用`/plan`理解要构建什么
- 使用`/tdd`用测试实现
- 如果发生构建错误使用`/build-fix`
- 使用`/code-review`审查实现
- 使用`/test-coverage`验证覆盖率

## 相关代理

此命令调用ECC提供的`tdd-guide`代理。

相关的`tdd-workflow`技能也与ECC捆绑。

对于手动安装，源文件位于：
- `agents/tdd-guide.md`
- `skills/tdd-workflow/SKILL.md`