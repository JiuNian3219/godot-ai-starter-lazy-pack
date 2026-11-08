# Godot AI Starter Lazy Pack

一个用于新 Godot 4.7.1 GDScript 项目的已验证懒人包。它为 Claude Code 和 Codex chat 提供同一套项目规则、MCP 配置、验证脚本、错误索引、资产台账和 Git 工作流。

## 直接交给 AI

把下面这段连同本仓库链接发给能够读写本机文件、运行命令的 AI。只填目标目录；项目名不填时，AI 应使用目标目录名。

```text
请使用这个 Godot 懒人包为我创建并验证一个新项目：
https://github.com/JiuNian3219/godot-ai-starter-lazy-pack

目标目录：<例如 D:\Study\Godot\MyGame>
项目名：<可选，例如 My Game>

请完整阅读并执行 docs/next_project_prompt.md 中的安装步骤。不要手写或重新生成模板文件。
```

AI 必须能访问该仓库，或使用你已下载的本地仓库副本；没有访问权限时，它应说明阻塞原因，而不是从其他来源拼凑模板。

## 安装入口

完整安装步骤统一维护在 [安装说明](docs/next_project_prompt.md)；打包时直接复制为 ZIP 根目录的 `INSTALL.md`。

提供仓库链接时，从源码直接创建新项目，无需先打包；已有安装 ZIP 时按包内 `INSTALL.md` 安装。只有用户明确选择 Release 才下载对应发行版，避免用旧发行包替代已更新的源码。

## 包含内容

- Godot 4.7.1 + typed GDScript 基础工程、示例场景和轻量行为测试。
- `scripts/verify.ps1`：导入、当前主场景启动冒烟、自动发现 `tests/**/*_test.gd` 与依赖审计。
- `scripts/record_game.ps1`：调用 Godot 原生录制，输出可直接查看的 PNG 帧序列或 AVI，按需观察相机、动画和移动；不增加录屏依赖。
- 场景节点持久化要求；重要游戏场景的结构测试随实际需求编写，不强制保留占位场景的 Title 节点。
- GitHub Actions 持续验证、原型场景规范、`.editorconfig` 和 Excel 资产台账模板。
- Git、Git LFS、作用域暂存和 Angular/Conventional Commits 规范。
- `AGENTS.md`、按任务读取的 Error 索引、`.mcp.json` 与 Godot MCP addon。
- 中文安装说明；开发时直接描述任务，项目文档由用户主导整理。
- 架构、资源体积/未来分包、性能、输入、UI、存档与游戏专项规范。
- 基础设施、普通功能、垂直切片三阶段的验证和试玩门槛。

## 安装内容边界

`scripts/copy_template.ps1` 统一选择开发内容。安装说明和包维护清单留在源码或发行包外层，不进入游戏项目；不附带工具专用技能、自动记忆或固定交接文件。

AGENTS 直接保留重要规则，特别要求玩法逻辑和执行顺序可读；Error 索引按任务关键词与操作命中。素材来源随变更登记到 XLSX，生成提示词记录可选。历史决策不作为新游戏项目文档复制。

源码和 ZIP 安装使用相同的开发内容清单；只用于新项目，不迁移已有游戏。

初始场景、主脚本和 HealthComponent 及其测试都是可替换示例。开发游戏时同步替换或删除对应测试；通用验证入口不固定这些路径，也不要求项目必须有示例组件。

## 打包与发布

以下命令用于制作分发包；从源码安装无需先打包。默认构建轻量包，不含引擎：

```powershell
powershell -ExecutionPolicy Bypass -File scripts\build_lazy_pack.ps1
```

构建可直接分发的 Windows x64 包，包含经过版本校验的 Godot 4.7.1：

```powershell
powershell -ExecutionPolicy Bypass -File scripts\build_lazy_pack.ps1 -IncludeGodot
```

含引擎包会生成 `dist\GodotAIStarterLazyPack-Godot-4.7.1-win64.zip` 及同名 `.sha256` 校验文件。引擎二进制只存在于该发行产物和 GitHub Release 附件，不进入 Git 历史；包内 `ENGINE_MANIFEST.txt` 记录官方来源、版本和 SHA-256。

## 持续验证

`.github/workflows/verify.yml` 会在每次 push、Pull Request 或手动触发时下载官方 Linux Godot 4.7.1，并运行同一条 `scripts/verify.ps1`。模板源码还运行验证器回归、行为验收工具自检、原生录制检查，以及 Windows 安装内容检查；这些维护脚本不安装到游戏项目，复制后的 CI 会跳过不存在的维护检查。录制检查在临时 CI 环境安装 Xvfb 和软件渲染依赖，不需要 AI 账号。新项目推送到 GitHub 后，确认仓库的 Actions 已启用，并将失败视为需要修复的验证结果。

## 不包含内容

- 你的游戏内容、导出包和 `.godot/` 缓存；轻量包不含引擎，含引擎版本另行构建。
- Codex CLI。
- 自动下载的未知 skills 或不受控的全局工具。

## 本地验证

```powershell
powershell -ExecutionPolicy Bypass -File scripts\verify.ps1
powershell -ExecutionPolicy Bypass -File scripts\build_lazy_pack.ps1 -IncludeGodot
```

安装包维护时运行 `powershell -ExecutionPolicy Bypass -File scripts/test_template_content.ps1`，检查安装边界、必需插件文件和 Error 链接；可通过 `-ProjectPaths` 传入已安装项目检查文档一致性。`scripts/test_verification.ps1` 用临时项目验证占位内容可替换、启动错误和新测试失败不会被漏过。这两个维护脚本不安装到游戏项目。

有图形环境时运行 `scripts/test_recording.ps1`，检查真实 PNG 动画帧、AVI、已有产物保护与运行错误检测；录制使用方式见 [工程规范](docs/engineering_rules.md#运行画面录制)。

## 懒人包的 AI 行为抽查

`maintenance/behavior_cases.json` 保留相机、回合、结算与生成、普通小改动四个正常需求，以及独立验收要点。它们仅供维护懒人包，不复制到游戏项目。调整规则、工具入口或主要模型后，按需选取相关任务；不是每次游戏开发都要运行的流程。

```powershell
powershell -ExecutionPolicy Bypass -File scripts/prepare_behavior_case.ps1 -Case round -TargetPath .tmp/round-evaluation
```

准备器使用当前模板内容，生成新评估目录中的 `project/`、外部 `task.txt` 和 `baseline.json`；可通过 `-GodotBin` 指定已确认的引擎。让独立 AI 会话在 `project/` 中工作，只给它 `task.txt` 的正常需求，不提前给验收条件或参考解法。完成后另行查看实际改动、运行行为和读取记录，按维护侧条件验收；内部类名和路径不同不构成失败。可读性由人核对规则、计算、等待和状态变化是否容易理解，不能靠函数长度评分。做提示词对照时保持任务、模型和工具环境一致，只改变要研究的要求；有限样本仅说明本次观察。

`scripts/test_behavior_checks.ps1` 自动检查四种工作区的准备和隔离，再验证参考回合的 28 项断言，确认删除等待、删除死亡后中止、忽略护盾的三个错误会被检出。参考样例不交给被测 AI；这项 CI 自检没有运行 AI，不能证明提示词有效。游戏项目自己的初始场景、脚本和测试仍可随需求替换。
