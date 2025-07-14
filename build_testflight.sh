#!/bin/bash

# Build script for TestFlight submission
# Usage: ./build_testflight.sh

set -e

echo "🚀 Starting TestFlight Build Process..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
PROJECT_NAME="Leavn"
SCHEME="Leavn"
CONFIGURATION="Release"
BUNDLE_ID="com.leavn.app"

# Load API credentials if available
if [ -f ".credentials/api_credentials.env" ]; then
    source .credentials/api_credentials.env
    echo "✅ Loaded App Store Connect API credentials"
else
    echo -e "${RED}❌ API credentials not found. Please:${NC}"
    echo "1. Copy .credentials/api_credentials.env.template to .credentials/api_credentials.env"
    echo "2. Add your actual API Key ID and Issuer ID from App Store Connect"
    echo "3. Place your .p8 private key file in the .credentials/ directory"
    exit 1
fi

# Validate required credentials
if [ -z "$APP_STORE_API_KEY_ID" ] || [ -z "$APP_STORE_API_ISSUER_ID" ]; then
    echo -e "${RED}❌ Missing API credentials. Please check .credentials/api_credentials.env${NC}"
    exit 1
fi

if [ ! -f "$APP_STORE_API_PRIVATE_KEY_PATH" ]; then
    echo -e "${RED}❌ Private key file not found: $APP_STORE_API_PRIVATE_KEY_PATH${NC}"
    echo "Please download your .p8 file from App Store Connect and place it in .credentials/"
    exit 1
fi

# Get current version and build number
CURRENT_VERSION=$(grep -A1 'CFBundleShortVersionString' Leavn/Info.plist | grep string | sed 's/.*<string>\(.*\)<\/string>/\1/')
CURRENT_BUILD=$(grep -A1 'CFBundleVersion' Leavn/Info.plist | grep string | sed 's/.*<string>\(.*\)<\/string>/\1/')

echo "Current Version: $CURRENT_VERSION"
echo "Current Build: $CURRENT_BUILD"

# Increment build number
NEW_BUILD=$((CURRENT_BUILD + 1))
echo -e "${YELLOW}New Build Number: $NEW_BUILD${NC}"

# Update build number in Info.plist
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $NEW_BUILD" Leavn/Info.plist

# Check if Firebase is needed
if [ ! -f "Leavn/GoogleService-Info.plist" ]; then
    echo -e "${YELLOW}ℹ️  No Firebase config found - building without community features${NC}"
fi

# Clean build folder
echo "🧹 Cleaning build folder..."
rm -rf build/
xcodebuild clean -project "${PROJECT_NAME}.xcodeproj" -scheme "$SCHEME" -configuration "$CONFIGURATION"

# Archive the app
echo "📦 Creating archive..."
xcodebuild archive \
    -project "${PROJECT_NAME}.xcodeproj" \
    -scheme "$SCHEME" \
    -configuration "$CONFIGURATION" \
    -archivePath "build/${PROJECT_NAME}.xcarchive" \
    -destination "generic/platform=iOS" \
    -allowProvisioningUpdates \
    CODE_SIGN_STYLE=Automatic

# Export IPA
echo "📱 Exporting IPA..."
cat > build/ExportOptions.plist <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>app-store</string>
    <key>teamID</key>
    <string>3CAM9954N7</string>
    <key>uploadSymbols</key>
    <true/>
    <key>uploadBitcode</key>
    <false/>
    <key>compileBitcode</key>
    <false/>
    <key>signingStyle</key>
    <string>automatic</string>
    <key>generateAppStoreInformation</key>
    <true/>
    <key>stripSwiftSymbols</key>
    <true/>
</dict>
</plist>
EOF

xcodebuild -exportArchive \
    -archivePath "build/${PROJECT_NAME}.xcarchive" \
    -exportPath "build/" \
    -exportOptionsPlist "build/ExportOptions.plist" \
    -allowProvisioningUpdates

# Upload to TestFlight
echo "☁️  Uploading to TestFlight..."
xcrun altool --upload-app \
    -f "build/${PROJECT_NAME}.ipa" \
    -type ios \
    --apiKey "$APP_STORE_API_KEY_ID" \
    --apiIssuer "$APP_STORE_API_ISSUER_ID" \
    --verbose

echo -e "${GREEN}✅ Build and upload complete!${NC}"
echo "Version: $CURRENT_VERSION (Build $NEW_BUILD)"
echo "IPA Location: build/${PROJECT_NAME}.ipa"

# Store build metadata for invitation script
BUILD_METADATA_DIR="logs/builds"
mkdir -p "$BUILD_METADATA_DIR"
BUILD_METADATA_FILE="$BUILD_METADATA_DIR/build_${NEW_BUILD}_metadata.json"

# Create build metadata JSON
cat > "$BUILD_METADATA_FILE" <<EOF
{
  "build_number": "$NEW_BUILD",
  "version": "$CURRENT_VERSION",
  "bundle_id": "$BUNDLE_ID",
  "upload_date": "$(date -u '+%Y-%m-%dT%H:%M:%SZ')",
  "ipa_path": "build/${PROJECT_NAME}.ipa",
  "archive_path": "build/${PROJECT_NAME}.xcarchive"
}
EOF

echo "Build metadata stored: $BUILD_METADATA_FILE"

# Commit the build number change
git add Leavn/Info.plist
git commit -m "Bump build number to $NEW_BUILD for TestFlight"

# Ask if user wants to invite testers immediately
echo
echo -e "${YELLOW}Would you like to invite TestFlight testers now?${NC}"
echo "This will run the invitation script to send invites to your configured testers."
read -p "Invite testers? [y/N]: " INVITE_RESPONSE

if [[ "$INVITE_RESPONSE" =~ ^[Yy]$ ]]; then
    echo
    echo -e "${BLUE}Running TestFlight invitation script...${NC}"
    
    # Check if invitation script exists
    if [ -f "./invite_testflight_testers.sh" ]; then
        # Pass build number and metadata file path as environment variables
        export TESTFLIGHT_BUILD_NUMBER="$NEW_BUILD"
        export TESTFLIGHT_BUILD_VERSION="$CURRENT_VERSION"
        export TESTFLIGHT_BUILD_METADATA="$BUILD_METADATA_FILE"
        
        # Run the invitation script
        ./invite_testflight_testers.sh invite
        
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✅ Invitation process completed!${NC}"
        else
            echo -e "${RED}❌ Invitation process failed. Check logs for details.${NC}"
        fi
    else
        echo -e "${RED}❌ Invitation script not found: ./invite_testflight_testers.sh${NC}"
        echo "Please ensure the invitation script is in the same directory."
    fi
else
    echo -e "${YELLOW}Skipping tester invitations.${NC}"
    echo
    echo -e "${YELLOW}To invite testers later, run:${NC}"
    echo "  export TESTFLIGHT_BUILD_NUMBER=$NEW_BUILD"
    echo "  export TESTFLIGHT_BUILD_VERSION=$CURRENT_VERSION"
    echo "  ./invite_testflight_testers.sh invite"
fi

echo
echo -e "${YELLOW}Remember to:${NC}"
echo "1. Add release notes in App Store Connect"
echo "2. Submit for TestFlight review if needed"
if [[ ! "$INVITE_RESPONSE" =~ ^[Yy]$ ]]; then
    echo "3. Invite external testers when ready"
fi
