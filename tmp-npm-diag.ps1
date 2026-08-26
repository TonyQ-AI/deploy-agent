$ErrorActionPreference = 'Continue'
$ip = '192.168.0.104'
$proj = "\\$ip\E$\runserv\job-ai-efficiency-generator-v2"
$server = "$proj\server"
$out = "$proj\_npm-diag.txt"

$installer = "$proj\_npm-diag.cmd"
$diag = @"
@echo off
echo === registry ===> "$out" 2>&1
npm config get registry>> "$out" 2>&1
echo.>> "$out" 2>&1
echo === npm ping ===>> "$out" 2>&1
npm ping>> "$out" 2>&1
echo === node/npm ===>> "$out" 2>&1
node -v>> "$out" 2>&1
npm -v>> "$out" 2>&1
echo === install ===>> "$out" 2>&1
cd /d "$server">> "$out" 2>&1
npm install --omit=dev --loglevel verbose --cache "$proj\.npm-cache">> "$out" 2>&1
echo === EXIT:%errorlevel% ===>> "$out" 2>&1
"@
Set-Content -Path $installer -Value $diag -Encoding ASCII

$rng = Get-Random
$task = "_npmdiag_$rng"
& schtasks /S $ip /Create /TN $task /TR "$installer" /SC ONCE /ST 23:59 /RU SYSTEM /RL HIGHEST /F 2>$null | Out-Null
& schtasks /S $ip /Run /TN $task 2>$null | Out-Null

for ($i=0; $i -lt 35; $i++) {
  Start-Sleep -Seconds 3
  if (Test-Path "$server\node_modules\express\package.json") { Write-Host "express installed ~$($i*3)s"; break }
  if ($i -eq 8) { Write-Host "  (still running...)" }
}

Write-Host ''
Write-Host '===== DIAG OUTPUT ====='
if (Test-Path $out) { Get-Content $out } else { Write-Host '(no out)' }
Write-Host '======================='
Write-Host ("express present: " + (Test-Path "$server\node_modules\express\package.json"))

& schtasks /S $ip /Delete /TN $task /F 2>$null | Out-Null
Remove-Item $installer -Force -ErrorAction SilentlyContinue
Remove-Item $out -Force -ErrorAction SilentlyContinue
