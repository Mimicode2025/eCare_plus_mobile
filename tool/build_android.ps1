param([switch]$Release)

$projectRoot = Split-Path -Parent $PSScriptRoot
$platformFlags = @('FLUTTER_WINDOWS', 'FLUTTER_LINUX', 'FLUTTER_MACOS')
$previousFlags = @{}
Push-Location -LiteralPath $projectRoot
try {
    foreach ($flag in $platformFlags) {
        $previousFlags[$flag] = [Environment]::GetEnvironmentVariable($flag, 'Process')
        [Environment]::SetEnvironmentVariable($flag, 'false', 'Process')
    }
    # Android registration must complete before building native plugins.
    & flutter pub get
    if ($LASTEXITCODE -ne 0) { throw 'Flutter dependency and plugin generation failed.' }
    $buildMode = if ($Release) { '--release' } else { '--debug' }
    & flutter build apk $buildMode --no-pub
    if ($LASTEXITCODE -ne 0) { throw 'Android compilation failed.' }
} finally {
    foreach ($flag in $previousFlags.Keys) {
        [Environment]::SetEnvironmentVariable($flag, $previousFlags[$flag], 'Process')
    }
    Pop-Location
}
