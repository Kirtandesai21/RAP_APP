# CI/CD Pipeline Guide for SAP BTP & ABAP RAP Application

This project includes a complete, enterprise-grade Continuous Integration and Continuous Deployment (CI/CD) setup supporting both **GitHub Actions** and **SAP Continuous Integration and Delivery (Project Piper)**.

---

## 1. CI/CD Architecture

```
 ┌────────────────────────────────────────────────────────┐
 │            Developer pushes commit to GitHub           │
 └───────────────────────────┬────────────────────────────┘
                             │
 ┌───────────────────────────▼────────────────────────────┐
 │  STAGE 1: Code Quality, Validation & Linting           │
 │  - Validates all JSON descriptors (manifest, xs-app)   │
 │  - Validates XML DDIC schemas & abapGit metadata       │
 │  - Runs abaplint on ABAP Cloud / CDS sources in src/   │
 └───────────────────────────┬────────────────────────────┘
                             │ (On successful validation of 'main' / 'master')
 ┌───────────────────────────▼────────────────────────────┐
 │  STAGE 2: Continuous Deployment to SAP BTP             │
 │  - Installs Cloud Foundry CLI                          │
 │  - Authenticates with SAP BTP using GitHub Secrets     │
 │  - Deploys automatically: cf push                      │
 │  - Verifies live health status on BTP                  │
 └───────────────────────────┬────────────────────────────┘
                             │
 ┌───────────────────────────▼────────────────────────────┐
 │   LIVE ON SAP BTP CLOUD FOUNDRY:                       │
 │   https://rap-travel-fiori-elements-...                │
 └────────────────────────────────────────────────────────┘
```

---

## 2. GitHub Actions Setup (`.github/workflows/ci-cd.yml`)

The workflow triggers automatically on:
- **Push** to `main` or `master` branch.
- **Pull Request** to `main` or `master` branch (runs validation only).
- **Manual Trigger** (`workflow_dispatch`) from the GitHub Actions tab.

### Required GitHub Repository Secrets
To enable automated deployments to SAP BTP from GitHub Actions, configure the following secrets in your GitHub repository:
**`Settings -> Secrets and variables -> Actions -> New repository secret`**

| Secret Name | Description | Example / Default |
| :--- | :--- | :--- |
| `CF_PASSWORD` | **(Required)** Your SAP BTP account password or technical user password | `••••••••` |
| `CF_USERNAME` | Your SAP BTP login email (Optional if using default) | `kirtandesai07@gmail.com` |
| `CF_API_URL` | Cloud Foundry API Endpoint (Optional if using default) | `https://api.cf.us10-001.hana.ondemand.com` |
| `CF_ORG` | SAP BTP Organization (Optional if using default) | `062d3605trial` |
| `CF_SPACE` | SAP BTP Space (Optional if using default) | `dev` |

---

## 3. ABAP Code Quality & Linting (`abaplint.json`)

The project uses **`abaplint`**, the official community and SAP standard for offline ABAP and CDS syntax validation:
- Configured for **ABAP Cloud / Steampunk** (`syntax.version: "Cloud"`).
- Enforces modern ABAP 7.57+ syntax, strict keyword casing, clean indentation, and safe SQL/FAE rules.
- Scans all files in `src/`.

Run locally:
```bash
npm run lint:abap
```

---

## 4. SAP BTP Native CI/CD Service (`.pipeline/config.yml`)

If you are using the **SAP Continuous Integration and Delivery** service directly in SAP BTP:
1. Go to your BTP Cockpit -> **Continuous Integration and Delivery**.
2. Add a new repository pointing to this Git repository.
3. Choose the **SAP Fiori** or **Cloud Foundry** job template.
4. The service will automatically read `.pipeline/config.yml` to build and deploy.

---

## 5. Local Commands Quick Reference

| Command | Description |
| :--- | :--- |
| `npm run validate` | Validates all UI5 JSON configuration files |
| `npm run lint:abap` | Runs `abaplint` on all ABAP and CDS view entities |
| `npm run deploy` | Deploys the application directly to SAP BTP via `cf push` |
| `npm start` | Launches the local interactive development server |
