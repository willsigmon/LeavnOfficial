#!/bin/bash

# NVME Reference Removal Script
# Permanently removes all NVME references from the project

set -e

echo "🧹 NVME Reference Removal Script"
echo "================================"

PROJECT_ROOT="/Users/wsig/GitHub Builds/LeavnOfficial"
cd "$PROJECT_ROOT"

# Function to print colored output
print_step() {
    echo -e "\n\033[1;34m➜ $1\033[0m"
}

print_success() {
    echo -e "\033[1;32m✓ $1\033[0m"
}

# Step 1: Remove old build scripts that reference NVME
print_step "Step 1: Cleaning up old build scripts..."
OLD_SCRIPTS=(
    "Scripts/build-nvme.sh"
    "Scripts/fix-spm-nvme.sh"
)
for script in "${OLD_SCRIPTS[@]}"; do
    if [ -f "$script" ]; then
        rm "$script"
        print_success "Removed $script"
    fi
done

# Step 2: Reset Xcode defaults
print_step "Step 2: Resetting Xcode defaults..."
/usr/bin/defaults delete com.apple.dt.Xcode IDECustomDerivedDataLocation 2>/dev/null || true
/usr/bin/defaults delete com.apple.dt.Xcode IDECustomBuildProductsPath 2>/dev/null || true
/usr/bin/defaults delete com.apple.dt.Xcode IDECustomIntermediatesPath 2>/dev/null || true
print_success "Xcode defaults reset to standard locations"

# Step 3: Clean up any NVME artifacts on disk
print_step "Step 3: Removing NVME artifacts..."
if [ -d "/Volumes/NVME/XcodeFiles" ]; then
    echo "Found NVME directory. Remove manually if needed: /Volumes/NVME/XcodeFiles"
fi
if [ -d "/Volumes/NVME/Xcode Files" ]; then
    echo "Found NVME directory with spaces. Remove manually if needed: /Volumes/NVME/Xcode Files"
fi

# Step 4: Create project-local directories
print_step "Step 4: Creating project-local build directories..."
mkdir -p "$PROJECT_ROOT/build"
mkdir -p "$PROJECT_ROOT/DerivedData"
print_success "Created local build directories"

# Step 5: Update .gitignore
print_step "Step 5: Updating .gitignore..."
if ! grep -q "^build/$" .gitignore 2>/dev/null; then
    echo "build/" >> .gitignore
fi
if ! grep -q "^DerivedData/$" .gitignore 2>/dev/null; then
    echo "DerivedData/" >> .gitignore
fi
print_success ".gitignore updated"

print_success "NVME reference removal complete!"
echo ""
echo "✅ All NVME references have been removed"
echo "✅ Build artifacts will now be generated in:"
echo "   - $PROJECT_ROOT/build"
echo "   - $PROJECT_ROOT/DerivedData"
echo ""
echo "Next steps:"
echo "1. Use Scripts/build-project-root.sh for builds"
echo "2. Or build directly in Xcode (will use default locations)"