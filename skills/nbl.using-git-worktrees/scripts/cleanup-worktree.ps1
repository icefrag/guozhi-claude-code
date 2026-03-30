#!/usr/bin/env pwsh
#===============================================================================
# cleanup-worktree.ps1 - 清理 git worktree (PowerShell)
#===============================================================================

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$ScriptDir/lib/common.ps1"

#-------------------------------------------------------------------------------
# 参数解析
#-------------------------------------------------------------------------------

param(
    [Parameter(Mandatory=$true, Position=0)]
    [string]$BaseName,

    [Parameter(Position=1)]
    [string]$TaskId = "",

    [switch]$Force
)

if ($BaseName -eq "-h" -or $BaseName -eq "--help") {
    Write-Host @"
用法: cleanup-worktree.ps1 <base_name> [task_id] [-Force]

清理 git worktree 和相关分支。

参数:
  base_name    功能名称 (例如: user-auth)
  task_id      可选，parallel 模式的任务 ID
  -Force       可选，强制删除跳过合并检查

示例:
  cleanup-worktree.ps1 user-auth
  cleanup-worktree.ps1 user-auth 1 -Force
"@
    exit 0
}

# 计算分支名和路径
$names = Compute-Names -BaseName $BaseName -TaskId $TaskId
$BranchName = $names.BranchName
$WorktreePath = $names.WorktreePath

Write-Host "🧹 清理 worktree: $WorktreePath (分支: $BranchName)"

#-------------------------------------------------------------------------------
# 前置检查
#-------------------------------------------------------------------------------

Ensure-GitRepo

#-------------------------------------------------------------------------------
# 检查未合并的提交
#-------------------------------------------------------------------------------

# 获取默认分支名
try {
    $baseBranch = git symbolic-ref refs/remotes/origin/HEAD 2>$null
    $baseBranch = $baseBranch -replace 'refs/remotes/origin/', ''
} catch {
    $baseBranch = "main"
}

# 检查未合并的提交
$unmerged = git log "$baseBranch..$BranchName" --oneline 2>$null
if ($unmerged) {
    if (-not $Force) {
        Write-Host "⚠️  检测到未合并的提交:"
        Write-Host $unmerged
        Write-Host ""
        Write-Host "请使用 -Force 参数强制删除"

        @{
            success = $false
            error = "unmerged commits detected"
            unmerged_commits = @($unmerged -split "`n")
            message = "Use --force to delete anyway"
        } | ConvertTo-Json -Compress

        exit 1
    } else {
        Write-Host "⚠️  警告: 继续删除未合并的提交"
    }
}

#-------------------------------------------------------------------------------
# 清理 worktree
#-------------------------------------------------------------------------------

if (Test-Path $WorktreePath) {
    $removeResult = git worktree remove --force $WorktreePath 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Worktree 已删除"
    } else {
        Write-Host "⚠️  删除 worktree 失败，跳过"
    }
} else {
    Write-Host "📂 Worktree 目录不存在，跳过删除"
}

#-------------------------------------------------------------------------------
# 删除分支
#-------------------------------------------------------------------------------

$branchExists = git show-ref --verify --quiet "refs/heads/$BranchName" 2>$null
if ($branchExists) {
    $deleteResult = git branch -d $BranchName 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ 分支 $BranchName 已删除"
    } else {
        Write-Host "⚠️  分支删除失败 (可能未合并)，尝试强制删除"
        git branch -D $BranchName 2>$null
        Write-Host "✅ 分支 $BranchName 已强制删除"
    }
} else {
    Write-Host "📂 分支不存在，跳过删除"
}

Write-Host "✅ Worktree 清理完成"
