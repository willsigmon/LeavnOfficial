#!/bin/bash

# Build script for TestFlight deployment
# Usage: ./Scripts/build-testflight.sh

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
PROJECT_NAME="LeavnSuperOfficial"
SCHEME="LeavnSuperOfficial"
CONFIGURATION="Release"
ARCHIVE_PATH="./build/Leavn.xcarchive"
EXPORT_PATH="./build/export"
IPA_PATH="$EXPORT_PATH/Leavn.ipa"

echo -e "${GREEN}🚀 Building Leavn for TestFlight${NC}"

# Clean build directory
echo -e "${YELLOW}Cleaning build directory...${NC}"
rm -rf ./build
mkdir -p ./build

# Increment build number
echo -e "${YELLOW}Incrementing build number...${NC}"
agvtool next-version -all

# Run tests
echo -e "${YELLOW}Running tests...${NC}"
xcodebuild test \
    -project "$PROJECT_NAME.xcodeproj" \
    -scheme "$SCHEME" \
    -destination 'platform=iOS Simulator,name=iPhone 15 Pro' \
    -quiet

# Build archive
echo -e "${YELLOW}Building archive...${NC}"
xcodebuild archive \
    -project "$PROJECT_NAME.xcodeproj" \
    -scheme "$SCHEME" \
    -configuration "$CONFIGURATION" \
    -archivePath "$ARCHIVE_PATH" \
    -allowProvisioningUpdates \
    DEVELOPMENT_TEAM="YOUR_TEAM_ID" \
    -quiet

# Export IPA
echo -e "${YELLOW}Exporting IPA...${NC}"
xcodebuild -exportArchive \
    -archivePath "$ARCHIVE_PATH" \
    -exportPath "$EXPORT_PATH" \
    -exportOptionsPlist "ExportOptions.plist" \
    -allowProvisioningUpdates \
    -quiet

# Validate app
echo -e "${YELLOW}Validating app...${NC}"
xcrun altool --validate-app \
    -f "$IPA_PATH" \
    -t ios \
    --apiKey "YOUR_API_KEY" \
    --apiIssuer "YOUR_ISSUER_ID" \
    --verbose

# Upload to TestFlight
echo -e "${YELLOW}Uploading to TestFlight...${NC}"
xcrun altool --upload-app \
    -f "$IPA_PATH" \
    -t ios \
    --apiKey "YOUR_API_KEY" \
    --apiIssuer "YOUR_ISSUER_ID" \
    --verbose

echo -e "${GREEN}✅ Successfully uploaded to TestFlight!${NC}"
echo -e "${GREEN}Build number: $(agvtool what-version -terse)${NC}"