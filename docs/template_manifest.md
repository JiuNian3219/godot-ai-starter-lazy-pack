# 懒人包内容清单

此文件供安装包维护与检查使用，不安装到游戏项目。`scripts/copy_template.ps1` 是打包、直接创建项目和 ZIP 安装共用的内容选择入口；ZIP 中同一脚本位于包根目录。

## 开发项目内容

- Godot 4.7.1 GDScript 工程、示例场景、HealthComponent、行为测试与持久场景结构测试。
- `AGENTS.md`：关键规则、玩法可读性、验证和提交要求，以及按需读取入口。
- 四份专项规则：工程、架构、游戏开发和原型场景。
- `docs/errors/index.md` 及七条错误经验；根据任务关键词和操作命中后读取，不自动写入新经验。
- `docs/assets/asset_manifest.xlsx`：单表资产台账。素材变更同步登记，提示词记录可选。
- `.mcp.json` 与 `addons/godot_mcp/`。MCP 服务仍固定为 `godot-mcp-server@0.5.0`，通过 Node.js 的 npx 启动。
- `.github/workflows/verify.yml`、编辑器/Git 配置、导入验证、依赖审计、引擎定位、编辑器和运行脚本。

## 安装包外层

ZIP 根目录包含安装器、统一复制脚本、中文使用说明、INSTALL.md、TEMPLATE_MANIFEST.md 与版本信息；这些资料不复制到新游戏项目。源码的构建和直接创建脚本也不安装到游戏项目。

含引擎版本额外携带 Windows x64 Godot 4.7.1 可执行文件与 ENGINE_MANIFEST.txt，安装时复制并保存目标路径。轻量版本使用用户确认的外部引擎。两者都生成 ZIP 的 SHA-256 校验文件。引擎和生成产物不进入 Git。

## 依赖与验证

需要 Git、Git LFS、Node.js/npm/npx 和 Godot 4.7.1。AI 工具入口任选支持项目规则的客户端，Claude Code 非必需，不需要 Codex CLI 或额外技能包。

在安装后的新进程中运行 `powershell -ExecutionPolicy Bypass -File scripts/verify.ps1`，验证导入、语法、场景实例化、持久节点、HealthComponent 行为和依赖边界；推送后检查 GitHub Actions。

`.godot/`、`.tmp/`、本地引擎及路径配置、构建和导出物不提交。用户自己的项目说明由用户主导整理，安装器不生成长期记忆或交接文件。
