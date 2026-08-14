# Daily fallback check - runs 02:00 daily (SYSTEM)
# 1. Consume leftover .deploy-flag (if watcher missed it)
# 2. Restart watcher if it died
$ErrorActionPreference = 'Continue'
$configPath = 'C:\deploy-agent\projects.config'
$watchTask = 'MediaManager-watcher'

$projects = @()
try {
    $projects = Get-Content $configPath -Raw -Encoding UTF8 | ConvertFrom-Json
} catch {
    $projects = @(@{ name = 'MediaManager-online'; path = 'E:\runserv\MediaManager-online'; flag = '.deploy-flag' })
}

# --- 1. Consume leftover flags ---
foreach ($p in $projects) {
    $flagFile = Join-Path $p.path $p.flag
    $restartCmd = Join-Path $p.path 'restart.cmd'
    $logFile = Join-Path $p.path 'logs\watcher.log'

    if (Test-Path $flagFile) {
        Add-Content -Path $logFile -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') [daily] leftover flag found, deploying" -Encoding UTF8
        if (Test-Path $restartCmd) {
            Start-Process cmd.exe -ArgumentList "/c `"$restartCmd`"" -WindowStyle Hidden
            Add-Content -Path $logFile -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') [daily] restart executed" -Encoding UTF8
        }
        Remove-Item $flagFile -Force -ErrorAction SilentlyContinue
        Add-Content -Path $logFile -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') [daily] flag consumed" -Encoding UTF8
    }
}

# --- 2. Ensure watcher alive ---
$watcherRunning = Get-CimInstance Win32_Process -Filter "Name='powershell.exe'" | Where-Object { $_.CommandLine -like '*watcher.ps1*' }
if (-not $watcherRunning) {
    $logFile = Join-Path $projects[0].path 'logs\watcher.log'
    Add-Content -Path $logFile -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') [daily] watcher dead, restarting..." -Encoding UTF8
    schtasks /Run /TN $watchTask 2>&1 | Out-Null
    Add-Content -Path $logFile -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') [daily] watcher restart triggered" -Encoding UTF8
}
