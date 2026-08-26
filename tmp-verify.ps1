$ErrorActionPreference = 'Continue'
$ip = '192.168.0.104'

Write-Host '########## 1. LOCAL check: did we create E:\192.168.0.104 ? ##########' -ForegroundColor Magenta
$localBad = 'E:\192.168.0.104'
if (Test-Path $localBad) {
  Write-Host ('  EXISTS: ' + $localBad) -ForegroundColor Red
  Write-Host '  --- contents ---'
  Get-ChildItem $localBad -Recurse -Depth 2 -ErrorAction SilentlyContinue | Select-Object -First 25 -ExpandProperty FullName
} else {
  Write-Host '  NOT present -> no local junk created.' -ForegroundColor Green
}

Write-Host ''
Write-Host '' 
Write-Host '########## 2. REMOTE check (via proper UNC .ps1) ##########' -ForegroundColor Magenta
Write-Host '--- remote E:\runserv\job-ai-efficiency-generator-v2 present? ---'
Write-Host ("  project dir: " + (Test-Path "\\$ip\E$\runserv\job-ai-efficiency-generator-v2"))
Write-Host ("  restart.cmd: " + (Test-Path "\\$ip\E$\runserv\job-ai-efficiency-generator-v2\restart.cmd"))
Write-Host ("  server\src\index.ts: " + (Test-Path "\\$ip\E$\runserv\job-ai-efficiency-generator-v2\server\src\index.ts"))
Write-Host ("  server\.env: " + (Test-Path "\\$ip\E$\runserv\job-ai-efficiency-generator-v2\server\.env"))
Write-Host ("  server\node_modules\express: " + (Test-Path "\\$ip\E$\runserv\job-ai-efficiency-generator-v2\server\node_modules\express"))
Write-Host ("  dist\client\index.html: " + (Test-Path "\\$ip\E$\runserv\job-ai-efficiency-generator-v2\dist\client\index.html"))

Write-Host '--- remote C:\deploy-agent\projects.config ---'
Get-Content "\\$ip\C$\deploy-agent\projects.config" -Raw -Encoding UTF8

Write-Host '--- remote tunnel config ingress ---'
Get-Content "\\$ip\C$\Users\Administrator\.cloudflared\config.yml" -Raw

Write-Host ''
Write-Host '########## 3. Server reachability over the network (not a path) ##########' -ForegroundColor Magenta
try {
  $h = Invoke-WebRequest -Uri "http://192.168.0.104:29001/health" -UseBasicParsing -TimeoutSec 6
  Write-Host ("  HTTP " + $h.StatusCode + " -> " + $h.Content)
} catch { Write-Host ("  ERR: " + $_.Exception.Message) }
