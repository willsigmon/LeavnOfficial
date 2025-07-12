#!/bin/bash
export PATH="/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin"

# Fix Build Paths Script
# Removes NVME references and sets proper build paths

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

echo "🔧 Fixing build paths in $PROJECT_DIR"

# Clean all build artifacts
echo "🧹 Cleaning build artifacts..."
rm -rf ~/Library/Developer/Xcode/DerivedData/*
rm -rf "$PROJECT_DIR/build"
rm -rf "$PROJECT_DIR/.build"
rm -rf "/Volumes/NVME/Xcode Files"

# Set proper build locations
echo "📁 Setting build locations..."
defaults write com.apple.dt.Xcode IDECustomBuildLocationType Relative
defaults write com.apple.dt.Xcode IDECustomBuildProductsPath "build/Products"
defaults write com.apple.dt.Xcode IDECustomBuildIntermediatesPath "build/Intermediates"

# Reset package cache
echo "📦 Resetting package cache..."
rm -rf ~/Library/Caches/org.swift.swiftpm

# Clean the project
echo "🏗️ Cleaning project..."
cd "$PROJECT_DIR"
xcodebuild clean -scheme Leavn -quiet || true

# Resolve packages
echo "📚 Resolving packages..."
xcodebuild -resolvePackageDependencies

echo "✅ Build paths fixed! Try building again."