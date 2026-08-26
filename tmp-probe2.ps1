$ErrorActionPreference = 'Continue'
$ip = '192.168.0.104'

Write-Host '===== A. Drive existence (via admin shares) =====' -ForegroundColor Cyan
foreach ($d in 'C$','D$','E$','F$') {
  $p = "\\$ip\$d"
  $ok = Test-Path $p
  Write-Host ("  {0,-6} -> {1}" -f $d, $ok)
}

Write-Host ''
Write-Host '===== B. deploy-agent already installed? =====' -ForegroundColor Cyan
Write-Host ("  C:\deploy-agent\          -> {0}" -f (Test-Path "\\$ip\C$\deploy-agent"))
Write-Host ("  C:\deploy-agent\watcher.ps1 -> {0}" -f (Test-Path "\\$ip\C$\deploy-agent\watcher.ps1"))
Write-Host ("  C:\deploy-agent\projects.config -> {0}" -f (Test-Path "\\$ip\C$\deploy-agent\projects.config"))

Write-Host ''
Write-Host '===== C. Node.js installed? =====' -ForegroundColor Cyan
$nodeCandidates = @('C$\Program Files\nodejs\node.exe', 'C$\Program Files (x86)\nodejs\node.exe')
foreach ($n in $nodeCandidates) {
  Write-Host ("  {0} -> {1}" -f $n, (Test-Path "\\$ip\$n"))
}
# Look around program files for node
$pfExe = Get-ChildItem "\\$ip\C$\Program Files\nodejs" -ErrorAction SilentlyContinue | Select-Object -First 5 -ExpandProperty Name
Write-Host ("  nodejs dir listing: " + ($pfExe -join ', '))

Write-Host ''
Write-Host '===== D. cloudflared installed? =====' -ForegroundColor Cyan
Write-Host ("  C:\Windows\cloudflared.exe -> {0}" -f (Test-Path "\\$ip\C$\Windows\cloudflared.exe"))
Write-Host ("  C:\cloudflared\cloudflared.exe -> {0}" -f (Test-Path "\\$ip\C$\cloudflared\cloudflared.exe"))

Write-Host ''
Write-Host '===== E. Existing project root E:\runserv =====' -ForegroundColor Cyan
if (Test-Path "\\$ip\E$\runserv") {
  Get-ChildItem "\\$ip\E$\runserv" -Directory -ErrorAction SilentlyContinue | ForEach-Object { Write-Host ("  {0}\" -f $_.Name) }
} else {
  Write-Host '  E:\runserv NOT present'
}

Write-Host ''
Write-Host '===== F. Remote schtasks query capability =====' -ForegroundColor Cyan
& schtasks /S $ip /Query 2>&1 | Select-Object -First 6
Write-Host ('  exit: ' + $LASTEXITCODE)
