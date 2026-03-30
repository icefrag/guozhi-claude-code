# Worktree 脚本化重构设计

## 问题背景

当前 `nbl.using-git-worktrees` 技能依赖 AI 逐条执行 git 命令来创建 worktree，这种方式存在以下问题：

1. **不稳定** - AI 容易遗漏步骤，在复杂状态（残留目录、已有分支、非git仓库）下处理不当
2. **不可靠** - 状态太多，边界情况难以覆盖
3. **难调试** - 问题发生后难以定位是哪一步出错
4. **重复逻辑** - 每次调用都需要重新执行多步流程

## 解决方案：脚本化

将所有复杂的 worktree 创建/清理逻辑下沉到独立的 shell 脚本文件中，AI 只需检测平台后调用相应脚本一次即可完成所有操作。

## 架构设计

### 目录结构

```
skills/nbl.using-git-worktrees/
├── SKILL.md                           # 简化的协调层，不包含具体命令逻辑
└── scripts/
    ├── create-worktree.sh              # bash版本 (Linux/macOS/Git-Bash)
    ├── create-worktree.ps1             # PowerShell版本 (原生Windows)
    ├── cleanup-worktree.sh             # 清理脚本 - bash
    ├── cleanup-worktree.ps1            # 清理脚本 - PowerShell
    └── lib/
        ├── common.sh                   # bash公共函数库
        └── common.ps1                  # PowerShell公共函数库
```

### 接口设计

#### create-worktree - 创建/恢复worktree

**签名：**
```bash
./scripts/create-worktree.sh <base_name> [task_id] [output_file]
./scripts/create-worktree.ps1 <base_name> [task_id] [output_file]
```

**参数：**
- `base_name`: 必填，功能名称 (例如: `fix-worktree-issue`)
- `task_id`: 可选，parallel模式的任务ID，添加后使用task后缀命名
- `output_file`: 可选，输出JSON结果到文件

**命名规则：**
| 调用 | 分支名 | 路径 |
|------|--------|------|
| `create-worktree.sh user-auth` | `feature/user-auth` | `.worktrees/user-auth` |
| `create-worktree.sh user-auth 1` | `feature/user-auth-task1` | `.worktrees/user-auth-task1` |
| `create-worktree.sh user-auth 3` | `feature/user-auth-task3` | `.worktrees/user-auth-task3` |

**返回值：**
- `exit code 0`: 成功
- `exit code 非0`: 失败，错误信息输出到stderr

**JSON输出格式（当指定output_file）：**

成功：
```json
{
  "success": true,
  "worktree_path": ".worktrees/user-auth",
  "branch_name": "feature/user-auth",
  "is_new": true,
  "message": "Created new worktree"
}
```

失败：
```json
{
  "success": false,
  "error": "Failed to create worktree: permission denied",
  "exit_code": 1
}
```

#### cleanup-worktree - 清理worktree

**签名：**
```bash
./scripts/cleanup-worktree.sh <base_name> [task_id] [--force]
./scripts/cleanup-worktree.ps1 <base_name> [task_id] [-Force]
```

**参数：**
- `base_name`: 必填，功能名称
- `task_id`: 可选，parallel模式的任务ID
- `--force` / `-Force`: 可选，强制删除跳过合并检查

**合并检查流程：**

```
1. 检查是否有未合并的提交
   unmerged=$(git log main..<branch_name> --oneline)

2. 如果有未合并提交且无 --force → 报错退出
   {
     "success": false,
     "error": "unmerged commits detected",
     "unmerged_commits": ["commit 1", "commit 2", ...],
     "message": "Use --force to delete anyway"
   }
   exit 1

3. 如果有未合并提交且有 --force → 打印警告，继续删除
   echo "⚠️ Warning: proceeding with unmerged commits"
```

**清理流程：**
```
1. 如果有未合并提交 → 按上述规则处理
2. 移除worktree: git worktree remove --force <path>
3. 删除分支: git branch -d <branch_name>
4. 成功输出:
   {
     "success": true,
     "message": "Worktree and branch cleaned up"
   }
```

## 核心处理流程

### create-worktree 流程

```
1. 解析参数 (base_name, [task_id], [output_file])

2. 计算分支名和路径
   - 无task_id: branch=feature/<base_name>, path=.worktrees/<base_name>
   - 有task_id: branch=feature/<base_name>-task<task_id>, path=.worktrees/<base_name>-task<task_id>

3. 检测是否为git仓库
   - 如果不是git仓库: 自动执行 git init + 初始提交，然后继续

4. 安全检查 - 确保 .worktrees/ 在 .gitignore 中
   git check-ignore -q .worktrees
   如果没有忽略 → 自动添加 .worktrees/ 到 .gitignore 并提交

5. 创建/恢复worktree

   尝试创建: git worktree add <path> -b <branch>
   如果成功 → 完成

   如果失败 → 尝试智能恢复：
   - 如果目录已存在 → 复用已有目录
   - 如果分支已存在但目录不存在 → re-attach worktree 到已有分支
   - 其他错误 → 输出错误信息，exit 1

6. 输出结果
   - 如果指定output_file → 输出JSON到文件
   - 否则输出人类可读的状态消息
```

### 错误处理策略

| 场景 | 处理策略 |
|------|----------|
| 非git仓库 | 自动 `git init` + 初始提交，继续 |
| 目录已存在 | 复用，不报错 |
| 分支已存在 | 重新attach，继续 |
| 磁盘满/权限不足 | 报错退出，需要用户干预 |
| .worktrees 未被gitignore | 自动添加，提交，继续 |

## SKILL.md 变化

**简化后的流程：**

1. 解析参数 (base_name, task_id)
2. 确定输出位置
3. 检测当前平台 (bash/powershell)
4. 调用对应脚本
5. 读取脚本输出
6. 报告结果给用户

原来的所有多行命令序列都删除，简化为一次脚本调用。

## 跨平台支持

遵循 spec-kit 模式：
- **bash脚本** (.sh) - 支持 Linux / macOS / Git-Bash on Windows
- **PowerShell脚本** (.ps1) - 支持原生 Windows PowerShell

两个脚本逻辑完全一致，只有语法差异。

## 受益

1. **更稳定** - 脚本在任何环境执行逻辑一致，不受AI记忆影响
2. **可测试** - 脚本可以单独测试和调试
3. **可维护** - 逻辑集中在脚本文件中，便于修改和验证
4. **边界覆盖** - 所有已知边界情况（非git仓库、已有分支、已有目录）都在脚本中统一处理
5. **AI责任清晰** - AI只做协调和调用，不用记忆复杂命令序列
