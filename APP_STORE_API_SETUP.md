# App Store Connect API Configuration Guide

## Overview
This guide helps you configure App Store Connect API credentials for automated TestFlight uploads.

## Step 1: Generate API Credentials in App Store Connect

### 1.1 Access App Store Connect
1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Sign in with your Apple Developer account
3. Navigate to **Users and Access**

### 1.2 Create API Key
1. Click on **Keys** tab
2. Click the **Generate API Key** button (+ icon)
3. Fill in the details:
   - **Name**: "TestFlight CI/CD Key" (or any descriptive name)
   - **Access**: Select **App Manager** (recommended) or **Developer**
   - **App Access**: Choose **All Apps** or select specific apps
4. Click **Generate**

### 1.3 Save the Credentials
After generation, you'll see three important pieces of information:
- **Key ID**: 10-character string (e.g., `ABC123DEFG`)
- **Issuer ID**: UUID format (e.g., `12345678-1234-1234-1234-123456789abc`)
- **Download API Key**: `.p8` file (can only be downloaded once!)

⚠️ **IMPORTANT**: Download and securely store the `.p8` file immediately - it cannot be downloaded again!

## Step 2: Configure Your Project

### 2.1 Quick Setup (Recommended)
Run the interactive setup script:
```bash
./setup_api_credentials.sh
```

This script will:
- Guide you through entering your API credentials
- Create the necessary configuration files
- Set appropriate file permissions
- Validate your setup

### 2.2 Manual Setup
If you prefer manual setup:

1. **Copy the template file:**
   ```bash
   cp .credentials/api_credentials.env.template .credentials/api_credentials.env
   ```

2. **Edit the credentials file:**
   ```bash
   nano .credentials/api_credentials.env
   ```
   
   Replace the placeholder values:
   ```bash
   export APP_STORE_API_KEY_ID="YOUR_ACTUAL_KEY_ID"
   export APP_STORE_API_ISSUER_ID="YOUR_ACTUAL_ISSUER_ID"
   export APP_STORE_API_PRIVATE_KEY_PATH="$(pwd)/.credentials/AuthKey_${APP_STORE_API_KEY_ID}.p8"
   ```

3. **Copy your .p8 file:**
   Place your downloaded `.p8` file in the `.credentials/` directory with the correct name:
   ```
   .credentials/AuthKey_[YOUR_KEY_ID].p8
   ```

4. **Set permissions:**
   ```bash
   chmod 600 .credentials/api_credentials.env
   chmod 600 .credentials/AuthKey_*.p8
   ```

## Step 3: Test Your Configuration

Run the build script to test your setup:
```bash
./build_testflight.sh
```

The script will:
- ✅ Validate your API credentials
- ✅ Check for the .p8 private key file
- 🏗️ Build and archive your app
- ☁️ Upload to TestFlight

## Security Features

### Files Protected
- `.credentials/` directory is in `.gitignore`
- `.p8` files are explicitly ignored
- Only template files are tracked in git

### File Permissions
- Credentials files are set to 600 (owner read/write only)
- Private key files are protected

### Environment Variables
- API credentials are loaded as environment variables
- No hardcoded secrets in scripts
- Credentials are validated before use

## Troubleshooting

### Common Issues

1. **"API credentials not found"**
   - Ensure `.credentials/api_credentials.env` exists
   - Run `./setup_api_credentials.sh` to create it

2. **"Private key file not found"**
   - Check the `.p8` file is in `.credentials/` directory
   - Verify the filename matches `AuthKey_[KEY_ID].p8`

3. **"Invalid API Key ID"**
   - Key ID should be exactly 10 characters
   - Copy it exactly from App Store Connect

4. **"Upload failed"**
   - Verify your Apple Developer account has TestFlight access
   - Check the API key has "App Manager" or "Developer" role
   - Ensure the key hasn't been revoked in App Store Connect

### Verification Commands

```bash
# Check if credentials file exists
ls -la .credentials/

# Test loading credentials
source .credentials/api_credentials.env && echo "Key ID: $APP_STORE_API_KEY_ID"

# Verify .p8 file
ls -la .credentials/AuthKey_*.p8
```

## File Structure

```
project/
├── build_testflight.sh          # Updated build script
├── setup_api_credentials.sh     # Interactive setup script
└── .credentials/
    ├── README.md                # This documentation
    ├── api_credentials.env.template  # Template file (tracked)
    ├── api_credentials.env      # Your actual credentials (ignored)
    └── AuthKey_[KEY_ID].p8     # Your private key (ignored)
```

## Next Steps

After configuration:
1. Test the build script: `./build_testflight.sh`
2. Monitor the upload in App Store Connect
3. Add release notes in TestFlight
4. Distribute to internal testers
5. Submit for external testing when ready

## Support

If you encounter issues:
1. Check the troubleshooting section above
2. Verify your App Store Connect permissions
3. Ensure your Apple Developer Program membership is active
4. Check Apple's system status page for outages
