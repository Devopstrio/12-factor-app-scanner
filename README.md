<div align="center">

<img src="https://raw.githubusercontent.com/Devopstrio/.github/main/assets/Browser_logo.png" height="72" alt="Devopstrio Logo" />

<h1>12-Factor App Scanner</h1>

<p><strong>Enterprise Cloud Governance &middot; Automated Compliance Audit &middot; Shift-Left Architecture</strong></p>

[![Governance](https://img.shields.io/badge/Governance-Compliance_as_Code-522c72?style=for-the-badge&labelColor=000000)](https://devopstrio.co.uk/)
  <a href="https://github.com/orgs/devopstrio/repositories"><img src="https://img.shields.io/badge/Status-Production_Ready-962964?style=for-the-badge&labelColor=000000" alt="Status"/></a>
[![Deployment](https://img.shields.io/badge/Deploy-Azure_Function-0078d4?style=for-the-badge&logo=microsoftazure&labelColor=000000)](/terraform)
[![Bundle](https://img.shields.io/badge/Bundle-Docker_Container-2496ed?style=for-the-badge&logo=docker&labelColor=000000)](Dockerfile)

<br/>

> **Scalability is not an accident; it is an architectural requirement.** The Devopstrio 12-Factor Scanner ensures your application codebases are built for high-performance cloud environments through automated, multi-factor static analysis.

</div>

---

## 🏛️ High-Level Architecture

The 12-Factor Scanner is built as a **Headless Compliance Engine**. It can be executed as a local CLI, a containerized CI/CD step, or a scalable serverless API.

### 🔄 Scanner Execution Lifecycle (Workflow)

```mermaid
sequenceDiagram
    participant Dev as Developer / CI Agent
    participant Engine as Scanner Engine (Python)
    participant Rules as Plugin Registry
    participant Report as Diagnostic Report

    Dev->>Engine: Run scan (./target-repo)
    Engine->>Engine: Initialize Context (Language Detection)
    
    rect rgb(82, 44, 114)
    Note over Engine, Rules: Factor Check Execution
    Engine->>Rules: Trigger: Dependencies (Factor II)
    Rules-->>Engine: Status: PASS (manifest.json found)
    Engine->>Rules: Trigger: Config Secrets (Factor III)
    Rules-->>Engine: Status: FAIL (hardcoded API Key detected)
    Engine->>Rules: Trigger: Statelessness (Factor VI)
    Rules-->>Engine: Status: PASS (no local I/O)
    end

    Engine->>Report: Aggregate Scores & Metrics
    Report-->>Dev: Return JSON / Markdown / Console Table
```

---

## ☁️ Enterprise Deployment Topology

When deployed via the included **Terraform blueprints**, the scanner resides within a hardened network perimeter, ensuring that your organization's intellectual property (source code) never leaves your private cloud boundary.

```mermaid
graph LR
    subgraph Azure_Subscription
        subgraph VNet_Scanner
            direction TB
            A[Application Gateway] --> B[Subnet: Frontend]
            B --> C[Linux Function App: Engine]
            C --> D[Subnet: Backend]
            D --> E[(Azure Storage: Results)]
            C -.-> F[Managed Identity]
            F --> G[Internal Git Repos]
        end
    end
    H[Developer / CI-CD] --> A
```

### Key Architectural Pillars
- **Zero-Trust Identity**: Uses Azure Managed Identity (MSI) to authenticate against internal repositories without requiring stored passwords.
- **Network Isolation**: The engine runs within a delegated VNet subnet, preventing data exfiltration to the public web.
- **Elastic Scale**: Built on the Azure Elastic Premium plan, providing instant scaling for high-concurrency enterprise auditing.

---

## 📋 Comprehensive 12-Factor Audit Log

| Factor | Governance Logic | Tooling |
|:---|:---|:---|
| **I. Codebase** | Verifies Git tracking and single-codebase-to-multi-deployment patterns. | `git-python` |
| **II. Dependencies** | Scans for manifest files (npm, pip, maven) to ensure zero implicit dependencies. | `parser-engine` |
| **III. Config** | High-fidelity regex scanning for hardcoded secrets and environment variables. | `regex-security` |
| **IV. Backing Services** | Evaluates resource strings to confirm database/cache connectivity is secondary. | `static-analysis` |
| **VI. Processes** | Detects local file writing and long-lived stateful memory patterns. | `io-analyzer` |
| **XI. Logs** | Audits print/console/logging statements for event-stream compliance. | `observability-check` |

---

## 🚀 DevOps Integration Workflow

Integrate the scanner into your existing Devopstrio Landing Zone using our pre-built GitHub Action:

```yaml
jobs:
  governance:
    steps:
      - uses: actions/checkout@v3
      - name: 12-Factor Audit
        uses: devopstrio/12-factor-scanner-action@v2
        with:
          threshold: 85
          report-type: 'markdown'
```

---
<sub>&copy; 2026 Devopstrio &mdash; Enterprise Cloud &middot; AI &middot; DevOps Acceleration Partner</sub>
