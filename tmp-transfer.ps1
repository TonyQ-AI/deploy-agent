$ErrorActionPreference = 'Continue'
$ip = '192.168.0.104'
$share = "\\$ip\E$"                # admin share → E: drive
$rel   = 'runserv\job-ai-efficiency-generator-v2'
$remote = "$share\$rel"
$local  = 'E:\AiDatas\projects\job-ai-efficiency-generator-v2'

Write-Host "target: $remote" -ForegroundColor Cyan

# --- 0. create remote dirs ---
New-Item -ItemType Directory -Force -Path "$remote\logs" | Out-Null
New-Item -ItemType Directory -Force -Path "$remote\server\data" | Out-Null
Write-Host '[dir] project + logs + server/data ready'

# --- 1. server source (exclude data + node_modules) ---
Write-Host '[1] robocopy server...' -ForegroundColor Cyan
& robocopy "$local\server" "$remote\server" /E /XD data node_modules /NFL /NDL /NJH /NJS
$rc1 = $LASTEXITCODE
Write-Host ("    server robocopy exit=$rc1") 
if ($rc1 -ge 8) { Write-Host "    (warning: server copy maybe incomplete)" }

# --- 2. dist (frontend build output, purge) ---
Write-Host '[2] robocopy dist...' -ForegroundColor Cyan
& robocopy "$local\dist" "$remote\dist" /E /PURGE /NFL /NDL /NJH /NJS
$rc2 = $LASTEXITCODE
Write-Host ("    dist robocopy exit=$rc2")
if ($rc2 -ge 8) { Write-Host "    (warning: dist copy maybe incomplete)" }

# --- 3. root files ---
Write-Host '[3] copy root files...' -ForegroundColor Cyan
Copy-Item "$local\package.json" "$remote\package.json" -Force -ErrorAction Stop
Copy-Item "$local\package-lock.json" "$remote\package-lock.json" -Force -ErrorAction Stop
Copy-Item "$local\restart.cmd" "$remote\restart.cmd" -Force -ErrorAction Stop
Write-Host '    package.json / package-lock.json / restart.cmd copied'

# --- 4. production .env (NOT committed) ---
Write-Host '[4] write server/.env (prod)...' -ForegroundColor Cyan
Copy-Item "$local\server\.env.prod-staging" "$remote\server\.env" -Force -ErrorAction Stop
Get-Content "$remote\server\.env" | Select-Object -First 3
Write-Host '    server/.env written'

# --- 5. verify remote contents ---
Write-Host ''
Write-Host '===== remote artifact check =====' -ForegroundColor Cyan
foreach ($f in @('server\package.json','server\src\index.ts','server\.env','restart.cmd','dist\client\index.html')) {
  $p = "$remote\$f"
  Write-Host ("  {0} -> {1}" -f $f, (Test-Path $p))
}
