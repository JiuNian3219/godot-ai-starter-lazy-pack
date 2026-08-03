---
name: godot-memory
description: 用于在 Godot AI 项目中记录长期决策、教训、交接信息和可复用提示词改进。
---

# Godot Memory

把可复用的信息写进项目，而不是只留在聊天里。

## 何时更新

- 架构、工具链、测试策略、依赖方向发生长期有效变化。
- 出现可复现的错误、误判、假阳性或 AI 重复坏模式。
- 一个中大型任务结束，需要另一个 agent 接手。

## 写到哪里

- 决策：`docs/decisions/`
- 教训：`docs/lessons/`
- 当前交接：`docs/session_handoff.md`
- 提示词或工作流改进：`docs/prompts.md`、`docs/ai_workflow.md` 或对应 skill/rules。
