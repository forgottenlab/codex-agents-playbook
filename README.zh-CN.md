# Codex AGENTS Playbook

> 一套可复用的 Codex 规则档位及源自实际输入的 ChatGPT 配套指令，用于范围明确、有证据可审查的工程工作流。

[English](README.md) | [简体中文](README.zh-CN.md)

> [!IMPORTANT]
> 本项目由社区维护，带有明确的个人工作流取舍，并非 OpenAI 官方项目。指令不提供安全沙箱，不能替代命令审查、平台权限和备份。

## ✨ 为什么创建这个项目

ChatGPT 准备边界明确的任务；Codex 检查实际检出目录、执行任务，再返回证据供审查。职责分离可以区分方案和仓库事实，避免把简单命令扩展成智能体流程，并让后续工作更容易审查。

这些是工作流职责，不改变平台指令优先级。Codex 仍可规划完成已授权任务所需的本地执行步骤。

## 🤝 ChatGPT / Codex 配套工作流

| 系统 | 负责内容 |
|---|---|
| ChatGPT | 准确性、对话边界、Direct Shell / Codex 路由、架构讨论、模型与推理强度建议、Prompt 设计、跨会话规划和结果审查 |
| Codex | 仓库检查、有限修改、上下文相关命令、工作树保护、测试、项目事实隔离和简洁事实交接 |

少量确定性命令通常使用 Direct Shell Mode，提供可复制命令、用途和预期结果。依赖仓库的调查、修改、工作树保护及测试闭环使用 Codex Task Mode。若拆分会损害安全性或复现性，审计中的简单命令仍可由 Codex 一起执行。

模型和 Reasoning 建议必须放在**可复制执行 Prompt 之外**。它们由用户在界面选择，Prompt 不要求 Codex 自行切换模型。

详见[配套工作流与 12 项一致性检查](docs/PAIRED-WORKFLOW.zh-CN.md)。

## 🚀 当前包含的内容

| 组件 | 用途 |
|---|---|
| `profiles/minimal` | 基本范围、隐私、Git、验证与交接保护 |
| `profiles/standard` | 推荐默认档，增加工作区、远程操作、文档及紧凑上下文规范 |
| `profiles/strict` | 模块化入口及 `personal-rules/`，覆盖路由、Git 审查、验证、上下文、历史、恢复和交接 |
| `chatgpt/custom-instructions.zh-CN.txt` | 从用户提供的 ChatGPT 源文件生成，可直接复制的纯指令 |
| `scripts/Initialize-LocalWorkspace.ps1` | 创建被忽略的私有配置及渲染后的 Strict 源文件包 |
| `scripts/Install-CodexAgents.ps1` | 渲染档位，在替换前备份每个已存在的目标文件 |
| `scripts/New-PublicSnapshot.ps1` | 对 Strict 或 ChatGPT 私有输入脱敏，先检查全部候选内容再写入 |
| `scripts/Test-Repository.ps1` | 运行语法、隐私、产物与隔离工作流检查 |
| `scripts/Bootstrap-CodexAgents.ps1` | 可见的克隆、更新及初始化流程，不使用下载后直接执行的管道 |
| `.local/` 与 `.ai/` | 被忽略的私有输入、测试夹具和本地执行记录 |

仓库根目录的 `AGENTS.md` 用于维护本仓库。供用户安装的规则位于 `profiles/`。

## 🌐 规则语言

可安装的 Codex 规则以英文为准，面向用户的解释使用配置语言。ChatGPT 配套指令保留实际源文件的简体中文。中英文文档说明相同的安装方法和边界；语言本身不保证模型可靠执行。

## 🧭 档位与个人取舍

| 档位 | 适合场景 | 主要代价 |
|---|---|---|
| Minimal | 小仓库、短任务 | 流程最少，连续性有限 |
| Standard | 大多数个人和开源项目 | 安全与上下文较平衡 |
| Strict | 持续、多阶段或依赖恢复的工作 | 文件更多，需明确按条件读取模块 |

Minimal、Standard、Strict 是**安装时选择的不同档位**，不会同时生效或自动切换；Direct Shell Mode 和 Codex Task Mode 则是**按任务判断的执行路由**，并非另外两种安装档位或界面模式。

Strict 安装一个入口及八份配套文件：**七个按任务触发的规则模块**和一个供人工维护的 `INDEX.md`。Markdown 链接**不会自动导入模块**：入口要求 Codex 在对应场景用文件读取工具加载。必需模块缺失时停止依赖它的工作。`INDEX.md` 不是执行前置步骤。

工作区布局、中文解释、ChatGPT/Codex 分工、授权标记、详细历史，以及 Strict 的两轮自动修复预算，都是个人工作流选择，采用前应审阅。Minimal / Standard 保留原有模板，不承诺提供 Strict 的详细路由和历史规则。

## 📦 安装 Codex 档位

要求 Git、PowerShell 7.2 或更高版本。本轮检查使用 PowerShell 7.6.3，未单独验证最低版本。

```powershell
git clone https://github.com/forgottenlab/codex-agents-playbook.git
Set-Location .\codex-agents-playbook
pwsh -NoProfile -File .\scripts\Initialize-LocalWorkspace.ps1
```

只需初始化一次。如果 `.local/user-settings.psd1` 已存在，应检查并保留，不要仅为照做指南而添加 `-Force`。初始化只创建私有输入，除非明确提供 `-InstallGlobal`，否则不安装全局规则。

检查配置中的路径、身份和语言，再预览并安装：

```powershell
pwsh -NoProfile -File .\scripts\Install-CodexAgents.ps1 `
  -Profile strict -SettingsPath .\.local\user-settings.psd1 -WhatIf

pwsh -NoProfile -File .\scripts\Install-CodexAgents.ps1 `
  -Profile strict -SettingsPath .\.local\user-settings.psd1
```

推荐较轻的默认档可选择 `standard`。默认目标是 `%USERPROFILE%\.codex\AGENTS.md`；通过 `-TargetPath` 指向其他 Codex home 或本地预览路径。Strict 的模块安装在目标文件旁的 `personal-rules/`。不要只复制 Strict 入口。

所有将被替换的已有文件使用同一个“时间戳加随机后缀”备份，其他文件保留。安装由连续写入组成，不具备事务性；若中断，先检查备份，将受影响入口与模块作为一组恢复，再重试。

检查已有 `AGENTS.override.md` 及自定义 `CODEX_HOME`，它们会影响实际读取哪个全局文件。安装后启动新的 Codex 会话，核验有效指令来源。参见[官方指令发现说明](https://learn.chatgpt.com/docs/agent-configuration/agents-md)。

## 安装 Grok Build 规则

省略 `-Client` 时沿用 Codex 和默认的 Standard 档。Grok Build 目前只支持全局 Strict 布局。提供私有设置后，可先预览实际目标目录。

```powershell
pwsh -NoProfile -File .\scripts\Install-CodexAgents.ps1 `
  -Client Grok -Profile strict -SettingsPath .\.local\user-settings.psd1 -WhatIf
```

移除 `-WhatIf` 后执行安装。可用 `-TargetDirectory` 指定夹具或其他 Grok home，省略时先读取 `GROK_HOME`，再回退到用户的 `.grok` 目录。Grok 原生发现 `rules/playbook-entry.md`，七份详细模块位于 `playbook/modules/`，由入口提示按需读取。Skills、信任设置及用户自己的规则单独管理。每次有变更的安装都会在规则目录外记录恢复批次。详见[冲突与批次恢复](docs/CUSTOMIZATION.zh-CN.md#grok-strict-更新与恢复)。

## 💬 复制 ChatGPT 指令

打开 [custom-instructions.zh-CN.txt](chatgpt/custom-instructions.zh-CN.txt)，全选文件内容并粘贴到 ChatGPT 自定义指令字段。只复制文件正文；文件没有外围说明或代码围栏。

生成器按本次发布的 5,000 字符预算检查，使用包含空白的保守 UTF-16 计数。实际源文件留有余量。请核验自己账户提供的字段；本仓库不测试实时 ChatGPT 界面，也不修改账户设置。

保存前审阅语言、工作流及模型选择建议。配套指令使用能力类别，不固定某一时点的模型目录。

## 🔐 私有源文件到公开快照

```text
已安装或本机 Codex 指令                    用户提供的 ChatGPT 指令
             ↓ 私下复制、核对                         ↓
.local/AGENTS.source.md + personal-rules/    .local/chatgpt-custom-instructions.source.txt
             ↓ 脱敏并审查                             ↓
profiles/strict/ 入口及模块                  chatgpt/custom-instructions.zh-CN.txt
             ↓ 渲染
用户自己的 Codex 本机安装
```

真实环境值放在 `.local/user-settings.psd1`。核对已有私有源文件前先备份。已安装入口和模块应**一起复制并审阅**；初始化只渲染公开模板，不会发现已安装文件中的改动。

```powershell
pwsh -NoProfile -File .\scripts\New-PublicSnapshot.ps1
pwsh -NoProfile -File .\scripts\New-PublicSnapshot.ps1 -Kind ChatGPT
pwsh -NoProfile -File .\scripts\Test-Repository.ps1
git diff --check
git status --short
git diff
git diff --cached
```

ChatGPT 输入缺失或为空时，生成失败并保留原公开输出。生成器只去除排版分隔线及 Markdown 标题标记、统一换行并替换已配置的私人值，不会编造当前指令。如果脱敏后可复制文本中仍有占位符，将停止并要求人工审阅。

转换边界及私有源流程见[隐私与脱敏说明](docs/PRIVACY-AND-SANITIZATION.zh-CN.md)。

## 🧩 定制与占位符

| 占位符 | 配置内容 |
|---|---|
| `{{WORKSPACE_ROOT}}` | 工作区根目录 |
| `{{PROJECTS_DIR}}` | 长期项目 |
| `{{AUTOMATIONS_DIR}}` | 持久自动化 |
| `{{SANDBOX_DIR}}` | 临时实验 |
| `{{ARCHIVED_DIR}}` | 归档 |
| `{{TEMPLATES_DIR}}` | 可复用模板 |
| `{{USER_PROFILE}}` | 安装器提供的当前操作系统用户目录 |
| `{{GITHUB_USERNAME}}` | 模板使用时的 GitHub 身份 |
| `{{PREFERRED_LANGUAGE}}` | 面向用户解释的语言 |

从[配置示例](examples/user-settings.example.psd1)开始，在私有配置中填写自己的值。公开 Codex 模板保留占位符，渲染到本机后不应残留。公开仓库地址有意保留本项目身份，下游 fork 应审阅。参见[定制指南](docs/CUSTOMIZATION.zh-CN.md)。

## 🛡️ 授权与隐私边界

Strict 的 `ALLOW_REMOTE_READONLY=true`、`ALLOW_REMOTE_VALIDATE=true`、`ALLOW_DEPLOY=true` 和 `ALLOW_SECRET_FILE_MOVE=true` 都是任务策略信号，不会授予系统权限、验证账户或覆盖平台控制。每个标记只适用于它声明的范围。

不要公开 `.local/`、`.ai/`、渲染后的私人文件、凭据、会话文件或私有执行记录。正则扫描不能证明没有个人信息，仍需独立检查姓名、路径、主机、邮箱、项目引用和链接。

## 🧪 验证

```powershell
pwsh -NoProfile -File .\scripts\Test-Repository.ps1
```

验证套件解析 `.ps1` / `.psm1`，扫描公开文件，检查已记录占位符、配套模块、ChatGPT 长度和相对文件链接，然后在被忽略的 `.local/validation-*` 中验证安装与生成流程。测试夹具保留供审查。测试不会安装实际全局规则或访问远程服务。

一致性结论是记录在[配套工作流](docs/PAIRED-WORKFLOW.zh-CN.md)中的人工判断，自动检查不能证明模型遵守规则。Windows 夹具覆盖了 Grok 安装中断及批次恢复。外部链接可用性、ChatGPT 界面行为、Codex 安装中断及其他文件系统故障仍在此项验证范围之外。

## 🧱 仓库结构

```text
codex-agents-playbook/
├─ AGENTS.md                     # 仓库维护规则
├─ README.md / README.zh-CN.md
├─ profiles/
│  ├─ grok/strict/playbook-entry.md  # Grok 原生入口
│  ├─ minimal/AGENTS.template.md
│  ├─ standard/AGENTS.template.md
│  └─ strict/
│     ├─ AGENTS.template.md
│     └─ personal-rules/
├─ chatgpt/custom-instructions.zh-CN.txt
├─ scripts/
├─ examples/
├─ docs/
├─ .local/                       # 忽略的私有源和测试夹具
└─ .ai/                          # 忽略的本地连续性记录
```

## 🗺️ 后续路线

基于场景的模型行为检查、macOS/Linux 安装器、版本化 Bootstrap 校验和及迁移工具，仍属于可能的后续工作。路线图不授权实现。

## 🤝 参与贡献

参见 [CONTRIBUTING.md](CONTRIBUTING.md)。规则修改应说明观察到的失败模式、成本及验证方式。保持范围聚焦，审查公开差异后只暂存明确文件。

## 📜 许可证

MIT License，详见 [LICENSE](LICENSE)。
