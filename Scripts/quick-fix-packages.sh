#!/bin/bash

# Quick fix for duplicate package GUID issue
# This script provides the immediate fix without prompting

echo "🚀 Quick fix for duplicate package GUID issue"
echo "============================================"

cd "$(dirname "$0")/.." || exit 1

# Step 1: Backup and remove current project
echo "1️⃣ Backing up and removing current Xcode project..."
if [ -d "Leavn.xcodeproj" ]; then
    mv Leavn.xcodeproj "Leavn.xcodeproj.backup.$(date +%Y%m%d_%H%M%S)"
fi

# Step 2: Clean all caches
echo "2️⃣ Cleaning all package caches..."
rm -rf ~/Library/Caches/org.swift.swiftpm
rm -rf .swiftpm
rm -rf .build
rm -rf .tuist
rm -rf ~/Library/Caches/tuist

# Step 3: Since both config files exist, we'll use Tuist (Project.swift)
# as it's more modern and already configured
echo "3️⃣ Using Tuist configuration (Project.swift)..."

# Check if Tuist is installed
if ! command -v tuist &> /dev/null; then
    echo "⚠️  Tuist not found. Installing via Homebrew..."
    brew install tuist
fi

# Step 4: Generate fresh project with Tuist
echo "4️⃣ Generating fresh project..."
tuist fetch
tuist generate

echo ""
echo "✅ Quick fix complete!"
echo ""
echo "To open in Xcode: open Leavn.xcodeproj"
echo ""
echo "If you see any remaining issues in Xcode:"
echo "1. File > Packages > Reset Package Caches"
echo "2. File > Packages > Update to Latest Package Versions"