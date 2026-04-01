.PHONY: help setup build upload-binaries download-binaries clean validate

TRIPLET ?= x86_64-linux-dynamic
NUGET_FEED ?= 
API_KEY ?=

help:
	@echo "Falcon Dependencies Management"
	@echo "=============================="
	@echo "Targets:"
	@echo "  setup              - Initialize vcpkg and dependencies"
	@echo "  build              - Build all dependencies locally"
	@echo "  validate           - Validate vcpkg.json and CMakePresets.json"
	@echo "  upload-binaries    - Upload prebuilt binaries to NuGet (requires NUGET_FEED and API_KEY)"
	@echo "  download-binaries  - Download prebuilt binaries (requires NUGET_FEED)"
	@echo "  clean              - Remove build artifacts"
	@echo ""
	@echo "Examples:"
	@echo "  make setup"
	@echo "  make build"
	@echo "  make upload-binaries NUGET_FEED=<url> API_KEY=<key>"
	@echo "  make download-binaries NUGET_FEED=<url>"

setup:
	@echo "Setting up vcpkg..."
	@if [ ! -d "vcpkg" ]; then \
		git clone https://github.com/microsoft/vcpkg.git --depth 1; \
	fi
	@cd vcpkg && ./bootstrap-vcpkg.sh && cd ..
	@echo "✓ vcpkg initialized"

build: setup
	@echo "Building dependencies for triplet: $(TRIPLET)"
	cmake --preset ci-linux-dynamic
	cmake --build build --parallel 4
	@echo "✓ Build complete"

validate:
	@echo "Validating configuration..."
	@jq . vcpkg.json > /dev/null && echo "✓ vcpkg.json valid"
	@jq . CMakePresets.json > /dev/null && echo "✓ CMakePresets.json valid"

upload-binaries: setup
	@if [ -z "$(NUGET_FEED)" ] || [ -z "$(API_KEY)" ]; then \
		echo "Error: NUGET_FEED and API_KEY are required"; \
		echo "Usage: make upload-binaries NUGET_FEED=<url> API_KEY=<key>"; \
		exit 1; \
	fi
	bash scripts/upload-binaries.sh $(TRIPLET) $(NUGET_FEED) $(API_KEY)

download-binaries: setup
	@if [ -z "$(NUGET_FEED)" ]; then \
		echo "Error: NUGET_FEED is required"; \
		echo "Usage: make download-binaries NUGET_FEED=<url>"; \
		exit 1; \
	fi
	bash scripts/download-binaries.sh $(NUGET_FEED)

clean:
	rm -rf build
	rm -rf exports
	@echo "✓ Cleaned build artifacts"
