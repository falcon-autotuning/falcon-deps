.PHONY: help setup build validate clean setup-lsp-port upload-binaries download-binaries

TRIPLET ?= x64-linux-dynamic
NUGET_FEED ?= 
API_KEY ?=

help:
	@echo "Falcon Dependencies Management"
	@echo "=============================="
	@echo "Targets:"
	@echo "  setup              - Initialize vcpkg and dependencies"
	@echo "  setup-lsp-port     - Generate SHA512 and setup lsp-framework vcpkg port"
	@echo "  build              - Build all dependencies"
	@echo "  validate           - Validate vcpkg.json and CMakePresets.json"
	@echo "  upload-binaries    - Upload prebuilt binaries to NuGet"
	@echo "  download-binaries  - Download prebuilt binaries"
	@echo "  clean              - Remove build artifacts"
	@echo ""
	@echo "Examples:"
	@echo "  make setup-lsp-port         # DO THIS FIRST"
	@echo "  make setup"
	@echo "  make build"

setup:
	@echo "Setting up vcpkg..."
	@if [ ! -d "vcpkg" ]; then \
		git clone https://github.com/microsoft/vcpkg.git --depth 1; \
	fi
	@cd vcpkg && ./bootstrap-vcpkg.sh && cd ..
	@echo "✓ vcpkg initialized"

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
	@echo "Building dependencies for triplet: $(TRIPLET)..."
	cmake --preset default
	cmake --build build --parallel 4
	@echo "✓ Build complete"

validate:
	@echo "Validating configuration..."
	@jq . vcpkg.json > /dev/null && echo "✓ vcpkg.json valid"
	@jq . CMakePresets.json > /dev/null && echo "✓ CMakePresets.json valid"

clean:
	rm -rf build
	rm -rf exports
	@echo "✓ Cleaned build artifacts"

upload-binaries: setup
	@if [ -z "$(NUGET_FEED)" ] || [ -z "$(API_KEY)" ]; then \
		echo "Error: NUGET_FEED and API_KEY required"; \
		exit 1; \
	fi
	bash scripts/upload-binaries.sh $(TRIPLET) $(NUGET_FEED) $(API_KEY)

download-binaries: setup
	@if [ -z "$(NUGET_FEED)" ]; then \
		echo "Error: NUGET_FEED required"; \
		exit 1; \
	fi
	bash scripts/download-binaries.sh $(NUGET_FEED)
