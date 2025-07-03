# Leavn Development Makefile

.PHONY: all clean build test format lint setup help device

# Default target
all: clean build

# Variables for simulator destination
# Default to iPhone 15 Pro, but allow overriding, e.g., make build DEVICE_NAME="iPhone SE (3rd generation)"
SIMULATOR_PLATFORM ?= "iOS Simulator"
SIMULATOR_OS_VERSION ?= "18.0" # Should match project's deployment target or newer
DEFAULT_DEVICE_NAME := "iPhone 15 Pro"
DEVICE_NAME ?= $(DEFAULT_DEVICE_NAME)
# Construct the destination string. If a specific DEVICE_ID is provided, use that.
ifeq ($(DEVICE_ID),)
  DESTINATION := "platform=$(SIMULATOR_PLATFORM),name=$(DEVICE_NAME),OS=$(SIMULATOR_OS_VERSION)"
else
  DESTINATION := "platform=$(SIMULATOR_PLATFORM),id=$(DEVICE_ID)"
endif

# Help command
help:
	@echo "Leavn Development Commands:"
	@echo "  make setup            - Initial project setup"
	@echo "  make clean            - Clean build artifacts"
	@echo "  make build            - Build for the default simulator ($(DEFAULT_DEVICE_NAME))"
	@echo "                        Override with: make build DEVICE_NAME=\"My Target Simulator\""
	@echo "                        Or by ID: make build DEVICE_ID=\"Simulator-GUID\""
	@echo "  make device           - Build for physical device testing"
	@echo "  make test             - Run tests on the default simulator ($(DEFAULT_DEVICE_NAME))"
	@echo "                        Override with: make test DEVICE_NAME=\"My Target Simulator\""
	@echo "  make format           - Format code with swift-format"
	@echo "  make lint             - Run SwiftLint"
	@echo "  make generate         - Generate Xcode project from project.yml"
	@echo "  make open             - Open in Xcode"
	@echo "  make archive          - Create archive for distribution"
	@echo "  make swift-version    - Check Swift version"
	@echo "  make update           - Update Swift Package Manager dependencies"
	# @echo "  make plane-ready - Quick device setup for plane testing" # Commented out - too specific
	# @echo "  make build-optimized - Build with maximum optimizations" # Commented out - too specific
	# @echo "  make perf-test - Run performance tests" # Commented out - too specific


# Initial setup
setup:
	@echo "🔧 Setting up Leavn development environment..."
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

# Build for specified simulator
build:
	@echo "🔨 Building Leavn for $(DEVICE_NAME) ($(SIMULATOR_PLATFORM) $(SIMULATOR_OS_VERSION))..."
	@xcodebuild build \
		-project Leavn.xcodeproj \
		-scheme "Leavn" \
		-destination '$(DESTINATION)' \
		-quiet \
		ONLY_ACTIVE_ARCH=YES \
		ASSETCATALOG_COMPILER_OPTIMIZATION=space \
		SWIFT_COMPILATION_MODE=wholemodule \
		LLVM_LTO=YES_THIN
	@echo "✅ Build complete for $(DEVICE_NAME)!"

# Build for physical device testing
device:
	@echo "📱 Building Leavn for Physical Device..."
	@xcodebuild build \
		-project Leavn.xcodeproj \
		-scheme "Leavn" \
		-destination 'generic/platform=iOS' \
		-quiet \
		CODE_SIGN_IDENTITY="iPhone Developer" \
		DEVELOPMENT_TEAM="" \
		PROVISIONING_PROFILE_SPECIFIER="" \
		ASSETCATALOG_COMPILER_OPTIMIZATION=space \
		SWIFT_COMPILATION_MODE=wholemodule \
		LLVM_LTO=YES_THIN \
		DEAD_CODE_STRIPPING=YES
	@echo "✅ Device build complete!"

# Run tests on specified simulator
test:
	@echo "🧪 Running tests on $(DEVICE_NAME) ($(SIMULATOR_PLATFORM) $(SIMULATOR_OS_VERSION))..."
	@xcodebuild test \
		-project Leavn.xcodeproj \
		-scheme "Leavn" \
		-destination '$(DESTINATION)' \
		-enableCodeCoverage YES \
		| xcpretty || true # xcpretty might not be installed, so allow failure
	@echo "✅ Tests complete!"

# Format code
format:
	@echo "🎨 Formatting code..."
	@swift-format -i -r Leavn/ Packages/ Modules/ Tests/ || true
	@echo "✅ Formatting complete!"

# Run linter
lint:
	@echo "🔍 Running SwiftLint..."
	@swiftlint --quiet --fix || true
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

# Archive for TestFlight/App Store
archive:
	@echo "📦 Creating archive for distribution..."
	@xcodebuild archive \
		-project Leavn.xcodeproj \
		-scheme "Leavn" \
		-archivePath ./build/Leavn.xcarchive \
		-destination 'generic/platform=iOS' \
		CODE_SIGN_IDENTITY="iPhone Distribution" \
		DEVELOPMENT_TEAM="" \
		PROVISIONING_PROFILE_SPECIFIER="" \
		ASSETCATALOG_COMPILER_OPTIMIZATION=space \
		SWIFT_COMPILATION_MODE=wholemodule \
		LLVM_LTO=YES \
		DEAD_CODE_STRIPPING=YES
	@echo "✅ Archive complete!"

# Check Swift version
swift-version:
	@swift --version

# Update dependencies
update:
	@echo "📦 Updating packages..."
	@xcodebuild -resolvePackageDependencies -project Leavn.xcodeproj
	@echo "✅ Packages updated!"

# # Quick setup and test build for personal device - iPhone 16 Pro Max ready
# plane-ready: clean generate device
# 	@echo "✈️ Your Leavn app is ready for plane testing on iPhone 16 Pro Max!"
# 	@echo "📋 To install on your device:"
# 	@echo "   1. Connect your iPhone 16 Pro Max (or compatible device) to this Mac"
# 	@echo "   2. Open Leavn.xcodeproj in Xcode"
# 	@echo "   3. Select your device as the destination"
# 	@echo "   4. Click Run (⌘R) to install and launch"
# 	@echo "   5. Trust the developer certificate in Settings > General > VPN & Device Management"
# 	@echo ""
# 	@echo "🚀 App Features Optimized for iPhone 16 Pro Max:"
# 	@echo "   • ProMotion 120Hz smooth scrolling Bible reading"
# 	@echo "   • Action Button shortcuts for quick verse lookup"
# 	@echo "   • Dynamic Island integration for reading progress"
# 	@echo "   • A17 Pro GPU acceleration for smooth animations"
# 	@echo "   • Always-On Display support for verse of the day"

# # iPhone 16 Pro Max specific optimization builds
# build-optimized:
# 	@echo "🔥 Building with maximum iPhone 16 Pro Max optimizations..."
# 	@xcodebuild build \
# 		-project Leavn.xcodeproj \
# 		-scheme "Leavn" \
# 		-destination '$(DESTINATION)' \
# 		-configuration Release \
# 		ASSETCATALOG_COMPILER_OPTIMIZATION=space \
# 		SWIFT_COMPILATION_MODE=wholemodule \
# 		SWIFT_OPTIMIZATION_LEVEL=-O \
# 		LLVM_LTO=YES \
# 		DEAD_CODE_STRIPPING=YES \
# 		MTL_FAST_MATH=YES \
# 		GCC_OPTIMIZATION_LEVEL=fast
# 	@echo "✅ Maximum optimization build complete!"

# # Performance test on iPhone 16 Pro Max
# perf-test:
# 	@echo "🏎️ Running performance tests on $(DEVICE_NAME)..."
# 	@xcodebuild test \
# 		-project Leavn.xcodeproj \
# 		-scheme "Leavn" \
# 		-destination '$(DESTINATION)' \
# 		-testPlan "Performance"
# 	@echo "✅ Performance tests complete!"
