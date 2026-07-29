# 隐私与脱敏说明

[English](PRIVACY-AND-SANITIZATION.md) | [简体中文](PRIVACY-AND-SANITIZATION.zh-CN.md)

## 1. 三类数据必须区分

1. **真正的秘密信息**：API Key、密码、Token、私钥、Cookie、私有链接、生产凭据。原则上连 `.local/` 也不应长期保存这些内容。
2. **本机与个人环境信息**：本地路径、操作系统账户目录、私有仓库名、内部主机以及个人工作流偏好。只保存在 `.local/`，公开前必须脱敏。
3. **有意公开的身份信息**：公开 GitHub 用户名、项目名或公开仓库地址。仓库作者可以有意保留，但下游用户仍应能够修改。

## 2. 公开模板中的占位符

| 占位符 | 含义 | 本机示例 |
|---|---|---|
| `{{WORKSPACE_ROOT}}` | 工作区根目录 | `D:\Codex` |
| `{{PROJECTS_DIR}}` | 长期项目目录 | `D:\Codex\01-Projects` |
| `{{AUTOMATIONS_DIR}}` | 自动化项目目录 | `D:\Codex\02-Automations` |
| `{{SANDBOX_DIR}}` | 临时实验目录 | `D:\Codex\03-Sandbox` |
| `{{ARCHIVED_DIR}}` | 归档项目目录 | `D:\Codex\04-Archived` |
| `{{TEMPLATES_DIR}}` | 模板目录 | `D:\Codex\_templates` |
| `{{USER_PROFILE}}` | 当前操作系统用户目录 | `C:\Users\example-user` |
| `{{GITHUB_USERNAME}}` | GitHub 用户名或组织名 | `example-user` |
| `{{PREFERRED_LANGUAGE}}` | 面向用户解释时的语言 | `Simplified Chinese` |

`profiles/` 中的公开模板应当保留占位符；安装到本机的最终文件不能残留占位符。

## 3. 真实值保存在哪里

```text
.local/user-settings.psd1
.local/AGENTS.source.md
```

仓库通过 `.gitignore` 排除了 `.local/`。不要使用 `git add -f` 强制添加它。

## 4. 为自己的电脑生成配置

交互式：

```powershell
pwsh -NoProfile -File .\scripts\Initialize-LocalWorkspace.ps1
```

直接提供参数：

```powershell
pwsh -NoProfile -File .\scripts\Initialize-LocalWorkspace.ps1 `
  -WorkspaceRoot 'D:\Codex' `
  -GitHubUsername 'example-user' `
  -PreferredLanguage 'Simplified Chinese' `
  -Profile standard `
  -InstallGlobal
```

## 5. 手动替换占位符的 PowerShell

优先使用仓库安装脚本；需要手动操作时，可复制下面的命令：

```powershell
$TemplatePath = '.\profiles\standard\AGENTS.template.md'
$OutputPath = Join-Path $env:USERPROFILE '.codex\AGENTS.md'

$WorkspaceRoot = 'D:\Codex'
$Replacements = [ordered]@{
    '{{WORKSPACE_ROOT}}'     = $WorkspaceRoot
    '{{PROJECTS_DIR}}'       = Join-Path $WorkspaceRoot '01-Projects'
    '{{AUTOMATIONS_DIR}}'    = Join-Path $WorkspaceRoot '02-Automations'
    '{{SANDBOX_DIR}}'        = Join-Path $WorkspaceRoot '03-Sandbox'
    '{{ARCHIVED_DIR}}'       = Join-Path $WorkspaceRoot '04-Archived'
    '{{TEMPLATES_DIR}}'      = Join-Path $WorkspaceRoot '_templates'
    '{{USER_PROFILE}}'       = $env:USERPROFILE
    '{{GITHUB_USERNAME}}'    = 'example-user'
    '{{PREFERRED_LANGUAGE}}' = 'Simplified Chinese'
}

$Content = Get-Content -LiteralPath $TemplatePath -Raw
foreach ($Entry in $Replacements.GetEnumerator()) {
    $Content = $Content.Replace($Entry.Key, [string]$Entry.Value)
}

$Unresolved = [regex]::Matches($Content, '\{\{[A-Z0-9_]+\}\}') |
    ForEach-Object Value |
    Sort-Object -Unique
if ($Unresolved) {
    throw "仍有未替换占位符：$($Unresolved -join ', ')"
}

New-Item -ItemType Directory -Path (Split-Path -Parent $OutputPath) -Force | Out-Null
Set-Content -LiteralPath $OutputPath -Value $Content -Encoding utf8
```

## 6. 从本机源文件生成公开快照

```powershell
pwsh -NoProfile -File .\scripts\New-PublicSnapshot.ps1
pwsh -NoProfile -File .\scripts\Test-PublicSafety.ps1
```

脱敏脚本会按照“路径越长越先替换”的顺序，将配置中的真实值转换为占位符；如果仍发现已配置的私人字面量，就会失败而不是静默输出。

## 7. 提交前必须检查

```powershell
git status --short --branch
git diff --check
git diff
git diff --cached
```

只暂存明确的公开文件，不得暂存 `.local/`。

## 8. 需要诚实说明的限制

- 字面量与正则检查无法数学意义上证明仓库没有秘密信息；
- 提示词中的授权标记不是操作系统权限，也不是 Codex 沙箱；
- 本机路径通常不等于密钥，但它属于环境信息，不应强加给其他用户；
- 高风险仓库仍应人工检查，并使用专门的 Secret Scanner。
