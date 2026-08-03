---
name: godot-test
description: 用于为 Godot 4.6 GDScript 添加或改进 smoke test、回归测试、验证脚本和可测试性。
---

# Godot Test

优先使用轻量 Godot 命令行测试。不要一开始就引入大型测试框架。

## 工作流

1. 分离可以脱离完整场景测试的逻辑。
2. 场景加载、导入、启动行为变动时补 smoke test。
3. 纯逻辑增加确定性测试。
4. 测试代码要有必要的中文注释，说明测试目标、特殊断言和回归风险。
5. 更新 `scripts/verify.ps1`，让一个命令能跑完相关验证。
6. 确认测试失败时命令真的返回失败。
7. 运行 `powershell -ExecutionPolicy Bypass -File scripts/verify.ps1`。
8. 验证通过后自动提交代码，除非用户明确说不要提交。提交前只 stage 本次测试任务真正需要提交的文件。
9. Git commit 使用 Angular/Conventional Commits 规范，例如 `test(player): cover dash cooldown`。

## 什么时候考虑 gdUnit4

- 背包、战斗、状态机、存档、程序生成等逻辑开始变多。
- 同类 bug 重复出现。
- 轻量脚本测试已经难以维护。
