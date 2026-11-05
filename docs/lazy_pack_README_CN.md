# Godot AI Starter Lazy Pack

这个安装包把 Godot 4.7.1 + GDScript 开发模板安装到新项目。AI 按外层 INSTALL.md 安装，开发时按项目 AGENTS.md 工作。

## 创建新项目

准备 Git、Git LFS、Node.js/npm/npx。含引擎 ZIP 携带 Windows x64 Godot 4.7.1；轻量 ZIP 使用本机兼容引擎。Claude Code 可选，也可使用其他支持 AGENTS 的 AI 工具。

解压后，在包目录运行：

```powershell
powershell -ExecutionPolicy Bypass -File .\template\scripts\find_godot_candidates.ps1
```

让 AI 展示候选版本与绝对路径，用户确认后再运行：

```powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1 -TargetPath "C:\path\to\new-game" -ProjectName "New Game" -GodotBin "C:\confirmed\Godot_v4.7.1-stable_win64_console.exe"
```

安装器复制明确选择的开发内容，初始化 Git/LFS 并验证。确认后的路径存入被 Git 忽略的 `tools/godot-bin.path`。安装后在新项目的新终端运行：

```powershell
powershell -ExecutionPolicy Bypass -File scripts\verify.ps1
```

只用于创建新项目，不用此安装流程覆盖已有项目。不要通过跳过验证报告安装成功。

## 开发时怎么用

直接向 AI 描述需求。AGENTS 保留核心规则；AI 先查 Error 索引，命中后读对应经验，按任务读专项规则。关键玩法计算、状态归属和先后顺序应能从代码看清。

AI 代码变更验证通过后默认提交本次相关文件，除非用户禁止；使用 Conventional Commits，不包含无关改动与生成物。普通功能以技术验证为主，正式试玩只在用户声明垂直切片时进行。

保留素材的来源和许可证登记在 Excel 台账中，随素材变更更新；生成提示词可选。项目文档由用户主导整理，不自动写总结、决策或交接记录。

## 包含与边界

开发项目获得规则、错误索引、资产台账、Godot MCP、示例场景、测试和验证脚本。完整清单见外层 TEMPLATE_MANIFEST.md。安装说明和维护资料留在包外层，不带入游戏项目。

源码构建方式见仓库 README。引擎二进制、`.godot/`、`.tmp/`、本地路径配置、构建和导出文件不提交。
