param(
    [Parameter(Mandatory = $true)]
    [string]$SourceRoot,
    [Parameter(Mandatory = $true)]
    [string]$TargetRoot,
    [switch]$CopyBundledTools
)

$ErrorActionPreference = "Stop"

# 打包、直接创建与 ZIP 安装共用此清单；安装说明和维护脚本不进入游戏项目。
$projectItems = @(
    ".github", "addons", "scenes", "tests", "scripts/components",
    "scripts/main.gd",
    "scripts/verify.ps1", "scripts/audit_dependencies.ps1",
    "scripts/resolve-godot.ps1", "scripts/find_godot_candidates.ps1",
    "scripts/open_editor.ps1", "scripts/run_game.ps1", "scripts/record_game.ps1",
    ".editorconfig", ".gitattributes", ".gitignore", ".mcp.json", "AGENTS.md", "project.godot",
    "docs/engineering_rules.md", "docs/game_development_rules.md",
    "docs/architecture_rules.md", "docs/prototype_scene_rules.md",
    "docs/assets/asset_manifest.xlsx", "docs/errors/index.md",
    "docs/errors/0001-verification-must-fail-hard.md",
    "docs/errors/0002-godot-signal-tests-need-stable-counters.md",
    "docs/errors/0003-do-not-trust-noninteractive-summary-output.md",
    "docs/errors/0004-negative-tests-must-not-live-in-excluded-paths.md",
    "docs/errors/0005-godot-path-must-survive-installer-process.md",
    "docs/errors/0006-runtime-nodes-do-not-replace-scene-authoring.md",
    "docs/errors/0007-ci-must-set-godot-bin.md"
)

# 目录存在不代表插件完整；这些是当前随包提供的 MCP 插件必需文件。
$pluginFiles = @(
    "addons/godot_mcp/plugin.cfg", "addons/godot_mcp/plugin.gd",
    "addons/godot_mcp/mcp_client.gd", "addons/godot_mcp/tool_executor.gd",
    "addons/godot_mcp/runtime/mcp_runtime.gd",
    "addons/godot_mcp/tools/file_tools.gd", "addons/godot_mcp/tools/scene_tools.gd",
    "addons/godot_mcp/tools/script_tools.gd", "addons/godot_mcp/tools/project_tools.gd",
    "addons/godot_mcp/tools/asset_tools.gd", "addons/godot_mcp/tools/visualizer_tools.gd",
    "addons/godot_mcp/utils/paths.gd", "addons/godot_mcp/utils/variant_codec.gd"
)

# 先完成预检，避免缺文件时已经向目标目录复制了一部分内容。
foreach ($item in $projectItems) {
    $source = Join-Path $SourceRoot $item
    if (-not (Test-Path -LiteralPath $source)) {
        throw "Required template content missing: $item"
    }
}
foreach ($item in $pluginFiles) {
    if (-not (Test-Path -LiteralPath (Join-Path $SourceRoot $item) -PathType Leaf)) {
        throw "Required template content missing: $item"
    }
}
foreach ($item in $projectItems) {
    $source = Join-Path $SourceRoot $item
    $destination = Join-Path $TargetRoot $item
    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $destination) | Out-Null
    Copy-Item -LiteralPath $source -Destination $destination -Recurse -Force
}

# UID 由新项目重新导入生成；复制清单不依赖上一次导入留下的 UID。
Get-ChildItem -LiteralPath $TargetRoot -Recurse -Filter "*.uid" -File |
    Remove-Item -Force

if ($CopyBundledTools) {
    $bundledTools = Join-Path $SourceRoot "tools"
    if (Test-Path -LiteralPath $bundledTools) {
        Copy-Item -LiteralPath $bundledTools -Destination (Join-Path $TargetRoot "tools") -Recurse -Force
    }
}
