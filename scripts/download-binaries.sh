#!/bin/bash
set -e
NUGET_FEED="${1:?Error: NUGET_FEED_URL required. Usage: ./scripts/download-binaries.sh <feed-url>}"
TRIPLET="x64-linux-dynamic"
echo "=========================================="
echo "Downloading vcpkg prebuilt binaries"
echo "Triplet: $TRIPLET"
echo "Feed: $NUGET_FEED"
echo "=========================================="
if [ ! -d "vcpkg" ]; then
  echo "Cloning vcpkg repository..."
  git clone https://github.com/microsoft/vcpkg.git --depth 1
fi
if [ ! -f "vcpkg/vcpkg" ]; then
  echo "Bootstrapping vcpkg..."
  (cd vcpkg && ./bootstrap-vcpkg.sh)
fi
export VCPKG_BINARY_SOURCES="clear;nuget,$NUGET_FEED,read"
export VCPKG_TARGET_TRIPLET="$TRIPLET"
echo "Installing dependencies from prebuilt binaries..."
./vcpkg/vcpkg install --triplet="$TRIPLET"
echo ""
echo "✓ vcpkg binaries installed from: $NUGET_FEED"
echo ""
echo "You can now build your project as usual."
