$ErrorActionPreference = 'Continue'
$ip = '192.168.0.104'

Write-Host '===== 1. remote projects.config =====' -ForegroundColor Cyan
Get-Content "\\$ip\C$\deploy-agent\projects.config" -ErrorAction SilentlyContinue

Write-Host ''
Write-Host '===== 2. remote watcher.ps1 (first 40 lines) =====' -ForegroundColor Cyan
Get-Content "\\$ip\C$\deploy-agent\watcher.ps1" -TotalCount 40 -ErrorAction SilentlyContinue

Write-Host ''
Write-Host '===== 3. remote MediaManager restart.cmd =====' -ForegroundColor Cyan
Get-Content "\\$ip\E$\runserv\MediaManager-online\restart.cmd" -ErrorAction SilentlyContinue

Write-Host ''
Write-Host '===== 4. Node version (file metadata) =====' -ForegroundColor Cyan
$ni = (Get-Item "\\$ip\C$\Program Files\nodejs\node.exe" -ErrorAction SilentlyContinue).VersionInfo
Write-Host ("  node.exe FileVersion: {0}" -f $ni.FileVersion)
Write-Host ("  node.exe ProductVersion: {0}" -f $ni.ProductVersion)

Write-Host ''
Write-Host '===== 5. full remote task list (*-watcher / DeployAgent) =====' -ForegroundColor Cyan
& schtasks /S $ip /Query /FO LIST 2>&1 | Select-String -Pattern 'TaskName|任务名|watcher|DeployAgent|MediaManager' -Context 0,1 | Select-Object -First 30

Write-Host ''
Write-Host '===== 6. remote store? is there a storage stock-sim data? just list runserv subdirs =====' -ForegroundColor Cyan
Get-ChildItem "\\$ip\E$\runserv" -Directory -ErrorAction SilentlyContinue | ForEach-Object { Write-Host ("  {0}\  (log: {1})" -f $_.Name, (Test-Path (Join-Path $_.FullName 'logs'))) }
