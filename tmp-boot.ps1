$ErrorActionPreference = 'Continue'
$ip = '192.168.0.104'
$proj = "\\$ip\E$\runserv\job-ai-efficiency-generator-v2"
$outFile = 'C:\boot-verify.txt'
$localOut = "\\$ip\C$\boot-verify.txt"
Remove-Item $localOut -Force -ErrorAction SilentlyContinue

# boot cmd: invoke restart.cmd (starts node detached on 29001), wait, then curl health+root
$boot = @"
@echo off
set F=$outFile
cd /d E:\runserv\job-ai-efficiency-generator-v2
call restart.cmd
echo === waited, checking health ===> "%F%" 2>&1
for /l %%i in (1,1,15) do (
  curl -s --max-time 3 http://localhost:29001/health>> "%F%" 2>&1
  if not errorlevel 1 goto ok
  timeout /t 1 /nobreak > nul
)
:ok
echo.>> "%F%" 2>&1
echo === ROOT HEADERS ===>> "%F%" 2>&1
curl -s -I --max-time 3 http://localhost:29001/>> "%F%" 2>&1
echo === done ===>> "%F%" 2>&1
"@
$installer = "$proj\_boot.cmd"
Set-Content -Path $installer -Value $boot -Encoding ASCII

$rng = Get-Random
$task = "_boot_$rng"
& schtasks /S $ip /Create /TN $task /TR "$installer" /SC ONCE /ST 23:59 /RU SYSTEM /RL HIGHEST /F 2>$null | Out-Null
& schtasks /S $ip /Run /TN $task 2>$null | Out-Null

for ($i=0; $i -lt 30; $i++) {
  Start-Sleep -Seconds 2
  if (Test-Path $localOut) { if ((Get-Content $localOut -Raw) -match '=== done ===') { break } }
}
Start-Sleep -Seconds 2

Write-Host '===== BOOT VERIFY OUTPUT ====='
if (Test-Path $localOut) { Get-Content $localOut } else { Write-Host '(no out)' }
Write-Host '=============================='

Write-Host ('port 29001 listening check:')
& netstat -ano 2>&1 | Select-String '29001' | Select-Object -First 3

& schtasks /S $ip /Delete /TN $task /F 2>$null | Out-Null
Remove-Item $installer -Force -ErrorAction SilentlyContinue
Remove-Item $localOut -Force -ErrorAction SilentlyContinue
