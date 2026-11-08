# 懒人包安装说明（给安装 AI）

按已提供的模板创建新 Godot 项目，不临场重写规则、配置或场景。本文件只用于安装，不进入新游戏项目。

## 安装步骤

1. 确认 Git、Git LFS、Node.js、npm、npx 可用，报告版本。Claude Code 可选，缺少它不阻塞安装；可用支持 AGENTS 的其他 AI 入口。使用 Claude 时确认客户端支持直接读取 AGENTS，旧版先升级；不分发或为兼容旧版另外生成 CLAUDE.md，也不禁止用户自行添加。不安装未知技能，不默认跳过权限检查，不要求 Codex CLI。
2. 使用已提供的源码版本或 ZIP，不自动换成 latest Release。仓库链接先克隆到临时目录；指定提交先检出。源码默认直接创建项目，需要分发安装包时才构建 ZIP。用户明确选择 Release 时才下载对应版本，报告提交或发行来源。不要把模板仓库或临时解压目录当作游戏项目。
3. 源码运行 `scripts/find_godot_candidates.ps1`；已有 ZIP 解压到临时目录，运行 `template/scripts/find_godot_candidates.ps1`。列出 Godot 4.7.1 候选的版本和绝对路径，即使只有一个也先让用户确认；找不到才请用户提供路径。含引擎 ZIP 选择包内引擎，使安装后路径指向新项目内副本。
4. 用户确认后，源码在仓库根目录运行，替换占位路径：

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\create_new_project_from_template.ps1 -TargetPath "C:\path\to\new-game" -ProjectName "New Game" -GodotBin "C:\confirmed\Godot_v4.7.1-stable_win64_console.exe"
```

已有 ZIP 则在解压包根目录运行：

```powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1 -TargetPath "C:\path\to\new-game" -ProjectName "New Game" -GodotBin "C:\confirmed\Godot_v4.7.1-stable_win64_console.exe"
```

项目名可省略，此时取目标目录名。只用于新项目，不用重新安装覆盖已有游戏。必须使用确认后的绝对路径，不用 `-SkipVerify` 伪造成功；缺依赖或验证失败时报告实际问题。

5. 在新项目目录启动新的 PowerShell 进程，清除该进程的临时 `GODOT_BIN` 后运行 `scripts/verify.ps1`，确认引擎路径由被 Git 忽略的 `tools/godot-bin.path` 持久保存。含引擎安装应指向新项目内复制的引擎，而非临时解压目录。
6. 检查新项目有 `AGENTS.md`、`docs/项目说明.md` 占位、四份专项规则、`docs/errors/index.md` 与七条有效链接、`docs/assets/asset_manifest.xlsx`、`.mcp.json`、完整 Godot MCP addon、验证脚本和示例测试。开发内容以源码 `scripts/copy_template.ps1` 或 ZIP 外层 `copy_template.ps1` 为准。确认所用客户端实际已加载项目 AGENTS；使用 Claude 时可通过 `/context` 查看，若未加载则检查版本、上级目录指令文件和客户端设置。不能仅凭文件存在报告规则就绪。
7. 检查安装说明、包维护资料、工具专用技能、自动记忆和交接文件没有进入新项目。保留随模板复制的项目说明占位，不自行填写游戏策划、总结或新经验文档。

## 安装报告

在聊天中报告源码提交或 ZIP 版本来源、依赖版本、用户确认的引擎路径、实际保存的引擎路径、新项目路径、验证结果、开发内容与规则装载检查结果及待人工处理事项，并告诉用户自己的文档入口是新项目的 `docs/项目说明.md`。不把本报告写入新项目。

安装后用户直接描述开发任务。AI 按 AGENTS 读取项目说明和 Error 索引，按任务查阅相关资料及专项规则；不需要复制额外日常提示词。
