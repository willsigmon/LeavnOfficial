#!/bin/bash

# App Store Connect API Setup Script
# This script helps you configure your API credentials for TestFlight uploads

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}📱 App Store Connect API Setup${NC}"
echo "==========================================="
echo

# Check if credentials directory exists
if [ ! -d ".credentials" ]; then
    echo -e "${RED}❌ .credentials directory not found${NC}"
    echo "Please run this script from the project root directory"
    exit 1
fi

# Check if template exists
if [ ! -f ".credentials/api_credentials.env.template" ]; then
    echo -e "${RED}❌ Template file not found${NC}"
    exit 1
fi

echo -e "${YELLOW}This script will help you set up App Store Connect API credentials.${NC}"
echo
echo "Before proceeding, make sure you have:"
echo "1. Generated an API key in App Store Connect (Users and Access > Keys)"
echo "2. Downloaded the .p8 private key file"
echo "3. Noted the Key ID (10 characters) and Issuer ID (UUID)"
echo

read -p "Do you have these ready? (y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo
    echo -e "${YELLOW}Please complete the setup in App Store Connect first:${NC}"
    echo "1. Go to https://appstoreconnect.apple.com"
    echo "2. Navigate to Users and Access > Keys"
    echo "3. Click Generate API Key (+)"
    echo "4. Choose 'App Manager' access level"
    echo "5. Download the .p8 file and note the Key ID and Issuer ID"
    echo
    exit 0
fi

echo
echo -e "${BLUE}📝 Enter your API credentials:${NC}"
echo

# Get API Key ID
read -p "Enter your API Key ID (10 characters): " API_KEY_ID
if [ ${#API_KEY_ID} -ne 10 ]; then
    echo -e "${RED}❌ API Key ID should be exactly 10 characters${NC}"
    exit 1
fi

# Get Issuer ID
read -p "Enter your Issuer ID (UUID format): " ISSUER_ID
if [[ ! $ISSUER_ID =~ ^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$ ]]; then
    echo -e "${YELLOW}⚠️  Warning: Issuer ID doesn't look like a UUID format${NC}"
    read -p "Continue anyway? (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Check for .p8 file
P8_FILE=".credentials/AuthKey_${API_KEY_ID}.p8"
if [ ! -f "$P8_FILE" ]; then
    echo
    echo -e "${YELLOW}📁 .p8 file not found at: $P8_FILE${NC}"
    echo "Please copy your downloaded .p8 file to this location."
    echo
    read -p "Press Enter when you've copied the file..." -r
    
    if [ ! -f "$P8_FILE" ]; then
        echo -e "${RED}❌ File still not found. Please copy your .p8 file to $P8_FILE${NC}"
        exit 1
    fi
fi

# Create the credentials file
CREDS_FILE=".credentials/api_credentials.env"
echo "# App Store Connect API Credentials" > "$CREDS_FILE"
echo "# Generated on $(date)" >> "$CREDS_FILE"
echo >> "$CREDS_FILE"
echo "# API Key ID (10-character string from App Store Connect)" >> "$CREDS_FILE"
echo "export APP_STORE_API_KEY_ID=\"$API_KEY_ID\"" >> "$CREDS_FILE"
echo >> "$CREDS_FILE"
echo "# Issuer ID (UUID from App Store Connect)" >> "$CREDS_FILE"
echo "export APP_STORE_API_ISSUER_ID=\"$ISSUER_ID\"" >> "$CREDS_FILE"
echo >> "$CREDS_FILE"
echo "# Path to the .p8 private key file" >> "$CREDS_FILE"
echo "export APP_STORE_API_PRIVATE_KEY_PATH=\"\$(pwd)/.credentials/AuthKey_\${APP_STORE_API_KEY_ID}.p8\"" >> "$CREDS_FILE"

# Set appropriate permissions
chmod 600 "$CREDS_FILE"
chmod 600 "$P8_FILE"

echo
echo -e "${GREEN}✅ Credentials configured successfully!${NC}"
echo
echo "Files created:"
echo "  📄 $CREDS_FILE"
echo "  🔐 $P8_FILE"
echo
echo -e "${YELLOW}Security notes:${NC}"
echo "• These files are already added to .gitignore"
echo "• File permissions set to 600 (owner read/write only)"
echo "• Never share or commit these credentials"
echo
echo -e "${BLUE}🚀 You can now run the build script:${NC}"
echo "  ./build_testflight.sh"
echo
