#!/bin/bash

# =============================================================================
# TestFlight Invitation Management Script
# =============================================================================
# This script manages TestFlight invitations for the Leavn app
# Features:
# - Loads existing API credentials from .credentials/api_credentials.env
# - Validates the presence of required .p8 key file
# - Sets up logging infrastructure for tracking invitation status
# - Creates dedicated log directory for this operation
# =============================================================================

set -e  # Exit on any error

# Script configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CREDENTIALS_DIR="${SCRIPT_DIR}/.credentials"
CREDENTIALS_FILE="${CREDENTIALS_DIR}/api_credentials.env"
LOG_DIR="${SCRIPT_DIR}/logs/testflight_invitations"
LOG_FILE="${LOG_DIR}/invitation_log_$(date +%Y%m%d_%H%M%S).log"
ERROR_LOG="${LOG_DIR}/invitation_errors_$(date +%Y%m%d_%H%M%S).log"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# =============================================================================
# LOGGING FUNCTIONS
# =============================================================================

log_info() {
    local message="$1"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "${GREEN}[INFO]${NC} ${message}"
    echo "[${timestamp}] [INFO] ${message}" >> "${LOG_FILE}"
}

log_warning() {
    local message="$1"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "${YELLOW}[WARNING]${NC} ${message}"
    echo "[${timestamp}] [WARNING] ${message}" >> "${LOG_FILE}"
}

log_error() {
    local message="$1"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "${RED}[ERROR]${NC} ${message}" >&2
    echo "[${timestamp}] [ERROR] ${message}" >> "${LOG_FILE}"
    echo "[${timestamp}] [ERROR] ${message}" >> "${ERROR_LOG}"
}

log_debug() {
    local message="$1"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    if [[ "${DEBUG:-false}" == "true" ]]; then
        echo -e "${BLUE}[DEBUG]${NC} ${message}"
    fi
    echo "[${timestamp}] [DEBUG] ${message}" >> "${LOG_FILE}"
}

# =============================================================================
# SETUP FUNCTIONS
# =============================================================================

# Function to read build metadata from file if available
read_build_metadata() {
    if [[ -n "$TESTFLIGHT_BUILD_METADATA" ]] && [[ -f "$TESTFLIGHT_BUILD_METADATA" ]]; then
        log_info "Reading build metadata from: $TESTFLIGHT_BUILD_METADATA"
        
        # Check if jq is available for JSON parsing
        if command -v jq > /dev/null 2>&1; then
            # Extract build information using jq
            local build_number=$(jq -r '.build_number // empty' "$TESTFLIGHT_BUILD_METADATA" 2>/dev/null)
            local version=$(jq -r '.version // empty' "$TESTFLIGHT_BUILD_METADATA" 2>/dev/null)
            local bundle_id=$(jq -r '.bundle_id // empty' "$TESTFLIGHT_BUILD_METADATA" 2>/dev/null)
            local upload_date=$(jq -r '.upload_date // empty' "$TESTFLIGHT_BUILD_METADATA" 2>/dev/null)
            
            if [[ -n "$build_number" ]]; then
                log_info "Build metadata loaded:"
                log_info "  Build Number: $build_number"
                log_info "  Version: $version"
                log_info "  Bundle ID: $bundle_id"
                log_info "  Upload Date: $upload_date"
                
                # Set environment variables if not already set
                TESTFLIGHT_BUILD_NUMBER=${TESTFLIGHT_BUILD_NUMBER:-$build_number}
                TESTFLIGHT_BUILD_VERSION=${TESTFLIGHT_BUILD_VERSION:-$version}
            else
                log_warning "Failed to parse build metadata"
            fi
        else
            log_warning "jq not installed - cannot parse build metadata JSON"
            log_info "Install jq to enable metadata parsing: brew install jq"
        fi
    fi
}

setup_logging() {
    # Create log directory first (before any logging)
    if [[ ! -d "${LOG_DIR}" ]]; then
        mkdir -p "${LOG_DIR}"
    fi
    
    log_info "Setting up logging infrastructure..."
    
    # Log directory status
    if [[ -d "${LOG_DIR}" ]]; then
        log_info "Log directory ready: ${LOG_DIR}"
    fi
    
    # Initialize log files
    touch "${LOG_FILE}"
    touch "${ERROR_LOG}"
    
    log_info "Log files initialized:"
    log_info "  - Main log: ${LOG_FILE}"
    log_info "  - Error log: ${ERROR_LOG}"
    
    # Set appropriate permissions
    chmod 600 "${LOG_FILE}" "${ERROR_LOG}"
    log_info "Log file permissions set to 600 (owner read/write only)"
}

load_credentials() {
    log_info "Loading API credentials..."
    
    # Check if credentials file exists
    if [[ ! -f "${CREDENTIALS_FILE}" ]]; then
        log_error "Credentials file not found: ${CREDENTIALS_FILE}"
        log_error "Please run './setup_api_credentials.sh' first to set up your API credentials"
        exit 1
    fi
    
    log_info "Found credentials file: ${CREDENTIALS_FILE}"
    
    # Source the credentials file
    set -a  # Automatically export all variables
    source "${CREDENTIALS_FILE}"
    set +a  # Turn off automatic export
    
    log_info "API credentials loaded successfully"
    log_debug "API Key ID: ${APP_STORE_API_KEY_ID}"
    log_debug "Issuer ID: ${APP_STORE_API_ISSUER_ID}"
    log_debug "Private Key Path: ${APP_STORE_API_PRIVATE_KEY_PATH}"
}

validate_credentials() {
    log_info "Validating API credentials and key file..."
    
    # Check required environment variables
    if [[ -z "${APP_STORE_API_KEY_ID}" ]]; then
        log_error "APP_STORE_API_KEY_ID is not set"
        exit 1
    fi
    
    if [[ -z "${APP_STORE_API_ISSUER_ID}" ]]; then
        log_error "APP_STORE_API_ISSUER_ID is not set"
        exit 1
    fi
    
    if [[ -z "${APP_STORE_API_PRIVATE_KEY_PATH}" ]]; then
        log_error "APP_STORE_API_PRIVATE_KEY_PATH is not set"
        exit 1
    fi
    
    log_info "Environment variables validated"
    
    # Check if private key file exists
    if [[ ! -f "${APP_STORE_API_PRIVATE_KEY_PATH}" ]]; then
        log_error "Private key file not found: ${APP_STORE_API_PRIVATE_KEY_PATH}"
        log_error "Expected file: AuthKey_${APP_STORE_API_KEY_ID}.p8"
        exit 1
    fi
    
    log_info "Private key file found: ${APP_STORE_API_PRIVATE_KEY_PATH}"
    
    # Check file permissions (should be 600 for security)
    local key_perms=$(stat -f "%OLp" "${APP_STORE_API_PRIVATE_KEY_PATH}" 2>/dev/null || stat -c "%a" "${APP_STORE_API_PRIVATE_KEY_PATH}" 2>/dev/null)
    if [[ "${key_perms}" != "600" ]]; then
        log_warning "Private key file permissions are ${key_perms}, should be 600 for security"
        log_info "Fixing permissions..."
        chmod 600 "${APP_STORE_API_PRIVATE_KEY_PATH}"
        log_info "Private key file permissions set to 600"
    else
        log_info "Private key file permissions are correct (600)"
    fi
    
    # Validate key file format
    if grep -q "BEGIN PRIVATE KEY" "${APP_STORE_API_PRIVATE_KEY_PATH}"; then
        log_info "Private key file format validated"
    else
        log_error "Private key file does not appear to be in valid format"
        log_error "Expected to find 'BEGIN PRIVATE KEY' header"
        exit 1
    fi
    
    log_info "All credentials and key file validation passed"
}

# =============================================================================
# EMAIL VALIDATION AND PROCESSING FUNCTIONS
# =============================================================================

# =============================================================================
# PASTE YOUR 50 EMAIL ADDRESSES HERE (one per line)
# =============================================================================
# Instructions:
# 1. Replace the example emails below with your actual tester email addresses
# 2. Each email should be on its own line within quotes
# 3. Make sure each line ends with a comma (except the last one)
# 4. Maximum of 50 emails recommended for TestFlight beta testing
# 5. The script will automatically:
#    - Validate email format
#    - Remove duplicates
#    - Check against existing beta testers
#
# Format examples:
#    "user1@example.com",
#    "user2@company.org",
#    "tester@domain.net"
# =============================================================================

TESTER_EMAILS=(
    # Example: "user1@example.com"
    # Example: "user2@example.com"
    # Paste your emails below:
    
    "john.doe@example.com"
    "jane.smith@company.com"
    "beta.tester@gmail.com"
    "developer@startup.io"
    "test.user@domain.org"
    "another.tester@email.com"
    "mobile.dev@tech.com"
    "qa.engineer@testing.net"
    # Add your remaining 42 email addresses here...
    # Remember: Maximum 50 emails total
)

# Function to validate email format using regex
validate_email() {
    local email="$1"
    local email_regex="^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$"
    
    if [[ "$email" =~ $email_regex ]]; then
        return 0  # Valid email
    else
        return 1  # Invalid email
    fi
}

# Function to process emails, validate them and remove duplicates
process_emails() {
    log_info "Processing and validating email list..."
    
    declare -a valid_emails      # Array to store valid emails
    declare -a invalid_emails    # Array to store invalid emails
    declare -a duplicate_emails  # Array to store duplicate emails
    
    local total_emails=${#TESTER_EMAILS[@]}
    log_info "Found ${total_emails} emails in the list"
    
    # Process each email
    for email in "${TESTER_EMAILS[@]}"; do
        # Trim whitespace
        email=$(echo "$email" | xargs)
        
        # Skip empty emails
        if [[ -z "$email" ]]; then
            log_warning "Skipping empty email entry"
            continue
        fi
        
        # Convert to lowercase for consistency
        email=$(echo "$email" | tr '[:upper:]' '[:lower:]')
        
        # Check if email is valid
        if validate_email "$email"; then
            # Check for duplicates in existing valid_emails array
            local is_duplicate=false
            for existing_email in "${valid_emails[@]}"; do
                if [[ "$email" == "$existing_email" ]]; then
                    log_warning "Duplicate email found: $email"
                    duplicate_emails+=("$email")
                    is_duplicate=true
                    break
                fi
            done
            
            # Add to valid list if not duplicate
            if [[ "$is_duplicate" == false ]]; then
                valid_emails+=("$email")
                log_debug "Valid email added: $email"
            fi
        else
            log_warning "Invalid email format: $email"
            invalid_emails+=("$email")
        fi
    done
    
    # Log summary
    log_info "Email processing completed:"
    log_info "  - Total emails processed: ${total_emails}"
    log_info "  - Valid emails: ${#valid_emails[@]}"
    log_info "  - Invalid emails: ${#invalid_emails[@]}"
    log_info "  - Duplicate emails: ${#duplicate_emails[@]}"
    
    # Log invalid emails if any
    if [[ ${#invalid_emails[@]} -gt 0 ]]; then
        log_warning "Invalid emails found:"
        for invalid_email in "${invalid_emails[@]}"; do
            log_warning "  - $invalid_email"
        done
    fi
    
    # Log duplicate emails if any
    if [[ ${#duplicate_emails[@]} -gt 0 ]]; then
        log_warning "Duplicate emails found:"
        for duplicate_email in "${duplicate_emails[@]}"; do
            log_warning "  - $duplicate_email"
        done
    fi
    
    # Export valid emails for use by other functions
    PROCESSED_VALID_EMAILS=("${valid_emails[@]}")
    
    return 0
}

# Function to generate JWT token for App Store Connect API
generate_jwt_token() {
    log_info "Generating JWT token for App Store Connect API..."
    
    local header='{"alg":"ES256","kid":"'"$APP_STORE_API_KEY_ID"'","typ":"JWT"}'
    local payload='{"iss":"'"$APP_STORE_API_ISSUER_ID"'","exp":'"$(($(date +%s) + 1200))"',"aud":"appstoreconnect-v1"}'
    
    # Base64 encode header and payload
    local encoded_header=$(echo -n "$header" | base64 | tr -d '=' | tr '/+' '_-' | tr -d '\n')
    local encoded_payload=$(echo -n "$payload" | base64 | tr -d '=' | tr '/+' '_-' | tr -d '\n')
    
    # Create signature
    local signature_input="${encoded_header}.${encoded_payload}"
    
    # Use OpenSSL to create ES256 signature
    local signature=$(echo -n "$signature_input" | openssl dgst -sha256 -sign "$APP_STORE_API_PRIVATE_KEY_PATH" | base64 | tr -d '=' | tr '/+' '_-' | tr -d '\n')
    
    # Construct JWT token
    JWT_TOKEN="${encoded_header}.${encoded_payload}.${signature}"
    
    log_info "JWT token generated successfully"
    log_debug "JWT token: ${JWT_TOKEN:0:50}..."
    
    return 0
}

# Function to check existing beta testers via App Store Connect API
check_existing_testers() {
    log_info "Checking existing beta testers via App Store Connect API..."
    
    # Generate JWT token if not already generated
    if [[ -z "$JWT_TOKEN" ]]; then
        generate_jwt_token
    fi
    
    # App Store Connect API endpoint for beta testers
    local api_url="https://api.appstoreconnect.apple.com/v1/betaTesters"
    
    # Make API request to get existing beta testers
    log_info "Fetching existing beta testers from App Store Connect..."
    
    local response=$(curl -s -w "\n%{http_code}" \
        -H "Authorization: Bearer $JWT_TOKEN" \
        -H "Content-Type: application/json" \
        "$api_url")
    
    # Extract HTTP status code
    local http_code=$(echo "$response" | tail -n1)
    local response_body=$(echo "$response" | head -n -1)
    
    log_debug "API response HTTP code: $http_code"
    
    if [[ "$http_code" == "200" ]]; then
        log_info "Successfully retrieved existing beta testers"
        
        # Parse JSON response to extract email addresses
        # Note: This requires jq for proper JSON parsing
        if command -v jq >/dev/null 2>&1; then
            local existing_emails=$(echo "$response_body" | jq -r '.data[]?.attributes?.email // empty' 2>/dev/null)
            
            if [[ -n "$existing_emails" ]]; then
                # Convert to array
                declare -a existing_testers_array
                while IFS= read -r email; do
                    existing_testers_array+=("$email")
                done <<< "$existing_emails"
                
                EXISTING_BETA_TESTERS=("${existing_testers_array[@]}")
                
                log_info "Found ${#EXISTING_BETA_TESTERS[@]} existing beta testers"
                
                # Check for duplicates between new and existing testers
                check_duplicate_invitations
            else
                log_info "No existing beta testers found"
                EXISTING_BETA_TESTERS=()
            fi
        else
            log_warning "jq not installed - cannot parse JSON response"
            log_warning "Install jq for proper duplicate detection: brew install jq"
            EXISTING_BETA_TESTERS=()
        fi
    elif [[ "$http_code" == "401" ]]; then
        log_error "Authentication failed - check your API credentials"
        log_error "HTTP Code: $http_code"
        return 1
    elif [[ "$http_code" == "403" ]]; then
        log_error "Access forbidden - check your API key permissions"
        log_error "HTTP Code: $http_code"
        return 1
    else
        log_error "API request failed with HTTP code: $http_code"
        log_error "Response: $response_body"
        return 1
    fi
    
    return 0
}

# Function to check for duplicate invitations
check_duplicate_invitations() {
    log_info "Checking for duplicate invitations..."
    
    declare -a already_invited=()
    declare -a new_invitations=()
    
    # Check each processed email against existing testers
    for email in "${PROCESSED_VALID_EMAILS[@]}"; do
        local is_duplicate=false
        
        # Check if email already exists in beta testers
        for existing_email in "${EXISTING_BETA_TESTERS[@]}"; do
            if [[ "$email" == "$existing_email" ]]; then
                already_invited+=("$email")
                is_duplicate=true
                break
            fi
        done
        
        if [[ "$is_duplicate" == false ]]; then
            new_invitations+=("$email")
        fi
    done
    
    # Log results
    log_info "Duplicate invitation check completed:"
    log_info "  - Already invited: ${#already_invited[@]}"
    log_info "  - New invitations: ${#new_invitations[@]}"
    
    # Log already invited emails
    if [[ ${#already_invited[@]} -gt 0 ]]; then
        log_warning "The following emails are already invited as beta testers:"
        for email in "${already_invited[@]}"; do
            log_warning "  - $email"
        done
    fi
    
    # Log new invitations
    if [[ ${#new_invitations[@]} -gt 0 ]]; then
        log_info "The following emails will receive new invitations:"
        for email in "${new_invitations[@]}"; do
            log_info "  - $email"
        done
    fi
    
    # Export arrays for use by other functions
    ALREADY_INVITED_EMAILS=("${already_invited[@]}")
    NEW_INVITATION_EMAILS=("${new_invitations[@]}")
    
    return 0
}

# =============================================================================
# INVITATION FUNCTIONS
# =============================================================================

show_usage() {
    cat << EOF
Usage: $0 [OPTIONS] [COMMAND]

TestFlight Invitation Management Script for Leavn App

COMMANDS:
    setup       Set up logging and validate credentials (default)
    invite      Process emails and send TestFlight invitations to testers
    test        Test email validation and processing (no API calls)
    status      Check invitation status
    help        Show this help message

OPTIONS:
    -d, --debug     Enable debug logging
    -h, --help      Show this help message

EXAMPLES:
    $0 setup                    # Set up logging and validate credentials
    $0 test                     # Test email validation without API calls
    $0 invite                   # Process emails and send invitations to testers
    $0 status                   # Check invitation status
    $0 --debug invite           # Send invitations with debug logging

LOGS:
    Main log: ${LOG_DIR}/invitation_log_YYYYMMDD_HHMMSS.log
    Error log: ${LOG_DIR}/invitation_errors_YYYYMMDD_HHMMSS.log

NOTES:
    - Ensure you have run './setup_api_credentials.sh' first
    - The script will create the log directory if it doesn't exist
    - All operations are logged with timestamps for audit purposes
    - Private key file permissions are automatically secured (600)

EOF
}

# =============================================================================
# MAIN SCRIPT LOGIC
# =============================================================================

main() {
    # Parse command line arguments
    local command="setup"
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            -d|--debug)
                DEBUG=true
                shift
                ;;
            -h|--help)
                show_usage
                exit 0
                ;;
            setup|invite|test|status|help)
                command="$1"
                shift
                ;;
            *)
                log_error "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done
    
    # Handle help command
    if [[ "$command" == "help" ]]; then
        show_usage
        exit 0
    fi
    
    # Initialize script
    echo -e "${BLUE}==============================================================================${NC}"
    echo -e "${BLUE}TestFlight Invitation Management Script${NC}"
    echo -e "${BLUE}==============================================================================${NC}"
    echo
    
    # Check if build metadata is available from environment
    if [[ -n "$TESTFLIGHT_BUILD_NUMBER" ]]; then
        echo -e "${GREEN}Build Information:${NC}"
        echo -e "  Build Number: ${TESTFLIGHT_BUILD_NUMBER}"
        echo -e "  Version: ${TESTFLIGHT_BUILD_VERSION:-Unknown}"
        if [[ -n "$TESTFLIGHT_BUILD_METADATA" ]] && [[ -f "$TESTFLIGHT_BUILD_METADATA" ]]; then
            echo -e "  Metadata file: ${TESTFLIGHT_BUILD_METADATA}"
        fi
        echo
    fi
    
    # Set up logging infrastructure
    setup_logging
    
    # Load and validate credentials
    load_credentials
    validate_credentials
    
    log_info "Script initialization completed successfully"
    
    # Execute command
    case "$command" in
        setup)
            log_info "Setup command completed - logging infrastructure ready"
            echo
            echo -e "${GREEN}✓ Setup completed successfully!${NC}"
            echo -e "  Log directory: ${LOG_DIR}"
            echo -e "  Log file: ${LOG_FILE}"
            echo -e "  Error log: ${ERROR_LOG}"
            echo
            echo -e "${YELLOW}Next steps:${NC}"
            echo -e "  1. Run '$0 invite' to send TestFlight invitations"
            echo -e "  2. Run '$0 status' to check invitation status"
            ;;
        invite)
            log_info "Invite command requested"
            echo -e "${BLUE}Processing email invitations...${NC}"
            echo
            
            # Process and validate emails
            if ! process_emails; then
                log_error "Failed to process emails"
                exit 1
            fi
            
            # Check if we have any valid emails to process
            if [[ ${#PROCESSED_VALID_EMAILS[@]} -eq 0 ]]; then
                log_error "No valid emails found to process"
                exit 1
            fi
            
            # Check existing beta testers to avoid duplicates
            if check_existing_testers; then
                log_info "Successfully checked existing beta testers"
            else
                log_warning "Failed to check existing beta testers - proceeding with caution"
                log_warning "Some invitations might be duplicates"
                # Copy all processed emails to new invitations if API check failed
                NEW_INVITATION_EMAILS=("${PROCESSED_VALID_EMAILS[@]}")
                ALREADY_INVITED_EMAILS=()
            fi
            
            # Display summary
            echo
            echo -e "${GREEN}Email Processing Summary:${NC}"
            echo -e "  ✓ Total valid emails: ${#PROCESSED_VALID_EMAILS[@]}"
            echo -e "  ✓ New invitations: ${#NEW_INVITATION_EMAILS[@]}"
            echo -e "  ⚠ Already invited: ${#ALREADY_INVITED_EMAILS[@]}"
            
            if [[ ${#NEW_INVITATION_EMAILS[@]} -gt 0 ]]; then
                echo
                echo -e "${YELLOW}Next steps:${NC}"
                echo -e "  The following ${#NEW_INVITATION_EMAILS[@]} email(s) are ready for TestFlight invitations:"
                for email in "${NEW_INVITATION_EMAILS[@]}"; do
                    echo -e "    - $email"
                done
                
                # Include build information if available
                if [[ -n "$TESTFLIGHT_BUILD_NUMBER" ]]; then
                    echo
                    echo -e "${GREEN}Invitations will be sent for:${NC}"
                    echo -e "  Build: ${TESTFLIGHT_BUILD_NUMBER}"
                    echo -e "  Version: ${TESTFLIGHT_BUILD_VERSION:-Unknown}"
                fi
                
                echo
                echo -e "${YELLOW}Note: Actual invitation sending will be implemented in the next phase.${NC}"
            else
                echo
                echo -e "${YELLOW}No new invitations needed - all emails are already invited.${NC}"
            fi
            ;;
        test)
            log_info "Test command requested - testing email validation only"
            echo -e "${BLUE}Testing email validation and processing...${NC}"
            echo
            
            # Process and validate emails (no API calls)
            if ! process_emails; then
                log_error "Failed to process emails"
                exit 1
            fi
            
            # Display results
            echo
            echo -e "${GREEN}Email Validation Test Results:${NC}"
            echo -e "  ✓ Total valid emails: ${#PROCESSED_VALID_EMAILS[@]}"
            
            if [[ ${#PROCESSED_VALID_EMAILS[@]} -gt 0 ]]; then
                echo
                echo -e "${GREEN}Valid emails:${NC}"
                for email in "${PROCESSED_VALID_EMAILS[@]}"; do
                    echo -e "  ✓ $email"
                done
            fi
            
            echo
            echo -e "${YELLOW}Note: This test only validates email formats and removes duplicates.${NC}"
            echo -e "${YELLOW}Use 'invite' command to check against existing beta testers via API.${NC}"
            ;;
        status)
            log_info "Status command requested"
            log_warning "Status check functionality not yet implemented"
            echo -e "${YELLOW}Status check feature coming soon!${NC}"
            echo -e "This will be implemented in the next phase of development."
            ;;
        *)
            log_error "Unknown command: $command"
            show_usage
            exit 1
            ;;
    esac
    
    echo
    log_info "Script execution completed"
}

# =============================================================================
# SCRIPT ENTRY POINT
# =============================================================================

# Check if script is being sourced or executed
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
