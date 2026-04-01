#!/bin/bash
# Script: scripts/setup-lsp-framework-port.sh

set -e

echo "Setting up lsp-framework port for vcpkg..."

# Step 1: Clone vcpkg if needed
if [ ! -d "vcpkg" ]; then
  echo "Cloning vcpkg..."
  git clone https://github.com/microsoft/vcpkg.git --depth 1
  ./vcpkg/bootstrap-vcpkg.sh
fi

# Step 2: Download and calculate SHA512
echo "Downloading lsp-framework 1.3.0..."
mkdir -p /tmp/lsp-framework
cd /tmp/lsp-framework
wget https://github.com/leon-bckl/lsp-framework/archive/refs/tags/1.3.0.tar.gz
SHA512=$(sha512sum 1.3.0.tar.gz | awk '{print $1}')
echo "SHA512: $SHA512"
cd -

# Step 3: Update portfile.cmake with SHA512
PORTFILE="ports/lsp-framework/portfile.cmake"
if [ -f "$PORTFILE" ]; then
  sed -i "s/SHA512 <REPLACE_WITH_ACTUAL_SHA512_FROM_STEP_ABOVE>/SHA512 $SHA512/" "$PORTFILE"
  echo "✓ Updated $PORTFILE with SHA512: $SHA512"
else
  echo "Error: $PORTFILE not found"
  exit 1
fi

# Step 4: Verify the port works
echo ""
echo "Testing lsp-framework port..."
./vcpkg/vcpkg install lsp-framework:x64-linux-dynamic --overlay-ports=./ports

echo ""
echo "✓ lsp-framework port is ready!"
echo "  Commit the updated portfile.cmake to git"
