# Deploy watcher v5 - single instance, config driven, multi-project
# Reads C:\deploy-agent\projects.config, polls each project's .deploy-flag
$ErrorActionPreference = 'Continue'
$configPath = 'C:\deploy-agent\projects.config'
$interval = 3  # seconds

$mutex = New-Object System.Threading.Mutex($false, 'Global\DeployWatcher')
if (-not $mutex.WaitOne(0)) { exit 0 }

# Load projects config
$projects = @()
try {
    $projects = Get-Content $configPath -Raw -Encoding UTF8 | ConvertFrom-Json
} catch {
    # config missing/invalid: fallback to MediaManager
    $projects = @(@{ name = 'MediaManager-online'; path = 'E:\runserv\MediaManager-online'; flag = '.deploy-flag' })
}

$lastStamps = @{}  # name -> last stamp

foreach ($p in $projects) {
    $logDir = Join-Path $p.path 'logs'
    New-Item -ItemType Directory -Force -Path $logDir | Out-Null
    $logFile = Join-Path $logDir 'watcher.log'
    Add-Content -Path $logFile -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') [watcher] started for $($p.name) (PID $PID)" -Encoding UTF8
}

Add-Content -Path (Join-Path $projects[0].path "logs\watcher.log") -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') [watcher] watching $($projects.Count) project(s), poll every ${interval}s" -Encoding UTF8

while ($true) {
    Start-Sleep -Seconds $interval
    foreach ($p in $projects) {
        $flagFile = Join-Path $p.path $p.flag
        $restartCmd = Join-Path $p.path 'restart.cmd'
        $logFile = Join-Path $p.path 'logs\watcher.log'

        $flag = Get-Item $flagFile -ErrorAction SilentlyContinue
        if (-not $flag) { $lastStamps[$p.name] = ''; continue }

        $stamp = $flag.LastWriteTime.Ticks.ToString()
        if ($lastStamps[$p.name] -eq $stamp) { continue }
        $lastStamps[$p.name] = $stamp

        Add-Content -Path $logFile -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') [watcher] deploy triggered ($($p.name))" -Encoding UTF8

        if (Test-Path $restartCmd) {
            Start-Process cmd.exe -ArgumentList "/c `"$restartCmd`"" -WindowStyle Hidden
            Add-Content -Path $logFile -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') [watcher] restart script executed" -Encoding UTF8
        } else {
            Add-Content -Path $logFile -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') [watcher] restart NOT FOUND: $restartCmd" -Encoding UTF8
        }

        Remove-Item $flagFile -Force -ErrorAction SilentlyContinue
        Add-Content -Path $logFile -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') [watcher] flag consumed" -Encoding UTF8
    }
}
