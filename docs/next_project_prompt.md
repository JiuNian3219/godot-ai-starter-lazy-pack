# 懒人包安装说明（给安装 AI）

按已提供的模板创建新 Godot 项目，不临场重写规则、配置或场景。本文件只用于安装，不进入新游戏项目。

## 安装步骤

1. 确认 Git、Git LFS、Node.js、npm、npx 可用，报告版本。Claude Code 可选，缺少它不阻塞安装；可用支持 AGENTS 的其他 AI 入口。不安装未知技能，不默认跳过权限检查，不要求 Codex CLI。
2. 从本仓库 Release 取得 ZIP；使用源码时按仓库 README 构建。含引擎包为 `GodotAIStarterLazyPack-Godot-4.7.1-win64.zip`；轻量包为 `GodotAIStarterLazyPack.zip`。解压到临时目录，不把模板仓库或包目录当作游戏项目。
3. 运行包内 `template/scripts/find_godot_candidates.ps1`，列出 Godot 4.7.1 候选的版本和绝对路径。即使只有一个也先让用户确认；找不到才请用户提供路径。不得静默选用。
4. 用户确认后，在包根目录运行安装器，替换以下占位路径：

```powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1 -TargetPath "C:\path\to\new-game" -ProjectName "New Game" -GodotBin "C:\confirmed\Godot_v4.7.1-stable_win64_console.exe"
```

项目名可省略，此时取目标目录名。只用于新项目，不用重新安装覆盖已有游戏。必须使用确认后的绝对路径，不用 `-SkipVerify` 伪造成功；缺依赖或验证失败时报告实际问题。

5. 在新项目目录启动新的 PowerShell 进程，清除该进程的临时 `GODOT_BIN` 后运行 `scripts/verify.ps1`，确认引擎路径由被 Git 忽略的 `tools/godot-bin.path` 持久保存。含引擎安装应指向新项目内复制的引擎，而非临时解压目录。
6. 检查新项目有 `AGENTS.md`、四份专项规则、`docs/errors/index.md` 与七条有效链接、`docs/assets/asset_manifest.xlsx`、`.mcp.json`、Godot MCP addon、验证脚本和示例测试。开发内容清单以包外层 `copy_template.ps1` 为准。
7. 检查安装说明、包维护资料、工具专用技能、自动记忆和交接文件没有进入新项目。不要生成游戏策划、总结或新经验文档。

## 安装报告

在聊天中报告依赖版本、用户确认的引擎路径、实际保存的引擎路径、新项目路径、验证结果、开发内容检查结果及待人工处理事项。不把本报告写入新项目。

安装后用户直接描述开发任务。AI 读取 AGENTS 和 Error 索引，按命中范围查阅记录及专项规则；不需要复制额外日常提示词。
