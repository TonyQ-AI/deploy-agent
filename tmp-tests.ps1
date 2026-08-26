$ErrorActionPreference = 'Continue'
$ip = '192.168.0.104'

Write-Host '=== A. minimal create (/SC ONCE /ST 23:59) ===' -ForegroundColor Cyan
& schtasks /S $ip /Create /TN _tst_min /TR "cmd.exe /c echo hi" /SC ONCE /ST 23:59 /F 2>&1
Write-Host ('  exit=' + $LASTEXITCODE)
& schtasks /S $ip /Delete /TN _tst_min /F 2>&1 | Out-Null

Write-Host ''
Write-Host '=== B. with /RU SYSTEM /RL HIGHEST ===' -ForegroundColor Cyan
& schtasks /S $ip /Create /TN _tst_sys /TR "cmd.exe /c echo hi" /SC ONCE /ST 23:59 /RU SYSTEM /RL HIGHEST /F 2>&1
Write-Host ('  exit=' + $LASTEXITCODE)
& schtasks /S $ip /Delete /TN _tst_sys /F 2>&1 | Out-Null

Write-Host ''
Write-Host '=== C. minimal create runs a .cmd on remote ===' -ForegroundColor Cyan
# write a .cmd to remote first
Set-Content -Path "\\$ip\C$\t_k.cmd" -Value "@echo off`r`necho HELLO_FROM_REMOTE > C:\t_k_out.txt"
& schtasks /S $ip /Create /TN _tst_k /TR "C:\t_k.cmd" /SC ONCE /ST 23:59 /F 2>&1
Write-Host ('  create exit=' + $LASTEXITCODE)
& schtasks /S $ip /Run /TN _tst_k 2>&1
Write-Host ('  run exit=' + $LASTEXITCODE)
Start-Sleep -Seconds 3
Write-Host '  outfile:'
Get-Content "\\$ip\C$\t_k_out.txt" -ErrorAction SilentlyContinue
& schtasks /S $ip /Delete /TN _tst_k /F 2>&1 | Out-Null
Remove-Item "\\$ip\C$\t_k.cmd" -Force -ErrorAction SilentlyContinue
Remove-Item "\\$ip\C$\t_k_out.txt" -Force -ErrorAction SilentlyContinue
