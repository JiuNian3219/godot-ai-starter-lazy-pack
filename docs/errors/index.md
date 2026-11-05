# Error 索引

开始任务先读本索引，根据需求、计划操作和涉及文件匹配；命中后先读对应记录再执行。任务范围扩大时重新匹配。关键词包括同义表达，不是必须逐字出现的搜索条件；没有命中的条目不必阅读全文。

每条记录描述已观察的问题、适用范围、原因或已知限制，以及避免和检查的方法。历史环境中的现象不自动成为所有版本的结论。目录由用户主导维护，AI 不在任务结束时自动新增记录。

| ID | 关键词 | 适用操作 | 问题 | 对应记录 |
| --- | --- | --- | --- | --- |
| E001 | 验证、测试失败、退出码、verify、LASTEXITCODE、CI | 修改验证脚本或判断验证是否成功 | 子进程失败却显示成功 | [验证必须失败](0001-verification-must-fail-hard.md) |
| E002 | 信号、signal、lambda、计数、回调、SceneTree | 编写信号触发次数测试 | 闭包中的局部计数未按预期变化 | [稳定的信号计数](0002-godot-signal-tests-need-stable-counters.md) |
| E003 | 非交互、Claude -p、摘要缺失、agent 输出 | 执行或验收非交互 AI 操作 | 摘要不能证明是否完成修改 | [检查实际文件和验证结果](0003-do-not-trust-noninteractive-summary-output.md) |
| E004 | 审计、负例、排除目录、忽略路径、.tmp | 测试依赖审计的失败检测能力 | 负例放在扫描范围之外 | [负例必须进入扫描范围](0004-negative-tests-must-not-live-in-excluded-paths.md) |
| E005 | Godot 路径、安装、环境变量、新终端、GODOT_BIN | 修改引擎定位或排查新进程启动失败 | 仅在安装进程设置路径 | [持久保存引擎路径](0005-godot-path-must-survive-installer-process.md) |
| E006 | 节点、场景、.tscn、add_child、_ready、UI、碰撞、相机、owner | 新增或修改节点结构、脚本创建节点、编辑器生成场景 | 可编辑结构被隐藏为运行时节点 | [场景持久化与动态节点](0006-runtime-nodes-do-not-replace-scene-authoring.md) |
| E007 | CI、GitHub Actions、Linux、引擎下载、GODOT_BIN | 修改 CI 引擎安装或定位流程 | 下载后的可执行文件未传给验证器 | [CI 显式传递引擎路径](0007-ci-must-set-godot-bin.md) |
