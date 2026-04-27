<div align="center">

<img src="https://raw.githubusercontent.com/Devopstrio/.github/main/assets/Browser_logo.png" height="120" alt="Devopstrio Logo" />

<h1>12-Factor App Scanner</h1>

<p><strong>The Enterprise Standard for Cloud-Native Compliance &middot; Automated SaaS Governance &middot; Institutionalized Scalability</strong></p>

[![Build Status](https://img.shields.io/github/actions/workflow/status/devopstrio/12-factor-app-scanner/audit.yml?branch=main&style=for-the-badge&logo=githubactions&logoColor=white&labelColor=000000)](https://github.com/Devopstrio/12-factor-app-scanner/actions)
[![Version](https://img.shields.io/badge/Version-2.1.0--enterprise-962964?style=for-the-badge&labelColor=000000)](https://github.com/Devopstrio/12-factor-app-scanner/releases)
[![License](https://img.shields.io/badge/License-MIT-blue?style=for-the-badge&labelColor=000000)](LICENSE)
[![Security](https://img.shields.io/badge/Security-VNet_Isolated-522c72?style=for-the-badge&logo=azurelock&logoColor=white&labelColor=000000)](/terraform)
[![Cloud](https://img.shields.io/badge/Cloud-Azure_Approved-0078d4?style=for-the-badge&logo=microsoftazure&logoColor=white&labelColor=000000)](/terraform)
[![Docker](https://img.shields.io/badge/Bundle-Docker_Ready-2496ed?style=for-the-badge&logo=docker&logoColor=white&labelColor=000000)](Dockerfile)
[![Status](https://img.shields.io/badge/Status-Production_Ready-success?style=for-the-badge&labelColor=000000)](https://devopstrio.co.uk/)

<br/>

> **"Traditional applications break in the cloud. 12-factor applications thrive."** The Devopstrio 12-Factor App Scanner is an institutional-grade governance engine that ensures every line of code in your enterprise adheres to the gold standard of cloud-native architecture.

</div>

---

## 📋 Executive Summary

### The Problem
Modern enterprise cloud environments demand extreme scalability, disposability, and dev/prod parity. However, manual architecture reviews are slow, inconsistent, and fail to scale with rapid delivery cycles.

### The Solution
The **12-Factor App Scanner** automates the enforcement of the [12-Factor Methodology](https://12factor.net/). By performing deep static analysis on source code, manifests, and IaC, the engine provides immediate, high-fidelity compliance scoring and remediation guidance.

### Value Proposition
- **Business Value**: Reduces "Cloud-Native Technical Debt" and ensures applications are ready for global scale-out.
- **Technical Value**: Implements automated linting for architectural anti-patterns.
- **Scalability Benefits**: Leverages serverless execution to audit thousands of repositories simultaneously.

---

## ✨ Key Features

### 🛡️ Enterprise Governance
- **Automated Scorecards**: Real-time compliance scoring (0-100) integrated into PR reviews.
- **Factor-Specific Plugins**: Modular rule engine covering Dependencies, Config, Processes, and more.
- **Remediation Roadmaps**: Context-aware guidance for fixing violations.

### 🔒 Zero-Trust Security
- **Secret Detection**: Scans for hardcoded credentials and non-externalized configuration.
- **VNet Isolated Scans**: Infrastructure blueprints enforce network delegation for all audit workloads.
- **Identity-Based Access**: Full support for Azure Managed Identities; no stored passwords.

### ⚙️ Automation & Productivity
- **CI/CD Native**: Ready-to-use GitHub Actions and Azure DevOps task templates.
- **Headless API**: REST-compatible serverless endpoints for custom integration.
- **Dockerized Execution**: Consistent audit results from local dev machines to production pipelines.

---

## 🏛️ High-Level Architecture

### System Architecture Diagram
```mermaid
graph TD
    A[Developer / CI-CD] -->|HTTP/REST| B[Azure Application Gateway]
    B -->|WAF/TLS| C[Linux Function App: Scanner Engine]
    C -->|Identity| D[Azure Key Vault]
    C -->|Store Results| E[(Azure Storage: Table/Blob)]
    C -->|Pull Code| F[External Repos: GitHub/GitLab]
    G[Application Insights] --- C
```

### Deployment Topology
```mermaid
graph LR
    subgraph VNet_Scanner
        subgraph Subnet_Frontend
            AGW[App Gateway]
        end
        subgraph Subnet_Backend
            FUNC[Function App Engine]
        end
        subgraph Subnet_Data
            PE_ST[Private Endpoint: Storage]
            PE_KV[Private Endpoint: Key Vault]
        end
    end
    AGW --> FUNC
    FUNC --> PE_ST
    FUNC --> PE_KV
```

### Request Lifecycle Flow
```mermaid
sequenceDiagram
    participant U as CI/CD Pipeline
    participant G as App Gateway
    participant E as Scanner Engine
    participant S as Storage Service
    U->>G: POST /scan (repo_url)
    G->>E: Authorize & Route
    E->>E: Execute 12-Factor Rules
    E->>S: Store Metadata (Table)
    E->>S: Upload Report (Blob)
    E-->>U: 202 Accepted (Correlation ID)
```

### CI/CD Workflow Diagram
```mermaid
graph LR
    A[Commit] --> B[GitHub Action]
    B --> C[12-Factor Audit]
    C -->|Fail| D[Block PR / Remediation]
    C -->|Pass| E[Build & Package]
    E --> F[Deploy to Staging]
```

### Security Model Diagram
```mermaid
graph TD
    subgraph Identity_and_Access
        A[Managed Identity] -->|Read Secrets| B[Key Vault]
        A -->|Write Logs| C[Log Analytics]
        A -->|Write Data| D[Storage]
    end
    subgraph Network_Security
        E[Private Endpoint] --- D
        F[NSG Rules] --- E
    end
```

---

## 🧩 Component Breakdown

| Component | Purpose | Technology | Scaling Model | Notes |
|:---:|:---|:---|:---:|:---|
| **Scanner Engine** | Core Logic & Heuristics | Python 3.11 | Elastic Premium | Modular Plugin Architecture |
| **Ingress Gateway** | Security & Traffic Routing | App Gateway v2 | Horizontal | WAF enabled by default |
| **Audit Vault** | Secure Report Storage | Azure Blob / Table | GRS | 99.999% Durability |
| **Secret Manager** | Credential Management | Azure Key Vault | Global | Managed Identity Access |

---

## 📂 Repository Structure

```text
12-factor-app-scanner/
├── .github/workflows/      # CI/CD Pipelines
├── src/                    # Core Scanner Engine
│   ├── engine.py           # Orchestration Logic
│   └── scanner.py          # Factor Plugin Registry
├── terraform/              # Enterprise Infrastructure
│   ├── networking.tf       # VNet & App Gateway
│   ├── storage.tf          # Database & Artifacts
│   └── compute.tf          # Serverless Architecture
├── Dockerfile              # Containerized Bundle
└── README.md               # Product Documentation
```

---

## ⚙️ Configuration & Setup

### Environment Variables
| Variable | Description | Sample Value |
|:---|:---|:---|
| `KEY_VAULT_URL` | URL for secret management | `https://kv-scan-prod.vault.azure.net/` |
| `STORAGE_TABLE` | Target for metadata strings | `ComplianceResults` |

### Sample `.env`
```bash
SCAN_TIMEOUT=300
OUTPUT_FORMAT=markdown
ORG_NAME=Devopstrio
```

---

## 🚀 Usage Examples

### CLI Execution
```bash
# Local static analysis
python src/scanner.py ./my-project-repo
```

### API Integration
```bash
curl -X POST https://api.devopstrio.co.uk/scan \
     -H "Content-Type: application/json" \
     -d '{"repo": "github.com/org/app"}'
```

---

## 🛡️ Security & Compliance

### Identity Model
The scanner implements **Azure RBAC** and **Managed Identities**. No service principal secrets are stored in the codebase.

### Compliance Mapping
| Reference | Score Contribution | Status |
|:---|:---|:---|
| CIS Benchmark | Secret detection | 100% |
| NIST 800-53 | Audit logging | 100% |
| 12-Factor | Complete Methodology | 100% |

---

## 📈 Performance & Scalability
- **Elastic Scale**: Uses Azure Function "Elastic Premium" to handle up to 100 concurrent scans.
- **Async Processing**: Long-running scans are offloaded to Azure Storage Queues.
- **Global Availability**: Configured for Geo-Redundant storage and global traffic management.

---

## �️ Roadmap
- **Short-term**: Support for AWS Landing Zone scanning.
- **Mid-term**: Integration with OpenPolicyAgent (OPA).
- **Long-term**: AI-powered remediation (Auto-fixing violators).

---

## 🤝 Contribution
Please see [CONTRIBUTING.md](CONTRIBUTING.md) for our professional code of conduct and pull request process.

---

## 🆘 Support & Contact
- **Documentation**: [docs.devopstrio.co.uk](https://devopstrio.co.uk/)
- **Enterprise Support**: [support@devopstrio.co.uk](mailto:support@devopstrio.co.uk)

---

## ⚖️ License
Licensed under the **MIT License**. See [LICENSE](LICENSE) for details.

---

<div align="center">

<img src="https://raw.githubusercontent.com/Devopstrio/.github/main/assets/Browser_logo.png" height="50" alt="Devopstrio Logo" />

**Building the future of enterprise infrastructure &mdash; one blueprint at a time.**

</div>
