# nbl.superpowers 开发项目

## 项目概述

本项目是 Claude Code Skills 的设计与开发仓库，基于官方 superpowers 扩展。

### 规则文件路径区分

修改 rules 目录下的文件时，**必须**使用项目相对路径，**禁止**使用全局路径：

| 路径类型 | 路径 | 用途 |
|---------|------|------|
| ✅ 项目规则 | `rules/common/xxx.md` | 本项目专用规则 |
| ❌ 全局规则 | `~/.claude/rules/common/xxx.md` | 所有项目共享规则 |

### 本地开发参考

本项目基于官方 superpowers 技能体系扩展开发，本地开发参考源码地址：

- 官方 superpowers 源码：`D:\workspace\superpowers`
- skills 目录：`D:\workspace\superpowers\skills`
