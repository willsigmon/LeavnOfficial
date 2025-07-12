#!/bin/bash

# Swift Package Manager Issue Resolution Script
# This script helps resolve common SPM cache and dependency issues

set -e

echo "🔧 Swift Package Manager Issue Resolver"
echo "======================================"

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

print_warning() {
    echo -e "\033[1;33m⚠ $1\033[0m"
}

# Check if we're in the right directory
if [ ! -f "Package.swift" ]; then
    print_error "Package.swift not found. Please run this script from the project root."
    exit 1
fi

# Step 1: Close Xcode
print_step "Step 1: Checking if Xcode is running..."
if pgrep -x "Xcode" > /dev/null; then
    print_warning "Xcode is running. Please close Xcode before continuing."
    echo "Press Enter when Xcode is closed..."
    read
fi

# Step 2: Clean derived data
print_step "Step 2: Cleaning Xcode derived data..."
rm -rf ~/Library/Developer/Xcode/DerivedData/Leavn-*
print_success "Derived data cleaned"

# Step 3: Clean SPM caches
print_step "Step 3: Cleaning Swift Package Manager caches..."
rm -rf ~/Library/Caches/org.swift.swiftpm
rm -rf ~/Library/Developer/Xcode/DerivedData/ModuleCache.noindex
print_success "SPM caches cleaned"

# Step 4: Reset package resolved
print_step "Step 4: Resetting Package.resolved..."
if [ -f "Leavn.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved" ]; then
    rm -f Leavn.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved
    print_success "Package.resolved removed"
else
    print_warning "Package.resolved not found (this is okay)"
fi

# Step 5: Reset Swift packages
print_step "Step 5: Resetting Swift packages..."
swift package reset
print_success "Swift packages reset"

# Step 6: Update packages
print_step "Step 6: Updating Swift packages..."
swift package update
print_success "Swift packages updated"

# Step 7: Check for duplicate GUIDs
print_step "Step 7: Checking for duplicate GUIDs in project file..."
if [ -f "Leavn.xcodeproj/project.pbxproj" ]; then
    duplicate_count=$(grep -o '[A-F0-9]\{24\}' Leavn.xcodeproj/project.pbxproj | sort | uniq -d | wc -l)
    if [ $duplicate_count -gt 0 ]; then
        print_warning "Found $duplicate_count duplicate GUIDs in project.pbxproj"
        echo "Duplicate GUIDs:"
        grep -o '[A-F0-9]\{24\}' Leavn.xcodeproj/project.pbxproj | sort | uniq -d
        echo ""
        echo "You may need to manually edit the project file or regenerate it."
    else
        print_success "No duplicate GUIDs found"
    fi
fi

# Step 8: Regenerate project if needed
print_step "Step 8: Project regeneration"
echo "Do you want to regenerate the Xcode project? (y/n)"
read -r response
if [[ "$response" =~ ^[Yy]$ ]]; then
    if [ -f "Makefile" ] && grep -q "generate:" Makefile; then
        print_step "Regenerating Xcode project..."
        make generate
        print_success "Project regenerated"
    else
        print_warning "No 'generate' target found in Makefile"
        echo "You may need to regenerate the project manually"
    fi
fi

# Step 9: Final instructions
print_step "Final Steps:"
echo "1. Open Xcode"
echo "2. Go to File > Packages > Reset Package Caches"
echo "3. Go to File > Packages > Resolve Package Versions"
echo "4. Clean build folder (Cmd+Shift+K)"
echo "5. Build the project (Cmd+B)"

print_success "SPM issue resolution complete!"
echo ""
echo "If you still see errors:"
echo "- Check the build log for specific package errors"
echo "- Ensure all package URLs are accessible"
echo "- Verify package versions in Package.swift"
echo "- Consider removing and re-adding problematic packages"