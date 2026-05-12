# =============================================================
# watch-preamble.ps1
#
# Watches include/**/*.tex for changes and auto-rebuilds
# preamble.sty via build-preamble.ps1.
#
# The MathJax Preamble Manager plugin (Obsidian) detects the
# preamble.sty change and hot-reloads -- no Ctrl+R needed.
#
# Usage:
#   pwsh -ExecutionPolicy Bypass -File tex/watch-preamble.ps1
#
# PowerShell profile alias (recommended):
#   function watch-tex {
#       pwsh -ExecutionPolicy Bypass -File "C:\path\to\vault\tex\watch-preamble.ps1"
#   }
# =============================================================

$ErrorActionPreference = "Stop"
$texDir      = $PSScriptRoot
$watchDir    = Join-Path $texDir "include"
$buildScript = Join-Path $texDir "build-preamble.ps1"

if (-not (Test-Path $watchDir)) {
    Write-Error "Cannot find $watchDir"
    exit 1
}

$watcher = New-Object System.IO.FileSystemWatcher
$watcher.Path                  = $watchDir
$watcher.Filter                = "*.tex"
$watcher.IncludeSubdirectories = $true
$watcher.EnableRaisingEvents   = $true

# Debounce: skip duplicate events fired within 500ms
$script:lastBuild = [DateTime]::MinValue

$action = {
    $now = Get-Date
    if (($now - $script:lastBuild).TotalMilliseconds -lt 500) { return }
    $script:lastBuild = $now

    $changed = $Event.SourceEventArgs.Name
    Write-Host "[$($now.ToString('HH:mm:ss'))] Changed: $changed" -ForegroundColor Yellow

    Start-Sleep -Milliseconds 100
    try {
        & $using:buildScript
    } catch {
        Write-Host "  Build failed: $_" -ForegroundColor Red
    }
}

Register-ObjectEvent $watcher Changed -Action $action | Out-Null
Register-ObjectEvent $watcher Created -Action $action | Out-Null
Register-ObjectEvent $watcher Deleted -Action $action | Out-Null
Register-ObjectEvent $watcher Renamed -Action $action | Out-Null

Write-Host "Watching $watchDir" -ForegroundColor Cyan
Write-Host "  -> rebuilds preamble.sty on .tex change (hot-reload in Obsidian)" -ForegroundColor Cyan
Write-Host "  Press Ctrl+C to stop." -ForegroundColor DarkGray

try {
    while ($true) { Wait-Event -Timeout 1 }
} finally {
    $watcher.Dispose()
    Write-Host "Watcher stopped." -ForegroundColor DarkGray
}
