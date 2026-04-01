.PHONY: help setup build validate clean setup-lsp-port upload-binaries download-binaries

TRIPLET ?= x64-linux-dynamic
NUGET_FEED ?= 
API_KEY ?=

help:
	@echo "Falcon Dependencies Management"
	@echo "=============================="
	@echo "Targets:"
	@echo "  setup              - Initialize vcpkg (full clone)"
	@echo "  setup-lsp-port     - Generate SHA512 and setup lsp-framework vcpkg port"
	@echo "  build              - Build all vcpkg dependencies"
	@echo "  validate           - Validate vcpkg.json and CMakePresets.json"
	@echo "  upload-binaries    - Upload prebuilt binaries to NuGet"
	@echo "  download-binaries  - Download prebuilt binaries"
	@echo "  clean              - Remove build artifacts"
	@echo ""
	@echo "Examples:"
	@echo "  make setup-lsp-port         # DO THIS FIRST"
	@echo "  make setup"
	@echo "  make build"
	@echo "  make validate"
	@echo ""
	@echo "Environment variables:"
	@echo "  TRIPLET=<name>     - vcpkg triplet (default: x64-linux-dynamic)"
	@echo "  NUGET_FEED=<url>   - NuGet feed URL"
	@echo "  API_KEY=<token>    - NuGet API key"

setup:
	@echo "Setting up vcpkg..."
	@if [ ! -d "vcpkg" ]; then \
		echo "Cloning vcpkg repository (full clone)..."; \
		git clone https://github.com/microsoft/vcpkg.git; \
	else \
		echo "vcpkg directory exists, updating..."; \
		cd vcpkg && git fetch --unshallow && cd ..; \
	fi
	@cd vcpkg && ./bootstrap-vcpkg.sh && cd ..
	@echo "✓ vcpkg initialized with full history"

setup-lsp-port:
	@echo "Setting up lsp-framework port..."
	@mkdir -p /tmp/lsp-framework
	@cd /tmp/lsp-framework && \
		wget -q https://github.com/leon-bckl/lsp-framework/archive/refs/tags/1.3.0.tar.gz && \
		SHA512=$$(sha512sum 1.3.0.tar.gz | awk '{print $$1}') && \
		cd - && \
		sed -i "s/SHA512 <REPLACE_WITH_ACTUAL_SHA512_FROM_STEP_ABOVE>/SHA512 $$SHA512/" ports/lsp-framework/portfile.cmake && \
		echo "✓ Updated portfile.cmake with SHA512: $$SHA512"
	@rm -rf /tmp/lsp-framework

build: setup
	@echo "Building vcpkg dependencies for triplet: $(TRIPLET)..."
	@echo "Using compilers: clang (C) and clang++ (C++)"
	./vcpkg/vcpkg install --triplet=$(TRIPLET) \
		--overlay-ports=./ports \
		--clean-after-build \
		--feature-flags=binarycaching \
		--x-install-root=./vcpkg_installed
	@echo "✓ Build complete"
	@echo "Dependencies installed to: ./vcpkg_installed"

validate:
	@echo "Validating configuration..."
	@jq . vcpkg.json > /dev/null && echo "✓ vcpkg.json valid"
	@jq . CMakePresets.json > /dev/null && echo "✓ CMakePresets.json valid"
	@echo "✓ All configurations valid"

clean:
	rm -rf build
	rm -rf exports
	rm -rf vcpkg_installed
	@echo "✓ Cleaned build artifacts"

upload-binaries: setup
	@if [ -z "$(NUGET_FEED)" ] || [ -z "$(API_KEY)" ]; then \
		echo "Error: NUGET_FEED and API_KEY required"; \
		echo "Usage: make upload-binaries NUGET_FEED=<url> API_KEY=<key>"; \
		exit 1; \
	fi
	@echo "Building and uploading binaries to NuGet feed..."
	@echo "Feed: $(NUGET_FEED)"
	@echo "Triplet: $(TRIPLET)"
	@echo "Using compilers: clang (C) and clang++ (C++)"
	CC=clang CXX=clang++ ./vcpkg/vcpkg install --triplet=$(TRIPLET) \
		--overlay-ports=./ports \
		--clean-after-build \
		--feature-flags=binarycaching \
		--x-install-root=./vcpkg_installed \
		--x-binarysource="clear;nuget,$(NUGET_FEED),readwrite"
	@echo "✓ Binaries built and uploaded"

download-binaries: setup
	@if [ -z "$(NUGET_FEED)" ]; then \
		echo "Error: NUGET_FEED required"; \
		echo "Usage: make download-binaries NUGET_FEED=<url>"; \
		exit 1; \
	fi
	@echo "Downloading prebuilt binaries from NuGet feed..."
	@echo "Feed: $(NUGET_FEED)"
	@echo "Triplet: $(TRIPLET)"
	./vcpkg/vcpkg install --triplet=$(TRIPLET) \
		--overlay-ports=./ports \
		--clean-after-build \
		--feature-flags=binarycaching \
		--x-install-root=./vcpkg_installed \
		--x-binarysource="clear;nuget,$(NUGET_FEED),read"
	@echo "✓ Binaries downloaded"
