# TestFlight Invitation Management CLI

This document describes the command-line interface for managing TestFlight invitations for the Leavn app.

## Overview

The TestFlight CLI provides a convenient way to:
- Check if the latest build is ready for testing
- View the status of previously sent invitations
- Validate email addresses without sending invitations
- Process and send invitations to beta testers

## Prerequisites

1. **API Credentials Setup**
   ```bash
   ./setup_api_credentials.sh
   ```
   This sets up your App Store Connect API credentials.

2. **Python Dependencies**
   ```bash
   pip install jwt cryptography requests python-dotenv
   ```

## Usage

### Basic Command Structure

```bash
./testflight [OPTIONS]
```

Or using Python directly:

```bash
python app_store_api.py [OPTIONS]
```

### Command-Line Options

#### `--check-build`
Check if the latest build is ready for testing.

```bash
./testflight --check-build
```

Example output:
```
🏗️  Checking if the latest build is ready for testing...

✅ Latest build found:
   Version: 1.0.0
   Build Number: 123
   Status: READY_FOR_TESTING
   Uploaded: 2024-01-15T10:30:00Z

✅ Build is ready for testing!
```

#### `--status`
Show the status of previously sent invitations.

```bash
./testflight --status
```

Example output:
```
📬 Checking status of previously sent invitations...

📊 Total beta testers: 25

✉️  Invitations sent: 25
✅ Invitations accepted: 18
⏳ Pending acceptance: 7

📋 Recent invitations (last 10):
   ✅ user1@example.com            - Status: ACCEPTED   - Added: 2024-01-15T09:00:00Z
   ⏳ user2@example.com            - Status: INVITED    - Added: 2024-01-15T08:30:00Z
   ...
```

#### `--dry-run`
Validate email addresses without sending invitations.

```bash
./testflight --dry-run --emails user1@example.com user2@invalid
```

Example output:
```
✉️  Validating emails without sending invitations...

📊 Validation Results:
   Total emails provided: 2
   Valid emails: 1
   Invalid emails: 1
   Duplicates removed: 0

❌ Invalid emails:
   - user2@invalid

✅ Valid emails (ready to send):
   1. user1@example.com
```

#### `--help`
Display usage instructions.

```bash
./testflight --help
```

### Default Behavior

When run without options, the script processes and sends invitations:

```bash
./testflight --emails user1@example.com user2@example.com user3@example.com
```

### Additional Options

#### `--emails`
Specify email addresses to process (space-separated).

```bash
./testflight --emails email1@example.com email2@example.com
```

#### `--bundle-id`
Specify a custom bundle identifier (default: com.leavn.app).

```bash
./testflight --bundle-id com.company.app --check-build
```

## Examples

### Check Build Status
```bash
# Check if the latest build is ready
./testflight --check-build
```

### View Invitation Status
```bash
# Check the status of all invitations
./testflight --status
```

### Validate Emails Before Sending
```bash
# Dry run to validate emails
./testflight --dry-run --emails john@example.com jane@example.com invalid-email
```

### Send Invitations
```bash
# Send invitations to specific emails
./testflight --emails john@example.com jane@example.com sarah@example.com

# Send invitations from a file
./testflight --emails $(cat tester_emails.txt)
```

### Batch Processing
```bash
# Process multiple emails from a file
while IFS= read -r email; do
    echo "$email"
done < emails.txt | xargs ./testflight --emails
```

## Exit Codes

- `0` - Success
- `1` - General error (API error, invalid credentials, etc.)
- `130` - Operation cancelled by user (Ctrl+C)

## Logging

All operations are logged to `app_store_api.log` with detailed information including:
- API requests and responses
- Error messages and stack traces
- Invitation processing results

## Best Practices

1. **Batch Size**: Limit invitations to 50 emails per batch for optimal performance.

2. **Email Validation**: Always use `--dry-run` first to validate emails before sending.

3. **Build Readiness**: Check build status with `--check-build` before sending invitations.

4. **Monitor Status**: Use `--status` to track invitation acceptance rates.

## Troubleshooting

### Common Issues

1. **Authentication Failed**
   ```
   ❌ Failed to initialize API client: Credentials file not found
   ```
   Solution: Run `./setup_api_credentials.sh` first.

2. **Build Not Ready**
   ```
   ⚠️  Build is not ready yet. Current state: PROCESSING
   ```
   Solution: Wait for build processing to complete.

3. **Invalid Email Format**
   ```
   ❌ Invalid emails:
      - not-an-email
   ```
   Solution: Ensure all emails follow standard format (user@domain.com).

### Debug Mode

For detailed debugging information, check the `app_store_api.log` file:

```bash
tail -f app_store_api.log
```

## Security

- API credentials are stored in `.credentials/api_credentials.env`
- Private key files should have 600 permissions
- Never commit credentials to version control
- Use environment variables for sensitive data

## Support

For issues or questions:
1. Check the log file for detailed error messages
2. Ensure API credentials are correctly configured
3. Verify network connectivity to App Store Connect API
4. Check that the bundle ID matches your app
