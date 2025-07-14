#!/bin/bash

# Clean up duplicate package GUID issue in Leavn project
# This script removes duplicate package references and regenerates the project cleanly

echo "🧹 Starting cleanup of duplicate package references..."

# Change to project directory
cd "$(dirname "$0")/.." || exit 1

# Step 1: Check current configuration
echo "📋 Checking project configuration..."
if [ -f "project.yml" ] && [ -f "Project.swift" ]; then
    echo "⚠️  Found both project.yml (XcodeGen) and Project.swift (Tuist)"
    echo "   This can cause conflicts. Recommend using only one."
    
    # Check which tool is installed
    if command -v tuist &> /dev/null; then
        echo "✅ Tuist is installed"
        TOOL="tuist"
    elif command -v xcodegen &> /dev/null; then
        echo "✅ XcodeGen is installed"
        TOOL="xcodegen"
    else
        echo "❌ Neither Tuist nor XcodeGen found. Please install one:"
        echo "   brew install tuist OR brew install xcodegen"
        exit 1
    fi
    
    echo ""
    echo "Which configuration would you like to use?"
    echo "1) Tuist (Project.swift) - Recommended for modern Swift projects"
    echo "2) XcodeGen (project.yml)"
    echo "3) Exit without changes"
    read -p "Enter choice (1-3): " choice
    
    case $choice in
        1)
            echo "Using Tuist configuration..."
            CONFIG="tuist"
            # Backup project.yml
            if [ -f "project.yml" ]; then
                mv project.yml project.yml.backup
                echo "📦 Backed up project.yml to project.yml.backup"
            fi
            ;;
        2)
            echo "Using XcodeGen configuration..."
            CONFIG="xcodegen"
            # Backup Project.swift
            if [ -f "Project.swift" ]; then
                mv Project.swift Project.swift.backup
                echo "📦 Backed up Project.swift to Project.swift.backup"
            fi
            ;;
        3)
            echo "Exiting without changes..."
            exit 0
            ;;
        *)
            echo "Invalid choice. Exiting..."
            exit 1
            ;;
    esac
elif [ -f "Project.swift" ]; then
    CONFIG="tuist"
elif [ -f "project.yml" ]; then
    CONFIG="xcodegen"
else
    echo "❌ No project configuration found (neither project.yml nor Project.swift)"
    exit 1
fi

# Step 2: Backup current Xcode project
if [ -d "Leavn.xcodeproj" ]; then
    BACKUP_NAME="Leavn.xcodeproj.backup.$(date +%Y%m%d_%H%M%S)"
    cp -R Leavn.xcodeproj "$BACKUP_NAME"
    echo "📦 Backed up current project to $BACKUP_NAME"
fi

# Step 3: Remove current Xcode project
echo "🗑️  Removing current Xcode project..."
rm -rf Leavn.xcodeproj

# Step 4: Clean all package caches
echo "🧹 Cleaning package caches..."
rm -rf ~/Library/Caches/org.swift.swiftpm
rm -rf .swiftpm
rm -rf .build
rm -rf ~/Library/Developer/Xcode/DerivedData/*

# Clean Tuist cache if using Tuist
if [ "$CONFIG" = "tuist" ]; then
    echo "🧹 Cleaning Tuist cache..."
    rm -rf .tuist
    rm -rf ~/Library/Caches/tuist
fi

# Step 5: Verify local packages exist
echo "📦 Verifying local packages..."
if [ ! -f "Core/LeavnCore/Package.swift" ]; then
    echo "❌ LeavnCore package not found at Core/LeavnCore/Package.swift"
    exit 1
fi
if [ ! -f "Core/LeavnModules/Package.swift" ]; then
    echo "❌ LeavnModules package not found at Core/LeavnModules/Package.swift"
    exit 1
fi
echo "✅ Local packages verified"

# Step 6: Generate fresh project
echo "🔨 Generating fresh project..."
if [ "$CONFIG" = "tuist" ]; then
    # Fetch dependencies first
    echo "📦 Fetching dependencies..."
    tuist fetch
    
    # Generate project
    echo "🏗️  Generating project with Tuist..."
    tuist generate
elif [ "$CONFIG" = "xcodegen" ]; then
    echo "🏗️  Generating project with XcodeGen..."
    xcodegen generate
fi

# Step 7: Verify the generated project
if [ -d "Leavn.xcodeproj" ]; then
    echo "✅ Project generated successfully!"
    
    # Open in Xcode
    echo ""
    read -p "Would you like to open the project in Xcode? (y/n): " open_xcode
    if [ "$open_xcode" = "y" ] || [ "$open_xcode" = "Y" ]; then
        open Leavn.xcodeproj
    fi
else
    echo "❌ Project generation failed"
    exit 1
fi

echo ""
echo "✅ Cleanup complete!"
echo ""
echo "Next steps:"
echo "1. Open the project in Xcode"
echo "2. Wait for package resolution to complete"
echo "3. Build the project (Cmd+B)"
echo ""
echo "If you still see package errors:"
echo "- File > Packages > Reset Package Caches"
echo "- File > Packages > Update to Latest Package Versions"