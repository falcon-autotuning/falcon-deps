#!/bin/bash
set -e

# Script to manually upload prebuilt vcpkg binaries to NuGet feed
# Usage: ./scripts/upload-binaries.sh [triplet] [nuget-feed-url] [api-key]

TRIPLET="${1:-x86_64-linux-dynamic}"
NUGET_FEED="${2:?Error: NUGET_FEED_URL required as argument 2}"
API_KEY="${3:?Error: API_KEY required as argument 3}"

echo "=========================================="
echo "Uploading vcpkg binaries"
echo "Triplet: $TRIPLET"
echo "Feed: $NUGET_FEED"
echo "=========================================="

# Ensure vcpkg is available
if [ ! -d "vcpkg" ]; then
  echo "Error: vcpkg directory not found. Run 'git clone https://github.com/microsoft/vcpkg.git' first."
  exit 1
fi

# Bootstrap vcpkg if needed
if [ ! -f "vcpkg/vcpkg" ]; then
  echo "Bootstrapping vcpkg..."
  ./vcpkg/bootstrap-vcpkg.sh
fi

# Configure binary sources for upload
export VCPKG_BINARY_SOURCES="clear;nuget,$NUGET_FEED,readwrite"
export VCPKG_NUGET_API_TOKEN="$API_KEY"
export VCPKG_TARGET_TRIPLET="$TRIPLET"

# Create build directory
mkdir -p build
cd build

# Configure CMake with NuGet sources
cmake .. \
  -G Ninja \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_TOOLCHAIN_FILE="../vcpkg/scripts/buildsystems/vcpkg.cmake" \
  -DVCPKG_TARGET_TRIPLET="$TRIPLET" \
  -DVCPKG_FEATURE_FLAGS="binarycaching" \
  -DVCPKG_BINARY_SOURCES="clear;nuget,$NUGET_FEED,readwrite"

cd ..

# List what will be uploaded
echo ""
echo "Packages to be uploaded:"
find build -name "*.nupkg" 2>/dev/null | wc -l || echo "0 (will be created during build)"

echo ""
echo "✓ Upload configuration complete!"
echo "  Binaries will be automatically uploaded when dependencies are installed."
echo "  Run: cmake --build build"
echo ""
echo "Note: Ensure your NUGET_FEED_URL and API_KEY are correct."
