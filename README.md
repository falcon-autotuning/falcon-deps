# Falcon Dependencies (falcon-deps)

Centralized C++ and C dependency management for the Falcon project using vcpkg and NuGet.

## Overview

This repository centralizes all vcpkg dependencies used across the Falcon project:
- **Single source of truth** for all dependencies
- **Prebuilt binaries** cached via NuGet for faster CI/CD and local development
- **Linux dynamic triplet** target: `x86_64-linux-dynamic`
- **Reduced duplication** across falcon-lib and other consumer projects

## Quick Start

### For Development

```bash
# Download prebuilt binaries (requires NuGet feed)
make download-binaries NUGET_FEED=<your-feed-url>

# Or build locally
make setup
make build
