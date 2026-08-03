# Godot AI Starter Lazy Pack

这是一个 Godot 4.7.1 + GDScript + AI 协作工作流懒人包。

它不是让 AI 临场手写模板，而是把已经验证过的模板放在 `template/` 里。你只需要解压，然后运行 `install.ps1`。

GitHub Release 的 Windows x64 发行包会内置 Godot 4.7.1；源码仓库默认不提交引擎二进制。

## 你需要先安装

硬依赖：

- Godot 4.7.1 stable
- Git
- Git LFS
- Node.js LTS / npm / npx

可选 AI 工具入口，至少准备一个即可：

- Claude Code
- Codex chat

这些只是让 AI 能读写文件、运行命令、使用 MCP 或识别项目 skills/rules 的入口。项目提示词不会把某个工具固定成实现、测试或 review 角色。

## 创建新项目

```powershell
powershell -ExecutionPolicy Bypass -File .\template\scripts\find_godot_candidates.ps1
```

让当前 AI 先报告候选 Godot 4.7.1 路径并向你确认。确认后再运行：

```powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1 -TargetPath "C:\path\to\new-game" -ProjectName "New Game" -GodotBin "C:\confirmed\path\to\Godot_v4.7.1-stable_win64_console.exe"
```

安装脚本会验证版本，并把确认后的绝对路径写入被 Git 忽略的 `tools\godot-bin.path`。后续 `verify.ps1`、打开编辑器和运行游戏都能从这里读取，不依赖这次安装进程的临时环境变量。

## 构建发行包

构建轻量包：

```powershell
powershell -ExecutionPolicy Bypass -File scripts\build_lazy_pack.ps1
```

构建含 Windows x64 Godot 4.7.1 的发行包：

```powershell
powershell -ExecutionPolicy Bypass -File scripts\build_lazy_pack.ps1 -IncludeGodot
```

后者生成 `dist\GodotAIStarterLazyPack-Godot-4.7.1-win64.zip` 和同名 `.sha256` 校验文件，应一起作为 GitHub Release 附件发布；引擎本体不进入 Git 历史。

## 安装脚本会做什么

- 检查 Git、Git LFS、Node.js、npm、npx。
- 检查可选 AI 工具入口：Claude Code。
- 要求已确认的 Godot 路径，并保存为项目本地配置。
- 复制 `template/` 里的项目模板文件。
- 修改 `project.godot` 项目名。
- 初始化 Git 和 Git LFS。
- 保留 Godot MCP addon。
- 保留 `.mcp.json`、Claude Code skills、Codex 可读的 `AGENTS.md` 与 `docs/`。
- 运行 `scripts/verify.ps1`。

## 提示词在哪里

安装完成后看：

```text
docs/prompts.md
```

里面保留真正需要复制粘贴的提示词：

- 通用 AI 功能实现提示词。
- 通用 AI 测试提示词。
- 通用 AI review 提示词。
- 交接给另一个 AI agent 的提示词。
- 长期记忆/复盘提示词。

这些提示词只描述任务流程，不指定“Claude 做实现、Codex 做某事”。当前 agent 应该自己发现项目内可用的 rules、skills、MCP 和验证脚本。

## 代码注释规则

新项目默认要求代码带有简明中文注释：

- 函数作用要注释，纯 trivial 函数可例外。
- 关键玩法逻辑、特殊判定、状态切换、时间窗、可调参数、资源加载假设和性能敏感点要注释。
- 测试代码要说明测试目标、特殊断言和回归风险。
- 不要把每一行自明代码翻译一遍。

## 自动提交规则

每次代码修改任务完成并验证通过后，默认自动提交代码，除非你明确说不要提交。

- 提交前检查 `git status` 和 `git diff`。
- 只 stage 本次任务真正需要提交的文件。
- 不提交无关用户改动、生成缓存、本地工具、导出产物、`.godot/`、`.tmp/` 或 ignored 文件。
- Git commit 使用 Angular/Conventional Commits 规范：`type(scope): short summary`。
- 常用 type：`feat`、`fix`、`test`、`refactor`、`docs`、`chore`、`perf`、`build`、`ci`、`style`、`revert`。
- 完成后报告 commit hash。

## AI 工具适配文件

- `.mcp.json`：项目级 MCP 配置。
- `.claude/skills/`：Claude Code 可识别的项目技能。
- `AGENTS.md`、`docs/ai_workflow.md`、`docs/ai_memory.md`、`docs/prompts.md`：所有 AI agent 都应该遵守的共享规则。

每次任务只选一个 agent 写文件。另一个 agent 可以 review、解释，或者在明确交接后接手。

## 架构规范

安装完成后先看：

```text
docs/engineering_rules.md
docs/game_development_rules.md
docs/architecture_rules.md
```

`engineering_rules.md` 是工程质量总纲，覆盖代码质量、中文注释、测试、资源体积、性能、输入、UI、存档/数据、调试和长期记忆。

`game_development_rules.md` 是游戏专项规范，覆盖核心循环、手感、反馈、输入延迟、相机、动画、物理、关卡迭代、资源管线、帧率预算、调参和试玩 checklist。

`architecture_rules.md` 规定模块边界、依赖方向、shared 资源使用、未来分包/资源包敏感规则。AI 写新功能前应该先说明新文件属于哪个模块、允许依赖哪些目录，避免后期出现小包被无关资源和模块拖大的问题。

## 验证

进入新项目目录后运行：

```powershell
powershell -ExecutionPolicy Bypass -File scripts\verify.ps1
```

如果要检查可选 AI 工具入口，可以运行：

```powershell
claude --version
```

## 重要原则

- MCP 只是编辑器/运行时操作桥，不是架构替代品。
- 代码质量优先：typed GDScript、清晰组件、可复用 Resource、中文注释、测试验证、干净提交。
- 长期项目要记录决策、教训和 session handoff。
- 不提交 `.godot/`、`.tmp/`、`tools/`、`builds/`、`exports/`。
