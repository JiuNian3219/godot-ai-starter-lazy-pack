# Godot 工程质量规则

## 架构

- 遵守 `docs/architecture_rules.md` 的模块边界和依赖方向。
- 避免跨模块 `preload()` / `load()`，除非依赖方向明确允许。
- 不要把大资源放进 `shared`，除非每个包都确实需要。
- 新文件要说明属于哪个模块、能依赖哪些目录、会被谁依赖。

## GDScript

- 使用 Godot 4.6 API，不要混入 Godot 3 写法。
- 使用 typed GDScript：变量、参数、返回值、数组、字典在可读的前提下尽量标注类型。
- 优先使用信号、导出引用、NodePath、分组或依赖注入，避免脆弱的深层 `$A/B/C` 路径。
- 可调参数优先放 exported properties 或 Resource，方便以后调手感。

## 验证

- 修改脚本或场景后必须跑 `scripts/verify.ps1`。
- 新增测试时优先使用轻量 Godot 命令行测试。
- 只有当轻量测试难以维护时，才考虑引入 gdUnit4。
- 验证脚本必须失败即失败，不能只打印错误然后返回成功。
