# reshade_watcher.ps1
# ─────────────────────────────────────────────────────────────────────────────
# Orion Drift Cinematic Camera – ReShade Toggle Watcher
#
# This script watches the cinematic camera config JSON file for changes.
# When "reshadeEnabled" flips, it sends the ReShade global-enable hotkey
# (default: Scroll Lock) to the game window.
#
# SETUP:
#  1. Open ReShade's in-game overlay, go to Settings > General.
#     Set "Effect toggle key" to Scroll Lock (or change $RESHADE_KEY below).
#  2. Run this script in the background:
#       powershell -ExecutionPolicy Bypass -File reshade_watcher.ps1
#  3. Use the ReShade ON/OFF button in the Cinematic Camera GUI.
# ─────────────────────────────────────────────────────────────────────────────

$CONFIG_PATH = "$env:USERPROFILE\Documents\Another-Axiom\A2\Cameras\Configs\cinematic.camera.json"
$GAME_WINDOW = "Orion Drift"   # Partial window title match
$RESHADE_KEY = "{SCROLLLOCK}"  # Virtual key sent to game window

Add-Type -AssemblyName System.Windows.Forms

function Get-ReshadeState {
    if (-not (Test-Path $CONFIG_PATH)) { return $null }
    try {
        $json = Get-Content $CONFIG_PATH -Raw | ConvertFrom-Json
        return $json.customdata.reshadeEnabled
    } catch {
        return $null
    }
}

function Send-KeyToGame {
    param([string]$Key)
    $wshell = New-Object -ComObject WScript.Shell
    $hwnd = (Get-Process | Where-Object { $_.MainWindowTitle -like "*$GAME_WINDOW*" } | Select-Object -First 1)
    if ($hwnd) {
        $wshell.AppActivate($hwnd.Id) | Out-Null
        Start-Sleep -Milliseconds 80
        [System.Windows.Forms.SendKeys]::SendWait($Key)
    } else {
        Write-Host "$(Get-Date -f 'HH:mm:ss') Game window not found: $GAME_WINDOW"
    }
}

Write-Host "Watching: $CONFIG_PATH"
Write-Host "ReShade key: $RESHADE_KEY"
Write-Host "Press Ctrl+C to stop."

$lastState = Get-ReshadeState
$watcher = New-Object System.IO.FileSystemWatcher
$watcher.Path   = [System.IO.Path]::GetDirectoryName($CONFIG_PATH)
$watcher.Filter = [System.IO.Path]::GetFileName($CONFIG_PATH)
$watcher.EnableRaisingEvents = $true

while ($true) {
    $changed = $watcher.WaitForChanged([System.IO.WatcherChangeTypes]::Changed, 2000)
    if (-not $changed.TimedOut) {
        Start-Sleep -Milliseconds 150   # let the file finish writing
        $newState = Get-ReshadeState
        if ($newState -ne $null -and $newState -ne $lastState) {
            $label = if ($newState) { "ENABLED" } else { "DISABLED" }
            Write-Host "$(Get-Date -f 'HH:mm:ss') ReShade toggled → $label"
            Send-KeyToGame -Key $RESHADE_KEY
            $lastState = $newState
        }
    }
}
