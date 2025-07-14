#!/bin/bash

# Emergency Xcode Project Fix Script
# This script fixes PBXFileReference buildPhase corruption

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_header() {
    echo -e "${BLUE}"
    echo "⚡️ ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ ⚡️"
    echo "⚡️               STORM EMERGENCY PROJECT FIX                    ⚡️"
    echo "⚡️                 PBXFileReference Corruption                   ⚡️"
    echo "⚡️ ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ ⚡️"
    echo -e "${NC}"
}

print_status() {
    echo -e "${GREEN}[FIX]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Main fix procedure
main() {
    print_header
    
    print_status "Starting emergency Xcode project fix..."
    
    # Step 1: Backup current project
    print_status "Creating backup..."
    if [ -d "Leavn.xcodeproj" ]; then
        cp -r "Leavn.xcodeproj" "Leavn.xcodeproj.backup.$(date +%Y%m%d_%H%M%S)"
        print_status "✓ Backup created"
    fi
    
    # Step 2: Remove corrupted project
    print_status "Removing corrupted project..."
    rm -rf "Leavn.xcodeproj"
    
    # Step 3: Check for XcodeGen
    if command -v xcodegen >/dev/null 2>&1; then
        print_status "Using XcodeGen to regenerate project..."
        xcodegen generate --spec project.yml
        
        if [ -d "Leavn.xcodeproj" ]; then
            print_status "✅ Project regenerated successfully with XcodeGen"
        else
            print_error "XcodeGen failed to create project"
            exit 1
        fi
    else
        print_error "XcodeGen not found!"
        print_warning "Please install XcodeGen: brew install xcodegen"
        print_warning "Then run: xcodegen generate --spec project.yml"
        exit 1
    fi
    
    # Step 4: Validate project structure
    print_status "Validating project structure..."
    
    if [ -f "Leavn.xcodeproj/project.pbxproj" ]; then
        print_status "✓ project.pbxproj exists"
        
        # Check for key targets
        if grep -q "Leavn-iOS" "Leavn.xcodeproj/project.pbxproj"; then
            print_status "✓ iOS target found"
        else
            print_error "iOS target missing"
        fi
        
        if grep -q "Leavn-macOS" "Leavn.xcodeproj/project.pbxproj"; then
            print_status "✓ macOS target found"
        else
            print_error "macOS target missing"
        fi
        
        if grep -q "Leavn-visionOS" "Leavn.xcodeproj/project.pbxproj"; then
            print_status "✓ visionOS target found"
        else
            print_error "visionOS target missing"
        fi
        
        if grep -q "Leavn-watchOS" "Leavn.xcodeproj/project.pbxproj"; then
            print_status "✓ watchOS target found"
        else
            print_error "watchOS target missing"
        fi
    else
        print_error "project.pbxproj not found after regeneration"
        exit 1
    fi
    
    # Step 5: Test basic build validation
    print_status "Testing basic build validation..."
    
    # Check if Swift packages resolve
    if [ -d "Core/LeavnCore" ]; then
        cd Core/LeavnCore
        if swift package resolve; then
            print_status "✓ LeavnCore packages resolved"
        else
            print_warning "LeavnCore package resolution failed"
        fi
        cd ../..
    fi
    
    if [ -d "Core/LeavnModules" ]; then
        cd Core/LeavnModules
        if swift package resolve; then
            print_status "✓ LeavnModules packages resolved"
        else
            print_warning "LeavnModules package resolution failed"
        fi
        cd ../..
    fi
    
    # Final status
    print_status "🎉 Emergency fix completed!"
    echo ""
    echo "Next steps:"
    echo "1. Open Leavn.xcodeproj in Xcode"
    echo "2. Verify all targets appear in scheme selector"
    echo "3. Test build for each platform"
    echo "4. Notify other agents that project is fixed"
    echo ""
}

# Check prerequisites
check_prerequisites() {
    if [ ! -f "project.yml" ]; then
        print_error "project.yml not found. Run from project root."
        exit 1
    fi
    
    if [ ! -d "Core" ]; then
        print_error "Core directory not found. Run from project root."
        exit 1
    fi
}

# Run the fix
check_prerequisites
main "$@"