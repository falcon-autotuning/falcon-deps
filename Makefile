.PHONY: help setup build validate clean setup-lsp-port upload-binaries download-binaries

TRIPLET ?= x64-linux-dynamic
NUGET_FEED ?= 
API_KEY ?=

help:
	@echo "Falcon Dependencies Management"
	@echo "=============================="
	@echo "Targets:"
	@echo "  setup              - Initialize vcpkg"
	@echo "  setup-lsp-port     - Generate SHA512 for lsp-framework port"
	@echo "  build              - Build all vcpkg dependencies"
	@echo "  validate           - Validate vcpkg.json"
	@echo "  clean              - Remove build artifacts"
	@echo ""
	@echo "Examples:"
	@echo "  make setup"
	@echo "  make build"

setup:
	@if [ ! -d "vcpkg" ]; then \
		echo "Cloning vcpkg..."; \
		git clone https://github.com/microsoft/vcpkg.git; \
	fi
	@cd vcpkg && ./bootstrap-vcpkg.sh && cd ..
	@echo "✓ vcpkg ready"

setup-lsp-port:
	@echo "Setting up lsp-framework port..."
	@mkdir -p /tmp/lsp-framework
	@cd /tmp/lsp-framework && \
		wget -q https://github.com/leon-bckl/lsp-framework/archive/refs/tags/1.3.0.tar.gz && \
		SHA512=$$(sha512sum 1.3.0.tar.gz | awk '{print $$1}') && \
		cd - && \
		sed -i "s/SHA512 <REPLACE_WITH_ACTUAL_SHA512_FROM_STEP_ABOVE>/SHA512 $$SHA512/" ports/lsp-framework/portfile.cmake && \
		echo "✓ Updated portfile.cmake with SHA512"
	@rm -rf /tmp/lsp-framework

build: setup validate
	@echo "Building vcpkg dependencies..."
	@echo "Triplet: $(TRIPLET)"
	@echo "Compiler: clang / clang++"
	./vcpkg/vcpkg install \
		--triplet=$(TRIPLET) \
		--overlay-ports=./ports
	@echo "✓ Build complete"
	@echo "Installed to: vcpkg_installed/$(TRIPLET)"

validate:
	@jq . vcpkg.json > /dev/null && echo "✓ vcpkg.json valid" || echo "✗ vcpkg.json invalid"

clean:
	rm -rf vcpkg_installed
	rm -rf build
	@echo "✓ Cleaned"
