# logback 日志路由权威参考

> 来源：`config/src/main/resources/logback.xml` + `logback.properties`。配置若变动，以代码为准。
> SKILL.md 只放了常用速查；需要精确判断「某条日志去了哪个文件」时读这里。

## 变量（logback.properties）

| 变量 | 值 | 含义 |
|------|----|------|
| loggerRoot | `./logs` | 日志根目录（容器内被 JVM 启动参数覆盖为 `/data/log`） |
| loggerAppName | `guozhi-common-platform` | 决定目录名 + 日志里的 service 字段 |
| logLevel | `INFO` | root 级别。**DEBUG/TRACE 默认不输出**——排查时别去找 DEBUG 日志 |
| traceIdName / spanIdName | `%X{X-B3-TraceId}` / `%X{X-B3-SpanId}` | Spring Cloud Sleuth 全链路 |

## Appender（产出哪些文件）

| appender | 文件 | 格式 | 收什么级别 |
|----------|------|------|-----------|
| STDOUT | （控制台） | 文本 | 全部 |
| LOGSTASH | `logstash.log` | **JSON**（供 ELK） | 全部 |
| ERROR | `error.log` | 文本 | 仅 ERROR |
| WARN | `warn.log` | 文本 | WARN 及以上 |
| TIME | `time.log` | 文本 | 全部 |
| INFO | `info.log` | 文本 | 全部 |
| APP | `app.log` | 文本 | 全部 |

**没有 request / gc / start / framework 的 appender。** `request.log`/`framework.log` 是废弃残留；`gc.log`/`start.log` 是 JVM 启动参数输出的，不归 logback 管。

## Logger 路由（additivity=false，不向 root 冒泡）

| logger（按 logger 名匹配） | 写入的 appender |
|---------------------------|----------------|
| `com.guozhi.api.commonplatform`（本项目业务代码） | APP + ERROR + WARN + LOGSTASH |
| `com.guozhi.api.framework`（框架） | APP + ERROR + WARN + LOGSTASH |
| `REQUEST-LOGGER`（请求日志） | APP + ERROR + WARN + LOGSTASH |
| `TIME-LOGGER`（耗时） | TIME |
| `ERROR-LOGGER` | ERROR + STDOUT |
| `WARN-LOGGER` | WARN |
| root（兜底，未被上面命中的，主要是第三方库） | INFO + ERROR + WARN + STDOUT + LOGSTASH |

**关键推导**：

- **业务代码的日志（任何级别）必进 `app.log`**——这是最全的业务日志源，排查首选。
- ERROR 额外进 error.log，WARN 额外进 warn.log（便于按级别快查）。
- 所有日志同时进 `logstash.log`（JSON，给 ELK 采集）。
- `info.log` 主要收走 root 的第三方库 INFO，**业务代码 INFO 不在这里**（业务 INFO 在 app.log）——别去 info.log 找业务日志。

## 日志行格式

### 纯文本文件（app/error/warn/info/time.log）

```
[时间] - 级别 - logger - appName - class[line] - traceId - spanId - thread - msg
```

- 用 ` - ` 分隔，共 9 段。
- **traceId 是第 6 段**，可直接 `grep '<traceId>'` 串全链路。
- **中文正常显示**，可 grep 中文关键字（如 `grep '审批' app.log`）。

### logstash.log（JSON）

```json
{"@timestamp":"<UTC>","logtime":"<本地+8>","level":"INFO","service":"...",
 "trace":"<traceId>","span":"<spanId>","thread":"...","class":"...[line]",
 "rest":"<消息>","exception":"<异常栈>"}
```

- 按 traceId 串：`grep '"trace":"<traceId>"'`
- `logtime` 是本地时间（+8），`@timestamp` 是 UTC——排查时间用 logtime。
- **坑：`rest` 字段的中文被 unicode 转义**（如「请求结束」存成 `请求结束`）。**grep 中文关键字在 logstash.log 里无效**，要 grep 中文只能用 app/error 等纯文本文件。按 traceId / 英文关键字则没问题。

## 归档

所有 logback 文件**按小时滚动**为 `archive/<file>.log.<yyyyMMddHH>.gz`，保留 **72 小时**（约 3 天）。更早的本地没有，只能去 ELK。
