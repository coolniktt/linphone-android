param(
    [string]$MasterIcon = (Join-Path $PSScriptRoot "ulta-phone-icon-master.png")
)

$ErrorActionPreference = "Stop"
$repoRoot = Split-Path -Parent $PSScriptRoot
$magickCommand = Get-Command magick -ErrorAction Stop
$launcherBackground = "#01153A"

$densities = [ordered]@{
    mdpi = @{ Launcher = 48; Foreground = 108 }
    hdpi = @{ Launcher = 72; Foreground = 162 }
    xhdpi = @{ Launcher = 96; Foreground = 216 }
    xxhdpi = @{ Launcher = 144; Foreground = 324 }
    xxxhdpi = @{ Launcher = 192; Foreground = 432 }
}

function Invoke-Magick {
    param([string[]]$Arguments)

    & $magickCommand.Source @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw "ImageMagick failed with exit code $LASTEXITCODE"
    }
}

if (-not (Test-Path -LiteralPath $MasterIcon -PathType Leaf)) {
    throw "Master icon not found: $MasterIcon"
}

foreach ($density in $densities.GetEnumerator()) {
    $resourceDir = Join-Path $repoRoot "app/src/main/res/mipmap-$($density.Key)"
    $launcherSize = [int]$density.Value.Launcher
    $foregroundSize = [int]$density.Value.Foreground
    $legacyTileSize = [Math]::Round($launcherSize * 0.92)
    # Android's guaranteed adaptive-icon safe zone occupies roughly 63% of the layer.
    $adaptiveTileSize = [Math]::Round($foregroundSize * 0.63)
    $center = ($launcherSize - 1) / 2

    Invoke-Magick @(
        $MasterIcon,
        "-trim", "+repage",
        "-resize", "${legacyTileSize}x${legacyTileSize}",
        "-gravity", "center",
        "-background", "none",
        "-extent", "${launcherSize}x${launcherSize}",
        "-strip", "-depth", "8",
        (Join-Path $resourceDir "ic_launcher.png")
    )

    Invoke-Magick @(
        "-size", "${launcherSize}x${launcherSize}", "xc:$launcherBackground",
        "(", $MasterIcon, "-trim", "+repage", "-resize", "${legacyTileSize}x${legacyTileSize}", ")",
        "-gravity", "center", "-compose", "over", "-composite",
        "(", "-size", "${launcherSize}x${launcherSize}", "xc:none", "-fill", "white",
        "-draw", "circle $center,$center $center,0", ")",
        "-alpha", "off", "-compose", "CopyOpacity", "-composite",
        "-strip", "-depth", "8",
        (Join-Path $resourceDir "ic_launcher_round.png")
    )

    Invoke-Magick @(
        $MasterIcon,
        "-trim", "+repage",
        "-resize", "${adaptiveTileSize}x${adaptiveTileSize}",
        "-gravity", "center",
        "-background", "none",
        "-extent", "${foregroundSize}x${foregroundSize}",
        "-strip", "-depth", "8",
        (Join-Path $resourceDir "linphone_launcher_icon_foreground.png")
    )
}

$storeIcon = Join-Path $repoRoot "metadata/en-US/images/icon.png"
Invoke-Magick @(
    "-size", "512x512", "xc:$launcherBackground",
    "(", $MasterIcon, "-trim", "+repage", "-resize", "500x500", ")",
    "-gravity", "center", "-compose", "over", "-composite",
    "-alpha", "off",
    "-strip", "-depth", "8",
    $storeIcon
)

Write-Host "ULTA Phone Android icons generated from $MasterIcon"
