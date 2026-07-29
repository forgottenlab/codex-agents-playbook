# Codex AGENTS Playbook

> 一套面向 Codex 的安全优先、证据驱动 `AGENTS.md` 配置集，包含可复用规则档位、隐私友好的公开流程与本地安装脚本。

[English](README.md) | [简体中文](README.zh-CN.md)

> [!IMPORTANT]
> 本项目来自真实开发经验，并非 OpenAI 官方项目，也不是操作系统级安全边界。任何规则和脚本都不能替代用户对实际命令、代码差异及运行环境的审查。

## ✨ 为什么创建这个项目

Codex 可以借助 `AGENTS.md` 理解如何检查仓库、运行哪些命令以及遵循哪些项目规范。因此，一套真正有用的规则不能只规定回答语气，还应明确任务范围、Git 安全、测试证据、隐私保护、持久上下文和最终交接方式。

本项目把这些要求整理成三个可复用档位，并采用“两层发布”流程：

```text
本机私有源文件
      ↓  脱敏并验证
公开规则模板
      ↓  配置并渲染
用户实际安装的 AGENTS.md
```

它不是所谓的“万能提示词”，而是一套有明确取舍的工程执行手册，目标是让智能体辅助开发更有边界、可审查、有证据并且能够恢复。

## 🚀 当前包含的内容

| 组件 | 用途 |
|---|---|
| `profiles/minimal` | 最基本的范围、敏感信息、Git、验证与交接保护 |
| `profiles/standard` | 推荐默认档，增加工作区、远程操作、文档及紧凑 `.ai` 规范 |
| `profiles/strict` | 完整档，增加授权标记、详细上下文治理、任务历史及界面历史恢复 |
| `scripts/Initialize-LocalWorkspace.ps1` | 创建被忽略的本机配置和可直接使用的私有源文件 |
| `scripts/Install-CodexAgents.ps1` | 渲染所选档位，备份旧文件后安装 |
| `scripts/New-PublicSnapshot.ps1` | 将本机严格版源文件转换为脱敏的公开模板 |
| `scripts/Test-PublicSafety.ps1` | 检查公开文件中是否残留已配置的私人值或常见凭据格式 |
| `scripts/Test-PowerShellSyntax.ps1` | 在不执行脚本的情况下解析全部 PowerShell 文件 |
| `scripts/Test-Repository.ps1` | 统一运行语法检查与公开安全检查 |
| `scripts/Bootstrap-CodexAgents.ps1` | 克隆或更新仓库，再调用可见的本地安装脚本 |
| `.local/` | 仅本机使用的私有配置与源文件，绝不能提交 |

## 🌐 为什么核心规则使用英文

可安装的规则层使用英文，是因为命令、路径、API 标识符、Git 术语、错误信息和上游工程文档主要使用英文。只维护一份英文核心规则，可以减少中英文混排歧义和双版本漂移；中文文档负责解释设计原因和使用流程。

这并不意味着英文天然能让模型表现更好。相比语言本身，明确的权限层级、有限范围、具体约束和可验证检查通常更重要。

## 🧭 三种规则档位

| 档位 | 适合场景 | 主要代价 |
|---|---|---|
| Minimal | 小仓库、实验、短任务 | 开销最低，但连续性能力有限 |
| Standard | 大多数个人项目和开源项目 | 安全、上下文与效率较平衡 |
| Strict | 长期、风险较高、多阶段或特别依赖恢复的任务 | 文件、流程和上下文开销更大 |

仓库根目录的 `AGENTS.md` 是维护本仓库时使用的规则；真正供用户安装的模板位于 `profiles/`。

## 📦 克隆后的快速使用

要求：

- Git
- PowerShell 7.2 或更高版本

```powershell
git clone https://github.com/forgottenlab/codex-agents-playbook.git
Set-Location .\codex-agents-playbook

pwsh -NoProfile -File .\scripts\Initialize-LocalWorkspace.ps1
```

初始化脚本会询问本机相关信息，只把真实值写入 Git 已忽略的 `.local/` 目录，生成本机严格版源文件，并可选择立即安装某个档位。

稍后单独安装：

```powershell
pwsh -NoProfile -File .\scripts\Install-CodexAgents.ps1 `
  -Profile standard `
  -SettingsPath .\.local\user-settings.psd1
```

默认安装位置：

```text
%USERPROFILE%\.codex\AGENTS.md
```

如果旧文件已存在，脚本会先生成带时间戳的备份。

## 🔐 本机私有源文件与公开快照

真实路径和个人偏好只应存在于：

```text
.local/user-settings.psd1
.local/AGENTS.source.md
```

这两个文件均被 Git 忽略。**绝对不要使用 `git add -f` 强制提交 `.local/`。**

有意修改本机严格版源文件后，运行：

```powershell
pwsh -NoProfile -File .\scripts\New-PublicSnapshot.ps1
pwsh -NoProfile -File .\scripts\Test-PublicSafety.ps1
```

随后检查实际差异：

```powershell
git status --short
git diff -- profiles/strict/AGENTS.template.md
git diff --check
```

完整占位符说明、手动替换命令和发布前检查见 [隐私与脱敏说明](docs/PRIVACY-AND-SANITIZATION.zh-CN.md)。

## 🧩 必须由用户替换的占位符

| 占位符 | 应替换为 |
|---|---|
| `{{WORKSPACE_ROOT}}` | 用户自己的 Codex 工作区根目录 |
| `{{PROJECTS_DIR}}` | 长期项目目录 |
| `{{AUTOMATIONS_DIR}}` | 自动化项目目录 |
| `{{SANDBOX_DIR}}` | 临时实验目录 |
| `{{ARCHIVED_DIR}}` | 归档项目目录 |
| `{{TEMPLATES_DIR}}` | 模板目录 |
| `{{USER_PROFILE}}` | 当前操作系统用户目录 |
| `{{GITHUB_USERNAME}}` | GitHub 用户名或组织名 |
| `{{PREFERRED_LANGUAGE}}` | 面向用户解释时使用的语言 |

仓库中的模板应当保留这些占位符；安装到本机的最终文件则不能残留任何占位符。

## ⚡ 为当前目录直接生成本机配置

例如将工作区根目录设置为 `D:\Codex`：

```powershell
pwsh -NoProfile -File .\scripts\Initialize-LocalWorkspace.ps1 `
  -WorkspaceRoot 'D:\Codex' `
  -GitHubUsername 'forgottenlab' `
  -PreferredLanguage 'Simplified Chinese' `
  -Profile strict `
  -InstallGlobal
```

脚本会自动推导：

```text
D:\Codex\01-Projects
D:\Codex\02-Automations
D:\Codex\03-Sandbox
D:\Codex\04-Archived
D:\Codex\_templates
```

这些真实值仅进入 `.local/` 和本机安装文件，不应进入公开提交。

## 🛡️ 授权标记不是安全沙箱

严格档中的 `ALLOW_DEPLOY=true` 等标记只是任务级、提示词层面的可见授权信号。它们不会授予操作系统权限、绕过 Codex 沙箱、验证用户身份，也不能自动证明命令安全。仍须审查实际命令、平台权限和用户最新的明确指令。

## 🧪 发布前验证

只要修改了规则模板、脚本、示例或隐私文档，提交前都应运行：

```powershell
pwsh -NoProfile -File .\scripts\Test-Repository.ps1
```

仓库测试会先解析全部 PowerShell 脚本，再运行公开安全检查。当 `.local/user-settings.psd1` 存在时，脚本会检查公开文件中是否残留其中记录的真实值；同时也会检查常见私钥和凭据格式。它只是额外防线，不能替代专业的密钥扫描和人工审查。

## 🧱 仓库结构

```text
codex-agents-playbook/
├─ AGENTS.md
├─ README.md
├─ README.zh-CN.md
├─ LICENSE
├─ CHANGELOG.md
├─ SECURITY.md
├─ CONTRIBUTING.md
├─ profiles/
│  ├─ minimal/AGENTS.template.md
│  ├─ standard/AGENTS.template.md
│  └─ strict/AGENTS.template.md
├─ scripts/
├─ examples/
├─ docs/
└─ .local/                 # Git 忽略，仅本机私有
```

## 🗺️ 后续路线

- 为三个档位增加基于场景的行为测试；
- 增加 macOS 和 Linux 渲染、安装脚本；
- 提供带校验和的版本化 Bootstrap 发布；
- 探索规则片段组合，减少完整文件重复；
- 通过 CI 检查占位符、Markdown 链接和敏感字面量；
- 为已安装的本机规则提供版本化迁移说明。

路线图只是建议方向，不代表已经实现或承诺交付。

## 🤝 参与贡献

高质量规则修改应说明：真实失败模式、受影响环境、建议措辞、可能代价以及验证方法。不要仅仅因为一条规则“看起来更严格”就加入；每条规则都会占用上下文并降低灵活性。

提交修改前请阅读 [CONTRIBUTING.md](CONTRIBUTING.md)。

## 📜 许可证

MIT License，详见 [LICENSE](LICENSE)。

## 🙏 项目来源

这套工作流来自 ChatGPT 与 Codex 在本地开发、自动化、文档、Git、测试和长期项目恢复中的反复实践。
