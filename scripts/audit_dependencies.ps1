$ErrorActionPreference = "Stop"

$projectRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$violations = New-Object System.Collections.Generic.List[string]

$rules = @(
    @{
        From = "res://scripts/core/"
        Forbidden = @("res://scripts/gameplay/", "res://scripts/ui/", "res://scenes/gameplay/", "res://scenes/ui/", "res://scenes/levels/")
        Message = "core must not depend on gameplay/ui/scenes"
    },
    @{
        From = "res://scripts/components/"
        Forbidden = @("res://scenes/gameplay/", "res://scenes/levels/", "res://assets/gameplay/", "res://assets/levels/")
        Message = "components must stay reusable and avoid concrete gameplay scenes/assets"
    },
    @{
        From = "res://scripts/ui/"
        Forbidden = @("res://scenes/levels/", "res://assets/levels/")
        Message = "ui must not depend on level packages"
    },
    @{
        From = "res://resources/shared/"
        Forbidden = @("res://assets/gameplay/", "res://assets/levels/", "res://scenes/gameplay/", "res://scenes/levels/")
        Message = "shared resources must not pull concrete package assets/scenes"
    }
)

$textFiles = Get-ChildItem -LiteralPath $projectRoot -Recurse -File -ErrorAction SilentlyContinue |
    Where-Object {
        $_.FullName -notmatch "\\.git\\|\\.godot\\|\\.tmp\\|\\dist\\|\\tools\\" -and
        $_.Extension -in @(".gd", ".tscn", ".tres", ".godot", ".cfg")
    }

foreach ($file in $textFiles) {
    $relativePath = $file.FullName.Substring($projectRoot.Path.Length + 1).Replace("\", "/")
    $resPath = "res://" + $relativePath
    $content = Get-Content -Raw -Encoding UTF8 -LiteralPath $file.FullName

    foreach ($rule in $rules) {
        if (-not $resPath.StartsWith($rule.From)) {
            continue
        }

        foreach ($forbidden in $rule.Forbidden) {
            if ($content.Contains($forbidden)) {
                $violations.Add("$resPath references $forbidden ($($rule.Message))")
            }
        }
    }
}

$sharedAssetExtensions = @(".png", ".jpg", ".jpeg", ".webp", ".gif", ".wav", ".ogg", ".mp3", ".glb", ".gltf", ".fbx")
$sharedAssetRoots = @("assets\shared", "resources\shared")

foreach ($root in $sharedAssetRoots) {
    $path = Join-Path $projectRoot $root
    if (-not (Test-Path -LiteralPath $path)) {
        continue
    }

    Get-ChildItem -LiteralPath $path -Recurse -File -ErrorAction SilentlyContinue |
        Where-Object { $_.Extension.ToLowerInvariant() -in $sharedAssetExtensions -and $_.Length -gt 5MB } |
        ForEach-Object {
            $violations.Add("Large shared asset may bloat every package: $($_.FullName.Substring($projectRoot.Path.Length + 1)) ($([math]::Round($_.Length / 1MB, 2)) MB)")
        }
}

if ($violations.Count -gt 0) {
    Write-Host "Dependency audit failed:"
    foreach ($violation in $violations) {
        Write-Host " - $violation"
    }
    exit 1
}

Write-Host "Dependency audit passed."

