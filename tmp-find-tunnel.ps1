$ErrorActionPreference = 'Continue'
$ip = '192.168.0.104'
$proj = "\\$ip\E$\runserv\job-ai-efficiency-generator-v2"
$outC = 'C:\cf-proc.txt'
$localOut = "\\$ip\C$\cf-proc.txt"
Remove-Item $localOut -Force -ErrorAction SilentlyContinue

$proc = @"
@echo off
powershell -NoProfile -Command "Get-CimInstance Win32_Process -Filter \"Name='cloudflared.exe'\" | Select-Object ProcessId,ParentProcessId,CommandLine | Format-List | Out-File -Encoding utf8 C:\cf-proc.txt"
echo DONE>> C:\cf-proc.txt
"@
$installer = "$proj\_cfproc.cmd"
Set-Content -Path $installer -Value $proc -Encoding ASCII
$rng=Get-Random; $task="_cf_$rng"
& schtasks /S $ip /Create /TN $task /TR "$installer" /SC ONCE /ST 23:59 /RU SYSTEM /RL HIGHEST /F 2>$null | Out-Null
& schtasks /S $ip /Run /TN $task 2>$null | Out-Null
Start-Sleep -Seconds 6
Write-Host '===== cloudflared process ====='
if (Test-Path $localOut) { Get-Content $localOut } else { Write-Host '(no out - cloudflared not running?)' }
& schtasks /S $ip /Delete /TN $task /F 2>$null | Out-Null
Remove-Item $installer -Force -ErrorAction SilentlyContinue
Remove-Item $localOut -Force -ErrorAction SilentlyContinue
