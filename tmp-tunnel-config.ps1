$ErrorActionPreference = 'Stop'
$ip = '192.168.0.104'
$cfg = "\\$ip\C$\Users\Administrator\.cloudflared\config.yml"

# 1. backup
$bak = "$cfg.bak-jae"
Copy-Item $cfg $bak -Force
Write-Host ("backup -> " + $bak)

# 2. write new config with added ingress for jae.myaitixiao.top -> localhost:29001
$newCfg = @"
tunnel: e1e0e80a-9658-4ce8-a464-b91211ac7bd7
credentials-file: C:\Users\Administrator\.cloudflared\e1e0e80a-9658-4ce8-a464-b91211ac7bd7.json
protocol: http2
ingress:
  - hostname: mm-online.top
    service: http://localhost:3456
  - hostname: stock-sim.top
    service: http://localhost:4173
  - hostname: mm-yunjing.top
    service: http://localhost:3457
  - hostname: jae.myaitixiao.top
    service: http://localhost:29001
  - service: http_status:404
"@
Set-Content -Path $cfg -Value $newCfg -Encoding ASCII

Write-Host ''
Write-Host '===== config.yml now =====' -ForegroundColor Cyan
Get-Content $cfg
