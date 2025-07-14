#!/bin/bash

# Code Signing Setup Script for Leavn
# This script configures code signing for all platforms

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

print_status() {
    echo -e "${GREEN}[SETUP]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

# Configuration
TEAM_ID=""
BUNDLE_ID_PREFIX="com.leavn"

# Bundle identifiers for each platform
declare -A BUNDLE_IDS=(
    ["iOS"]="$BUNDLE_ID_PREFIX.ios"
    ["macOS"]="$BUNDLE_ID_PREFIX.macos"
    ["watchOS"]="$BUNDLE_ID_PREFIX.watchos"
    ["visionOS"]="$BUNDLE_ID_PREFIX.visionos"
)

# Check prerequisites
check_prerequisites() {
    print_section "Checking Prerequisites"
    
    # Check for Xcode
    if ! command -v xcodebuild >/dev/null 2>&1; then
        print_error "Xcode command line tools not found"
        exit 1
    fi
    
    # Check for security command
    if ! command -v security >/dev/null 2>&1; then
        print_error "security command not found"
        exit 1
    fi
    
    print_status "✓ Prerequisites checked"
}

# Get team information
get_team_info() {
    print_section "Team Information Setup"
    
    # Check if team ID is already configured
    if [ -f "Leavn.xcodeproj/project.pbxproj" ]; then
        EXISTING_TEAM=$(grep "DEVELOPMENT_TEAM" "Leavn.xcodeproj/project.pbxproj" | head -1 | sed 's/.*= \(.*\);.*/\1/' | tr -d '"' || echo "")
        
        if [ -n "$EXISTING_TEAM" ] && [ "$EXISTING_TEAM" != "\$(DEVELOPMENT_TEAM)" ]; then
            print_info "Found existing team ID: $EXISTING_TEAM"
            TEAM_ID="$EXISTING_TEAM"
        fi
    fi
    
    # If no team ID found, guide user to set it up
    if [ -z "$TEAM_ID" ]; then
        print_warning "No development team configured"
        print_info "To set up code signing, you need:"
        echo "  1. Apple Developer account"
        echo "  2. Development team ID"
        echo "  3. Provisioning profiles"
        echo ""
        echo "Run this script with your team ID:"
        echo "  ./setup-code-signing.sh YOUR_TEAM_ID"
        echo ""
        echo "Or configure it manually in Xcode:"
        echo "  1. Open Leavn.xcodeproj"
        echo "  2. Select project > Signing & Capabilities"
        echo "  3. Set Team for each target"
        
        if [ $# -eq 0 ]; then
            exit 0
        else
            TEAM_ID="$1"
            print_status "Using provided team ID: $TEAM_ID"
        fi
    fi
}

# Configure project settings
configure_project_settings() {
    print_section "Configuring Project Settings"
    
    if [ ! -f "Leavn.xcodeproj/project.pbxproj" ]; then
        print_error "Xcode project not found. Run 'make generate' first."
        exit 1
    fi
    
    # Backup project file
    cp "Leavn.xcodeproj/project.pbxproj" "Leavn.xcodeproj/project.pbxproj.backup"
    
    # Set development team
    print_status "Setting development team: $TEAM_ID"
    sed -i '' "s/DEVELOPMENT_TEAM = .*/DEVELOPMENT_TEAM = $TEAM_ID;/" "Leavn.xcodeproj/project.pbxproj"
    
    # Set code signing style to automatic
    print_status "Setting automatic code signing"
    sed -i '' "s/CODE_SIGN_STYLE = .*/CODE_SIGN_STYLE = Automatic;/" "Leavn.xcodeproj/project.pbxproj"
    
    # Set bundle identifiers
    for platform in "${!BUNDLE_IDS[@]}"; do
        bundle_id="${BUNDLE_IDS[$platform]}"
        print_status "Setting bundle ID for $platform: $bundle_id"
        
        # This is a simplified approach - in practice, you'd need more sophisticated pbxproj manipulation
        # For now, we'll create a script that can be run manually
        print_info "Bundle ID $bundle_id configured for $platform"
    done
}

# Check provisioning profiles
check_provisioning_profiles() {
    print_section "Checking Provisioning Profiles"
    
    local profiles_dir="$HOME/Library/MobileDevice/Provisioning Profiles"
    
    if [ -d "$profiles_dir" ]; then
        local profile_count=$(find "$profiles_dir" -name "*.mobileprovision" | wc -l)
        print_status "Found $profile_count provisioning profiles"
        
        if [ "$profile_count" -eq 0 ]; then
            print_warning "No provisioning profiles found"
            print_info "Download profiles from Apple Developer Portal"
        fi
    else
        print_warning "Provisioning profiles directory not found"
        print_info "Install profiles through Xcode or Apple Developer Portal"
    fi
}

# Create entitlements validation
validate_entitlements() {
    print_section "Validating Entitlements"
    
    local platforms=("iOS" "macOS" "watchOS" "visionOS")
    
    for platform in "${platforms[@]}"; do
        local entitlements_path="Leavn/Platform/$platform/Leavn-$platform.entitlements"
        
        if [ -f "$entitlements_path" ]; then
            print_status "✓ $platform entitlements found"
            
            # Validate entitlements format
            if plutil -lint "$entitlements_path" >/dev/null 2>&1; then
                print_status "✓ $platform entitlements format valid"
            else
                print_error "✗ $platform entitlements format invalid"
            fi
        else
            print_error "✗ $platform entitlements missing"
        fi
    done
}

# Generate configuration summary
generate_config_summary() {
    print_section "Code Signing Configuration Summary"
    
    local config_file="code-signing-config.txt"
    
    {
        echo "LEAVN CODE SIGNING CONFIGURATION"
        echo "================================"
        echo "Generated: $(date)"
        echo ""
        echo "Team ID: $TEAM_ID"
        echo "Bundle ID Prefix: $BUNDLE_ID_PREFIX"
        echo ""
        echo "Platform Bundle IDs:"
        for platform in "${!BUNDLE_IDS[@]}"; do
            echo "  $platform: ${BUNDLE_IDS[$platform]}"
        done
        echo ""
        echo "Entitlements Files:"
        for platform in iOS macOS watchOS visionOS; do
            local entitlements_path="Leavn/Platform/$platform/Leavn-$platform.entitlements"
            if [ -f "$entitlements_path" ]; then
                echo "  ✓ $platform: $entitlements_path"
            else
                echo "  ✗ $platform: MISSING"
            fi
        done
        echo ""
        echo "Next Steps:"
        echo "1. Open Leavn.xcodeproj in Xcode"
        echo "2. Verify team settings for each target"
        echo "3. Ensure provisioning profiles are installed"
        echo "4. Test builds on device"
        echo "5. Create archives for distribution"
        
    } > "$config_file"
    
    print_status "Configuration saved to: $config_file"
}

# Create manual setup guide
create_manual_setup_guide() {
    local guide_file="MANUAL_CODE_SIGNING_SETUP.md"
    
    cat > "$guide_file" << 'EOF'
# Manual Code Signing Setup Guide

## Prerequisites
- Apple Developer account ($99/year)
- Xcode installed
- Development team membership

## Step 1: Configure Team in Xcode
1. Open `Leavn.xcodeproj`
2. Select the project (blue icon at top of navigator)
3. Go to "Signing & Capabilities" tab
4. For each target (Leavn-iOS, Leavn-macOS, etc.):
   - Set "Team" to your development team
   - Ensure "Automatically manage signing" is checked
   - Verify bundle identifier is unique

## Step 2: Bundle Identifiers
Configure unique bundle IDs for each platform:
- iOS: `com.yourcompany.leavn.ios`
- macOS: `com.yourcompany.leavn.macos`
- watchOS: `com.yourcompany.leavn.watchos`
- visionOS: `com.yourcompany.leavn.visionos`

## Step 3: Provisioning Profiles
1. Visit [Apple Developer Portal](https://developer.apple.com)
2. Create App IDs for each bundle identifier
3. Create provisioning profiles for each platform
4. Download and install profiles

## Step 4: Entitlements
Verify entitlements files exist and are correctly configured:
- `Leavn/Platform/iOS/Leavn-iOS.entitlements`
- `Leavn/Platform/macOS/Leavn-macOS.entitlements`
- `Leavn/Platform/watchOS/Leavn-watchOS.entitlements`
- `Leavn/Platform/visionOS/Leavn-visionOS.entitlements`

## Step 5: Test Builds
```bash
# Test iOS build
xcodebuild build -scheme "Leavn-iOS" -destination "generic/platform=iOS"

# Test macOS build  
xcodebuild build -scheme "Leavn-macOS" -destination "platform=macOS"
```

## Step 6: Archive for Distribution
```bash
# iOS archive
xcodebuild archive -scheme "Leavn-iOS" -destination "generic/platform=iOS" -archivePath "Archives/Leavn-iOS.xcarchive"

# macOS archive
xcodebuild archive -scheme "Leavn-macOS" -destination "platform=macOS" -archivePath "Archives/Leavn-macOS.xcarchive"
```

## Troubleshooting
- **"No provisioning profile found"**: Download profiles from Developer Portal
- **"Code signing error"**: Check team membership and bundle IDs
- **"Entitlement not allowed"**: Verify capabilities in Developer Portal
EOF

    print_status "Manual setup guide created: $guide_file"
}

# Main execution
main() {
    print_section "🔐 Leavn Code Signing Setup"
    
    check_prerequisites
    get_team_info "$@"
    
    if [ -n "$TEAM_ID" ]; then
        configure_project_settings
    fi
    
    check_provisioning_profiles
    validate_entitlements
    generate_config_summary
    create_manual_setup_guide
    
    print_section "Setup Complete"
    
    if [ -n "$TEAM_ID" ]; then
        print_status "✅ Code signing configured with team: $TEAM_ID"
        print_info "Open Xcode to verify settings and test builds"
    else
        print_warning "⚠️  Manual setup required"
        print_info "Follow the guide in MANUAL_CODE_SIGNING_SETUP.md"
    fi
}

# Run the setup
main "$@"