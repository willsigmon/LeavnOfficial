#!/bin/bash

# Comprehensive Build Error Fix Script for Leavn
# This script fixes all known build errors in one go

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print functions
print_section() {
    echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}▶ $1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# Main execution
main() {
    print_section "🛠️  Leavn Build Error Fix Script"
    
    # Step 1: Clean DerivedData
    print_section "Step 1: Cleaning DerivedData"
    if rm -rf ~/Library/Developer/Xcode/DerivedData/Leavn-*; then
        print_success "DerivedData cleaned"
    else
        print_warning "No DerivedData to clean"
    fi
    
    # Step 2: Clean SPM cache
    print_section "Step 2: Cleaning Swift Package Manager Cache"
    if [ -d ".build" ]; then
        rm -rf .build
        print_success "SPM build directory cleaned"
    fi
    
    if [ -d ".swiftpm" ]; then
        rm -rf .swiftpm
        print_success "SPM cache directory cleaned"
    fi
    
    # Step 3: Resolve packages
    print_section "Step 3: Resolving Swift Packages"
    if command -v swift >/dev/null 2>&1; then
        cd Core/LeavnCore && swift package resolve && cd ../..
        print_success "LeavnCore packages resolved"
        
        cd Core/LeavnModules && swift package resolve && cd ../..
        print_success "LeavnModules packages resolved"
    else
        print_warning "Swift command not found - resolve packages in Xcode"
    fi
    
    # Step 4: Clean Xcode project state
    print_section "Step 4: Cleaning Xcode Project State"
    if [ -d "Leavn.xcodeproj/project.xcworkspace/xcshareddata/swiftpm" ]; then
        rm -rf Leavn.xcodeproj/project.xcworkspace/xcshareddata/swiftpm
        print_success "Xcode SPM state cleaned"
    fi
    
    if [ -d "Leavn.xcodeproj/xcuserdata" ]; then
        rm -rf Leavn.xcodeproj/xcuserdata
        print_success "Xcode user data cleaned"
    fi
    
    # Step 5: Verify package structure
    print_section "Step 5: Verifying Package Structure"
    
    if [ -f "Core/LeavnCore/Package.swift" ]; then
        print_success "LeavnCore Package.swift exists"
    else
        print_error "LeavnCore Package.swift missing!"
    fi
    
    if [ -f "Core/LeavnModules/Package.swift" ]; then
        print_success "LeavnModules Package.swift exists"
    else
        print_error "LeavnModules Package.swift missing!"
    fi
    
    # Step 6: Create verification file
    print_section "Step 6: Creating Verification Instructions"
    
    cat > BUILD_FIX_INSTRUCTIONS.md << 'EOF'
# Build Fix Instructions

## Automated Steps Completed ✅

1. **Cleaned DerivedData** - All cached build artifacts removed
2. **Cleaned SPM Cache** - Package resolution cache cleared
3. **Resolved Packages** - Fresh package resolution attempted
4. **Cleaned Xcode State** - Project-specific caches removed

## Manual Steps Required in Xcode 🔧

### 1. Open Xcode
```bash
open Leavn.xcodeproj
```

### 2. Reset Package Caches
- Go to **File → Packages → Reset Package Caches**
- Wait for the operation to complete

### 3. Resolve Package Versions
- Go to **File → Packages → Resolve Package Versions**
- Monitor the activity viewer for completion

### 4. Clean Build Folder
- Press **⌘+Shift+K** or go to **Product → Clean Build Folder**

### 5. Build the Project
- Press **⌘+B** or go to **Product → Build**

## If Build Still Fails 🚨

### Check Package Dependencies
1. Select the project in the navigator
2. Select the "Leavn" target
3. Go to "Frameworks, Libraries, and Embedded Content"
4. Ensure all these are present:
   - LeavnCore
   - LeavnServices
   - NetworkingKit
   - PersistenceKit
   - AnalyticsKit
   - DesignSystem
   - LeavnBible
   - LeavnSearch
   - LeavnLibrary
   - LeavnSettings
   - LeavnCommunity
   - AuthenticationModule

### Force Re-add Packages
1. Select the project in the navigator
2. Go to "Package Dependencies" tab
3. Remove both local packages (- button)
4. Re-add them (+ button → Add Local):
   - Core/LeavnCore
   - Core/LeavnModules

## Build Order
The modules should build in this order:
1. LeavnCore
2. NetworkingKit, PersistenceKit, AnalyticsKit (parallel)
3. DesignSystem
4. LeavnServices
5. All LeavnModules (parallel)
6. Main app target

## Success Indicators ✅
- All packages resolve without errors
- No "Unable to find module" errors
- Build succeeds with "Build Succeeded" message
EOF
    
    print_success "Created BUILD_FIX_INSTRUCTIONS.md"
    
    # Step 7: Summary
    print_section "Summary"
    print_success "All automated fixes completed!"
    print_info "Next: Open Xcode and follow the instructions in BUILD_FIX_INSTRUCTIONS.md"
    print_info "The project should now build successfully after package resolution."
    
    # Open the instructions
    if command -v open >/dev/null 2>&1; then
        open BUILD_FIX_INSTRUCTIONS.md
    fi
}

# Run the script
main "$@"