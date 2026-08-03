# Godot AI Starter Lazy Pack

一个用于新 Godot 4.7.1 GDScript 项目的已验证懒人包。它为 Claude Code 和 Codex chat 提供同一套项目规则、MCP 配置、验证脚本、提示词、长期记忆和 Git 工作流。

## 直接交给 AI

把下面这段连同本仓库链接发给能够读写本机文件、运行命令的 AI。只填目标目录；项目名不填时，AI 应使用目标目录名。

```text
请使用这个 Godot 懒人包为我创建并验证一个新项目：
https://github.com/JiuNian3219/godot-ai-starter-lazy-pack

目标目录：<例如 D:\Study\Godot\MyGame>
项目名：<可选，例如 My Game>

请先完整阅读仓库根目录 README.md 和 docs/next_project_prompt.md，然后严格执行其中的安装流程。不要手写或重新生成模板文件。
```

仓库是私有的。AI 必须能访问该仓库，或使用你已下载的本地仓库副本；没有访问权限时，它应说明阻塞原因，而不是从其他来源拼凑模板。

## AI 安装流程

AI 接到上面的指令后应执行：

1. 使用已存在的本地仓库，或将仓库克隆到临时目录；不要把模板仓库直接当作新游戏目录。
2. 优先下载本仓库 GitHub Release 中的含引擎 ZIP；只有使用源码仓库时，才运行 `scripts/build_lazy_pack.ps1 -IncludeGodot` 构建 ZIP。
3. 将 ZIP 解压到临时目录，运行 `template/scripts/find_godot_candidates.ps1`。
4. 展示所有 Godot 4.7.1 候选项的版本和绝对路径，等待用户确认。即使只有一个候选项也不得静默选择。
5. 以确认路径作为 `-GodotBin` 运行 ZIP 根目录的 `install.ps1`。
6. 进入新项目，在新的 PowerShell 进程中运行 `scripts/verify.ps1`。
7. 检查 MCP、Claude skills、共享规则和 `tools/godot-bin.path` 是否存在，并报告验证结果与仍需人工处理的事项。

安装器会将确认后的 Godot 路径保存到被 Git 忽略的 `tools/godot-bin.path`，因此后续打开编辑器、运行游戏或验证不依赖临时环境变量。

## 包含内容

- Godot 4.7.1 + typed GDScript 基础工程、示例场景和轻量行为测试。
- `scripts/verify.ps1`：导入、语法检查、场景 smoke test、组件测试与依赖审计。
- Git、Git LFS、作用域暂存和 Angular/Conventional Commits 规范。
- `AGENTS.md`、`CLAUDE.md`、Claude project skills、`.mcp.json` 与 Godot MCP addon。
- 中文安装、实现、测试、review、交接和长期记忆提示词。
- 架构、资源体积/未来分包、性能、输入、UI、存档与游戏专项规范。
- 基础设施、普通功能、垂直切片三阶段的验证和试玩门槛。

## 打包与发布

默认构建轻量包，不含引擎：

```powershell
powershell -ExecutionPolicy Bypass -File scripts\build_lazy_pack.ps1
```

构建可直接分发的 Windows x64 包，包含经过版本校验的 Godot 4.7.1：

```powershell
powershell -ExecutionPolicy Bypass -File scripts\build_lazy_pack.ps1 -IncludeGodot
```

含引擎包会生成 `dist\GodotAIStarterLazyPack-Godot-4.7.1-win64.zip` 及同名 `.sha256` 校验文件。引擎二进制只存在于该发行产物和 GitHub Release 附件，不进入 Git 历史；包内 `ENGINE_MANIFEST.txt` 记录官方来源、版本和 SHA-256。

## 不包含内容

- Godot 引擎本体、你的游戏内容、导出包和 `.godot/` 缓存。
- Codex CLI。
- 自动下载的未知 skills 或不受控的全局工具。

## 本地验证

```powershell
powershell -ExecutionPolicy Bypass -File scripts\verify.ps1
powershell -ExecutionPolicy Bypass -File scripts\build_lazy_pack.ps1 -IncludeGodot
```

详细安装约束见 [docs/next_project_prompt.md](docs/next_project_prompt.md)。
