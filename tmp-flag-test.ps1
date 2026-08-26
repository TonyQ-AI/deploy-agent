$ErrorActionPreference = 'Continue'
$ip = '192.168.0.104'
$proj = "\\$ip\E$\runserv\job-ai-efficiency-generator-v2"
$flag = "$proj\.deploy-flag"
$wlog = "$proj\logs\watcher.log"

# drop the flag
echo "deploy-$(Get-Date -Format yyyyMMddHHmmss)" | Set-Content -Path $flag -Encoding ASCII
Write-Host ("flag written: " + (Test-Path $flag))
Write-Host 'waiting for watcher to pick up...'
Start-Sleep -Seconds 8

Write-Host '== watcher.log ==' -ForegroundColor Cyan
Get-Content $wlog

Write-Host ''
Write-Host '== flag consumed (should be False)? ==' -ForegroundColor Cyan
Write-Host ("  flag still exists: " + (Test-Path $flag))
