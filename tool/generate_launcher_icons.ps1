# Export the approved launcher artwork at the platform-required sizes.
# Run from the project with: powershell -File tool/generate_launcher_icons.ps1
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$projectRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$sourcePath = Join-Path $projectRoot 'assets/branding/launcher_foreground.png'
$source = [System.Drawing.Image]::FromFile($sourcePath)

function Save-LauncherPng {
    param([int]$Size, [string]$Path, [ValidateSet('opaque', 'rounded', 'foreground')][string]$Mode)
    $format = if ($Mode -eq 'opaque') { [System.Drawing.Imaging.PixelFormat]::Format24bppRgb } else { [System.Drawing.Imaging.PixelFormat]::Format32bppArgb }
    $bitmap = [System.Drawing.Bitmap]::new($Size, $Size, $format)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $clipPath = $null
    try {
        $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
        $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
        if ($Mode -eq 'rounded') {
            $graphics.Clear([System.Drawing.Color]::Transparent)
            $clipPath = [System.Drawing.Drawing2D.GraphicsPath]::new()
            $diameter = [single]($Size * .4)
            $edge = [single]($Size - $diameter)
            $clipPath.AddArc(0, 0, $diameter, $diameter, 180, 90)
            $clipPath.AddArc($edge, 0, $diameter, $diameter, 270, 90)
            $clipPath.AddArc($edge, $edge, $diameter, $diameter, 0, 90)
            $clipPath.AddArc(0, $edge, $diameter, $diameter, 90, 90)
            $clipPath.CloseFigure()
            $graphics.SetClip($clipPath)
            $graphics.FillRectangle([System.Drawing.Brushes]::White, 0, 0, $Size, $Size)
        } elseif ($Mode -eq 'opaque') {
            $graphics.Clear([System.Drawing.Color]::White)
        } else {
            $graphics.Clear([System.Drawing.Color]::Transparent)
        }
        $graphics.DrawImage($source, [System.Drawing.Rectangle]::new(0, 0, $Size, $Size))
        $directory = [System.IO.Path]::GetDirectoryName($Path)
        [System.IO.Directory]::CreateDirectory($directory) | Out-Null
        $bitmap.Save($Path, [System.Drawing.Imaging.ImageFormat]::Png)
    } finally {
        if ($clipPath) { $clipPath.Dispose() }
        $graphics.Dispose()
        $bitmap.Dispose()
    }
}

try {
    Save-LauncherPng 1024 (Join-Path $projectRoot 'assets/branding/launcher_icon.png') 'opaque'
    Save-LauncherPng 512 (Join-Path $projectRoot 'artifacts/icone-ecare.png') 'rounded'
    $densities = @{
        'mdpi' = @(48, 108)
        'hdpi' = @(72, 162)
        'xhdpi' = @(96, 216)
        'xxhdpi' = @(144, 324)
        'xxxhdpi' = @(192, 432)
    }
    foreach ($density in $densities.Keys) {
        Save-LauncherPng $densities[$density][0] (Join-Path $projectRoot "android/app/src/main/res/mipmap-$density/ic_launcher.png") 'rounded'
        Save-LauncherPng $densities[$density][1] (Join-Path $projectRoot "android/app/src/main/res/mipmap-$density/ic_launcher_foreground.png") 'foreground'
    }
    $catalogPath = Join-Path $projectRoot 'ios/Runner/Assets.xcassets/AppIcon.appiconset'
    $catalog = Get-Content -LiteralPath (Join-Path $catalogPath 'Contents.json') -Raw | ConvertFrom-Json
    foreach ($icon in $catalog.images) {
        $dimension = [double]::Parse($icon.size.Split('x')[0], [System.Globalization.CultureInfo]::InvariantCulture)
        $scale = [double]::Parse($icon.scale.TrimEnd('x'), [System.Globalization.CultureInfo]::InvariantCulture)
        Save-LauncherPng ([int]($dimension * $scale)) (Join-Path $catalogPath $icon.filename) 'opaque'
    }
    Write-Output 'Android launcher resources, iOS icon catalog and preview exported.'
} finally {
    $source.Dispose()
}
