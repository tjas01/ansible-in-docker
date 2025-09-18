# Ansible in Docker — Automated AI Stack Orchestration

This project shows how I use **Ansible** inside a Docker container to manage and update my AI stack (Ollama, n8n, Postgres, Qdrant, and related services).  
It provides a clean, repeatable setup with simple playbooks and a Windows script to run everything with one click.

---

## Why this project matters
- **Automation:** Common tasks like updates and restarts are handled by playbooks.  
- **Consistency:** Ansible runs in a container, so the environment is the same every time.  
- **Ease of use:** A PowerShell script starts Docker, brings up the controller, runs the playbook, and saves logs.  
- **Extensibility:** Separate playbooks for each service make it easy to add more as the stack grows.  
- **CI/CD Ready:** Can be connected to GitHub Actions with a self‑hosted runner.  

---

## Skills demonstrated
- Writing and organizing **Ansible playbooks**.  
- Using **inventories** to target local and remote systems.  
- Running Ansible from a **containerized controller**.  
- Automating with a **PowerShell wrapper script** on Windows.  
- Designing a repo structure that is **ready for CI/CD**.  

---

## Architecture
```
Windows Host
└─ Docker Desktop
   └─ compose.yaml
      └─ ansible-toolbox  (Ansible controller)
          ├─ playbooks/
          ├─ inventories/dev/hosts.ini
          └─ collections/requirements.yml

Windows automation
└─ AIstack.ps1  (start Docker → compose up → run playbook → log)
```

---

## Repository structure
```
ANSIBLE-IN-DOCKER/
├─ .devcontainer/               # VS Code dev container setup
├─ .vscode/                     # Editor settings and tasks
├─ .vault/                      # placeholder only; do not commit secrets
├─ collections/requirements.yml # Ansible Galaxy dependencies
├─ inventories/dev/hosts.ini    # inventory for local dev
├─ playbooks/
│  ├─ ping.yml
│  ├─ update_all.yml
│  ├─ update_ansible_container.yml
│  ├─ update_n8n.yml
│  ├─ update_ollama.yml
│  ├─ update_postgres.yml
│  └─ update_qdrant.yml
├─ roles/                       # add roles here as needed
├─ AIstack.ps1                  # one‑click Windows runner
├─ ansible.cfg                  # Ansible defaults
├─ compose.yaml                 
└─ README.md
```

---

## Getting started

### 1. Start the controller
```bash
docker compose up -d
```

### 2. Install collections (first run)
```bash
docker exec -it $(docker compose ps -q ansible-toolbox) \
  sh -lc "ansible-galaxy install -r collections/requirements.yml"
```

### 3. Test connectivity
```bash
docker exec -it $(docker compose ps -q ansible-toolbox) \
  sh -lc "ansible -i inventories/dev/hosts.ini all -m ping"
```

### 4. Run all updates
```bash
docker exec -it $(docker compose ps -q ansible-toolbox) \
  sh -lc "ansible-playbook playbooks/update_all.yml -i inventories/dev/hosts.ini"
```

### 5. Run specific updates
```bash
# Example: update n8n
docker exec -it $(docker compose ps -q ansible-toolbox) \
  sh -lc "ansible-playbook playbooks/update_n8n.yml -i inventories/dev/hosts.ini"
```

---

## Windows one‑click script

**`AIstack.ps1`** runs the full update from Windows:
- Starts Docker Desktop if needed.  
- Brings up the `ansible-toolbox` container.  
- Runs `update_all.yml`.  
- Saves logs in `.\logs\update-YYYYMMDD-HHMMSS.log`.  
- Prevents overlapping runs with a global mutex.  

Run manually:
```powershell
.\AIstack.ps1
```

Schedule with **Task Scheduler** if you want it to run automatically.  

---

## Configuration

- **Inventory (`inventories/dev/hosts.ini`)**: define your hosts and connection details.  
- **ansible.cfg**: set defaults like inventory path and roles path.  
- **requirements.yml**: declare external collections.  
- **.vault/**: keep this empty in git; use Ansible Vault for secrets.  

---

## Optional: GitHub Actions

You can add a workflow later to run these playbooks automatically.  
Example workflow (disabled by default):

```yaml
name: Deploy (self-hosted)

on:
  workflow_dispatch:
  schedule:
    - cron: "0 6 * * *"  # daily 06:00 UTC

jobs:
  deploy:
    runs-on: self-hosted
    steps:
      - uses: actions/checkout@v4
      - name: Run playbook
        run: |
          docker compose up -d
          docker exec -i $(docker compose ps -q ansible-toolbox) \
            sh -lc "ansible-playbook playbooks/update_all.yml -i inventories/dev/hosts.ini"
```

---

## Security notes
- Use a **non‑admin** Ansible user where possible.  
- Store sensitive data in **Ansible Vault**.  
- Pin Docker image tags to avoid surprises during updates.  
- Test playbooks on non‑critical hosts first.  

---

##  Screenshots / demo
See portfolio gallery: https://tjas01.github.io

---

##  License
MIT — fork and adapt freely.
