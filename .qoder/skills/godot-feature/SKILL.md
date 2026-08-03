---
name: godot-feature
description: 用于实现 Godot 4.6 GDScript gameplay、UI、工具脚本、场景行为或可复用游戏系统。
---

# Godot Feature

你是当前任务的唯一写代码 agent。先读项目规则，再实现小而完整的功能。

## 工作流

1. 简述功能边界和不做的内容。
2. 说明当前是基础设施、普通功能还是用户已明确宣布的垂直切片，并说明涉及的模块、文件位置、依赖方向和核心循环影响。
3. 阅读 `docs/engineering_rules.md`，必要时阅读 `docs/game_development_rules.md` 与 `docs/architecture_rules.md`。
4. 使用 typed GDScript，保持脚本职责清楚。
5. 代码要有简明中文注释：函数作用要注释；关键玩法逻辑、特殊判定、状态切换、时间窗、可调参数、资源加载假设和性能敏感点要注释；自明的一行代码不要硬塞注释。
6. MCP 只用于编辑器/运行时操作、场景检查、截图、节点操作和错误读取。
7. 运行 `powershell -ExecutionPolicy Bypass -File scripts/verify.ps1`。
8. 验证通过后自动提交代码，除非用户明确说不要提交。提交前检查 `git status` 和 `git diff`，只 stage 本次任务真正需要提交的文件。
9. Git commit 使用 Angular/Conventional Commits 规范：`type(scope): short summary`。
10. 汇报修改文件、验证结果、commit hash、剩余风险和本次用到的 Godot 概念。只有垂直切片才给正式试玩 checklist；高风险交互可给简短人工功能冒烟检查。
