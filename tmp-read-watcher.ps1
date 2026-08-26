$ErrorActionPreference = 'Continue'
$ip = '192.168.0.104'
Write-Host '===== REMOTE watcher.ps1 (full) =====' -ForegroundColor Cyan
Get-Content "\\$ip\C$\deploy-agent\watcher.ps1"
