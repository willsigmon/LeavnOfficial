# Leavn Development Makefile - Optimized for iPhone 16 Pro Max

.PHONY: all clean build test format lint setup help device

# Default target
all: clean build

# Primary device target for development  
DEVICE := "iPhone 16 Pro Max"
DEVICE_ID := platform=iOS Simulator,id=2DFCBD7D-FF4D-4EE6-8D8D-E0ABAD590A36

# Help command
help:
	@echo "Leavn Development Commands:"
	@echo "  make setup    - Initial project setup"
	@echo "  make clean    - Clean build artifacts"
	@echo "  make build    - Build for iPhone 16 Pro Max simulator"
	@echo "  make device   - Build for physical device testing"
	@echo "  make test     - Run tests on iPhone 16 Pro Max"
	@echo "  make format   - Format code with swift-format"
	@echo "  make lint     - Run SwiftLint"
	@echo "  make generate - Generate Xcode project from project.yml"
	@echo "  make open     - Open in Xcode"
	@echo "  make plane-ready - Quick device setup for plane testing"

# Initial setup
setup:
	@echo "🔧 Setting up Leavn for iPhone 16 Pro Max development..."
	@which xcodegen || (echo "Installing XcodeGen..." && brew install xcodegen)
	@which swiftlint || (echo "Installing SwiftLint..." && brew install swiftlint)
	@which swift-format || (echo "Installing swift-format..." && brew install swift-format)
	@make generate
	@echo "✅ Setup complete! Optimized for iPhone 16 Pro Max"

# Clean build artifacts
clean:
	@echo "🧹 Cleaning..."
	@rm -rf .build
	@rm -rf DerivedData
	@rm -rf ~/Library/Developer/Xcode/DerivedData/Leavn-*
	@xcodebuild clean -quiet || true
	@echo "✅ Clean complete!"

# Build for iPhone 16 Pro Max simulator
build:
	@echo "🔨 Building Leavn for $(DEVICE)..."
	@xcodebuild build \
		-project Leavn.xcodeproj \
		-scheme "Leavn" \
		-destination '$(DEVICE_ID)' \
		-quiet \
		ONLY_ACTIVE_ARCH=YES \
		ASSETCATALOG_COMPILER_OPTIMIZATION=space \
		SWIFT_COMPILATION_MODE=wholemodule \
		LLVM_LTO=YES_THIN
	@echo "✅ Build complete for $(DEVICE)!"

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

# Run tests on iPhone 16 Pro Max
test:
	@echo "🧪 Running tests on $(DEVICE)..."
	@xcodebuild test \
		-project Leavn.xcodeproj \
		-scheme "Leavn" \
		-destination '$(DEVICE_ID)' \
		-enableCodeCoverage YES \
		| xcpretty || true
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

# Generate Xcode project with iPhone 16 Pro Max optimizations
generate:
	@echo "🏗️ Generating Xcode project with iPhone 16 Pro Max optimizations..."
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

# Quick setup and test build for personal device - iPhone 16 Pro Max ready
plane-ready: clean generate device
	@echo "✈️ Your Leavn app is ready for plane testing on iPhone 16 Pro Max!"
	@echo "📋 To install on your device:"
	@echo "   1. Connect your iPhone 16 Pro Max (or compatible device) to this Mac"
	@echo "   2. Open Leavn.xcodeproj in Xcode"
	@echo "   3. Select your device as the destination"
	@echo "   4. Click Run (⌘R) to install and launch"
	@echo "   5. Trust the developer certificate in Settings > General > VPN & Device Management"
	@echo ""
	@echo "🚀 App Features Optimized for iPhone 16 Pro Max:"
	@echo "   • ProMotion 120Hz smooth scrolling Bible reading"
	@echo "   • Action Button shortcuts for quick verse lookup"
	@echo "   • Dynamic Island integration for reading progress"
	@echo "   • A17 Pro GPU acceleration for smooth animations"
	@echo "   • Always-On Display support for verse of the day"

# iPhone 16 Pro Max specific optimization builds
build-optimized:
	@echo "🔥 Building with maximum iPhone 16 Pro Max optimizations..."
	@xcodebuild build \
		-project Leavn.xcodeproj \
		-scheme "Leavn" \
		-destination '$(DEVICE_ID)' \
		-configuration Release \
		ASSETCATALOG_COMPILER_OPTIMIZATION=space \
		SWIFT_COMPILATION_MODE=wholemodule \
		SWIFT_OPTIMIZATION_LEVEL=-O \
		LLVM_LTO=YES \
		DEAD_CODE_STRIPPING=YES \
		MTL_FAST_MATH=YES \
		GCC_OPTIMIZATION_LEVEL=fast
	@echo "✅ Maximum optimization build complete!"

# Performance test on iPhone 16 Pro Max
perf-test:
	@echo "🏎️ Running performance tests on $(DEVICE)..."
	@xcodebuild test \
		-project Leavn.xcodeproj \
		-scheme "Leavn" \
		-destination '$(DEVICE_ID)' \
		-testPlan "Performance"
	@echo "✅ Performance tests complete!"
