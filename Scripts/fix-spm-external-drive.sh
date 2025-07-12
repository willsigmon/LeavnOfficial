#!/bin/bash

# Swift Package Manager Issue Resolution Script - Project Root Version
# All artifacts stay within the project root

set -e

echo "🔧 SPM Issue Resolver - Project Root Edition"
echo "===================================="

PROJECT_ROOT="/Users/wsig/GitHub Builds/LeavnOfficial"
PROJECT_DD="$PROJECT_ROOT/DerivedData"

# Function to print colored output
print_step() {
    echo -e "\n\033[1;34m➜ $1\033[0m"
}

print_success() {
    echo -e "\033[1;32m✓ $1\033[0m"
}

print_error() {
    echo -e "\033[1;31m✗ $1\033[0m"
}

# Navigate to project root
cd "$PROJECT_ROOT"

# Step 1: Clean all DerivedData
print_step "Step 1: Purging all DerivedData..."
rm -rf ~/Library/Developer/Xcode/DerivedData/* 2>/dev/null || true
rm -rf "$PROJECT_DD"/* 2>/dev/null || true
rm -rf .build DerivedData 2>/dev/null || true
print_success "DerivedData purged"

# Step 2: Clean SPM caches in local packages
print_step "Step 2: Cleaning local package SPM caches..."
rm -rf "$PROJECT_ROOT/local/LeavnCore/.build" 2>/dev/null || true
rm -rf "$PROJECT_ROOT/local/LeavnModules/.build" 2>/dev/null || true
rm -rf ~/Library/Caches/org.swift.swiftpm 2>/dev/null || true
print_success "Local SPM caches cleaned"

# Step 3: Reset Package.resolved files
print_step "Step 3: Resetting Package.resolved files..."
rm -f "$PROJECT_ROOT/Leavn.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved" 2>/dev/null || true
rm -f "$PROJECT_ROOT/local/LeavnCore/Package.resolved" 2>/dev/null || true
rm -f "$PROJECT_ROOT/local/LeavnModules/Package.resolved" 2>/dev/null || true
print_success "Package.resolved files removed"

# Step 4: Reset to default DerivedData location
print_step "Step 4: Resetting DerivedData to default location..."
/usr/bin/defaults delete com.apple.dt.Xcode IDECustomDerivedDataLocation 2>/dev/null || true
print_success "DerivedData location reset to default"

# Step 5: Check for space/encoding issues
print_step "Step 5: Scanning for path encoding issues..."
space_count=$(grep -r "Xcode Files\|Xcode%20Files" "$PROJECT_ROOT" --include="*.swift" --include="*.yml" --include="*.xcconfig" 2>/dev/null | wc -l || echo "0")
if [[ $space_count -gt 0 ]]; then
    print_error "Found $space_count files with space/encoding issues in paths"
else
    print_success "No path encoding issues found"
fi

# Step 6: Create project directory structure
print_step "Step 6: Ensuring project directories exist..."
/bin/mkdir -p "$PROJECT_DD"
/bin/mkdir -p "$PROJECT_ROOT/build"
print_success "Project directory structure ready"

print_success "SPM project root resolution complete!"
echo ""
echo "Next steps:"
echo "1. Run: xcodebuild clean -project Leavn.xcodeproj"
echo "2. Run: xcodebuild build -project Leavn.xcodeproj -scheme Leavn -derivedDataPath \"$PROJECT_DD\""