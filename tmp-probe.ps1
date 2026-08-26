$ErrorActionPreference = 'Continue'
$host = 'DESKTOP-GHDR9LC'
$ip   = '192.168.0.104'

Write-Host '===== 1. SMB share test (IPv4, direct UNC) =====' -ForegroundColor Cyan
# Common share candidates the deployment doc expects
$candidates = @('E$','C$','runserv','share','projects','data','deploy-agent')
foreach ($s in $candidates) {
  $p = "\\$ip\$s"
  $ok = Test-Path $p
  Write-Host ("  {0,-24} -> {1}" -f $p, $ok)
}

Write-Host ''
Write-Host '===== 2. WS-Man / WinRM reachability (port 5985/5986) =====' -ForegroundColor Cyan
foreach ($port in 5985,5986) {
  $c = New-Object System.Net.Sockets.TcpClient
  try {
    $ar = $c.BeginConnect($ip, $port, $null, $null)
    $ok = $ar.AsyncWaitHandle.WaitOne(3000, $false)
    Write-Host ("  port {0} -> {1}" -f $port, $(if ($c.Connected) {'OPEN'} else {'closed/timeout'}))
  } catch { Write-Host ("  port {0} -> err" -f $port) }
  finally { $c.Close() }
}

Write-Host ''
Write-Host '===== 3. Enter-PSSession attempt (WinRM) =====' -ForegroundColor Cyan
try {
  $s = New-PSSession -ComputerName $ip -ErrorAction Stop
  Write-Host '  WinRM session OK'
  Invoke-Command -Session $s -ScriptBlock { Write-Host "  remote hostname: $env:COMPUTERNAME" }
  Remove-PSSession $s
} catch {
  Write-Host ("  WinRM FAILED: " + $_.Exception.Message)
}

Write-Host ''
Write-Host '===== 4. This machine identity =====' -ForegroundColor Cyan
Write-Host ("  localhost: {0}  user: {1}\{2}" -f $env:COMPUTERNAME, $env:USERDOMAIN, $env:USERNAME)
