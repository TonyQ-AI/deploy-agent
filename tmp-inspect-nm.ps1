$ErrorActionPreference = 'Continue'
$ip = '192.168.0.104'
$proj = "\\$ip\E$\runserv\job-ai-efficiency-generator-v2"
$nm = "$proj\server\node_modules"

Write-Host '===== server\node_modules present? =====' -ForegroundColor Cyan
Write-Host ("  node_modules exists: " + (Test-Path $nm))
Write-Host ("  express exists:     " + (Test-Path "$nm\express"))
Write-Host ("  body-parser exists: " + (Test-Path "$nm\body-parser"))

Write-Host ''
Write-Host '===== express package.json size + keys =====' -ForegroundColor Cyan
$epj = "$nm\express\package.json"
if (Test-Path $epj) {
  $fi = Get-Item $epj
  Write-Host ("  size: " + $fi.Length + " bytes")
  try { $j = Get-Content $epj -Raw | ConvertFrom-Json; Write-Host ("  name: " + $j.name + " version: " + $j.version); Write-Host ("  main: " + $j.main + " module: " + $j.module) } catch { Write-Host ("  JSON parse FAILED: " + $_.Exception.Message) }
} else { Write-Host "  express package.json MISSING" }

Write-Host ''
Write-Host '===== express dir top-level entries =====' -ForegroundColor Cyan
Get-ChildItem "$nm\express" -ErrorAction SilentlyContinue | Select-Object -First 12 -ExpandProperty Name

Write-Host ''
Write-Host '===== any higher-level node_modules shadowing? =====' -ForegroundColor Cyan
foreach ($p in @("$proj\node_modules", "\\$ip\E$\runserv\node_modules", "\\$ip\E$\node_modules")) {
  Write-Host ("  {0} -> {1}" -f $p, (Test-Path $p))
}
Write-Host ''
Write-Host '===== express package.json FIRST 3 lines =====' -ForegroundColor Cyan
Get-Content $epj -TotalCount 3 -ErrorAction SilentlyContinue
