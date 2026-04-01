#!/bin/bash
set -e

# Script to download and cache prebuilt vcpkg binaries for faster local development
# Usage: ./scripts/download-binaries.sh [nuget-feed-url]

NUGET_FEED="${1:?Error: NUGET_FEED_URL required. Usage: ./scripts/download-binaries.sh <feed-url>}"
TRIPLET="x86_64-linux-dynamic"

echo "=========================================="
echo "Downloading vcpkg prebuilt binaries"
echo "Triplet: $TRIPLET"
echo "Feed: $NUGET_FEED"
echo "=========================================="

# Ensure vcpkg is available
if [ ! -d "vcpkg" ]; then
  echo "Cloning vcpkg repository..."
  git clone https://github.com/microsoft/vcpkg.git --depth 1
fi

# Bootstrap vcpkg if needed
if [ ! -f "vcpkg/vcpkg" ]; then
  echo "Bootstrapping vcpkg..."
  ./vcpkg/bootstrap-vcpkg.sh
fi

# Create build directory
mkdir -p build
cd build

# Configure CMake with NuGet sources (read-only for users)
export VCPKG_BINARY_SOURCES="clear;nuget,$NUGET_FEED,read"
export VCPKG_TARGET_TRIPLET="$TRIPLET"

echo "Configuring CMake..."
cmake .. \
  -G Ninja \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_TOOLCHAIN_FILE="../vcpkg/scripts/buildsystems/vcpkg.cmake" \
  -DVCPKG_TARGET_TRIPLET="$TRIPLET" \
  -DVCPKG_FEATURE_FLAGS="binarycaching"

echo ""
echo "✓ Configuration complete!"
echo ""
echo "To build:"
echo "  cmake --build build"
echo ""
echo "Prebuilt binaries will be downloaded from: $NUGET_FEED"
echo "This significantly speeds up local development builds."
