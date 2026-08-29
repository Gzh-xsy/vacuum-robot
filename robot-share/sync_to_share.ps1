# sync_to_share.ps1 — one-click: push D:\harness\vacuum_ws to the VMware shared folder.
# Run on Windows:   powershell -ExecutionPolicy Bypass -File "C:\Users\Administrator\Desktop\机器人-项目结构\扫地机器人\robot-share\sync_to_share.ps1"
$ErrorActionPreference = "Stop"

$src = "D:\harness\vacuum_ws"
$dst = "C:\Users\Administrator\Desktop\机器人-项目结构\扫地机器人\robot-share\vacuum_ws"

if (-not (Test-Path $src)) {
  Write-Error "Source not found: $src"
  exit 1
}

if (Test-Path $dst) {
  Remove-Item -Path $dst -Recurse -Force
}
Copy-Item -Path $src -Destination $dst -Recurse -Force

Write-Host "[OK] synced:"
Write-Host "  $src"
Write-Host "  ->"
Write-Host "  $dst"
