#!/bin/bash
# BCOS v2 Scanner - GitHub Action Entrypoint
# SPDX-License-Identifier: MIT

set -e

# Parse arguments
PATH_ARG="${1:-.}"
TIER="${3:-L1}"
REVIEWER="${5:-}"
NODE_URL="${7:-}"
FAIL_ON_UNMET="${9:-false}"

echo "=============================================="
echo "BCOS v2 - Beacon Certified Open Source"
echo "=============================================="
echo ""
echo "Configuration:"
echo "  Path:         $PATH_ARG"
echo "  Tier:         $TIER"
echo "  Reviewer:     ${REVIEWER:-none}"
echo "  Node URL:     ${NODE_URL:-none}"
echo "  Fail on unmet: $FAIL_ON_UNMET"
echo ""

# Change to the workspace path
cd "$PATH_ARG" || exit 1

# Run BCOS scan
echo "Running BCOS v2 scan..."
python3 /usr/local/bin/bcos_engine.py . --tier "$TIER" --reviewer "$REVIEWER" --json > /tmp/bcos_report.json 2>&1 || true

# Parse results
if [ -f /tmp/bcos_report.json ]; then
    TRUST_SCORE=$(jq -r '.trust_score // 0' /tmp/bcos_report.json)
    CERT_ID=$(jq -r '.cert_id // "pending"' /tmp/bcos_report.json)
    TIER_MET=$(jq -r '.tier_met // false' /tmp/bcos_report.json)
    REPO_NAME=$(jq -r '.repo_name // "unknown"' /tmp/bcos_report.json)
    COMMIT_SHA=$(jq -r '.commit_sha // "unknown"' /tmp/bcos_report.json)
    
    # Write GitHub outputs
    echo "trust_score=$TRUST_SCORE" >> $GITHUB_OUTPUT
    echo "cert_id=$CERT_ID" >> $GITHUB_OUTPUT
    echo "tier_met=$TIER_MET" >> $GITHUB_OUTPUT
    echo "report_path=/tmp/bcos_report.json" >> $GITHUB_OUTPUT
    
    # Print report
    python3 /usr/local/bin/bcos_engine.py . --tier "$TIER" --reviewer "$REVIEWER"
    
    # Generate PR comment body
    cat > /tmp/pr_comment.md << EOF
## 🛡️ BCOS v2 Scan Results

### Summary

| Metric | Value |
|--------|-------|
| **Trust Score** | ${TRUST_SCORE}/100 |
| **Cert ID** | \`${CERT_ID}\` |
| **Tier Claimed** | ${TIER} |
| **Tier Met** | $([ "$TIER_MET" = "true" ] && echo "✅ Yes" || echo "❌ No") |
| **Repository** | ${REPO_NAME} |
| **Commit** | \`${COMMIT_SHA:0:12}\` |

### Score Breakdown

EOF
    
    # Add score breakdown to PR comment
    jq -r '.score_breakdown | to_entries[] | "| **\(.key | gsub("_"; " "))** | \(.value) / \(.value) |"' /tmp/bcos_report.json >> /tmp/pr_comment.md 2>/dev/null || true
    
    # Add badge
    BADGE_COLOR=$([ "$TIER_MET" = "true" ] && echo "brightgreen" || echo "yellow")
    echo "" >> /tmp/pr_comment.md
    echo "![BCOS Badge](https://img.shields.io/badge/BCOS-${TRUST_SCORE}%2F100-${BADGE_COLOR})" >> /tmp/pr_comment.md
    echo "" >> /tmp/pr_comment.md
    echo "---" >> /tmp/pr_comment.md
    echo "*BCOS v2 Engine • [Learn More](https://rustchain.org/bcos/)*" >> /tmp/pr_comment.md
    
    # Save PR comment for later use
    echo "pr_comment_file=/tmp/pr_comment.md" >> $GITHUB_OUTPUT
    
    # Anchor to RustChain if node URL provided and tier met
    if [ -n "$NODE_URL" ] && [ "$TIER_MET" = "true" ]; then
        echo ""
        echo "Anchoring attestation to RustChain..."
        COMMITMENT=$(jq -r '.commitment // ""' /tmp/bcos_report.json)
        if [ -n "$COMMITMENT" ]; then
            # This would need actual RustChain API integration
            echo "⚠️ RustChain anchoring requires API integration (coming soon)"
            echo "Commitment: $COMMITMENT"
        fi
    fi
    
    # Exit with appropriate code
    if [ "$FAIL_ON_UNMET" = "true" ] && [ "$TIER_MET" = "false" ]; then
        echo ""
        echo "❌ Tier not met and fail-on-unmet is enabled"
        exit 1
    fi
    
    exit 0
else
    echo "❌ BCOS scan failed - no report generated"
    echo "trust_score=0" >> $GITHUB_OUTPUT
    echo "cert_id=error" >> $GITHUB_OUTPUT
    echo "tier_met=false" >> $GITHUB_OUTPUT
    exit 1
fi