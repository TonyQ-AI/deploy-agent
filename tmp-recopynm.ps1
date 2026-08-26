$ErrorActionPreference = 'Continue'
$ip = '192.168.0.104'
$proj = "\\$ip\E$\runserv\job-ai-efficiency-generator-v2"
$nm = "$proj\server\node_modules"
$local = 'E:\AiDatas\projects\job-ai-efficiency-generator-v2\server\node_modules'

Write-Host '== recopy node_modules ==' -ForegroundColor Cyan
& robocopy $local $nm /E /NFL /NDL /NJH /NJS
Write-Host ('robocopy exit=' + $LASTEXITCODE)

Start-Sleep -Seconds 2
Write-Host ''
Write-Host '== post-copy checks ==' -ForegroundColor Cyan
Write-Host ("  node_modules dir: " + (Test-Path $nm))
Write-Host ("  express:          " + (Test-Path "$nm\express"))
Write-Host ("  body-parser:      " + (Test-Path "$nm\body-parser"))
$epj = "$nm\express\package.json"
if (Test-Path $epj) { $fi=Get-Item $epj; Write-Host ("  express package.json " + $fi.Length + " bytes") }

Write-Host ''
Write-Host '== node import test on remote ==' -ForegroundColor Cyan
$outFile = 'C:\nm-import.txt'
$localOut = "\\$ip\C$\nm-import.txt"
Remove-Item $localOut -Force -ErrorAction SilentlyContinue
$test = @"
@echo off
cd /d E:\runserv\job-ai-efficiency-generator-v2\server
node -e "import('express').then(()=>console.log('EXPRESS_OK')).catch(e=>{console.log('FAIL:'+e.message)})" > C:\nm-import.txt 2>&1
"@
$installer = "$proj\_nmtest.cmd"
Set-Content -Path $installer -Value $test -Encoding ASCII
$rng=Get-Random; $task="_nm_$rng"
& schtasks /S $ip /Create /TN $task /TR "$installer" /SC ONCE /ST 23:59 /RU SYSTEM /RL HIGHEST /F 2>$null | Out-Null
& schtasks /S $ip /Run /TN $task 2>$null | Out-Null
Start-Sleep -Seconds 7
if (Test-Path $localOut) { Get-Content $localOut } else { Write-Host '(no import out)' }
& schtasks /S $ip /Delete /TN $task /F 2>$null | Out-Null
Remove-Item $installer -Force -ErrorAction SilentlyContinue
Remove-Item $localOut -Force -ErrorAction SilentlyContinue
