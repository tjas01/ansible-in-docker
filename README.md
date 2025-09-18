# 🛠️ Ansible in Docker – Automated AI Stack Orchestration

## 🎯 Why this project matters
This repository demonstrates **infrastructure automation and DevOps practices** in a real environment:
- **Infrastructure as Code (IaC):** automated updates & deployments with Ansible playbooks.  
- **CI/CD Pipelines:** GitHub Actions integrated with self-hosted runners.  
- **Container Orchestration:** Dockerized AI services (Ollama, n8n, Postgres, Qdrant, etc.).  
- **Scalability:** playbooks designed for local PC, NAS, or cloud VPS.  
- **Security Awareness:** secrets management, least-privilege users, and scheduled workflows.  

👉 This showcases my ability to **design, automate, and maintain production-ready systems** — exactly the kind of skills needed for Data/BI/Automation/DevOps roles.

---

## 📌 What this repo is about
- A **ready-to-run Ansible controller** running inside Docker.  
- Playbooks for:
  - Updating & restarting containers (`playbooks/update_all.yml`)
  - Managing configs & secrets (templates & roles)
  - Automating local development services (Docker Compose)  
- **Inventory structure** (`inventories/dev/hosts.ini`) for easy extension to multiple servers.  
- Integrated with **GitHub Actions** for hands-free orchestration.

---

## 🚀 Hosting this yourself

### 1. Clone the repo
```bash
git clone https://github.com/<your-username>/ansible-in-docker.git
cd ansible-in-docker
```

### 2. Build & start the Ansible container
```bash
docker compose up -d
```

### 3. Run a playbook
```bash
docker exec -it ansible ansible-playbook playbooks/update_all.yml -i inventories/dev/hosts.ini
```

---

## ⚙️ Customizing your stack
- Edit `inventories/dev/hosts.ini` with your own server IPs.  
- Add or modify roles under `roles/` to manage services like:
  - Postgres  
  - Qdrant  
  - Ollama  
  - n8n  
  - Any other containerized apps

---

## 🔑 Example `.env` file
```ini
# Inventory defaults
ANSIBLE_USER=youruser
ANSIBLE_PASSWORD=yourpassword

# Example service config
OLLAMA_MODEL=llama3.1
POSTGRES_DB=ai_db
POSTGRES_USER=ai_user
POSTGRES_PASSWORD=supersecret
```

---

## 🔒 Security & Best Practices
- Use a **dedicated Ansible user** on your target machines.  
- Store sensitive credentials in **Ansible Vault** instead of plain `.env`.  
- Pin Docker image versions to avoid breaking updates.  
- Schedule heavy jobs during off-hours via GitHub Actions.  

---

## 🤖 GitHub Actions Integration
This repo includes workflows to trigger playbooks automatically:
```yaml
on:
  workflow_dispatch:
  schedule:
    - cron: "0 6 * * *"  # run daily at 06:00 UTC

jobs:
  deploy:
    runs-on: self-hosted
    steps:
      - uses: actions/checkout@v4
      - name: Run Ansible playbook
        run: ansible-playbook playbooks/update_all.yml -i inventories/dev/hosts.ini
```

- Trigger updates **manually** from GitHub.  
- Run scheduled updates (daily, weekly).  
- Deploy automatically on every code push.  

---

## 📷 Screenshots / Demo
👉 Visuals of the full AI stack available on my portfolio:  
https://tjas01.github.io

---

## 📜 License
MIT License – feel free to fork, modify, and adapt.
