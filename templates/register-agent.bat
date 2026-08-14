@echo off
title Register Deploy Agent
echo [1/4] Killing old watcher instances...
powershell.exe -NoProfile -Command "Get-CimInstance Win32_Process | Where-Object {$_.CommandLine -like '*watcher.ps1*'} | ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue }"

echo [2/4] Registering <PROJECT>-watcher (AtStartup, SYSTEM)...
schtasks /Delete /TN <PROJECT>-watcher /F > nul 2>&1
schtasks /Create /TN <PROJECT>-watcher /TR "powershell.exe -NoProfile -ExecutionPolicy Bypass -File C:\deploy-agent\watcher.ps1" /SC ONSTART /RU SYSTEM /RL HIGHEST /F

echo [3/4] Registering daily fallback (02:00, SYSTEM)...
schtasks /Delete /TN DeployAgentDaily /F > nul 2>&1
schtasks /Create /TN DeployAgentDaily /TR "powershell.exe -NoProfile -ExecutionPolicy Bypass -File C:\deploy-agent\daily-check.ps1" /SC DAILY /ST 02:00 /RU SYSTEM /RL HIGHEST /F

echo Starting watcher now...
schtasks /Run /TN <PROJECT>-watcher
echo Done!
timeout /t 5 /nobreak > nul
