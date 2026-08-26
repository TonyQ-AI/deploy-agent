$ErrorActionPreference = 'Continue'
$ip = '192.168.0.104'
$proj = "\\$ip\E$\runserv\job-ai-efficiency-generator-v2"
$out = "$proj\_net.txt"
$installer = "$proj\_net.cmd"
$diag = @"
@echo off
set F=$out
echo --- npmmirror curl ---> "%F%" 2>&1
curl -s -o NUL --max-time 12 https://registry.npmmirror.com/express
echo npmmirror_exit=%errorlevel%>> "%F%" 2>&1
echo --- npmjs curl --->> "%F%" 2>&1
curl -s -o NUL --max-time 12 https://registry.npmjs.org/express
echo npmjs_exit=%errorlevel%>> "%F%" 2>&1
echo --- tls/connect via curl to npmjs verbose --->> "%F%" 2>&1
curl -s -o NUL --max-time 12 https://registry.npmjs.org
echo npmsj_exit2=%errorlevel%>> "%F%" 2>&1
echo done>> "%F%" 2>&1
"@
Set-Content -Path $installer -Value $diag -Encoding ASCII

$rng = Get-Random
$task = "_net_$rng"
& schtasks /S $ip /Create /TN $task /TR "$installer" /SC ONCE /ST 23:59 /RU SYSTEM /RL HIGHEST /F 2>$null | Out-Null
& schtasks /S $ip /Run /TN $task 2>$null | Out-Null

Start-Sleep -Seconds 30
Write-Host '===== NET TEST ====='
if (Test-Path $out) { Get-Content $out } else { Write-Host '(no out)' }
Write-Host '===================='

& schtasks /S $ip /Delete /TN $task /F 2>$null | Out-Null
Remove-Item $installer -Force -ErrorAction SilentlyContinue
Remove-Item $out -Force -ErrorAction SilentlyContinue
