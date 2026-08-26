# Remote command executor on old PC via schtasks (SYSTEM). 
# Usage: .\tmp-remote-exec.ps1 'node -v'   (and optionally -Wait 8)
param(
  [Parameter(Mandatory=$true)][string]$Command,
  [string]$Ip = '192.168.0.104',
  [int]$Wait = 6,
  [switch]$NoWait
)
$ErrorActionPreference = 'Continue'
$outFile = 'C:\deploy-remote-out.txt'
$runCmd  = 'C:\deploy-remote-run.cmd'
$localOut = "\\$Ip\C$\deploy-remote-out.txt"
$localCmd = "\\$Ip\C$\deploy-remote-run.cmd"

Remove-Item $localOut -Force -ErrorAction SilentlyContinue

# Write a .cmd that runs the command and captures output (avoids schtasks /TR quoting hell)
$cmdBody = "@echo off`r`n$Command > $outFile 2>&1`r`n"
Set-Content -Path $localCmd -Value $cmdBody -Encoding ASCII

$rng = Get-Random
$task = "_tmpdep_$rng"

& schtasks /S $Ip /Create /TN $task /TR "C:\deploy-remote-run.cmd" /SC ONCE /ST 23:59 /RU SYSTEM /RL HIGHEST /F 2>$null | Out-Null
if ($LASTEXITCODE -ne 0) { Write-Host "CREATE FAILED (exit $LASTEXITCODE)"; Remove-Item $localCmd -Force -ErrorAction SilentlyContinue; exit 1 }

& schtasks /S $Ip /Run /TN $task 2>$null | Out-Null
Start-Sleep -Seconds $Wait

Write-Host '----- OUTPUT -----'
if (Test-Path $localOut) {
  Write-Host (Get-Content $localOut -Raw -ErrorAction SilentlyContinue)
} else {
  Write-Host '(no output file produced)'
}
Write-Host '------------------'

if (-not $NoWait) { & schtasks /S $Ip /Delete /TN $task /F 2>$null | Out-Null }
Remove-Item $localOut -Force -ErrorAction SilentlyContinue
Remove-Item $localCmd -Force -ErrorAction SilentlyContinue
