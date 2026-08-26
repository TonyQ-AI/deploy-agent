$ErrorActionPreference = 'Continue'
$ip = '192.168.0.104'
$wlog = "\\$ip\E$\runserv\job-ai-efficiency-generator-v2\logs\watcher.log"

Write-Host '== end MediaManager-watcher ==' -ForegroundColor Cyan
& schtasks /S $ip /End /TN MediaManager-watcher 2>&1 | Out-Null
Write-Host ('  end exit=' + $LASTEXITCODE)
Start-Sleep -Seconds 2

# ensure no watcher.ps1 process lingering (uses schtasks end; mutex will be released)
Write-Host '== run MediaManager-watcher ==' -ForegroundColor Cyan
& schtasks /S $ip /Run /TN MediaManager-watcher 2>&1 | Out-Null
Write-Host ('  run exit=' + $LASTEXITCODE)
Start-Sleep -Seconds 4

Write-Host ''
Write-Host '== my project watcher.log (should now show started line) ==' -ForegroundColor Cyan
if (Test-Path $wlog) { Get-Content $wlog } else { Write-Host '(no watcher.log yet)' }
