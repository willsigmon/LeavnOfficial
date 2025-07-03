# Leavn Development Makefile

.PHONY: all clean build test format lint setup help

# Default target
all: clean build

# Help command
help:
	@echo "Leavn Development Commands:"
	@echo "  make setup    - Initial project setup"
	@echo "  make clean    - Clean build artifacts"
	@echo "  make build    - Build the project"
	@echo "  make test     - Run tests"
	@echo "  make format   - Format code with swift-format"
	@echo "  make lint     - Run SwiftLint"
	@echo "  make generate - Generate Xcode project from project.yml"
	@echo "  make open     - Open in Xcode"

# Initial setup
setup:
	@echo "🔧 Setting up Leavn..."
	@which xcodegen || (echo "Installing XcodeGen..." && brew install xcodegen)
	@which swiftlint || (echo "Installing SwiftLint..." && brew install swiftlint)
	@which swift-format || (echo "Installing swift-format..." && brew install swift-format)
	@make generate
	@echo "✅ Setup complete!"

# Clean build artifacts
clean:
	@echo "🧹 Cleaning..."
	@rm -rf .build
	@rm -rf DerivedData
	@rm -rf ~/Library/Developer/Xcode/DerivedData/Leavn-*
	@xcodebuild clean -quiet || true
	@echo "✅ Clean complete!"

# Build the project
build:
	@echo "🔨 Building Leavn..."
	@xcodebuild build \
		-project Leavn.xcodeproj \
		-scheme Leavn \
		-destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
		-quiet \
		ONLY_ACTIVE_ARCH=YES
	@echo "✅ Build complete!"

# Run tests
test:
	@echo "🧪 Running tests..."
	@xcodebuild test \
		-project Leavn.xcodeproj \
		-scheme Leavn \
		-destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
		| xcpretty
	@echo "✅ Tests complete!"

# Format code
format:
	@echo "🎨 Formatting code..."
	@swift-format -i -r Leavn/ Packages/ Modules/ Tests/
	@echo "✅ Formatting complete!"

# Run linter
lint:
	@echo "🔍 Running SwiftLint..."
	@swiftlint --quiet --fix
	@echo "✅ Linting complete!"

# Generate Xcode project
generate:
	@echo "🏗️ Generating Xcode project..."
	@xcodegen generate
	@echo "✅ Project generated!"

# Open in Xcode
open:
	@echo "🚀 Opening in Xcode..."
	@open Leavn.xcodeproj

# Quick build for development
dev: generate open

# Release build
release:
	@echo "📦 Building release..."
	@xcodebuild archive \
		-project Leavn.xcodeproj \
		-scheme Leavn \
		-archivePath ./build/Leavn.xcarchive
	@echo "✅ Release build complete!"

# Check Swift version
swift-version:
	@swift --version

# Update dependencies
update:
	@echo "📦 Updating packages..."
	@xcodebuild -resolvePackageDependencies
	@echo "✅ Packages updated!"
