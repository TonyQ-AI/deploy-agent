$ErrorActionPreference = 'Continue'
$ip = '192.168.0.104'
$proj = "\\$ip\E$\runserv\job-ai-efficiency-generator-v2"
$outFile = 'C:\boot-diag.txt'
$localOut = "\\$ip\C$\boot-diag.txt"
Remove-Item $localOut -Force -ErrorAction SilentlyContinue

$diag = @"
@echo off
set F=$outFile
cd /d E:\runserv\job-ai-efficiency-generator-v2
echo --- node run start ---> "%F%" 2>&1
node --env-file-if-exists=server/.env --experimental-strip-types server/src/index.ts>> "%F%" 2>&1
echo --- node exited (code %errorlevel%) --->> "%F%" 2>&1
"@
$installer = "$proj\_diag-srv.cmd"
Set-Content -Path $installer -Value $diag -Encoding ASCII

$rng = Get-Random
$task = "_diagsrv_$rng"
& schtasks /S $ip /Create /TN $task /TR "$installer" /SC ONCE /ST 23:59 /RU SYSTEM /RL HIGHEST /F 2>$null | Out-Null
& schtasks /S $ip /Run /TN $task 2>$null | Out-Null

Start-Sleep -Seconds 9

Write-Host '===== NODE DIAG ====='
if (Test-Path $localOut) { Get-Content $localOut } else { Write-Host '(no out)' }
Write-Host '===================='

# clean up any node the diag started on 29001
& "netstat" -ano 2>&1 | Select-String '29001' | ForEach-Object {
  if ($_ -match 'LISTENING.*?(\d+)\s*$') {
    $p = $matches[1]
    Write-Host ("killing diag node pid on 29001: " + $p)
    & taskkill /F /PID $p 2>$null | Out-Null
  }
}

& schtasks /S $ip /Delete /TN $task /F 2>$null | Out-Null
Remove-Item $installer -Force -ErrorAction SilentlyContinue
Remove-Item $localOut -Force -ErrorAction SilentlyContinue
