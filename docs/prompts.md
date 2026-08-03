# 常用提示词

这个文件只放“项目装好以后”真正需要复制给 AI 的提示词。

安装懒人包时使用：`docs/next_project_prompt.md`。

Claude Code、Codex chat 这类工具都只是“有手的 AI 入口”。提示词不应该把某个工具固定成实现、测试或 review 角色。真正的规则是：当前可操作工作区的 AI agent 先发现项目内可用的 rules、skills、MCP 和验证脚本，然后按同一套工程流程完成任务。

## 当前 AI Agent 实现功能

```text
你现在是当前任务的唯一写文件 agent。

开始前请先发现并读取本项目可用的本地规则、skills、MCP 配置和验证脚本，例如：
- AGENTS.md
- docs/ai_workflow.md
- docs/ai_memory.md
- docs/engineering_rules.md
- docs/game_development_rules.md
- docs/architecture_rules.md
- docs/decisions/
- docs/lessons/
- docs/session_handoff.md
- .mcp.json
- .claude/skills/（如果当前工具能读取/调用）

请实现这个 Godot 4.7.1 GDScript 功能：<写清楚功能>

要求：
1. 代码质量优先。MCP 只用于编辑器/运行时操作、场景检查、截图、节点操作和错误读取，不是架构替代品。
2. gameplay 逻辑写在 typed GDScript、可复用组件、Resource 或职责清楚的场景脚本中。
3. 不要把场景脚本写成大杂烩。
4. 代码要有简明中文注释：函数作用要注释；关键玩法逻辑、特殊判定、状态切换、时间窗、可调参数、资源加载假设和性能敏感点要注释；自明的一行代码不要硬塞注释。
5. 开始前说明：当前是基础设施、普通功能还是用户已明确宣布的垂直切片；涉及模块、新文件位置、依赖方向、核心循环影响、验证方式，以及性能/体积/平台/UI/存档风险。只有高风险交互才列简短人工功能冒烟检查；只有垂直切片才列正式试玩 checklist 和手感评价。
6. 不要随便跨模块 preload/load，不要把大资源放到 shared 里。
7. 运行 powershell -ExecutionPolicy Bypass -File scripts/verify.ps1，失败就修到通过。
8. 验证通过后自动提交代码，除非我明确说不要提交。提交前检查 `git status` 和 `git diff`，只 stage 本次任务真正需要提交的文件，不要提交无关用户改动、生成缓存、本地工具、导出产物、`.godot/`、`.tmp/` 或 ignored 文件。
9. Git commit 使用 Angular/Conventional Commits 规范：`type(scope): short summary`，常用 type 包括 `feat`、`fix`、`test`、`refactor`、`docs`、`chore`、`perf`、`build`、`ci`、`style`、`revert`。
10. 如果涉及架构、工具、测试策略或踩坑，请更新 docs/decisions、docs/lessons、docs/session_handoff.md。

完成后请报告：
1. 改了哪些文件。
2. 验证结果。
3. 还存在哪些风险；普通功能只报告必要的人工功能冒烟检查，垂直切片才报告正式试玩结果或计划。
4. 这次用到的 Godot 概念，方便我学习。
5. 如果是 gameplay 功能，列出可调参数和手感/反馈占位项。
6. Git commit hash；如果没有提交，说明原因。
```

## 当前 AI Agent 添加测试

```text
你现在是当前任务的唯一写文件 agent。

开始前请先发现并读取本项目可用的本地规则、skills、MCP 配置和验证脚本。尤其要检查 AGENTS.md、docs/ai_workflow.md、docs/ai_memory.md、docs/engineering_rules.md，以及当前工具能识别的 .claude/skills/。

请给下面这个行为添加验证：<写清楚行为或 bug>

要求：
1. 优先使用轻量 Godot 命令行测试，不要一开始就引入 gdUnit4。
2. 如果确实需要 gdUnit4，先说明为什么，再添加。
3. 测试代码也要有必要的中文注释，说明测试目标、特殊断言和回归风险。
4. 更新 scripts/verify.ps1，让一个命令能跑完相关检查。
5. 验证脚本必须在失败时返回失败，不允许只打印错误后继续成功。
6. 运行 powershell -ExecutionPolicy Bypass -File scripts/verify.ps1，直到通过。
7. 验证通过后自动提交代码，除非我明确说不要提交。提交前检查 `git status` 和 `git diff`，只 stage 本次测试任务真正需要提交的文件。
8. Git commit 使用 Angular/Conventional Commits 规范，例如 `test(player): cover dash cooldown`。
```

## 当前 AI Agent 自查

```text
请按代码审查模式 review 当前 diff，先列问题，再给简短修改建议。

开始前请先发现并读取本项目可用的本地规则、skills、MCP 配置和验证脚本。尤其要检查 AGENTS.md、docs/engineering_rules.md、docs/game_development_rules.md、docs/architecture_rules.md，以及当前工具能识别的 .claude/skills/。

重点检查：
1. Godot 4.7.1 API 是否正确。
2. 是否有 Godot 3 旧写法。
3. typed GDScript 是否足够清晰。
4. 函数作用、关键玩法逻辑、特殊判定、状态切换、时间窗、可调参数、资源加载假设和性能敏感点是否有简明中文注释。
5. 是否有脆弱的节点路径或场景耦合。
6. 是否违反 docs/engineering_rules.md、docs/game_development_rules.md 或 docs/architecture_rules.md。
7. 是否会导致 shared 资源过大、跨模块引用、未来分包困难。
8. 是否有性能、输入、UI、存档、资源导入、平台风险。
9. 是否缺少与当前阶段相称的测试或验证；只有已声明为垂直切片的任务才检查正式人工试玩 checklist。
10. 如果这是代码修改任务，是否已经在验证通过后用 Angular/Conventional Commits 规范做了干净提交，且只提交了本次任务必要文件。
11. 是否需要更新 docs/decisions、docs/lessons 或 docs/session_handoff.md。
```

## 让另一个 AI Agent 独立 Review

当一个 agent 完成功能后，把 `git diff`、相关文件片段、`scripts/verify.ps1` 输出交给另一个 agent，然后用：

```text
请作为独立 reviewer 审查这次 Godot 4.7.1 GDScript 改动。

你不是刚才的实现 agent。请从第二视角检查问题。

开始前请先发现并读取本项目可用的本地规则、skills、MCP 配置和验证脚本。

重点看：
1. bug 和行为风险。
2. Godot 4.7.1 API 是否正确。
3. 是否有旧 Godot 写法。
4. 函数作用、关键玩法逻辑、特殊判定、状态切换、时间窗、可调参数和性能敏感点是否有简明中文注释。
5. 节点/场景耦合是否脆弱。
6. typed GDScript、组件职责、Resource 使用是否合理。
7. 是否违反 docs/engineering_rules.md、docs/game_development_rules.md 或 docs/architecture_rules.md。
8. 是否会导致 shared 资源过大、跨模块引用、未来分包困难。
9. 是否有性能、输入、UI、存档、资源导入、平台风险。
10. 测试是否真的能失败、是否覆盖关键行为。
11. 如果这是代码修改任务，是否已经在验证通过后用 Angular/Conventional Commits 规范做了干净提交，且只提交了本次任务必要文件。
12. 是否应该更新 docs/decisions、docs/lessons 或 docs/session_handoff.md。

请按这个格式输出：
1. 严重问题。
2. 中等问题。
3. 测试缺口。
4. 游戏手感/反馈/性能/资源风险。
5. 建议的小范围重构。
6. 文档/记忆是否需要更新。
```

## 交接给另一个 AI Agent

```text
请接手这个 Godot 4.7.1 GDScript 任务。

上一个 agent 已经停止写文件。你现在可以作为唯一写文件 agent。

交接信息：
1. 已修改文件：<列文件>
2. 最新验证输出：<贴 verify 输出>
3. 仍未解决的问题：<列问题>
4. 需要保留的决策：<列决策>
5. 需要特别注意的 docs/lessons：<列 lesson>

请先发现并读取本项目可用的本地规则、skills、MCP 配置和验证脚本，再继续。
```

## 什么时候引入 gdUnit4

先用内置 smoke test 和轻量 SceneTree 测试。

出现这些情况，再考虑 gdUnit4：

- 背包、战斗、状态机、存档、程序生成等逻辑开始变多。
- 同类 bug 重复出现。
- 需要大量断言和测试夹具。
- 轻量脚本测试已经难以维护。
