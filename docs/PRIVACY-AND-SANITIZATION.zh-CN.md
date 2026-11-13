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
.local/personal-rules/
.local/chatgpt-custom-instructions.source.txt
```

仓库通过 `.gitignore` 排除了 `.local/`。不要使用 `git add -f` 强制添加它。

## 4. 为自己的电脑生成配置

只需初始化一次，检查并调整配置后，再执行第 5 节安装。如果 `.local/user-settings.psd1` 已存在，跳过初始化并保留原配置；不要仅为照做本指南而使用 `-Force`。

交互式：

```powershell
pwsh -NoProfile -File .\scripts\Initialize-LocalWorkspace.ps1
```

直接提供参数：

```powershell
pwsh -NoProfile -File .\scripts\Initialize-LocalWorkspace.ps1 `
  -WorkspaceRoot 'D:\Codex' `
  -GitHubUsername 'example-user' `
  -PreferredLanguage 'Simplified Chinese'
```

以上两个示例只在 `.local/` 中生成本机配置及私有 strict 源文件，不安装全局规则。全局档位在第 5 节选择。添加 `-InstallGlobal` 会立即调用同一个安装器安装；此处有意省略，避免重复安装。

## 5. 配置占位符替换并安全安装

使用正式安装器，不要直接写入全局文件。手动编辑第 4 节生成的 `.local/user-settings.psd1`；如果该文件不存在，可以根据 `examples/user-settings.example.psd1` 创建。保留已有本机配置。文件内容为 PowerShell 数据哈希表，例如：

```powershell
@{
    WorkspaceRoot      = 'D:\Codex'
    ProjectsDir        = 'D:\Codex\01-Projects'
    AutomationsDir     = 'D:\Codex\02-Automations'
    SandboxDir         = 'D:\Codex\03-Sandbox'
    ArchivedDir        = 'D:\Codex\04-Archived'
    TemplatesDir       = 'D:\Codex\_templates'
    GitHubUsername     = 'example-user'
    PreferredLanguage  = 'Simplified Chinese'
}
```

将示例路径、GitHub 身份和语言替换为自己的值。各目录可以独立配置；省略或留空的目录设置会根据 `WorkspaceRoot` 推导。`WorkspaceRoot`、`GitHubUsername` 和 `PreferredLanguage` 必须存在且非空。安装器从 `$env:USERPROFILE` 获取 `{{USER_PROFILE}}` 的值。私人值应保存在 `.local/`，不要写入已提交的模板。

在仓库根目录运行：

```powershell
pwsh -NoProfile -File .\scripts\Install-CodexAgents.ps1 `
  -Profile standard `
  -SettingsPath .\.local\user-settings.psd1
```

默认目标为 `%USERPROFILE%\.codex\AGENTS.md`。其他位置通过 `-TargetPath` 指定包含父目录的路径。安装器在修改目标前验证完整渲染文件包，拒绝残留占位符。Strict 安装入口及同级 `personal-rules/` 下八份配套文件。所有将被替换的已有文件先使用同一个“时间戳加随机后缀”备份，备份失败则终止安装，其他文件保留。写入按顺序进行，不具备事务性；应将受影响入口与模块的备份一起保留，安装中断后恢复该组文件。避免并发安装，不要绕过正式流程直接覆盖。

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

## 9. 模块化与 ChatGPT 发布审查

已安装入口及配套模块只是来源输入，准备发布时不要覆盖实际全局文件。
核对已有忽略源文件前先备份；若私有源和配置原本不存在，应记录事实并基于
已核验输入建立它们，不能声称已备份一个原本不存在的源文件。

模块化快照相对于私有入口读取每个必需模块，替换已配置值，规范化过时的候选
及暂存元数据，并将人工索引译为英文。同时在 Strict Git 模块保留 Minimal
明确禁止未授权历史重写和分支删除的规则。这是有限的档位继承保护，
不修改实际安装来源。审查全部生成模块，不要只看入口。

从实际提供的文本生成配套指令：

```powershell
pwsh -NoProfile -File .\scripts\New-PublicSnapshot.ps1 -Kind ChatGPT
```

没有来源就不生成配套指令。生成器去除排版分隔线及标题标记，保留来源语言，
按本次 5,000 字符预算检查，并在替换公开输出前拒绝空文本、超长内容、
敏感格式及残留占位符。

扫描器支持内存候选内容，以便在写入前检查。公开扫描排除被忽略的
`.local/` 和 `.ai/`，本地任务证据不得公开。检查 `git ls-files .local .ai`
及暂存差异：若忽略目录已被误跟踪，仍应阻止发布。另行人工审阅姓名、
用户目录、私有项目引用、主机、邮箱及私有链接，字面量和正则扫描并不完整。

只有源自实际输入的指令产物、经过审阅的工具及文档属于候选发布文件。
公开项目地址有意代表本项目，不应作为下游用户身份。实时账户设置及私有
执行记录不是发布产物。参见[配套一致性检查](PAIRED-WORKFLOW.zh-CN.md)。
