# 🛠️ Ansible in Docker — Automated AI Stack Orchestration

## 🎯 Why this project matters (Recruiter Focus)
This repository demonstrates **infrastructure automation** in a realistic home‑lab environment:
- **Infrastructure as Code (IaC):** consistent deployments with versioned Ansible playbooks.  
- **Container Orchestration:** automates Dockerized services (Ollama, n8n, Postgres, Qdrant, etc.).  
- **Operational Reliability:** one‑click Windows automation script with logging & single‑instance lock.  
- **Scalable Design:** same playbooks work on a local PC, NAS, or cloud VPS.  
- **Security Awareness:** least‑privilege users, secrets hygiene, scheduled updates.

> Outcome: shows the ability to **design, automate, and operate** a small production‑like stack using Ansible + Docker, with CI-ready structure.

---

## 📌 What’s in this repo (current state)
- **Ansible controller in Docker** (run Ansible from a container; keep the host clean).
- **Playbooks** for updating/restarting containers (e.g., `playbooks/update_all.yml`).
- **Inventory** for your lab machines: `inventories/dev/hosts.ini`.
- **Windows one‑click updater** (**ready now**): `AIstack.ps1` (starts Docker Desktop if needed, brings up the toolbox, runs the Ansible playbook, writes logs).

> **Not enabled yet:** GitHub Actions. A sample workflow is provided below, but it is **not active** until you add it to `.github/workflows/`.

---

## 🧭 Repo structure (minimal)
```
ansible-in-docker/
├─ playbooks/
│  └─ update_all.yml
├─ inventories/
│  └─ dev/
│     └─ hosts.ini
├─ roles/                  # (add roles here as your stack grows)
├─ compose.yaml            # (defines the 'ansible-toolbox' service)
├─ AIstack.ps1             # one-click Windows automation
└─ README.md
```

---

## 🚀 Quick start

### 1) Bring up the controller
```powershell
# From the repo root
docker compose up -d
```

### 2) Run the playbook from the container
```powershell
# Replace inventory path if needed
docker exec -it $(docker compose ps -q ansible-toolbox) sh -lc "ansible-playbook playbooks/update_all.yml -i inventories/dev/hosts.ini"
```

If you defined inventory in `ansible.cfg`, you can omit the `-i` flag.

---

## 🪟 One‑click Windows automation (ready today)

Use **`AIstack.ps1`** to:  
1) ensure Docker Desktop is running,  
2) start the `ansible-toolbox` container,  
3) execute your Ansible playbook,  
4) log everything to `logs\update-YYYYMMDD-HHMMSS.log`,  
5) prevent overlapping runs with a global mutex.

### Run it manually
```powershell
.\AIstack.ps1
```

### Schedule it (Task Scheduler)
- **Trigger:** At log on, or Daily at desired time.  
- **Action:** PowerShell `-ExecutionPolicy Bypass -File "Z:\GitHub\ansible-in-docker\AIstack.ps1"`  
- **Run whether user is logged on or not**, **Run with highest privileges** (if needed).  
- Ensure your user is in the **docker-users** group.

> Logs live in `.\logs\`. If Docker takes longer to start, the script waits up to ~3 minutes for the engine.

---

## ⚙️ Environment & customization
Create a `.env` (or inventory/group_vars) for service parameters:
```ini
# Example
ANSIBLE_USER=youruser
ANSIBLE_PASSWORD=yourpassword

OLLAMA_MODEL=llama3.1
POSTGRES_DB=ai_db
POSTGRES_USER=ai_user
POSTGRES_PASSWORD=supersecret
```

Update `inventories/dev/hosts.ini` with your target(s). Add roles under `roles/` for Postgres, Qdrant, Ollama, n8n, etc.

---

## 🔐 Security notes
- Use a **dedicated non‑admin** Ansible user on targets.  
- Store secrets in **Ansible Vault** or GitHub Actions Secrets (when you enable CI).  
- Pin image tags and test updates in a staging inventory before prod.  
- Prefer running steps inside containers for isolation.

---

## 🤖 CI/CD (optional — not enabled yet)
If you want to run this via a **self‑hosted GitHub Actions runner** on your lab machine, add the following workflow at `.github/workflows/deploy.yml`:

```yaml
name: Deploy (self-hosted)

on:
  workflow_dispatch:
  schedule:
    - cron: "0 6 * * *" # daily 06:00 UTC

jobs:
  deploy:
    runs-on: self-hosted
    steps:
      - uses: actions/checkout@v4
      - name: Run Ansible playbook
        run: |
          docker compose up -d
          docker exec -i $(docker compose ps -q ansible-toolbox) sh -lc "ansible --version && ansible-playbook playbooks/update_all.yml -i inventories/dev/hosts.ini"
```

> **Reminder:** This is just a template. It won’t run until you register a self‑hosted runner **and** commit this file.

---

## 📷 Screenshots / demo
See portfolio gallery: https://tjas01.github.io

---

## 📜 License
MIT — fork and adapt freely.
