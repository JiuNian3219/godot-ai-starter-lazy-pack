---
name: godot-review
description: 用于 review Godot 4.6 GDScript、场景、项目设置、AI 生成代码或 MCP 改动。
---

# Godot Review

按代码审查模式工作，先列问题，再给简短建议。

## 检查重点

- Godot 4.6 API 是否正确，是否混入 Godot 3 写法。
- typed GDScript 是否足够清楚。
- 职责是否清晰，scene script 是否变成大杂烩。
- 函数作用、关键玩法逻辑、特殊判定、状态切换、时间窗、可调参数、资源加载假设和性能敏感点是否有简明中文注释。
- 节点路径、信号、资源、导出引用是否脆弱。
- 是否违反 `docs/engineering_rules.md`、`docs/game_development_rules.md` 或 `docs/architecture_rules.md`。
- 是否引入跨模块依赖、shared 资源膨胀、未来分包困难。
- 是否缺少与当前阶段相称的测试或验证；只有声明为垂直切片的任务才检查正式试玩 checklist。
- 如果这是代码修改任务，是否已经在验证通过后用 Angular/Conventional Commits 规范做了干净提交。
- 提交是否只包含本次任务需要的文件，是否避开无关用户改动、生成缓存、本地工具、导出产物、`.godot/`、`.tmp/` 和 ignored 文件。
- 是否需要更新 `docs/decisions/`、`docs/lessons/` 或 `docs/session_handoff.md`。
