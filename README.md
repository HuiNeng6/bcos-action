# BCOS v2 GitHub Action

[![BCOS L2 Certified](https://50.28.86.131/bcos/badge/BCOS-GHACTION.svg)](https://rustchain.org/bcos/verify/BCOS-GHACTION)

Run **BCOS v2 (Beacon Certified Open Source)** verification on your repository with a single GitHub Action.

## What is BCOS v2?

BCOS v2 is an open-source, on-chain verified certification system for open source repositories. It checks:

- ✅ License compliance (SPDX headers, OSI-compatible deps)
- ✅ Vulnerability scanning (CVEs, security issues)
- ✅ Static analysis (code quality, anti-patterns)
- ✅ SBOM completeness (CycloneDX)
- ✅ Dependency freshness
- ✅ Test evidence
- ✅ Human review attestations (L1/L2)

**Free. Open source. MIT licensed.** [Learn more →](https://rustchain.org/bcos/)

## Quick Start

```yaml
# .github/workflows/bcos.yml
name: BCOS Verification

on:
  push:
    branches: [main]
  pull_request:

jobs:
  verify:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Run BCOS v2 Verification
        uses: Scottcjn/bcos-action@v1
        with:
          tier: L1
        id: bcos
      
      - name: Check results
        run: |
          echo "Trust Score: ${{ steps.bcos.outputs.trust-score }}"
          echo "Tier Met: ${{ steps.bcos.outputs.tier-met }}"
          echo "Cert ID: ${{ steps.bcos.outputs.cert-id }}"
```

## Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `tier` | Target certification tier (L0, L1, or L2) | No | `L0` |
| `reviewer` | Reviewer name for L1/L2 attestations | No | `""` |
| `node-url` | RustChain node URL for anchoring | No | `https://rustchain.org` |
| `path` | Path to repository root | No | `.` |
| `fail-on-tier-miss` | Fail if tier threshold not met | No | `false` |

## Outputs

| Output | Description |
|--------|-------------|
| `trust-score` | Calculated trust score (0-100) |
| `cert-id` | BCOS certificate ID (if certified) |
| `tier-met` | Highest tier achieved (L0, L1, or L2) |
| `report` | Full JSON verification report |

## Tier Thresholds

| Tier | Score Required | Description |
|------|---------------|-------------|
| **L0** | ≥ 40 | Basic certification |
| **L1** | ≥ 60 | Automated certification |
| **L2** | ≥ 80 + Human signature | Premium certification |

## Examples

### Basic L0 Verification

```yaml
- uses: Scottcjn/bcos-action@v1
```

### L1 with Fail on Miss

```yaml
- uses: Scottcjn/bcos-action@v1
  with:
    tier: L1
    fail-on-tier-miss: true
```

### L2 with Reviewer

```yaml
- uses: Scottcjn/bcos-action@v1
  with:
    tier: L2
    reviewer: 'your-username'
```

### Custom Path

```yaml
- uses: Scottcjn/bcos-action@v1
  with:
    path: './packages/my-lib'
```

## Badge

Add a BCOS badge to your README:

```markdown
[![BCOS L1 Certified](https://50.28.86.131/bcos/badge/YOUR-CERT-ID.svg)](https://rustchain.org/bcos/verify/YOUR-CERT-ID)
```

Generate your badge at: [rustchain.org/bcos/badge-generator](https://rustchain.org/bcos/badge-generator)

## On Merge: Anchor to RustChain

When a PR is merged with BCOS verification, the attestation can be anchored to the RustChain blockchain:

```yaml
on:
  push:
    branches: [main]

jobs:
  anchor:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: BCOS Verify & Anchor
        uses: Scottcjn/bcos-action@v1
        with:
          tier: L1
          # Anchoring happens automatically after merge
```

This creates an immutable record of your repository's state and trust score.

## Trust Score Formula

| Component | Max Points |
|-----------|------------|
| License Compliance | 20 |
| Vulnerability Scan | 25 |
| Static Analysis | 20 |
| SBOM Completeness | 10 |
| Dependency Freshness | 5 |
| Test Evidence | 10 |
| Review Attestation | 10 |
| **Total** | **100** |

Full formula details: [BEACON_CERTIFIED_OPEN_SOURCE.md](https://github.com/Scottcjn/Rustchain/blob/main/docs/BEACON_CERTIFIED_OPEN_SOURCE.md)

## Requirements

- Python 3.11+
- `semgrep` (installed automatically)
- `cyclonedx-bom` (installed automatically)

## Why BCOS v2?

- **Free forever** — MIT licensed, no subscriptions
- **On-chain proof** — Every certification anchored to RustChain
- **Transparent formula** — Published scoring, no black boxes
- **CI/CD friendly** — Simple GitHub Action integration
- **Human review layer** — L2 Ed25519 signatures from real reviewers

## Links

- 🌐 [BCOS Dashboard](https://rustchain.org/bcos/)
- 📖 [Documentation](https://github.com/Scottcjn/Rustchain/blob/main/docs/BEACON_CERTIFIED_OPEN_SOURCE.md)
- 💬 [Discord](https://discord.gg/rustchain)
- 🐦 [X/Twitter](https://x.com/RustchainPOA)

## License

MIT License — Free for personal and commercial use.

---

Built with 💚 by [Elyan Labs](https://elyanlabs.ai)