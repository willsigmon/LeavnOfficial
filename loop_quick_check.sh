#!/bin/bash

# Loop's Quick Check - "Obvious Error Causes" Rapid Validation
# Agent 3: Build Validation & Recovery System
# Based on Loop's methodology for instant build issue detection

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}⚡ Loop's Quick Check - Obvious Error Causes${NC}"
echo -e "${CYAN}===========================================${NC}"

# Quick check status
QUICK_CHECK_PASSED=true
CRITICAL_ISSUES=()
WARNINGS=()

# Function to add critical issue
add_critical() {
    CRITICAL_ISSUES+=("$1")
    QUICK_CHECK_PASSED=false
}

# Function to add warning
add_warning() {
    WARNINGS+=("$1")
}

# 1. RAPID XCODE CHECK
echo -e "${BLUE}⚡ 1. Xcode Version Check (iOS 26.0 compatibility)${NC}"

if command -v xcodebuild &> /dev/null; then
    XCODE_VERSION=$(xcodebuild -version | head -1 | awk '{print $2}')
    XCODE_MAJOR=$(echo "$XCODE_VERSION" | cut -d. -f1)
    
    if [ "$XCODE_MAJOR" -ge 16 ]; then
        echo -e "${GREEN}✅ Xcode $XCODE_VERSION - iOS 26.0 compatible${NC}"
    else
        echo -e "${RED}❌ Xcode $XCODE_VERSION - NOT iOS 26.0 compatible${NC}"
        add_critical "Xcode version $XCODE_VERSION < 16.0 (required for iOS 26.0)"
    fi
    
    # Quick SDK check
    if xcodebuild -showsdks | grep -q "iphoneos"; then
        echo -e "${GREEN}✅ iOS SDK available${NC}"
    else
        echo -e "${RED}❌ No iOS SDK found${NC}"
        add_critical "No iOS SDK available"
    fi
else
    echo -e "${RED}❌ Xcode not installed or not in PATH${NC}"
    add_critical "Xcode not installed"
fi

# 2. RAPID LICENSE CHECK
echo -e "${BLUE}⚡ 2. License Agreement Check${NC}"

# Test if xcodebuild works (would fail if license not agreed)
if xcodebuild -showsdks > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Xcode license agreements accepted${NC}"
else
    echo -e "${RED}❌ Xcode license not accepted${NC}"
    add_critical "Xcode license not accepted - run 'sudo xcodebuild -license'"
fi

# Quick Apple ID check
if security find-generic-password -s "Xcode:PlatformTokenProvider" &> /dev/null; then
    echo -e "${GREEN}✅ Apple ID credentials found${NC}"
else
    echo -e "${YELLOW}⚠️ No Apple ID credentials in keychain${NC}"
    add_warning "No Apple ID credentials - sign in to Xcode"
fi

# 3. RAPID CERTIFICATE CHECK
echo -e "${BLUE}⚡ 3. Certificate Validation${NC}"

# Development certificates
if security find-certificate -c "Apple Development" &> /dev/null; then
    echo -e "${GREEN}✅ Development certificates found${NC}"
    
    # Quick expiry check (simplified)
    if security find-certificate -c "Apple Development" -p | openssl x509 -checkend 2592000 -noout &> /dev/null; then
        echo -e "${GREEN}✅ Development certificates valid (>30 days)${NC}"
    else
        echo -e "${YELLOW}⚠️ Development certificates expire soon${NC}"
        add_warning "Development certificates expire within 30 days"
    fi
else
    echo -e "${RED}❌ No development certificates${NC}"
    add_critical "No Apple Development certificates found"
fi

# Distribution certificates (for App Store)
if security find-certificate -c "Apple Distribution" &> /dev/null; then
    echo -e "${GREEN}✅ Distribution certificates found${NC}"
    
    if security find-certificate -c "Apple Distribution" -p | openssl x509 -checkend 2592000 -noout &> /dev/null; then
        echo -e "${GREEN}✅ Distribution certificates valid (>30 days)${NC}"
    else
        echo -e "${YELLOW}⚠️ Distribution certificates expire soon${NC}"
        add_warning "Distribution certificates expire within 30 days"
    fi
else
    echo -e "${YELLOW}⚠️ No distribution certificates${NC}"
    add_warning "No distribution certificates (needed for App Store)"
fi

# Provisioning profiles
PROFILES_DIR="$HOME/Library/MobileDevice/Provisioning Profiles"
if [ -d "$PROFILES_DIR" ] && [ "$(ls -A "$PROFILES_DIR" 2>/dev/null)" ]; then
    PROFILE_COUNT=$(ls "$PROFILES_DIR" | wc -l)
    echo -e "${GREEN}✅ Provisioning profiles found ($PROFILE_COUNT)${NC}"
else
    echo -e "${YELLOW}⚠️ No provisioning profiles${NC}"
    add_warning "No provisioning profiles found"
fi

# QUICK BUILD TEST
echo -e "${BLUE}⚡ 4. Quick Build Test${NC}"

if [ -f "Leavn.xcodeproj/project.pbxproj" ]; then
    echo -e "${GREEN}✅ Xcode project found${NC}"
    
    # Test build command (without actually building)
    if xcodebuild -project Leavn.xcodeproj -scheme Leavn -showBuildSettings > /dev/null 2>&1; then
        echo -e "${GREEN}✅ Build configuration valid${NC}"
    else
        echo -e "${RED}❌ Build configuration issues${NC}"
        add_critical "Build configuration problems detected"
    fi
else
    echo -e "${RED}❌ No Xcode project found${NC}"
    add_critical "Leavn.xcodeproj not found"
fi

# SUMMARY
echo -e "${CYAN}⚡ QUICK CHECK SUMMARY${NC}"
echo -e "${CYAN}=====================${NC}"

if [ ${#CRITICAL_ISSUES[@]} -eq 0 ]; then
    if [ ${#WARNINGS[@]} -eq 0 ]; then
        echo -e "${GREEN}🎉 ALL CLEAR - Ready to build!${NC}"
        echo -e "${GREEN}✅ No critical issues or warnings detected${NC}"
    else
        echo -e "${YELLOW}⚠️ READY WITH WARNINGS - Can build but address warnings${NC}"
        echo -e "${YELLOW}⚠️ ${#WARNINGS[@]} warning(s) detected${NC}"
    fi
else
    echo -e "${RED}🚫 BUILD BLOCKED - Critical issues must be resolved${NC}"
    echo -e "${RED}❌ ${#CRITICAL_ISSUES[@]} critical issue(s) detected${NC}"
fi

# Show issues
if [ ${#CRITICAL_ISSUES[@]} -gt 0 ]; then
    echo -e "${RED}CRITICAL ISSUES:${NC}"
    for issue in "${CRITICAL_ISSUES[@]}"; do
        echo -e "${RED}  ❌ $issue${NC}"
    done
fi

if [ ${#WARNINGS[@]} -gt 0 ]; then
    echo -e "${YELLOW}WARNINGS:${NC}"
    for warning in "${WARNINGS[@]}"; do
        echo -e "${YELLOW}  ⚠️ $warning${NC}"
    done
fi

# Quick fix suggestions
if [ ${#CRITICAL_ISSUES[@]} -gt 0 ]; then
    echo -e "${CYAN}QUICK FIXES:${NC}"
    
    for issue in "${CRITICAL_ISSUES[@]}"; do
        case "$issue" in
            *"Xcode version"*)
                echo -e "${BLUE}  🔧 Update Xcode from App Store to version 16.0+${NC}"
                ;;
            *"Xcode not installed"*)
                echo -e "${BLUE}  🔧 Install Xcode from App Store${NC}"
                ;;
            *"license not accepted"*)
                echo -e "${BLUE}  🔧 Run: sudo xcodebuild -license${NC}"
                ;;
            *"Development certificates"*)
                echo -e "${BLUE}  🔧 Download certificates from Apple Developer portal${NC}"
                ;;
            *"Build configuration"*)
                echo -e "${BLUE}  🔧 Check project settings and clean build folder${NC}"
                ;;
            *"project not found"*)
                echo -e "${BLUE}  🔧 Ensure you're in the correct project directory${NC}"
                ;;
        esac
    done
    
    echo -e "${CYAN}For comprehensive analysis and automated recovery:${NC}"
    echo -e "${BLUE}  🔧 Run: ./build_validation_recovery.sh${NC}"
fi

# Exit with appropriate code
if [ "$QUICK_CHECK_PASSED" = true ]; then
    exit 0
else
    exit 1
fi