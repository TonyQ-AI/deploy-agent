$ErrorActionPreference = 'Continue'
$ip = '192.168.0.104'
$proj = "\\$ip\E$\runserv\job-ai-efficiency-generator-v2"
$cf = "C:\Program Files\cloudflared\cloudflared.exe"
$cfHome = "\\$ip\C$\Users\Administrator\.cloudflared"
$outC = 'C:\route-dns.txt'
$localOut = "\\$ip\C$\route-dns.txt"
Remove-Item $localOut -Force -ErrorAction SilentlyContinue

Write-Host '== .cloudflared contents (cert.pem present?) ==' -ForegroundColor Cyan
Get-ChildItem $cfHome -ErrorAction SilentlyContinue | ForEach-Object { Write-Host ("  " + $_.Name + "  (" + $_.Length + " bytes)") }

Write-Host ''
Write-Host '== running: cloudflared tunnel route dns <tunnel> jae.myaitixiao.top ==' -ForegroundColor Cyan
$diag = @"
@echo off
"$cf" tunnel route dns e1e0e80a-9658-4ce8-a464-b91211ac7bd7 jae.myaitixiao.top > C:\route-dns.txt 2>&1
echo EXIT:%errorlevel%>> C:\route-dns.txt
"@
$installer = "$proj\_routedns.cmd"
Set-Content -Path $installer -Value $diag -Encoding ASCII
$rng=Get-Random; $task="_rd_$rng"
& schtasks /S $ip /Create /TN $task /TR "$installer" /SC ONCE /ST 23:59 /RU SYSTEM /RL HIGHEST /F 2>$null | Out-Null
& schtasks /S $ip /Run /TN $task 2>$null | Out-Null
Start-Sleep -Seconds 8
if (Test-Path $localOut) { Get-Content $localOut } else { Write-Host '(no out)' }
& schtasks /S $ip /Delete /TN $task /F 2>$null | Out-Null
Remove-Item $installer -Force -ErrorAction SilentlyContinue
Remove-Item $localOut -Force -ErrorAction SilentlyContinue
