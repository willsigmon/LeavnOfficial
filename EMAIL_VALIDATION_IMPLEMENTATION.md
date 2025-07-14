# Email Validation and Processing Implementation

## Overview
This document summarizes the implementation of core email validation and processing functions for the TestFlight invitation management script.

## Implemented Functions

### 1. `validate_email()`
- **Purpose**: Regex-based email validation
- **Features**:
  - Uses comprehensive regex pattern for email validation
  - Validates standard email format: `user@domain.tld`
  - Returns 0 for valid emails, 1 for invalid emails
- **Regex Pattern**: `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$`

### 2. `process_emails()`
- **Purpose**: Parse and deduplicate the hardcoded email list
- **Features**:
  - Processes hardcoded `BETA_TESTERS_EMAILS` array
  - Trims whitespace and normalizes to lowercase
  - Validates each email using `validate_email()`
  - Detects and removes duplicates
  - Categorizes emails into: valid, invalid, and duplicate
  - Provides detailed logging and statistics
  - Exports `PROCESSED_VALID_EMAILS` array for other functions

### 3. `check_existing_testers()`
- **Purpose**: Query App Store Connect API for existing beta testers
- **Features**:
  - Generates JWT token for authentication using `generate_jwt_token()`
  - Makes authenticated API call to App Store Connect
  - Handles HTTP response codes (200, 401, 403, etc.)
  - Parses JSON response using `jq` (if available)
  - Extracts existing beta tester email addresses
  - Calls `check_duplicate_invitations()` to compare with new emails

### 4. `generate_jwt_token()`
- **Purpose**: Generate JWT token for App Store Connect API authentication
- **Features**:
  - Creates ES256 JWT token with proper headers
  - Uses API key ID, issuer ID, and private key
  - Sets 20-minute expiration time
  - Handles Base64 encoding and URL-safe formatting
  - Uses OpenSSL for ES256 signature generation

### 5. `check_duplicate_invitations()`
- **Purpose**: Handle duplicate detection and provide warnings
- **Features**:
  - Compares processed emails against existing beta testers
  - Categorizes emails into: already invited vs. new invitations
  - Provides detailed warnings for duplicate invitations
  - Exports `ALREADY_INVITED_EMAILS` and `NEW_INVITATION_EMAILS` arrays

## Hardcoded Email List
The script includes a test email list with intentional duplicates and invalid emails:
- **Total emails**: 10
- **Valid emails**: 8 (after deduplication)
- **Invalid emails**: 1 (`invalid.email@`)
- **Duplicates**: 1 (`john.doe@example.com`)

## Commands Added

### `test` Command
- Tests email validation and processing without making API calls
- Shows validation results and statistics
- Safe to run without API credentials

### Enhanced `invite` Command
- Processes emails using `process_emails()`
- Checks existing beta testers via API
- Provides comprehensive summary of invitation status
- Handles API failures gracefully

## Usage Examples

```bash
# Test email validation only (no API calls)
./invite_testflight_testers.sh test

# Test with debug logging
./invite_testflight_testers.sh --debug test

# Process emails and check against existing testers
./invite_testflight_testers.sh invite

# Show help
./invite_testflight_testers.sh --help
```

## Error Handling
- Validates API credentials before making calls
- Handles network failures and API errors
- Provides fallback behavior when `jq` is not available
- Comprehensive logging of all operations

## Security Features
- Secure JWT token generation
- Proper private key file permissions (600)
- No secrets logged in plain text
- Secure credential file handling

## Dependencies
- **Required**: `curl`, `openssl`, `base64`
- **Optional**: `jq` (for JSON parsing - provides better duplicate detection)

## Logging
All operations are logged with timestamps to:
- Main log: `logs/testflight_invitations/invitation_log_YYYYMMDD_HHMMSS.log`
- Error log: `logs/testflight_invitations/invitation_errors_YYYYMMDD_HHMMSS.log`

## Next Steps
The implementation provides a solid foundation for:
1. Actual TestFlight invitation sending
2. Status checking and monitoring
3. Advanced email management features
4. Integration with external email lists
