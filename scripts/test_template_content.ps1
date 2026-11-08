param(
    [string[]]$ProjectPaths = @()
)

$ErrorActionPreference = "Stop"
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$scratchRoot = Join-Path $repoRoot (".tmp\template-content-" + [Guid]::NewGuid().ToString("N"))
$copyScript = Join-Path $PSScriptRoot "copy_template.ps1"

# Check the installed contract independently of the copy implementation.
function Assert-ProjectContent {
    param([string]$Root)

    foreach ($required in @(
        "AGENTS.md", ".mcp.json", "project.godot", "scripts/verify.ps1", "scripts/record_game.ps1", "docs/assets/asset_manifest.xlsx", "docs/errors/index.md",
        "docs/项目说明.md",
        "addons/godot_mcp/plugin.cfg", "addons/godot_mcp/plugin.gd", "addons/godot_mcp/mcp_client.gd",
        "addons/godot_mcp/tool_executor.gd", "addons/godot_mcp/runtime/mcp_runtime.gd",
        "addons/godot_mcp/tools/file_tools.gd", "addons/godot_mcp/tools/scene_tools.gd",
        "addons/godot_mcp/tools/script_tools.gd", "addons/godot_mcp/tools/project_tools.gd",
        "addons/godot_mcp/tools/asset_tools.gd", "addons/godot_mcp/tools/visualizer_tools.gd",
        "addons/godot_mcp/utils/paths.gd", "addons/godot_mcp/utils/variant_codec.gd"
    )) {
        if (-not (Test-Path -LiteralPath (Join-Path $Root $required) -PathType Leaf)) {
            throw "Missing project content: $required in $Root"
        }
    }
    foreach ($retired in @(".claude", "docs/decisions", "docs/lessons", "docs/ai_memory.md", "docs/ai_workflow.md", "docs/session_handoff.md", "docs/prompts.md", "docs/next_project_prompt.md", "docs/lazy_pack_README_CN.md", "docs/template_manifest.md", "docs/assets/asset_manifest.md", "scripts/ai_context.ps1", "scripts/build_lazy_pack.ps1", "scripts/create_new_project_from_template.ps1", "scripts/test_verification.ps1")) {
        if (Test-Path -LiteralPath (Join-Path $Root $retired)) {
            throw "Non-project content leaked: $retired in $Root"
        }
    }
    foreach ($maintenance in @("maintenance", "scripts/prepare_behavior_case.ps1", "scripts/test_behavior_checks.ps1", "scripts/test_recording.ps1")) {
        if (Test-Path -LiteralPath (Join-Path $Root $maintenance)) { throw "Maintenance content leaked: $maintenance in $Root" }
    }

    $indexPath = Join-Path $Root "docs/errors/index.md"
    $index = Get-Content -LiteralPath $indexPath -Raw -Encoding UTF8
    $links = [regex]::Matches($index, '\]\(([^)]+\.md)\)')
    if ($links.Count -ne 7) { throw "Expected seven Error records." }
    foreach ($link in $links) {
        if (-not (Test-Path -LiteralPath (Join-Path (Split-Path -Parent $indexPath) $link.Groups[1].Value))) {
            throw "Broken Error link: $($link.Groups[1].Value)"
        }
    }
}

try {
    $fixture = Join-Path $scratchRoot "source"
    $target = Join-Path $scratchRoot "project"
    & $copyScript -SourceRoot $repoRoot -TargetRoot $fixture
    Set-Content -LiteralPath (Join-Path $fixture "docs/installation-only.md") -Value "Must not enter a game project." -Encoding UTF8
    New-Item -ItemType Directory -Path (Join-Path $fixture ".claude") | Out-Null
    Set-Content -LiteralPath (Join-Path $fixture ".claude/settings.json") -Value '{}' -Encoding UTF8
    Set-Content -LiteralPath (Join-Path $fixture "CLAUDE.md") -Value "Source-local instructions, not distributed." -Encoding UTF8
    & $copyScript -SourceRoot $fixture -TargetRoot $target
    Assert-ProjectContent -Root $target
    if (Test-Path -LiteralPath (Join-Path $target "docs/installation-only.md")) {
        throw "Unlisted documentation was copied."
    }
    if (Test-Path -LiteralPath (Join-Path $target "CLAUDE.md")) {
        throw "Source-local CLAUDE.md was copied."
    }
    # 不分发 CLAUDE.md，不等于禁止用户在自己的项目中创建它。
    Set-Content -LiteralPath (Join-Path $target "CLAUDE.md") -Value "User-owned instructions." -Encoding UTF8
    Assert-ProjectContent -Root $target

    # 每轮恢复源文件，分别验证台账、插件入口和依赖缺失，并确保失败发生在复制前。
    foreach ($missing in @("docs/项目说明.md", "docs/assets/asset_manifest.xlsx", "scripts/record_game.ps1", "addons/godot_mcp/plugin.cfg", "addons/godot_mcp/plugin.gd", "addons/godot_mcp/utils/paths.gd", "addons/godot_mcp/runtime/mcp_runtime.gd")) {
        $missingPath = Join-Path $fixture $missing
        $backup = [IO.File]::ReadAllBytes($missingPath)
        Remove-Item -LiteralPath $missingPath
        $missingFileRejected = $false
        try {
            & $copyScript -SourceRoot $fixture -TargetRoot (Join-Path $scratchRoot "incomplete")
        }
        catch {
            if ($_.Exception.Message -ne "Required template content missing: $missing") { throw }
            $missingFileRejected = $true
        }
        finally {
            [IO.File]::WriteAllBytes($missingPath, $backup)
        }
        if (-not $missingFileRejected) { throw "Missing file was silently accepted: $missing" }
        if (Test-Path -LiteralPath (Join-Path $scratchRoot "incomplete")) { throw "Incomplete content was copied before validation." }
    }

    foreach ($project in $ProjectPaths) {
        Assert-ProjectContent -Root $project
        # Installation may change project name and engine path, but not the rules or asset template.
        foreach ($source in (Get-ChildItem -LiteralPath (Join-Path $target "docs") -Recurse -File)) {
            $relative = $source.FullName.Substring($target.Length + 1)
            $installed = Join-Path $project $relative
            if ((Get-FileHash -LiteralPath $source.FullName).Hash -ne (Get-FileHash -LiteralPath $installed).Hash) {
                throw "Installed document differs: $relative"
            }
        }
        if ((Get-FileHash -LiteralPath (Join-Path $target "AGENTS.md")).Hash -ne (Get-FileHash -LiteralPath (Join-Path $project "AGENTS.md")).Hash) {
            throw "Installed AGENTS differs."
        }
    }
    Write-Host "Template content checks passed: exclusions, required files, Error links and installed document parity."
}
finally {
    if (Test-Path -LiteralPath $scratchRoot) {
        $resolvedScratch = (Resolve-Path -LiteralPath $scratchRoot).Path
        $allowedPrefix = Join-Path (Join-Path $repoRoot ".tmp") "template-content-"
        if (-not $resolvedScratch.StartsWith($allowedPrefix, [StringComparison]::OrdinalIgnoreCase)) {
            throw "Refusing to remove a directory outside the test workspace."
        }
        Remove-Item -LiteralPath $resolvedScratch -Recurse -Force
    }
}
