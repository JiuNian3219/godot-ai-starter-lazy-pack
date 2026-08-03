# Godot AI 项目规则

本项目使用 Godot 4.6.x stable 与 GDScript。QoderCN/Qoder 是让当前 AI agent 读取规则、写文件、运行命令和使用 MCP 的工具入口。一次任务只允许一个 AI agent 写文件。

## 进入任务前

- 先阅读 `AGENTS.md`、`docs/ai_workflow.md`、`docs/ai_memory.md`。
- 中大型任务还要阅读相关 `docs/decisions/`、`docs/lessons/`、`docs/session_handoff.md`。
- 新增 gameplay、UI、resource、assets、工具脚本或模块目录前，先阅读 `docs/architecture_rules.md` 并说明模块边界与依赖方向。
- 涉及玩法、输入、相机、动画、物理、关卡、资源、性能或手感时，先阅读 `docs/game_development_rules.md`。
- 涉及工程质量、测试、资源体积、平台、UI、存档或调试时，先阅读 `docs/engineering_rules.md`。

## 写代码原则

- 代码质量优先，MCP 只是编辑器和运行时操作桥，不是架构替代品。
- 优先 typed GDScript，保持节点脚本小而清楚。
- 玩法逻辑放在职责明确的脚本、组件、Resource 或小场景里。
- 不要把场景脚本写成大杂烩。
- 代码要有简明中文注释：函数作用要注释；关键玩法逻辑、特殊判定、状态切换、时间窗、可调参数、资源加载假设和性能敏感点要注释；自明的一行代码不要硬塞注释。
- 不要随意改 `.godot/`、`project.godot`、输入映射、autoload、导出配置或插件配置。
- 不要让多个 AI 工具入口同时编辑同一批文件。

## 完成任务前

- 运行 `powershell -ExecutionPolicy Bypass -File scripts/verify.ps1`。
- 验证通过后自动提交代码，除非用户明确说不要提交。
- 提交前检查 `git status` 和 `git diff`，只 stage 本次任务真正需要提交的文件。
- Git commit 使用 Angular/Conventional Commits 规范：`type(scope): short summary`。不要提交无关用户改动、生成缓存、本地工具、导出产物、`.godot/`、`.tmp/` 或 ignored 文件。
- 报告修改文件、验证结果、剩余风险和本次用到的 Godot 概念。只有用户明确进入垂直切片里程碑时才给正式试玩 checklist；高风险交互可给简短人工功能冒烟检查。
- 报告 commit hash；如果没有提交，说明原因。
- 如果产生了长期有效的架构/工具/测试决策，更新 `docs/decisions/`。
- 如果踩到可复现的坑，更新 `docs/lessons/`。
- 中大型任务结束时更新 `docs/session_handoff.md`。
