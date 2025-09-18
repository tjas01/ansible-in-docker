# --- Update-AIStack.ps1 ---
# Purpose: start Docker Desktop (if needed), start your toolbox, run update_all.yml, log output.

$ErrorActionPreference = 'Stop'
$repoPath   = "Z:\GitHub\ansible-in-docker"     # <- your repo
$service    = "ansible-toolbox"                 # <- your compose service name
$logDir     = Join-Path $repoPath "logs"
$logFile    = Join-Path $logDir ("update-" + (Get-Date -Format "yyyyMMdd-HHmmss") + ".log")

# Single-instance guard
$mutex = New-Object System.Threading.Mutex($false, "Global\AIStackUpdaterMutex")
if (-not $mutex.WaitOne(0)) { Write-Host "Another run is in progress. Exiting."; exit 0 }

try {
  New-Item -ItemType Directory -Force -Path $logDir | Out-Null
  Start-Transcript -Path $logFile -Append

  Write-Host "==> Ensure Docker Desktop is running"
  $dockerProc = Get-Process -Name "Docker Desktop" -ErrorAction SilentlyContinue
  if (-not $dockerProc) {
    Start-Process "C:\Program Files\Docker\Docker\Docker Desktop.exe"
  }

  # Wait for engine
  $maxTries = 90
  for ($i=0; $i -lt $maxTries; $i++) {
    try {
      docker info *>$null
      break
    } catch { Start-Sleep -Seconds 2 }
  }
  if ($i -eq $maxTries) { throw "Docker engine didn't come up in time." }

  Write-Host "==> cd $repoPath"
  Set-Location $repoPath

  Write-Host "==> Bring up toolbox (and pull latest image if tag changed)"
  docker compose up -d
  # optional aggressive pull:
  # docker compose pull $service
  # docker compose up -d --remove-orphans

  Write-Host "==> Wait for toolbox to be ready"
  # If you have a healthcheck, you could poll it here. Otherwise, confirm we can run a shell:
  $cid = (docker compose ps -q $service)
  if (-not $cid) { throw "Service '$service' not found. Check compose.yaml service name." }

  Write-Host "==> Run Ansible playbook"
  # If your ansible.cfg defines inventory, this is enough:
  docker exec -i $cid sh -lc "ansible --version && ansible-galaxy install -r requirements.yml --ignore-errors || true && ansible-playbook playbooks/update_all.yml"

  Write-Host "==> Done. Play recap is above. Logs saved to $logFile"
}
finally {
  Stop-Transcript | Out-Null
  $mutex.ReleaseMutex() | Out-Null
  $mutex.Dispose()
}
