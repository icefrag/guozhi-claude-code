---
name: verification-loop
description: "Claude Code会话的综合验证系统。"
origin: ECC
---

# 验证循环技能

Claude Code会话的综合验证系统。

## 何时使用

在以下场景调用此技能：
- 完成功能或重大代码变更后
- 创建PR之前
- 确保质量门禁通过时
- 重构完成后

## 验证阶段

### 阶段1：构建验证
```bash
# 检查项目是否构建成功
mvn clean compile 2>&1 | tail -20
# 或者
gradle build 2>&1 | tail -20
```

如果构建失败，停止并在继续之前修复。

### 阶段2：类型检查
```bash
# Java项目使用Maven编译检查
mvn compile 2>&1 | head -30

# 或使用Gradle
gradle compileJava 2>&1 | head -30
```

报告所有编译错误。在继续之前修复关键错误。

### 阶段3：代码规范检查
```bash
# 使用Maven Checkstyle插件
mvn checkstyle:check 2>&1 | head -30

# 或使用SpotBugs
mvn spotbugs:check 2>&1 | head -30

# 或使用Gradle
gradle checkstyleMain 2>&1 | head -30
```

### 阶段4：测试套件
```bash
# 运行测试并生成覆盖率报告
mvn test jacoco:report 2>&1 | tail -50

# 或使用Gradle
gradle test jacocoTestReport 2>&1 | tail -50

# 检查覆盖率阈值
# 目标：最低80%
```

报告：
- 总测试数：X
- 通过：X
- 失败：X
- 覆盖率：X%

### 阶段5：安全扫描
```bash
# 检查硬编码密钥
grep -rn "sk-" --include="*.java" . 2>/dev/null | head -10
grep -rn "api_key" --include="*.java" . 2>/dev/null | head -10
grep -rn "password" --include="*.java" . 2>/dev/null | head -10
grep -rn "secret" --include="*.java" . 2>/dev/null | head -10

# 检查System.out.println（应使用日志框架）
grep -rn "System.out.println" --include="*.java" src/ 2>/dev/null | head -10
grep -rn "System.err.println" --include="*.java" src/ 2>/dev/null | head -10
grep -rn "e.printStackTrace()" --include="*.java" src/ 2>/dev/null | head -10

# 使用OWASP依赖检查
mvn dependency-check:check 2>&1 | tail -20
```

### 阶段6：差异审查
```bash
# 显示变更内容
git diff --stat
git diff HEAD~1 --name-only
```

审查每个变更文件的：
- 非预期变更
- 缺失的错误处理
- 潜在的边界情况

## 输出格式

运行所有阶段后，生成验证报告：

```
验证报告
==================

构建：     [通过/失败]
类型检查： [通过/失败] (X个错误)
代码规范： [通过/失败] (X个警告)
测试：     [通过/失败] (X/Y通过，Z%覆盖率)
安全：     [通过/失败] (X个问题)
差异：     [X个文件变更]

总体：     [准备就绪/未准备就绪] 可提交PR

需修复的问题：
1. ...
2. ...
```

## 持续模式

对于长时间会话，每15分钟或重大变更后运行验证：

```markdown
设置心理检查点：
- 完成每个方法后
- 完成一个类后
- 移至下一个任务前

运行：/verify
```

## 与钩子集成

此技能与PostToolUse钩子互补，但提供更深入的验证。
钩子立即捕获问题；此技能提供全面的审查。
