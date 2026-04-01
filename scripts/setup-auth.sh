#!/bin/bash
# Run this once on your local machine
vcpkg fetch nuget
mono "$(vcpkg fetch nuget)" sources add \
  -Name "GitHub-falcon-deps" \
  -Source "https://nuget.pkg.github.com/falcon-autotuning/index.json" \
  -Username "YOUR_GITHUB_USER" \
  -Password "YOUR_PAT_TOKEN" \
  -StorePasswordInClearText
