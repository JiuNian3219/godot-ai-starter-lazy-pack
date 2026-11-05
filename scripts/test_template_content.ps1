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

    foreach ($required in @("AGENTS.md", ".mcp.json", "project.godot", "scripts/verify.ps1", "docs/assets/asset_manifest.xlsx", "docs/errors/index.md")) {
        if (-not (Test-Path -LiteralPath (Join-Path $Root $required))) {
            throw "Missing project content: $required in $Root"
        }
    }
    foreach ($retired in @("CLAUDE.md", ".claude", "docs/decisions", "docs/lessons", "docs/ai_memory.md", "docs/ai_workflow.md", "docs/session_handoff.md", "docs/prompts.md", "docs/next_project_prompt.md", "docs/lazy_pack_README_CN.md", "docs/template_manifest.md", "docs/assets/asset_manifest.md", "scripts/ai_context.ps1", "scripts/build_lazy_pack.ps1", "scripts/create_new_project_from_template.ps1")) {
        if (Test-Path -LiteralPath (Join-Path $Root $retired)) {
            throw "Non-project content leaked: $retired in $Root"
        }
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
    & $copyScript -SourceRoot $fixture -TargetRoot $target
    Assert-ProjectContent -Root $target
    if (Test-Path -LiteralPath (Join-Path $target "docs/installation-only.md")) {
        throw "Unlisted documentation was copied."
    }

    # A missing required workbook must fail instead of silently creating an incomplete project.
    Remove-Item -LiteralPath (Join-Path $fixture "docs/assets/asset_manifest.xlsx")
    $missingFileRejected = $false
    try {
        & $copyScript -SourceRoot $fixture -TargetRoot (Join-Path $scratchRoot "incomplete")
    }
    catch {
        if ($_.Exception.Message -notlike '*Required template content missing: docs/assets/asset_manifest.xlsx*') { throw }
        $missingFileRejected = $true
    }
    if (-not $missingFileRejected) { throw "Missing workbook was silently accepted." }

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
        $allowedPrefix = $repoRoot + "\.tmp\template-content-"
        if (-not $resolvedScratch.StartsWith($allowedPrefix, [StringComparison]::OrdinalIgnoreCase)) {
            throw "Refusing to remove a directory outside the test workspace."
        }
        Remove-Item -LiteralPath $resolvedScratch -Recurse -Force
    }
}
