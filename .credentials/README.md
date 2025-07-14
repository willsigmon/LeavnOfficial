# App Store Connect API Credentials

This directory contains sensitive API credentials for App Store Connect.

## Files:
- `AuthKey_[KEY_ID].p8` - Private key file downloaded from App Store Connect
- `api_credentials.env` - Environment variables for API Key ID and Issuer ID

## Security Notes:
- Never commit these files to version control
- Keep the .p8 file secure and backed up
- The .p8 file can only be downloaded once from App Store Connect
- Use environment variables to reference these credentials in scripts

## Usage:
Source the environment file before running build scripts:
```bash
source .credentials/api_credentials.env
./build_testflight.sh
```
