$ErrorActionPreference = 'Stop'
$ip = '192.168.0.104'
$remote = "\\$ip\E$\runserv\job-ai-efficiency-generator-v2"
$local  = 'E:\AiDatas\projects\job-ai-efficiency-generator-v2'

Copy-Item "$local\server\.env.prod-staging" "$remote\server\.env" -Force
Copy-Item "$local\restart.cmd" "$remote\restart.cmd" -Force

Write-Host 'server/.env ->' -ForegroundColor Cyan
Get-Content "$remote\server\.env" | Select-String -Pattern '^PORT|^DB_PATH|^JWT_SECRET|^LLM_|^REG_GUARD' | ForEach-Object { Write-Host ("  " + $_.Line) }
Write-Host ''
Write-Host 'restart.cmd ->' -ForegroundColor Cyan
Get-Content "$remote\restart.cmd" | Select-String -Pattern 'PORT=29001|LocalPort 29001'
