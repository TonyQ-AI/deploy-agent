$ErrorActionPreference = 'Continue'
$ip = '192.168.0.104'
$sc = "$env:SystemRoot\System32\sc.exe"
Write-Host '===== query cloudflared =====' -ForegroundColor Cyan
& $sc "\\$ip" query cloudflared 2>&1
Write-Host ''
Write-Host '===== query per-tunnel service =====' -ForegroundColor Cyan
& $sc "\\$ip" query cloudflared-e1e0e80a-9658-4ce8-a464-b91211ac7bd7 2>&1 | Select-Object -First 12
