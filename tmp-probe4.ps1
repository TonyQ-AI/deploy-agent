$ErrorActionPreference = 'Continue'
$ip = '192.168.0.104'

Write-Host '===== 1. cloudflared.exe search (common dirs) =====' -ForegroundColor Cyan
$exeDirs = @(
  "\\$ip\C$\Program Files\cloudflared\cloudflared.exe",
  "\\$ip\C$\Program Files (x86)\cloudflared\cloudflared.exe",
  "\\$ip\C$\ProgramData\cloudflared\cloudflared.exe",
  "\\$ip\C$\Users\Administrator\.cloudflared\cloudflared.exe",
  "\\$ip\C$\Tools\cloudflared\cloudflared.exe",
  "\\$ip\C$\Windows\System32\cloudflared.exe",
  "\\$ip\E$\cloudflared\cloudflared.exe"
)
foreach ($e in $exeDirs) { Write-Host ("  {0,-60} -> {1}" -f $e, (Test-Path $e)) }

Write-Host ''
Write-Host '===== 2. Search C:\Users\*\.cloudflared =====' -ForegroundColor Cyan
Get-ChildItem "\\$ip\C$\Users" -Directory -ErrorAction SilentlyContinue | ForEach-Object {
  $cf = Join-Path $_.FullName '.cloudflared'
  if (Test-Path $cf) {
    Write-Host ("  FOUND .cloudflared in: {0}" -f $cf)
    Get-ChildItem $cf -ErrorAction SilentlyContinue | ForEach-Object { Write-Host ("      {0}" -f $_.Name) }
  }
}

Write-Host ''
Write-Host '===== 3. cloudflared scheduled task / service =====' -ForegroundColor Cyan
& schtasks /S $ip /Query /FO LIST 2>&1 | Select-String -Pattern 'cloudflared' | Select-Object -First 20
