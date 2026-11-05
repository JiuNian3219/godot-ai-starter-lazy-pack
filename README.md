# Godot AI Starter Lazy Pack

一个用于新 Godot 4.7.1 GDScript 项目的已验证懒人包。它为 Claude Code 和 Codex chat 提供同一套项目规则、MCP 配置、验证脚本、错误索引、资产台账和 Git 工作流。

## 直接交给 AI

把下面这段连同本仓库链接发给能够读写本机文件、运行命令的 AI。只填目标目录；项目名不填时，AI 应使用目标目录名。

```text
请使用这个 Godot 懒人包为我创建并验证一个新项目：
https://github.com/JiuNian3219/godot-ai-starter-lazy-pack

目标目录：<例如 D:\Study\Godot\MyGame>
项目名：<可选，例如 My Game>

请先完整阅读仓库根目录 README.md 和 docs/next_project_prompt.md，然后严格执行其中的安装流程。不要手写或重新生成模板文件。
```

AI 必须能访问该仓库，或使用你已下载的本地仓库副本；没有访问权限时，它应说明阻塞原因，而不是从其他来源拼凑模板。

## AI 安装流程

AI 接到上面的指令后应执行：

1. 使用已存在的本地仓库，或将仓库克隆到临时目录；不要把模板仓库直接当作新游戏目录。
2. 优先下载本仓库 GitHub Release 中的含引擎 ZIP；只有使用源码仓库时，才运行 `scripts/build_lazy_pack.ps1 -IncludeGodot` 构建 ZIP。
3. 将 ZIP 解压到临时目录，运行 `template/scripts/find_godot_candidates.ps1`。
4. 展示所有 Godot 4.7.1 候选项的版本和绝对路径，等待用户确认。即使只有一个候选项也不得静默选择。
5. 以确认路径作为 `-GodotBin` 运行 ZIP 根目录的 `install.ps1`。
6. 进入新项目，在新的 PowerShell 进程中运行 `scripts/verify.ps1`。
7. 检查 MCP、共享规则、Error 索引、Excel 资产台账和 `tools/godot-bin.path` 是否存在，并报告验证结果与仍需人工处理的事项。

安装器会将确认后的 Godot 路径保存到被 Git 忽略的 `tools/godot-bin.path`，因此后续打开编辑器、运行游戏或验证不依赖临时环境变量。

## 包含内容

- Godot 4.7.1 + typed GDScript 基础工程、示例场景和轻量行为测试。
- `scripts/verify.ps1`：导入、语法检查、场景 smoke test、组件测试与依赖审计。
- 场景节点持久化错误经验与示例契约测试，防止 AI 用运行时节点替代应在编辑器中维护的场景结构。
- GitHub Actions 持续验证、原型场景规范、`.editorconfig` 和 Excel 资产台账模板。
- Git、Git LFS、作用域暂存和 Angular/Conventional Commits 规范。
- `AGENTS.md`、按任务读取的 Error 索引、`.mcp.json` 与 Godot MCP addon。
- 中文安装说明；开发时直接描述任务，项目文档由用户主导整理。
- 架构、资源体积/未来分包、性能、输入、UI、存档与游戏专项规范。
- 基础设施、普通功能、垂直切片三阶段的验证和试玩门槛。

## 安装内容边界

`scripts/copy_template.ps1` 统一选择开发内容。安装说明和包维护清单留在源码或发行包外层，不进入游戏项目；不附带工具专用技能、自动记忆或固定交接文件。

AGENTS 直接保留重要规则，特别要求玩法逻辑和执行顺序可读；Error 索引按任务关键词与操作命中。素材来源随变更登记到 XLSX，生成提示词记录可选。历史决策不作为新游戏项目文档复制。

直接从源码创建新项目也使用相同清单：先发现并确认引擎，再运行 `scripts/create_new_project_from_template.ps1 -TargetPath <新目录> -GodotBin <确认路径>`。此流程只用于新项目，不迁移已有游戏。

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

## 持续验证

`.github/workflows/verify.yml` 会在每次 push、Pull Request 或手动触发时下载官方 Linux Godot 4.7.1，并运行同一条 `scripts/verify.ps1`。新项目推送到 GitHub 后，确认仓库的 Actions 已启用，并将失败视为需要修复的验证结果。

## 不包含内容

- 你的游戏内容、导出包和 `.godot/` 缓存；轻量包不含引擎，含引擎版本另行构建。
- Codex CLI。
- 自动下载的未知 skills 或不受控的全局工具。

## 本地验证

```powershell
powershell -ExecutionPolicy Bypass -File scripts\verify.ps1
powershell -ExecutionPolicy Bypass -File scripts\build_lazy_pack.ps1 -IncludeGodot
```

安装包维护时运行 `powershell -ExecutionPolicy Bypass -File scripts/test_template_content.ps1`，检查安装边界、必需文件和 Error 链接；可通过 `-ProjectPaths` 传入已安装项目检查文档一致性。此检查脚本不安装到游戏项目。

详细安装约束见 [docs/next_project_prompt.md](docs/next_project_prompt.md)。
