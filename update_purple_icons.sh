#!/bin/bash

# Update all app icons with new purple Bible design
# This script will generate all required icon sizes from a source image

echo "Purple Bible Icon Update Script"
echo "==============================="

# Check if source file is provided
if [ -z "$1" ]; then
    echo "Please provide the path to your purple Bible icon image"
    echo "Usage: ./update_purple_icons.sh /path/to/purple_bible_icon.png"
    exit 1
fi

SOURCE_ICON="$1"
ICON_DIR="/Users/wsig/Cursor Repos/LeavnOfficial/Leavn/Assets.xcassets/AppIcon.appiconset"

# Verify source file exists
if [ ! -f "$SOURCE_ICON" ]; then
    echo "Error: Source icon file not found: $SOURCE_ICON"
    exit 1
fi

echo "Source icon: $SOURCE_ICON"
echo "Target directory: $ICON_DIR"
echo ""

# Generate all required icon sizes
echo "Generating icons..."

# iPhone icons
sips -z 40 40 "$SOURCE_ICON" --out "$ICON_DIR/icon-20@2x.png" >/dev/null 2>&1
echo "✓ Generated icon-20@2x.png (40x40)"

sips -z 60 60 "$SOURCE_ICON" --out "$ICON_DIR/icon-20@3x.png" >/dev/null 2>&1
echo "✓ Generated icon-20@3x.png (60x60)"

sips -z 58 58 "$SOURCE_ICON" --out "$ICON_DIR/icon-29@2x.png" >/dev/null 2>&1
echo "✓ Generated icon-29@2x.png (58x58)"

sips -z 87 87 "$SOURCE_ICON" --out "$ICON_DIR/icon-29@3x.png" >/dev/null 2>&1
echo "✓ Generated icon-29@3x.png (87x87)"

sips -z 80 80 "$SOURCE_ICON" --out "$ICON_DIR/icon-40@2x.png" >/dev/null 2>&1
echo "✓ Generated icon-40@2x.png (80x80)"

sips -z 120 120 "$SOURCE_ICON" --out "$ICON_DIR/icon-40@3x.png" >/dev/null 2>&1
echo "✓ Generated icon-40@3x.png (120x120)"

sips -z 120 120 "$SOURCE_ICON" --out "$ICON_DIR/icon-60@2x.png" >/dev/null 2>&1
echo "✓ Generated icon-60@2x.png (120x120)"

sips -z 180 180 "$SOURCE_ICON" --out "$ICON_DIR/icon-60@3x.png" >/dev/null 2>&1
echo "✓ Generated icon-60@3x.png (180x180)"

# iPad icons
sips -z 20 20 "$SOURCE_ICON" --out "$ICON_DIR/icon-20.png" >/dev/null 2>&1
echo "✓ Generated icon-20.png (20x20)"

sips -z 29 29 "$SOURCE_ICON" --out "$ICON_DIR/icon-29.png" >/dev/null 2>&1
echo "✓ Generated icon-29.png (29x29)"

sips -z 40 40 "$SOURCE_ICON" --out "$ICON_DIR/icon-40.png" >/dev/null 2>&1
echo "✓ Generated icon-40.png (40x40)"

sips -z 76 76 "$SOURCE_ICON" --out "$ICON_DIR/icon-76.png" >/dev/null 2>&1
echo "✓ Generated icon-76.png (76x76)"

sips -z 152 152 "$SOURCE_ICON" --out "$ICON_DIR/icon-76@2x.png" >/dev/null 2>&1
echo "✓ Generated icon-76@2x.png (152x152)"

sips -z 167 167 "$SOURCE_ICON" --out "$ICON_DIR/icon-83.5@2x.png" >/dev/null 2>&1
echo "✓ Generated icon-83.5@2x.png (167x167)"

# App Store icon
sips -z 1024 1024 "$SOURCE_ICON" --out "$ICON_DIR/icon-1024.png" >/dev/null 2>&1
echo "✓ Generated icon-1024.png (1024x1024)"

echo ""
echo "All icons generated successfully!"
echo ""

# Verify all files were created
echo "Verifying generated icons:"
ls -la "$ICON_DIR"/*.png | wc -l | read count
echo "Found $count icon files in the AppIcon directory"

echo ""
echo "✨ Purple Bible icons are ready for TestFlight!"
echo ""
echo "Next steps:"
echo "1. Build the app in Xcode"
echo "2. Archive and upload to TestFlight"
echo "3. The new purple Bible icon will appear in TestFlight"