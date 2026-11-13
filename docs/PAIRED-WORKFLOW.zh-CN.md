# ChatGPT / Codex 配套工作流

[English](PAIRED-WORKFLOW.md) | [简体中文](PAIRED-WORKFLOW.zh-CN.md)

## 范围与证据

本次比较[从实际源文件生成的 ChatGPT 指令](../chatgpt/custom-instructions.zh-CN.txt)与 [Strict 入口](../profiles/strict/AGENTS.template.md)及其配套模块。Minimal / Standard 是较轻的替代档位，不是等价副本。

Codex 来源为实际已安装的模块化入口及同级模块，复制到私有目录后用于发布。ChatGPT 来源为用户提供的本地文本文件。文件来源不能证明实时 ChatGPT 账户中启用了哪些设置。Owner 已明确授权公开模块化 Strict 结构。发布准备阶段没有重装全局规则；随后经单独授权，仅修正了本机入口的状态措辞，配套模块保持不变。

生成器规范化入口中过时的候选标题及仅适用于暂存目录的描述，将人工模块索引译为英文，替换已配置的环境值并统一换行。execution 模块中过时的候选版安装限制改为通用的“不得修改无关配置”边界。Strict 同时在 Git 模块保留 Minimal 已有的禁止未授权历史重写和分支删除条款，满足档位继承要求。ChatGPT 只去除排版分隔线、标题标记及行尾排版空白，不改变任务规则。私有原始输入保留。

## 职责边界

ChatGPT 判断对话边界，准备已授权的执行任务，讨论架构、拆分任务、在 Prompt 外推荐模型和推理设置、跨会话规划并审查结果。

Codex 验证本地事实、有限修改并提供命令及测试证据。本地执行计划不接管对话路由或长期架构职责。ChatGPT 源文件中的“架构设计”Codex 触发项指依赖仓库的调查、可行性核验或实现工作；概念架构讨论仍由 ChatGPT 与用户负责。重大决策仍需确认。

比较另一个项目不授权检查或修改它。另一个独立实现任务应明确指定仓库。

## 一致性检查

分类为 CONSISTENT、INTENTIONAL_SEPARATION、MINOR_DRIFT、CONFLICT、NEEDS_USER_DECISION。详细程度不同本身不构成冲突。

| 检查项 | 分类 | 证据及实际含义 |
|---|---|---|
| Conversation Scope / Project Context Isolation | INTENTIONAL_SEPARATION | ChatGPT 的对话边界章节负责讨论路由；Strict 入口和 execution 模块独立核验并隔离项目事实。Codex 不决定使用哪个 ChatGPT 对话。 |
| Direct Shell 定义及例外 | CONSISTENT | 两边都按是否独立于仓库、是否确定性工作判断。Strict 入口允许明显简单命令不加载无关模块，高风险保护仍有效。 |
| Codex Task 触发条件 | INTENTIONAL_SEPARATION | ChatGPT 路由实际仓库工作，execution.md 再检查上下文依赖。架构讨论及用户决策保留在 ChatGPT，Codex 负责证据与已授权执行。 |
| 混合任务 | CONSISTENT | 有价值时拆分简单前置步骤；拆分损害安全性、复现性或验证时不机械拆分。 |
| Windows 约定 | CONSISTENT | 都默认 PowerShell；明确 Linux/macOS 时用相应 Shell，路径及标识符保留原样。 |
| 高风险操作 | INTENTIONAL_SEPARATION | ChatGPT 提出只读检查、dry-run 和备份；Strict 定义执行确认、环境配置边界及明确远程标记。需要时应将相应标记写入已授权任务。 |
| Git 与工作树保护 | CONSISTENT | ChatGPT 将需保护工作树的任务交给 Codex；Strict 入口及 git-safety.md 要求检查状态与差异、保留无关工作并控制暂存范围。 |
| Prompt 所有权 | CONSISTENT | ChatGPT 在实施已定案后生成任务专用 Prompt；Strict 入口和 handoff.md 不自动输出下一轮完整 Prompt，保留用户明确要求时的例外。 |
| Model / Reasoning 分离 | INTENTIONAL_SEPARATION | ChatGPT 在任务 Prompt 外推荐界面选项；Codex 负责执行，不选择模型，Strict 不重复维护模型目录。 |
| 任务历史 | INTENTIONAL_SEPARATION | ChatGPT 不为简单命令创建产物；Strict history.md 定义非平凡任务连续性、Direct Shell 例外、只读限制及隐私。临时实验需要持久化授权。 |
| 最终交接 | CONSISTENT | ChatGPT 审查结果；Strict handoff.md 要求改动文件、行为、命令、验证、剩余风险及一个简短后续目标。未运行的检查仍属未验证。 |
| 跨项目事实隔离 | CONSISTENT | ChatGPT 在综合讨论中区分项目事实；Strict 独立核验检出目录，不无证据转用其他项目的版本、测试或已接受决策。 |

结果：**7 项 CONSISTENT、5 项 INTENTIONAL_SEPARATION**。本次比较没有未解决的 CONFLICT 或 NEEDS_USER_DECISION。旧候选元数据属于 MINOR_DRIFT，已在公开输出中规范化。这是人工内容审查结论，不是模型行为保证。

## 安装迁移

原公开 Strict 是单文件 Complete Edition。模块化版本把保护条款保留在入口，按触发条件读取详细流程。通过[安装器](../scripts/Install-CodexAgents.ps1)一起安装入口及八份配套文件。

1. 检查配置和已有指令覆盖文件。
2. 用 `-WhatIf` 及明确的 `-TargetPath` 预览本地安装。
3. 单独授权实际全局安装。
4. 将入口及受影响模块的备份作为一组保留；安装中断时恢复该组文件。脚本不具备事务性。
5. 新建会话，核验有效指令及必需模块可读性。

其他自定义模块保留。切换到较轻档位不删除 `personal-rules/`；过时文件应另行审查，不自动清理。本次发布准备不安装全局规则。

## 审查场景与限制

仓库套件检查脚本语法、隐私模式、占位符、相对文件链接及隔离的安装和生成行为。工作流覆盖三个档位、备份、无关文件保护、无写入预览、模块缺失、Strict 可复现渲染、ChatGPT 输入缺失／为空／超长，以及写入前拒绝敏感内容。

规则审查采用以下人工场景：

- 单次版本检查返回命令，不创建任务归档；
- 审计中的同一条简单 Git 命令可以作为证据收集执行；
- 项目比较区分事实，不自动切换对话；
- 完整实现 Prompt 不包含模型和推理界面配置；
- 严格只读任务不写上下文或历史；
- 必需模块缺失时停止依赖工作，不静默读取其他副本。

以上场景按规则文本审阅，未执行模型评估或实时 ChatGPT 界面测试，也不是自动语义一致性证明。粘贴配套指令前应核验账户界面限制；环境或模型可用性变化后应重新核实事实。

## 有限运行时冒烟测试（2026-11-13）

仓库维护者随后提供了两项 Windows Codex 会话的实际结果：

- **模块读取：** 新会话定位了当前全局 `AGENTS.md`，并实际读取同级 `personal-rules/execution.md`，报告 Direct Shell / Codex Task 的规则边界及文件位置、行号。这证明模块在明确要求时可以读取，并不证明所有任务都会自动加载。
- **自然 Direct Shell 响应：** 在不提及规则文件的情况下，维护者询问如何查看 Git 版本。Codex 返回可复制的 PowerShell 命令 `git --version` 及解释；所提供的回复没有启动仓库审计或创建任务历史。

这些是维护者提供的有限人工观察，不是自动化模型评测、独立运行时追踪或未来每次任务的遵从性保证。尚未测试实时 ChatGPT 账户行为。
