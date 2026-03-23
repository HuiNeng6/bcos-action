# BCOS v2 Scanner - Docker Action
# Beacon Certified Open Source verification

FROM python:3.11-slim

LABEL maintainer="RustChain Community"
LABEL description="BCOS v2 Scanner for GitHub Actions"
LABEL version="1.0.2"

# Cache buster
ARG CACHE_DATE=2026-03-23

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    jq \
    && rm -rf /var/lib/apt/lists/*

# Install semgrep for static analysis
RUN pip install --no-cache-dir semgrep

# Install CycloneDX tools for SBOM generation
RUN pip install --no-cache-dir cyclonedx-bom

# Create working directory
WORKDIR /workspace

# Copy the BCOS engine
COPY bcos_engine.py /usr/local/bin/bcos_engine.py
COPY entrypoint.sh /entrypoint.sh

# Make entrypoint executable
RUN chmod +x /entrypoint.sh

# Set up environment
ENV PYTHONUNBUFFERED=1

ENTRYPOINT ["/entrypoint.sh"]