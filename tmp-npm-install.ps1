$ErrorActionPreference = 'Continue'
$ip = '192.168.0.104'
$proj = "\\$ip\E$\runserv\job-ai-efficiency-generator-v2"
$server = "$proj\server"

# 1. write installer cmd on remote
$installer = "$proj\_npm-install.cmd"
$body = "@echo off`r`ncd /d `"$server`"`r`nnpm install --omit=dev > `"$proj\_npm-out.txt`" 2>&1`r`n"
Set-Content -Path $installer -Value $body -Encoding ASCII
Write-Host "installer written: $installer"

# 2. create + run schtasks (SYSTEM)
$rng = Get-Random
$task = "_npm_$rng"
& schtasks /S $ip /Create /TN $task /TR "$installer" /SC ONCE /ST 23:59 /RU SYSTEM /RL HIGHEST /F 2>$null | Out-Null
Write-Host ("create exit=" + $LASTEXITCODE)
& schtasks /S $ip /Run /TN $task 2>$null | Out-Null
Write-Host ("run exit=" + $LASTEXITCODE)

# 3. poll for completion
$out = "$proj\_npm-out.txt"
for ($i=0; $i -lt 30; $i++) {
  Start-Sleep -Seconds 3
  if (Test-Path "$server\node_modules\express\package.json") { Write-Host "express installed after ~$($i*3)s"; break }
}
Write-Host ''
Write-Host '===== npm output ====='
if (Test-Path $out) { Get-Content $out -Raw } else { Write-Host '(no npm output file)' }

Write-Host ''
Write-Host '===== express check ====='
Write-Host ("  express: " + (Test-Path "$server\node_modules\express\package.json"))

& schtasks /S $ip /Delete /TN $task /F 2>$null | Out-Null
Remove-Item $installer -Force -ErrorAction SilentlyContinue
Remove-Item $out -Force -ErrorAction SilentlyContinue
