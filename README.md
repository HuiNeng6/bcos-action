# BCOS v2 Scanner - GitHub Action

[![BCOS Certified](https://img.shields.io/badge/BCOS-Certified-brightgreen)](https://rustchain.org/bcos/)
[![MIT License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

> **Beacon Certified Open Source (BCOS)** - A practical methodology for using AI agents in open source without destroying maintainer incentives or supply-chain safety.

## Overview

This GitHub Action runs BCOS v2 verification scans on your repository, producing:

- **Trust Score** (0-100) - Transparent, reproducible quality metric
- **Certificate ID** - Unique attestation identifier
- **Tier Compliance** - L0, L1, or L2 certification level
- **PR Comments** - Automated badges and score breakdowns

## Quick Start

```yaml
# .github/workflows/bcos-scan.yml
name: BCOS v2 Scan

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  bcos-scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Run BCOS v2 Scan
        id: bcos
        uses: HuiNeng6/bcos-action@v1
        with:
          tier: 'L1'
          fail-on-unmet: 'false'
      
      - name: Post PR Comment
        if: github.event_name == 'pull_request'
        uses: actions/github-script@v7
        with:
          script: |
            const fs = require('fs');
            const comment = fs.readFileSync('/tmp/pr_comment.md', 'utf8');
            await github.rest.issues.createComment({
              owner: context.repo.owner,
              repo: context.repo.repo,
              issue_number: context.issue.number,
              body: comment
            });
```

## Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `tier` | Certification tier to target (`L0`, `L1`, or `L2`) | No | `L1` |
| `reviewer` | Human reviewer name/handle (required for L2 tier) | No | `""` |
| `node-url` | RustChain node URL for on-chain anchoring | No | `""` |
| `path` | Repository path to scan | No | `.` |
| `fail-on-unmet` | Fail the action if tier is not met | No | `false` |

## Outputs

| Output | Description |
|--------|-------------|
| `trust_score` | Computed trust score (0-100) |
| `cert_id` | BCOS certificate ID (e.g., `BCOS-a1b2c3d4`) |
| `tier_met` | Whether the claimed tier was met (`true`/`false`) |
| `report_json` | Path to the full JSON report |

## Trust Score Components

The BCOS v2 trust score is computed from 7 transparent components:

| Component | Max Points | Description |
|-----------|------------|-------------|
| License Compliance | 20 | SPDX headers + OSI-compatible licenses |
| Vulnerability Scan | 25 | 0 critical/high CVEs = 25; -5/crit, -2/high |
| Static Analysis | 20 | 0 semgrep errors = 20; -3/err, -1/warn |
| SBOM Completeness | 10 | CycloneDX SBOM generated |
| Dependency Freshness | 5 | % deps at latest version |
| Test Evidence | 10 | Test suite present & passing |
| Review Attestation | 10 | L0=0, L1=5, L2=10 |
| **Total** | **100** | |

## Certification Tiers

### L0 - Automation Only (Score ≥ 40)
- ✅ Basic linting/style checks
- ✅ Unit test detection
- ✅ License scan (SPDX headers)
- ✅ SBOM generation

**Use case:** Quick validation for low-risk changes, documentation updates.

### L1 - Agent Review + Evidence (Score ≥ 60)
- ✅ All of L0
- ✅ Security vulnerability scan
- ✅ Static analysis (semgrep)
- ✅ Dependency freshness check

**Use case:** Standard tier for most code changes, automated reviews.

### L2 - Human Eyes Required (Score ≥ 80)
- ✅ All of L1
- ✅ Human reviewer attestation required
- ✅ Maximum trust score

**Use case:** High-risk changes (wallet, auth, payouts), security-sensitive code.

## Advanced Usage

### With PR Comment and Badge

```yaml
name: BCOS v2 Scan

on:
  pull_request:
    branches: [main]

jobs:
  bcos-scan:
    runs-on: ubuntu-latest
    permissions:
      pull-requests: write
    steps:
      - uses: actions/checkout@v4
      
      - name: Run BCOS v2 Scan
        id: bcos
        uses: HuiNeng6/bcos-action@v1
        with:
          tier: 'L2'
          reviewer: '${{ github.actor }}'
      
      - name: Comment Results
        uses: actions/github-script@v7
        with:
          script: |
            const score = '${{ steps.bcos.outputs.trust_score }}';
            const certId = '${{ steps.bcos.outputs.cert_id }}';
            const tierMet = '${{ steps.bcos.outputs.tier_met }}';
            
            const badge = tierMet === 'true' 
              ? `![BCOS Badge](https://img.shields.io/badge/BCOS-${score}%2F100-brightgreen)`
              : `![BCOS Badge](https://img.shields.io/badge/BCOS-${score}%2F100-yellow)`;
            
            await github.rest.issues.createComment({
              owner: context.repo.owner,
              repo: context.repo.repo,
              issue_number: context.issue.number,
              body: `## 🛡️ BCOS v2 Scan Results\n\n${badge}\n\n| Metric | Value |\n|--------|-------|\n| Trust Score | ${score}/100 |\n| Cert ID | \`${certId}\` |\n| Tier Met | ${tierMet === 'true' ? '✅' : '❌'} |`
            });
```

### Conditional Merge Requirements

```yaml
name: BCOS Gate

on:
  pull_request:
    branches: [main]

jobs:
  bcos-scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: BCOS L2 Check
        uses: HuiNeng6/bcos-action@v1
        with:
          tier: 'L2'
          reviewer: '${{ github.actor }}'
          fail-on-unmet: 'true'  # This will block the PR if L2 not met
```

### On-Chain Anchoring (RustChain)

```yaml
- name: Run BCOS and Anchor
  uses: HuiNeng6/bcos-action@v1
  with:
    tier: 'L2'
    reviewer: 'trusted-maintainer'
    node-url: 'https://rustchain.org/api'
```

## Integration with Branch Protection

1. Go to **Settings → Branches → Branch protection rules**
2. Add rule for your main branch
3. Under "Require status checks", add the BCOS scan job
4. The scan must pass (tier met) before merging

## Why BCOS?

BCOS addresses the challenges of AI-generated code in open source:

- **Code is cheap, review is valuable** - BCOS makes reviews machine-verifiable
- **Provenance tracking** - Every scan produces a verifiable commitment
- **Incentive alignment** - Bounties should pay only for verified, reviewed contributions
- **Supply chain safety** - License checks, vulnerability scans, and SBOM generation

## Learn More

- [BCOS Specification](https://github.com/Scottcjn/Rustchain/blob/main/docs/BEACON_CERTIFIED_OPEN_SOURCE.md)
- [BCOS Engine Source](https://github.com/Scottcjn/Rustchain/blob/main/tools/bcos_engine.py)
- [RustChain](https://rustchain.org/bcos/)

## License

MIT License - Free and open source.

## Bounty Submission

**Wallet Address:** `9dRRMiHiJwjF3VW8pXtKDtpmmxAPFy3zWgV2JY5H6eeT`

This action was created for RustChain Bounty #2291 (25 RTC).

---

*Maintained by the RustChain Community*