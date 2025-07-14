#!/bin/bash

# App Store Readiness Check Script
# This script validates the app for App Store submission readiness

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Results tracking
ERRORS=0
WARNINGS=0
PASSED=0

# Print functions
print_section() {
    echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}▶ $1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

print_check() {
    echo -e "${YELLOW}↳ Checking:${NC} $1"
}

print_pass() {
    echo -e "  ${GREEN}✓${NC} $1"
    ((PASSED++))
}

print_fail() {
    echo -e "  ${RED}✗${NC} $1"
    ((ERRORS++))
}

print_warn() {
    echo -e "  ${YELLOW}⚠${NC} $1"
    ((WARNINGS++))
}

# Check functions
check_info_plist() {
    local platform=$1
    local plist_path="Leavn/Platform/$platform/Info.plist"
    
    print_check "$platform Info.plist"
    
    if [ ! -f "$plist_path" ]; then
        print_fail "Info.plist not found at $plist_path"
        return
    fi
    
    # Check required keys
    local required_keys=(
        "CFBundleIdentifier"
        "CFBundleName"
        "CFBundleShortVersionString"
        "CFBundleVersion"
        "CFBundleExecutable"
    )
    
    for key in "${required_keys[@]}"; do
        if /usr/libexec/PlistBuddy -c "Print :$key" "$plist_path" >/dev/null 2>&1; then
            print_pass "$key is present"
        else
            print_fail "$key is missing"
        fi
    done
    
    # Platform-specific checks
    if [ "$platform" == "iOS" ]; then
        # iOS specific required keys
        local ios_keys=(
            "UILaunchStoryboardName"
            "LSRequiresIPhoneOS"
            "UIRequiredDeviceCapabilities"
            "UISupportedInterfaceOrientations"
        )
        
        for key in "${ios_keys[@]}"; do
            if /usr/libexec/PlistBuddy -c "Print :$key" "$plist_path" >/dev/null 2>&1; then
                print_pass "$key is present"
            else
                print_warn "$key is recommended for iOS apps"
            fi
        done
    elif [ "$platform" == "macOS" ]; then
        # macOS specific required keys
        local macos_keys=(
            "LSMinimumSystemVersion"
            "NSHumanReadableCopyright"
            "LSApplicationCategoryType"
        )
        
        for key in "${macos_keys[@]}"; do
            if /usr/libexec/PlistBuddy -c "Print :$key" "$plist_path" >/dev/null 2>&1; then
                print_pass "$key is present"
            else
                print_warn "$key is recommended for macOS apps"
            fi
        done
    fi
}

check_entitlements() {
    local platform=$1
    local entitlements_path="Leavn/Platform/$platform/Leavn-$platform.entitlements"
    
    print_check "$platform Entitlements"
    
    if [ ! -f "$entitlements_path" ]; then
        print_fail "Entitlements file not found at $entitlements_path"
        return
    fi
    
    print_pass "Entitlements file exists"
    
    # Check for common entitlements
    if grep -q "com.apple.security.app-sandbox" "$entitlements_path"; then
        print_pass "App Sandbox is configured"
    else
        print_warn "App Sandbox not configured (required for App Store)"
    fi
    
    # Check for potentially problematic entitlements
    if grep -q "com.apple.security.get-task-allow" "$entitlements_path"; then
        if grep -q "<true/>" "$entitlements_path"; then
            print_fail "get-task-allow is set to true (must be false for App Store)"
        fi
    fi
}

check_assets() {
    print_check "App Icons"
    
    local icon_path="Resources/Assets.xcassets/AppIcon.appiconset/Contents.json"
    
    if [ ! -f "$icon_path" ]; then
        print_fail "AppIcon asset catalog not found"
        return
    fi
    
    # Check if Contents.json has images defined
    local image_count=$(grep -c "filename" "$icon_path" 2>/dev/null || echo 0)
    
    if [ "$image_count" -eq 0 ]; then
        print_fail "No app icons defined in asset catalog"
    else
        print_pass "App icon asset catalog found with $image_count icon slots"
    fi
    
    # Check for launch screen
    print_check "Launch Screen"
    
    if [ -f "Leavn/Platform/iOS/LaunchScreen.storyboard" ]; then
        print_pass "Launch screen storyboard found"
    else
        print_warn "Launch screen storyboard not found (required for iOS)"
    fi
}

check_privacy_info() {
    print_check "Privacy Information"
    
    # Check for privacy keys in Info.plist
    local privacy_keys=(
        "NSCameraUsageDescription"
        "NSPhotoLibraryUsageDescription"
        "NSLocationWhenInUseUsageDescription"
        "NSMicrophoneUsageDescription"
    )
    
    local found_privacy_keys=0
    
    for platform in iOS macOS; do
        local plist_path="Leavn/Platform/$platform/Info.plist"
        if [ -f "$plist_path" ]; then
            for key in "${privacy_keys[@]}"; do
                if /usr/libexec/PlistBuddy -c "Print :$key" "$plist_path" >/dev/null 2>&1; then
                    ((found_privacy_keys++))
                fi
            done
        fi
    done
    
    if [ "$found_privacy_keys" -gt 0 ]; then
        print_warn "Found $found_privacy_keys privacy usage descriptions - ensure they are accurate"
    else
        print_pass "No privacy usage descriptions found (add if your app uses protected resources)"
    fi
}

check_code_signing() {
    print_check "Code Signing Configuration"
    
    # Check if provisioning profiles exist
    if ls ~/Library/MobileDevice/Provisioning\ Profiles/*.mobileprovision >/dev/null 2>&1; then
        print_pass "Provisioning profiles found"
    else
        print_warn "No provisioning profiles found in ~/Library/MobileDevice/Provisioning Profiles/"
    fi
    
    # Check for development team in project
    if [ -f "Leavn.xcodeproj/project.pbxproj" ]; then
        if grep -q "DEVELOPMENT_TEAM" "Leavn.xcodeproj/project.pbxproj"; then
            print_pass "Development team configuration found in project"
        else
            print_fail "No development team configured in project"
        fi
    fi
}

check_app_store_requirements() {
    print_check "App Store Requirements"
    
    # Check for export compliance
    local ios_plist="Leavn/Platform/iOS/Info.plist"
    if [ -f "$ios_plist" ]; then
        if /usr/libexec/PlistBuddy -c "Print :ITSAppUsesNonExemptEncryption" "$ios_plist" >/dev/null 2>&1; then
            print_pass "Export compliance key found"
        else
            print_warn "ITSAppUsesNonExemptEncryption not set (required for App Store)"
        fi
    fi
    
    # Check for required device capabilities
    if [ -f "$ios_plist" ]; then
        if /usr/libexec/PlistBuddy -c "Print :UIRequiredDeviceCapabilities" "$ios_plist" >/dev/null 2>&1; then
            print_pass "Device capabilities specified"
        else
            print_warn "UIRequiredDeviceCapabilities not specified"
        fi
    fi
}

check_metadata() {
    print_check "App Metadata"
    
    # Check for README
    if [ -f "README.md" ]; then
        print_pass "README.md exists"
    else
        print_warn "README.md not found (recommended for documentation)"
    fi
    
    # Check for CHANGELOG
    if [ -f "CHANGELOG.md" ] || [ -f "CHANGELOG.txt" ]; then
        print_pass "Changelog found"
    else
        print_warn "No changelog found (recommended for version tracking)"
    fi
    
    # Check for LICENSE
    if [ -f "LICENSE" ] || [ -f "LICENSE.md" ] || [ -f "LICENSE.txt" ]; then
        print_pass "License file found"
    else
        print_warn "No license file found"
    fi
}

generate_report() {
    local report_file="app-store-readiness-report.txt"
    
    {
        echo "APP STORE READINESS REPORT"
        echo "=========================="
        echo "Generated on: $(date)"
        echo ""
        echo "Summary:"
        echo "  ✓ Passed: $PASSED"
        echo "  ⚠ Warnings: $WARNINGS"
        echo "  ✗ Errors: $ERRORS"
        echo ""
        
        if [ "$ERRORS" -eq 0 ]; then
            echo "Status: READY FOR SUBMISSION (with $WARNINGS warnings to review)"
        else
            echo "Status: NOT READY - $ERRORS critical issues must be resolved"
        fi
        
        echo ""
        echo "Critical Issues to Address:"
        echo "1. Ensure all Info.plist files have required keys"
        echo "2. Configure proper code signing and provisioning"
        echo "3. Add all required app icons and launch screens"
        echo "4. Set up proper entitlements for each platform"
        echo "5. Add privacy usage descriptions if needed"
        echo ""
        echo "Recommended Actions:"
        echo "- Review and fix all errors before submission"
        echo "- Consider addressing warnings for better app quality"
        echo "- Test on actual devices before submission"
        echo "- Prepare App Store Connect metadata and screenshots"
        
    } > "$report_file"
    
    echo -e "\n${GREEN}Report saved to: $report_file${NC}"
}

# Main execution
main() {
    echo -e "${BLUE}🔍 App Store Readiness Check${NC}"
    echo -e "${BLUE}=============================${NC}"
    
    print_section "1. Info.plist Validation"
    check_info_plist "iOS"
    check_info_plist "macOS"
    check_info_plist "watchOS"
    check_info_plist "visionOS"
    
    print_section "2. Entitlements Validation"
    check_entitlements "iOS"
    check_entitlements "macOS"
    check_entitlements "watchOS"
    check_entitlements "visionOS"
    
    print_section "3. Assets Validation"
    check_assets
    
    print_section "4. Privacy & Security"
    check_privacy_info
    
    print_section "5. Code Signing"
    check_code_signing
    
    print_section "6. App Store Requirements"
    check_app_store_requirements
    
    print_section "7. Project Metadata"
    check_metadata
    
    # Summary
    echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}SUMMARY${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "  ${GREEN}✓ Passed:${NC} $PASSED"
    echo -e "  ${YELLOW}⚠ Warnings:${NC} $WARNINGS"
    echo -e "  ${RED}✗ Errors:${NC} $ERRORS"
    
    if [ "$ERRORS" -eq 0 ]; then
        echo -e "\n${GREEN}✅ App is READY for submission (review warnings)${NC}"
    else
        echo -e "\n${RED}❌ App is NOT READY - fix $ERRORS critical issues${NC}"
    fi
    
    generate_report
}

# Run the check
main