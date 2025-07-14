# Leavn Project Makefile

.PHONY: help setup clean build test archive lint format docs ci

# Default target
help:
	@echo "Leavn Project Commands:"
	@echo ""
	@echo "  make setup       - Setup development environment"
	@echo "  make clean       - Clean all build artifacts"
	@echo "  make build       - Build the project (iOS by default)"
	@echo "  make test        - Run all tests"
	@echo "  make archive     - Create release archive"
	@echo "  make lint        - Run SwiftLint"
	@echo "  make format      - Format code with SwiftFormat"
	@echo "  make docs        - Generate documentation"
	@echo "  make ci          - Run CI pipeline locally"
	@echo ""
	@echo "Platform-specific builds:"
	@echo "  make build-ios   - Build for iOS"
	@echo "  make build-macos - Build for macOS"
	@echo "  make build-watch - Build for watchOS"
	@echo "  make build-tv    - Build for tvOS"
	@echo "  make build-vision- Build for visionOS"

# Setup development environment
setup:
	@echo "Setting up development environment..."
	@# Install tools if needed
	@command -v xcodegen >/dev/null 2>&1 || brew install xcodegen
	@command -v swiftlint >/dev/null 2>&1 || brew install swiftlint
	@command -v swiftformat >/dev/null 2>&1 || brew install swiftformat
	@command -v xcbeautify >/dev/null 2>&1 || brew install xcbeautify
	@# Generate project
	@if [ -f "project.yml" ]; then \
		xcodegen generate; \
	fi
	@# Resolve packages
	@./Scripts/fix-spm-issues.sh
	@echo "Setup complete!"

# Clean build artifacts
clean:
	@echo "Cleaning build artifacts..."
	@rm -rf .build
	@rm -rf .swiftpm
	@rm -rf ~/Library/Developer/Xcode/DerivedData/Leavn-*
	@find . -name "*.xcodeproj" -type d -exec rm -rf {} + 2>/dev/null || true
	@find . -name "*.xcworkspace" -type d -not -path "*/xcshareddata/*" -exec rm -rf {} + 2>/dev/null || true
	@echo "Clean complete!"

# Build targets
build: build-ios

build-ios:
	@./Scripts/build.sh --platform iOS --configuration Debug

build-macos:
	@./Scripts/build.sh --platform macOS --configuration Debug

build-watch:
	@./Scripts/build.sh --platform watchOS --configuration Debug

build-tv:
	@./Scripts/build.sh --platform tvOS --configuration Debug

build-vision:
	@./Scripts/build.sh --platform visionOS --configuration Debug

# Test
test:
	@echo "Running tests..."
	@./Scripts/build.sh --platform iOS --configuration Debug --test

test-core:
	@echo "Testing Core modules..."
	@cd Core/LeavnCore && swift test
	@cd Core/LeavnModules && swift test

# Archive
archive:
	@echo "Creating archive..."
	@./Scripts/build.sh --platform iOS --configuration Release --archive

# Lint
lint:
	@echo "Running SwiftLint..."
	@if command -v swiftlint >/dev/null 2>&1; then \
		swiftlint lint --config .swiftlint.yml; \
	else \
		echo "SwiftLint not installed. Run 'make setup' first."; \
		exit 1; \
	fi

lint-fix:
	@echo "Running SwiftLint autocorrect..."
	@if command -v swiftlint >/dev/null 2>&1; then \
		swiftlint lint --fix --config .swiftlint.yml; \
	else \
		echo "SwiftLint not installed. Run 'make setup' first."; \
		exit 1; \
	fi

# Format
format:
	@echo "Running SwiftFormat..."
	@if command -v swiftformat >/dev/null 2>&1; then \
		swiftformat . --config .swiftformat; \
	else \
		echo "SwiftFormat not installed. Run 'make setup' first."; \
		exit 1; \
	fi

# Documentation
docs:
	@echo "Generating documentation..."
	@if command -v jazzy >/dev/null 2>&1; then \
		jazzy \
			--clean \
			--author "Leavn" \
			--module-name Leavn \
			--theme apple \
			--output docs/; \
	else \
		echo "Jazzy not installed. Install with: gem install jazzy"; \
		exit 1; \
	fi

# CI Pipeline
ci: clean lint test
	@echo "CI pipeline complete!"

# Development shortcuts
dev: setup
	@open Leavn.xcworkspace || open Leavn.xcodeproj

# Release build
release: clean
	@./Scripts/build.sh --platform iOS --configuration Release --clean --archive
	@./Scripts/build.sh --platform macOS --configuration Release --clean --archive

# Generate app icons
icons:
	@echo "Generating app icons..."
	@chmod +x Scripts/generate-app-icons.sh
	@./Scripts/generate-app-icons.sh

# Setup code signing
setup-signing:
	@echo "Setting up code signing..."
	@chmod +x Scripts/setup-code-signing.sh
	@./Scripts/setup-code-signing.sh

# Install git hooks
install-hooks:
	@echo "Installing git hooks..."
	@cp Scripts/git-hooks/* .git/hooks/
	@chmod +x .git/hooks/*
	@echo "Git hooks installed!"