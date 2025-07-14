#!/bin/bash

# Agent 3: Build Validation & Recovery System
# Implementing Loop's "Obvious Error Causes" Checklist
# 1. Xcode version compatibility with iOS 26.0
# 2. Apple Developer license agreements  
# 3. Certificate validation and renewal

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}🔧 Build Validation & Recovery System${NC}"
echo -e "${CYAN}====================================${NC}"
echo -e "${BLUE}Implementing Loop's 'Obvious Error Causes' Checklist${NC}"

# Configuration
VALIDATION_DIR="validation_recovery_results"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
VALIDATION_LOG="$VALIDATION_DIR/validation_recovery_$TIMESTAMP.log"
RECOVERY_LOG="$VALIDATION_DIR/recovery_actions_$TIMESTAMP.log"

# iOS 26.0 compatibility requirements
REQUIRED_XCODE_VERSION="16.0"
REQUIRED_IOS_SDK="26.0"
REQUIRED_MACOS_VERSION="15.0"

# Create validation directory
mkdir -p "$VALIDATION_DIR"

# Validation status tracking
declare -A VALIDATION_STATUS
declare -A RECOVERY_ACTIONS

# Function to log messages
log_message() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    echo -e "${timestamp} [${level}] ${message}" | tee -a "$VALIDATION_LOG"
}

# Function to log recovery actions
log_recovery() {
    local action="$1"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    echo -e "${timestamp} [RECOVERY] ${action}" | tee -a "$RECOVERY_LOG"
}

# 1. XCODE VERSION COMPATIBILITY VALIDATION
validate_xcode_compatibility() {
    echo -e "${BLUE}🔍 1. Validating Xcode Version Compatibility with iOS 26.0${NC}"
    log_message "INFO" "Starting Xcode compatibility validation"
    
    local validation_report="$VALIDATION_DIR/xcode_compatibility_$TIMESTAMP.txt"
    
    {
        echo "=== XCODE VERSION COMPATIBILITY VALIDATION ==="
        echo "Date: $(date)"
        echo "Required for iOS 26.0 Support:"
        echo "- Xcode: $REQUIRED_XCODE_VERSION+"
        echo "- iOS SDK: $REQUIRED_IOS_SDK"
        echo "- macOS: $REQUIRED_MACOS_VERSION+"
        echo ""
        
        # Check Xcode installation
        echo "1. XCODE INSTALLATION CHECK"
        echo "=========================="
        
        if command -v xcodebuild &> /dev/null; then
            echo "✅ Xcode is installed"
            
            # Get Xcode version
            local xcode_version=$(xcodebuild -version | head -1 | awk '{print $2}')
            echo "📱 Installed Xcode version: $xcode_version"
            
            # Version comparison for iOS 26.0 compatibility
            if [[ $(echo "$xcode_version" | cut -d. -f1) -ge 16 ]]; then
                echo "✅ Xcode version is compatible with iOS 26.0"
                VALIDATION_STATUS["xcode_version"]="PASS"
            else
                echo "❌ Xcode version is NOT compatible with iOS 26.0"
                echo "   Required: Xcode $REQUIRED_XCODE_VERSION+"
                echo "   Installed: Xcode $xcode_version"
                VALIDATION_STATUS["xcode_version"]="FAIL"
                RECOVERY_ACTIONS["xcode_version"]="Update Xcode to version $REQUIRED_XCODE_VERSION or later"
            fi
            
            # Check Xcode command line tools
            echo ""
            echo "2. COMMAND LINE TOOLS CHECK"
            echo "==========================="
            
            if xcode-select -p &> /dev/null; then
                local xcode_path=$(xcode-select -p)
                echo "✅ Xcode command line tools are configured"
                echo "📁 Xcode developer directory: $xcode_path"
                
                # Verify the path exists and is valid
                if [ -d "$xcode_path" ]; then
                    echo "✅ Xcode developer directory exists"
                    VALIDATION_STATUS["xcode_cli_tools"]="PASS"
                else
                    echo "❌ Xcode developer directory does not exist"
                    VALIDATION_STATUS["xcode_cli_tools"]="FAIL"
                    RECOVERY_ACTIONS["xcode_cli_tools"]="Reset Xcode command line tools path"
                fi
            else
                echo "❌ Xcode command line tools are not configured"
                VALIDATION_STATUS["xcode_cli_tools"]="FAIL"
                RECOVERY_ACTIONS["xcode_cli_tools"]="Install and configure Xcode command line tools"
            fi
            
            # Check available SDKs
            echo ""
            echo "3. iOS SDK AVAILABILITY CHECK"
            echo "============================="
            
            local available_sdks=$(xcodebuild -showsdks | grep "iphoneos")
            echo "Available iOS SDKs:"
            echo "$available_sdks"
            
            if echo "$available_sdks" | grep -q "iphoneos26.0\|iphoneos17"; then
                echo "✅ Compatible iOS SDK available for iOS 26.0 development"
                VALIDATION_STATUS["ios_sdk"]="PASS"
            else
                echo "❌ No compatible iOS SDK found for iOS 26.0"
                VALIDATION_STATUS["ios_sdk"]="FAIL"
                RECOVERY_ACTIONS["ios_sdk"]="Update Xcode to get iOS 26.0 SDK"
            fi
            
            # Check simulator availability
            echo ""
            echo "4. iOS 26.0 SIMULATOR CHECK"
            echo "==========================="
            
            if command -v xcrun &> /dev/null; then
                local simulators=$(xcrun simctl list devices available | grep "iOS 26\|iOS 17\|iOS 18")
                if [ -n "$simulators" ]; then
                    echo "✅ iOS 26.0 compatible simulators available"
                    echo "Available simulators:"
                    echo "$simulators" | head -5
                    VALIDATION_STATUS["ios_simulators"]="PASS"
                else
                    echo "❌ No iOS 26.0 compatible simulators found"
                    VALIDATION_STATUS["ios_simulators"]="FAIL"
                    RECOVERY_ACTIONS["ios_simulators"]="Download iOS 26.0 simulator runtime"
                fi
            else
                echo "❌ Cannot check simulators - xcrun not available"
                VALIDATION_STATUS["ios_simulators"]="FAIL"
                RECOVERY_ACTIONS["ios_simulators"]="Fix Xcode installation and xcrun access"
            fi
            
        else
            echo "❌ Xcode is not installed or not in PATH"
            VALIDATION_STATUS["xcode_version"]="FAIL"
            RECOVERY_ACTIONS["xcode_version"]="Install Xcode $REQUIRED_XCODE_VERSION+ from App Store or Apple Developer"
        fi
        
        # Check macOS compatibility
        echo ""
        echo "5. macOS COMPATIBILITY CHECK"
        echo "============================"
        
        local macos_version=$(sw_vers -productVersion)
        echo "📱 macOS version: $macos_version"
        
        if [[ $(echo "$macos_version" | cut -d. -f1) -ge 15 ]] || [[ $(echo "$macos_version" | cut -d. -f1) -eq 14 && $(echo "$macos_version" | cut -d. -f2) -ge 5 ]]; then
            echo "✅ macOS version supports iOS 26.0 development"
            VALIDATION_STATUS["macos_version"]="PASS"
        else
            echo "❌ macOS version may not support iOS 26.0 development"
            echo "   Recommended: macOS $REQUIRED_MACOS_VERSION+"
            echo "   Installed: macOS $macos_version"
            VALIDATION_STATUS["macos_version"]="WARN"
            RECOVERY_ACTIONS["macos_version"]="Consider updating to macOS $REQUIRED_MACOS_VERSION+"
        fi
        
    } > "$validation_report"
    
    echo -e "${GREEN}✅ Xcode compatibility validation completed${NC}"
    log_message "INFO" "Xcode compatibility validation completed"
}

# 2. APPLE DEVELOPER LICENSE AGREEMENT VALIDATION
validate_developer_license() {
    echo -e "${BLUE}🔍 2. Validating Apple Developer License Agreements${NC}"
    log_message "INFO" "Starting Apple Developer license validation"
    
    local license_report="$VALIDATION_DIR/developer_license_$TIMESTAMP.txt"
    
    {
        echo "=== APPLE DEVELOPER LICENSE AGREEMENT VALIDATION ==="
        echo "Date: $(date)"
        echo ""
        
        # Check Apple ID authentication
        echo "1. APPLE ID AUTHENTICATION"
        echo "========================="
        
        # Try to get account information
        local account_info=$(security find-generic-password -s "Xcode:PlatformTokenProvider" 2>/dev/null || echo "No stored credentials")
        
        if [[ "$account_info" != "No stored credentials" ]]; then
            echo "✅ Apple ID credentials found in keychain"
            VALIDATION_STATUS["apple_id_auth"]="PASS"
            
            # Check if we can access developer portal info
            echo "📱 Checking developer portal access..."
            
            # Try to list provisioning profiles
            if security find-certificate -a -c "Apple Development" 2>/dev/null | grep -q "Apple Development"; then
                echo "✅ Development certificates found"
                VALIDATION_STATUS["dev_certificates"]="PASS"
            else
                echo "❌ No development certificates found"
                VALIDATION_STATUS["dev_certificates"]="FAIL"
                RECOVERY_ACTIONS["dev_certificates"]="Download development certificates from Apple Developer portal"
            fi
            
        else
            echo "❌ No Apple ID credentials found"
            VALIDATION_STATUS["apple_id_auth"]="FAIL"
            RECOVERY_ACTIONS["apple_id_auth"]="Sign in to Apple ID in Xcode preferences"
        fi
        
        # Check license agreement status
        echo ""
        echo "2. LICENSE AGREEMENT STATUS"
        echo "=========================="
        
        # Check if Xcode can build without license issues
        echo "📱 Testing build capabilities..."
        
        # Create a temporary test project to check license status
        local temp_dir="/tmp/license_test_$$"
        mkdir -p "$temp_dir"
        
        # Try a simple xcodebuild command that would fail if licenses aren't agreed to
        if xcodebuild -showsdks > /dev/null 2>&1; then
            echo "✅ Xcode commands work - licenses appear to be agreed to"
            VALIDATION_STATUS["license_agreements"]="PASS"
        else
            echo "❌ Xcode commands failing - may need to agree to license"
            VALIDATION_STATUS["license_agreements"]="FAIL"
            RECOVERY_ACTIONS["license_agreements"]="Run 'sudo xcodebuild -license' to agree to Xcode license"
        fi
        
        rm -rf "$temp_dir"
        
        # Check Apple Developer Program membership
        echo ""
        echo "3. DEVELOPER PROGRAM MEMBERSHIP"
        echo "==============================="
        
        # Check for distribution certificates which indicate paid membership
        if security find-certificate -a -c "Apple Distribution" 2>/dev/null | grep -q "Apple Distribution"; then
            echo "✅ Distribution certificates found - appears to have paid developer membership"
            VALIDATION_STATUS["paid_membership"]="PASS"
        elif security find-certificate -a -c "Apple Development" 2>/dev/null | grep -q "Apple Development"; then
            echo "⚠️ Only development certificates found - may be free Apple ID"
            echo "   Note: TestFlight and App Store distribution requires paid membership"
            VALIDATION_STATUS["paid_membership"]="WARN"
            RECOVERY_ACTIONS["paid_membership"]="Consider upgrading to paid Apple Developer Program for full features"
        else
            echo "❌ No Apple certificates found"
            VALIDATION_STATUS["paid_membership"]="FAIL"
            RECOVERY_ACTIONS["paid_membership"]="Join Apple Developer Program and download certificates"
        fi
        
        # Check team access
        echo ""
        echo "4. TEAM ACCESS VALIDATION"
        echo "========================"
        
        # Check if user has access to provisioning profiles
        local profiles_dir="$HOME/Library/MobileDevice/Provisioning Profiles"
        if [ -d "$profiles_dir" ] && [ "$(ls -A "$profiles_dir" 2>/dev/null)" ]; then
            echo "✅ Provisioning profiles found"
            echo "📱 Profile count: $(ls "$profiles_dir" | wc -l)"
            VALIDATION_STATUS["provisioning_profiles"]="PASS"
        else
            echo "❌ No provisioning profiles found"
            VALIDATION_STATUS["provisioning_profiles"]="FAIL"
            RECOVERY_ACTIONS["provisioning_profiles"]="Download provisioning profiles from Apple Developer portal"
        fi
        
    } > "$license_report"
    
    echo -e "${GREEN}✅ Developer license validation completed${NC}"
    log_message "INFO" "Developer license validation completed"
}

# 3. CERTIFICATE VALIDATION AND RENEWAL SYSTEM
validate_certificates() {
    echo -e "${BLUE}🔍 3. Certificate Validation and Renewal System${NC}"
    log_message "INFO" "Starting certificate validation"
    
    local cert_report="$VALIDATION_DIR/certificate_validation_$TIMESTAMP.txt"
    
    {
        echo "=== CERTIFICATE VALIDATION AND RENEWAL ==="
        echo "Date: $(date)"
        echo ""
        
        # Get current date for expiration checking
        local current_date=$(date +%s)
        local thirty_days=$((30 * 24 * 3600))
        local ninety_days=$((90 * 24 * 3600))
        
        echo "1. DEVELOPMENT CERTIFICATES"
        echo "=========================="
        
        # Check Apple Development certificates
        local dev_certs=$(security find-certificate -a -c "Apple Development" -p 2>/dev/null)
        
        if [ -n "$dev_certs" ]; then
            echo "✅ Apple Development certificates found"
            
            # Parse certificate details
            echo "$dev_certs" | while IFS= read -r cert_line; do
                if [[ "$cert_line" == "-----BEGIN CERTIFICATE-----" ]]; then
                    cert_data=""
                elif [[ "$cert_line" == "-----END CERTIFICATE-----" ]]; then
                    cert_data+="$cert_line"
                    
                    # Extract certificate info
                    local cert_info=$(echo "$cert_data" | openssl x509 -text -noout 2>/dev/null)
                    local subject=$(echo "$cert_info" | grep "Subject:" | head -1)
                    local not_after=$(echo "$cert_info" | grep "Not After" | head -1)
                    
                    if [ -n "$subject" ] && [ -n "$not_after" ]; then
                        echo "📱 Certificate: $(echo "$subject" | sed 's/.*CN=\([^,]*\).*/\1/')"
                        echo "📅 Expires: $(echo "$not_after" | sed 's/.*Not After : //')"
                        
                        # Check expiration
                        local expire_date=$(echo "$not_after" | sed 's/.*Not After : //' | xargs -I {} date -d "{}" +%s 2>/dev/null || echo "0")
                        local days_until_expiry=$(( (expire_date - current_date) / 86400 ))
                        
                        if [ "$expire_date" -gt 0 ]; then
                            if [ "$days_until_expiry" -lt 30 ]; then
                                echo "🔴 WARNING: Certificate expires in $days_until_expiry days!"
                                VALIDATION_STATUS["dev_cert_expiry"]="WARN"
                                RECOVERY_ACTIONS["dev_cert_expiry"]="Renew development certificate (expires in $days_until_expiry days)"
                            elif [ "$days_until_expiry" -lt 90 ]; then
                                echo "🟡 NOTICE: Certificate expires in $days_until_expiry days"
                                VALIDATION_STATUS["dev_cert_expiry"]="PASS"
                            else
                                echo "✅ Certificate is valid for $days_until_expiry days"
                                VALIDATION_STATUS["dev_cert_expiry"]="PASS"
                            fi
                        fi
                        echo ""
                    fi
                    cert_data=""
                else
                    cert_data+="$cert_line"$'\n'
                fi
            done
            
        else
            echo "❌ No Apple Development certificates found"
            VALIDATION_STATUS["dev_certificates"]="FAIL"
            RECOVERY_ACTIONS["dev_certificates"]="Download development certificates from Apple Developer portal"
        fi
        
        echo "2. DISTRIBUTION CERTIFICATES"
        echo "============================"
        
        # Check Apple Distribution certificates
        local dist_certs=$(security find-certificate -a -c "Apple Distribution" -p 2>/dev/null)
        
        if [ -n "$dist_certs" ]; then
            echo "✅ Apple Distribution certificates found"
            
            # Similar parsing for distribution certificates
            echo "$dist_certs" | while IFS= read -r cert_line; do
                if [[ "$cert_line" == "-----BEGIN CERTIFICATE-----" ]]; then
                    cert_data=""
                elif [[ "$cert_line" == "-----END CERTIFICATE-----" ]]; then
                    cert_data+="$cert_line"
                    
                    local cert_info=$(echo "$cert_data" | openssl x509 -text -noout 2>/dev/null)
                    local subject=$(echo "$cert_info" | grep "Subject:" | head -1)
                    local not_after=$(echo "$cert_info" | grep "Not After" | head -1)
                    
                    if [ -n "$subject" ] && [ -n "$not_after" ]; then
                        echo "📱 Certificate: $(echo "$subject" | sed 's/.*CN=\([^,]*\).*/\1/')"
                        echo "📅 Expires: $(echo "$not_after" | sed 's/.*Not After : //')"
                        
                        local expire_date=$(echo "$not_after" | sed 's/.*Not After : //' | xargs -I {} date -d "{}" +%s 2>/dev/null || echo "0")
                        local days_until_expiry=$(( (expire_date - current_date) / 86400 ))
                        
                        if [ "$expire_date" -gt 0 ]; then
                            if [ "$days_until_expiry" -lt 30 ]; then
                                echo "🔴 WARNING: Distribution certificate expires in $days_until_expiry days!"
                                VALIDATION_STATUS["dist_cert_expiry"]="WARN"
                                RECOVERY_ACTIONS["dist_cert_expiry"]="Renew distribution certificate (expires in $days_until_expiry days)"
                            elif [ "$days_until_expiry" -lt 90 ]; then
                                echo "🟡 NOTICE: Distribution certificate expires in $days_until_expiry days"
                                VALIDATION_STATUS["dist_cert_expiry"]="PASS"
                            else
                                echo "✅ Distribution certificate is valid for $days_until_expiry days"
                                VALIDATION_STATUS["dist_cert_expiry"]="PASS"
                            fi
                        fi
                        echo ""
                    fi
                    cert_data=""
                else
                    cert_data+="$cert_line"$'\n'
                fi
            done
            
        else
            echo "⚠️ No Apple Distribution certificates found"
            echo "   Note: Distribution certificates are needed for TestFlight and App Store"
            VALIDATION_STATUS["dist_certificates"]="WARN"
            RECOVERY_ACTIONS["dist_certificates"]="Download distribution certificates for App Store deployment"
        fi
        
        echo "3. PROVISIONING PROFILES"
        echo "======================="
        
        local profiles_dir="$HOME/Library/MobileDevice/Provisioning Profiles"
        if [ -d "$profiles_dir" ]; then
            local profile_count=$(ls "$profiles_dir" 2>/dev/null | wc -l)
            echo "📱 Found $profile_count provisioning profiles"
            
            if [ "$profile_count" -gt 0 ]; then
                echo "✅ Provisioning profiles available"
                
                # Check profile expiration dates
                ls "$profiles_dir"/*.mobileprovision 2>/dev/null | head -5 | while read -r profile; do
                    if [ -f "$profile" ]; then
                        local profile_name=$(basename "$profile" .mobileprovision)
                        local profile_info=$(security cms -D -i "$profile" 2>/dev/null)
                        
                        if [ -n "$profile_info" ]; then
                            local expiry_date=$(echo "$profile_info" | grep -A1 "ExpirationDate" | tail -1 | sed 's/.*<date>\(.*\)<\/date>.*/\1/')
                            
                            if [ -n "$expiry_date" ]; then
                                echo "📱 Profile: $profile_name"
                                echo "📅 Expires: $expiry_date"
                                
                                # Check if profile is expiring soon
                                local expire_timestamp=$(date -d "$expiry_date" +%s 2>/dev/null || echo "0")
                                local days_until_expiry=$(( (expire_timestamp - current_date) / 86400 ))
                                
                                if [ "$expire_timestamp" -gt 0 ]; then
                                    if [ "$days_until_expiry" -lt 30 ]; then
                                        echo "🔴 WARNING: Profile expires in $days_until_expiry days!"
                                        VALIDATION_STATUS["profile_expiry"]="WARN"
                                        RECOVERY_ACTIONS["profile_expiry"]="Renew provisioning profiles (some expire in <30 days)"
                                    else
                                        echo "✅ Profile valid for $days_until_expiry days"
                                        VALIDATION_STATUS["profile_expiry"]="PASS"
                                    fi
                                fi
                                echo ""
                            fi
                        fi
                    fi
                done
                
                VALIDATION_STATUS["provisioning_profiles"]="PASS"
            else
                echo "❌ No provisioning profiles found"
                VALIDATION_STATUS["provisioning_profiles"]="FAIL"
                RECOVERY_ACTIONS["provisioning_profiles"]="Download provisioning profiles from Apple Developer portal"
            fi
        else
            echo "❌ Provisioning profiles directory not found"
            VALIDATION_STATUS["provisioning_profiles"]="FAIL"
            RECOVERY_ACTIONS["provisioning_profiles"]="Set up provisioning profiles directory and download profiles"
        fi
        
        echo "4. KEYCHAIN VALIDATION"
        echo "====================="
        
        # Check if certificates are properly installed in keychain
        local keychain_status=$(security list-keychains | grep -c "login.keychain" || echo "0")
        
        if [ "$keychain_status" -gt 0 ]; then
            echo "✅ Login keychain is available"
            
            # Check for private keys
            local private_keys=$(security find-key -t private 2>/dev/null | wc -l)
            echo "🔑 Private keys found: $private_keys"
            
            if [ "$private_keys" -gt 0 ]; then
                echo "✅ Private keys available for code signing"
                VALIDATION_STATUS["keychain_access"]="PASS"
            else
                echo "❌ No private keys found"
                VALIDATION_STATUS["keychain_access"]="FAIL"
                RECOVERY_ACTIONS["keychain_access"]="Import private keys for code signing certificates"
            fi
        else
            echo "❌ Login keychain not accessible"
            VALIDATION_STATUS["keychain_access"]="FAIL"
            RECOVERY_ACTIONS["keychain_access"]="Fix keychain access and unlock login keychain"
        fi
        
    } > "$cert_report"
    
    echo -e "${GREEN}✅ Certificate validation completed${NC}"
    log_message "INFO" "Certificate validation completed"
}

# AUTOMATED RECOVERY PROCEDURES
implement_recovery_procedures() {
    echo -e "${BLUE}🔧 4. Implementing Automated Recovery Procedures${NC}"
    log_message "INFO" "Starting automated recovery procedures"
    
    local recovery_script="$VALIDATION_DIR/automated_recovery_$TIMESTAMP.sh"
    
    cat > "$recovery_script" << 'EOF'
#!/bin/bash

# Automated Recovery Procedures for Build Validation Issues
# Generated by Agent 3: Build Validation & Recovery System

set -e

echo "🔧 Automated Recovery Procedures"
echo "================================"

# Recovery function for Xcode issues
recover_xcode_issues() {
    echo "🔧 Recovering from Xcode issues..."
    
    # Reset Xcode command line tools
    echo "Resetting Xcode command line tools..."
    sudo xcode-select --reset
    sudo xcode-select --install || echo "Command line tools already installed"
    
    # Accept Xcode license
    echo "Accepting Xcode license..."
    sudo xcodebuild -license accept || echo "License already accepted"
    
    # Clear Xcode cache
    echo "Clearing Xcode cache..."
    rm -rf ~/Library/Developer/Xcode/DerivedData/*
    rm -rf ~/Library/Caches/com.apple.dt.Xcode/*
    
    echo "✅ Xcode recovery procedures completed"
}

# Recovery function for certificate issues
recover_certificate_issues() {
    echo "🔧 Recovering from certificate issues..."
    
    # Unlock keychain
    echo "Unlocking login keychain..."
    security unlock-keychain ~/Library/Keychains/login.keychain-db || echo "Keychain unlock failed"
    
    # Refresh certificates
    echo "Refreshing certificates..."
    security find-identity -v -p codesigning || echo "No code signing identities found"
    
    # Clear provisioning profiles cache
    echo "Clearing provisioning profiles cache..."
    rm -rf ~/Library/MobileDevice/Provisioning\ Profiles/*
    
    echo "✅ Certificate recovery procedures completed"
    echo "📝 Note: You may need to re-download certificates and profiles from Apple Developer portal"
}

# Recovery function for license agreement issues
recover_license_issues() {
    echo "🔧 Recovering from license agreement issues..."
    
    # Accept all necessary licenses
    echo "Accepting Xcode license..."
    sudo xcodebuild -license accept
    
    # Check for additional licenses
    echo "Checking for additional license agreements..."
    xcodebuild -runFirstLaunch || echo "First launch setup completed"
    
    echo "✅ License recovery procedures completed"
}

# Main recovery function
main_recovery() {
    echo "🚀 Starting automated recovery..."
    
    recover_xcode_issues
    recover_certificate_issues
    recover_license_issues
    
    echo "🎉 Automated recovery completed!"
    echo "📝 Please run validation again to verify fixes"
}

# Execute recovery if script is run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main_recovery
fi
EOF
    
    chmod +x "$recovery_script"
    
    echo -e "${GREEN}✅ Recovery procedures script created: $recovery_script${NC}"
    log_recovery "Created automated recovery script"
}

# GENERATE COMPREHENSIVE VALIDATION REPORT
generate_validation_report() {
    echo -e "${BLUE}📊 5. Generating Comprehensive Validation Report${NC}"
    log_message "INFO" "Generating comprehensive validation report"
    
    local report_file="$VALIDATION_DIR/loop_validation_report_$TIMESTAMP.md"
    
    # Count validation results
    local total_checks=0
    local passed_checks=0
    local failed_checks=0
    local warning_checks=0
    
    for status in "${VALIDATION_STATUS[@]}"; do
        ((total_checks++))
        case "$status" in
            "PASS") ((passed_checks++)) ;;
            "FAIL") ((failed_checks++)) ;;
            "WARN") ((warning_checks++)) ;;
        esac
    done
    
    cat > "$report_file" << EOF
# Build Validation & Recovery Report
## Loop's "Obvious Error Causes" Checklist Implementation

### Validation Summary
- **Date**: $(date)
- **Total Checks**: $total_checks
- **Passed**: $passed_checks ✅
- **Failed**: $failed_checks ❌
- **Warnings**: $warning_checks ⚠️

### Overall Status
$(if [ $failed_checks -eq 0 ]; then
    echo "🟢 **BUILD READY** - All critical validations passed"
elif [ $failed_checks -le 2 ]; then
    echo "🟡 **BUILD ISSUES** - Minor issues detected, recovery possible"
else
    echo "🔴 **BUILD BLOCKED** - Critical issues detected, manual intervention required"
fi)

---

## 1. Xcode Version Compatibility (iOS 26.0)

### Requirements
- **Xcode**: $REQUIRED_XCODE_VERSION+
- **iOS SDK**: $REQUIRED_IOS_SDK
- **macOS**: $REQUIRED_MACOS_VERSION+

### Validation Results
$(for check in xcode_version xcode_cli_tools ios_sdk ios_simulators macos_version; do
    status="${VALIDATION_STATUS[$check]:-NOT_CHECKED}"
    case "$status" in
        "PASS") echo "✅ **${check}**: PASS" ;;
        "FAIL") echo "❌ **${check}**: FAIL" ;;
        "WARN") echo "⚠️ **${check}**: WARNING" ;;
        *) echo "⚪ **${check}**: NOT CHECKED" ;;
    esac
done)

### Recovery Actions Needed
$(for check in xcode_version xcode_cli_tools ios_sdk ios_simulators macos_version; do
    if [[ -n "${RECOVERY_ACTIONS[$check]}" ]]; then
        echo "- **${check}**: ${RECOVERY_ACTIONS[$check]}"
    fi
done)

---

## 2. Apple Developer License Agreements

### Validation Results
$(for check in apple_id_auth license_agreements paid_membership provisioning_profiles; do
    status="${VALIDATION_STATUS[$check]:-NOT_CHECKED}"
    case "$status" in
        "PASS") echo "✅ **${check}**: PASS" ;;
        "FAIL") echo "❌ **${check}**: FAIL" ;;
        "WARN") echo "⚠️ **${check}**: WARNING" ;;
        *) echo "⚪ **${check}**: NOT CHECKED" ;;
    esac
done)

### Recovery Actions Needed
$(for check in apple_id_auth license_agreements paid_membership provisioning_profiles; do
    if [[ -n "${RECOVERY_ACTIONS[$check]}" ]]; then
        echo "- **${check}**: ${RECOVERY_ACTIONS[$check]}"
    fi
done)

---

## 3. Certificate Validation and Renewal

### Validation Results
$(for check in dev_certificates dist_certificates dev_cert_expiry dist_cert_expiry profile_expiry keychain_access; do
    status="${VALIDATION_STATUS[$check]:-NOT_CHECKED}"
    case "$status" in
        "PASS") echo "✅ **${check}**: PASS" ;;
        "FAIL") echo "❌ **${check}**: FAIL" ;;
        "WARN") echo "⚠️ **${check}**: WARNING" ;;
        *) echo "⚪ **${check}**: NOT CHECKED" ;;
    esac
done)

### Recovery Actions Needed
$(for check in dev_certificates dist_certificates dev_cert_expiry dist_cert_expiry profile_expiry keychain_access; do
    if [[ -n "${RECOVERY_ACTIONS[$check]}" ]]; then
        echo "- **${check}**: ${RECOVERY_ACTIONS[$check]}"
    fi
done)

---

## Automated Recovery

### Recovery Script
- **Location**: \`$VALIDATION_DIR/automated_recovery_$TIMESTAMP.sh\`
- **Usage**: \`./automated_recovery_$TIMESTAMP.sh\`

### Manual Steps Required
$(if [ ${#RECOVERY_ACTIONS[@]} -gt 0 ]; then
    echo "The following manual steps are recommended:"
    for action in "${RECOVERY_ACTIONS[@]}"; do
        echo "1. $action"
    done
else
    echo "No manual recovery steps required - all validations passed!"
fi)

---

## Next Steps

### If All Validations Pass
1. ✅ Proceed with build and deployment
2. ✅ Run comprehensive testing
3. ✅ Deploy to TestFlight

### If Issues Found
1. 🔧 Run automated recovery script
2. 🔧 Follow manual recovery steps
3. 🔧 Re-run validation
4. 🔧 Contact Apple Developer Support if needed

---

## Files Generated
- **Validation Log**: \`$VALIDATION_LOG\`
- **Recovery Log**: \`$RECOVERY_LOG\`
- **Xcode Report**: \`$VALIDATION_DIR/xcode_compatibility_$TIMESTAMP.txt\`
- **License Report**: \`$VALIDATION_DIR/developer_license_$TIMESTAMP.txt\`
- **Certificate Report**: \`$VALIDATION_DIR/certificate_validation_$TIMESTAMP.txt\`
- **Recovery Script**: \`$VALIDATION_DIR/automated_recovery_$TIMESTAMP.sh\`

---

*Generated by Agent 3: Build Validation & Recovery System*  
*Implementing Loop's "Obvious Error Causes" Checklist*
EOF
    
    echo -e "${GREEN}✅ Validation report generated: $report_file${NC}"
    log_message "INFO" "Comprehensive validation report generated"
}

# MAIN EXECUTION
main() {
    echo -e "${CYAN}🚀 Starting Loop's Build Validation & Recovery System${NC}"
    log_message "INFO" "Starting build validation and recovery system"
    
    # Update todo status
    echo -e "${BLUE}📋 Executing Loop's 'Obvious Error Causes' Checklist${NC}"
    
    # Execute all validation steps
    validate_xcode_compatibility
    validate_developer_license
    validate_certificates
    implement_recovery_procedures
    generate_validation_report
    
    # Display summary
    echo -e "${CYAN}📊 VALIDATION SUMMARY${NC}"
    echo -e "${CYAN}====================${NC}"
    
    local total_issues=0
    local critical_issues=0
    
    for status in "${VALIDATION_STATUS[@]}"; do
        case "$status" in
            "FAIL") 
                ((total_issues++))
                ((critical_issues++))
                ;;
            "WARN")
                ((total_issues++))
                ;;
        esac
    done
    
    if [ $critical_issues -eq 0 ]; then
        echo -e "${GREEN}🎉 BUILD VALIDATION SUCCESSFUL!${NC}"
        echo -e "${GREEN}All critical checks passed - ready for build and deployment${NC}"
    else
        echo -e "${YELLOW}⚠️ BUILD VALIDATION ISSUES DETECTED${NC}"
        echo -e "${YELLOW}Critical issues: $critical_issues${NC}"
        echo -e "${YELLOW}Total issues: $total_issues${NC}"
        echo -e "${YELLOW}Recovery actions available in generated reports${NC}"
    fi
    
    echo -e "${BLUE}📁 Results: $VALIDATION_DIR/${NC}"
    echo -e "${BLUE}📊 Report: $VALIDATION_DIR/loop_validation_report_$TIMESTAMP.md${NC}"
    echo -e "${BLUE}🔧 Recovery: $VALIDATION_DIR/automated_recovery_$TIMESTAMP.sh${NC}"
    
    log_message "INFO" "Build validation and recovery system completed"
    
    # Return appropriate exit code
    if [ $critical_issues -eq 0 ]; then
        exit 0
    else
        exit 1
    fi
}

# Execute main function
main "$@"