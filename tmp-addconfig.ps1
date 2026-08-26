$ErrorActionPreference = 'Stop'
$ip = '192.168.0.104'
$cfgPath = "\\$ip\C$\deploy-agent\projects.config"

$proj = [ordered]@{
  name = 'job-ai-efficiency-generator-v2'
  path = 'E:\runserv\job-ai-efficiency-generator-v2'
  flag = '.deploy-flag'
}

$current = Get-Content $cfgPath -Raw -Encoding UTF8 | ConvertFrom-Json
$names = @($current | ForEach-Object { $_.name })
if ($names -contains $proj.name) {
  Write-Host 'already present, nothing to do'
} else {
  $current = @($current) + $proj
  $json = $current | ConvertTo-Json -Depth 5
  Set-Content -Path $cfgPath -Value $json -Encoding UTF8
  Write-Host 'project added to projects.config'
}

Write-Host ''
Write-Host '===== new projects.config =====' -ForegroundColor Cyan
Get-Content $cfgPath -Raw -Encoding UTF8
