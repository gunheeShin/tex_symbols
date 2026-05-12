# =============================================================
# watch-preamble.ps1
#
# Watches include/**/*.tex for changes and auto-rebuilds
# preamble.sty via build-preamble.ps1.
#
# The MathJax Preamble Manager plugin (Obsidian) detects the
# preamble.sty change and hot-reloads -- no Ctrl+R needed.
#
# Usage (from vault root):
#   pwsh -ExecutionPolicy Bypass -File tex/obsidian/watch-preamble.ps1
#
# PowerShell profile alias:
#   function watch-tex {
#       pwsh -ExecutionPolicy Bypass -File "C:\path\to\vault\tex\obsidian\watch-preamble.ps1"
#   }
# =============================================================

$ErrorActionPreference = "Stop"
$texDir      = Split-Path $PSScriptRoot -Parent         # tex/
$watchDir    = Join-Path $texDir "include"
$buildScript = Join-Path $PSScriptRoot "build-preamble.ps1"

if (-not (Test-Path $watchDir)) {
    Write-Error "Cannot find $watchDir"
    exit 1
}

$watcher = New-Object System.IO.FileSystemWatcher
$watcher.Path                  = $watchDir
$watcher.Filter                = "*.tex"
$watcher.IncludeSubdirectories = $true
$watcher.EnableRaisingEvents   = $true

# Catch up any changes that happened before the watcher started.
Write-Host "Running initial build to sync preamble.sty..." -ForegroundColor DarkGray
try {
    & $buildScript
} catch {
    Write-Host "  Initial build failed: $_" -ForegroundColor Red
}

# Shared context between event handler invocations.
# (Windows PowerShell 5.1 cannot use $using: inside Register-ObjectEvent -Action,
#  so we pass state in via -MessageData as a mutable hashtable.)
$ctx = @{
    BuildScript = $buildScript
    LastBuild   = [DateTime]::MinValue
}

$action = {
    try {
        $ctx = $Event.MessageData
        $now = Get-Date

        # Debounce: skip duplicate events fired within 500ms
        if (($now - $ctx.LastBuild).TotalMilliseconds -lt 500) { return }
        $ctx.LastBuild = $now

        $changed = $Event.SourceEventArgs.Name
        Write-Host "[$($now.ToString('HH:mm:ss'))] Changed: $changed" -ForegroundColor Yellow

        Start-Sleep -Milliseconds 100
        & $ctx.BuildScript
    } catch {
        Write-Host "  Build failed: $_" -ForegroundColor Red
    }
}

Register-ObjectEvent $watcher Changed -Action $action -MessageData $ctx | Out-Null
Register-ObjectEvent $watcher Created -Action $action -MessageData $ctx | Out-Null
Register-ObjectEvent $watcher Deleted -Action $action -MessageData $ctx | Out-Null
Register-ObjectEvent $watcher Renamed -Action $action -MessageData $ctx | Out-Null

Write-Host "Watching $watchDir" -ForegroundColor Cyan
Write-Host "  -> rebuilds preamble.sty on .tex change (hot-reload in Obsidian)" -ForegroundColor Cyan
Write-Host "  Press Ctrl+C to stop." -ForegroundColor DarkGray

try {
    while ($true) { Wait-Event -Timeout 1 }
} finally {
    $watcher.Dispose()
    Write-Host "Watcher stopped." -ForegroundColor DarkGray
}
