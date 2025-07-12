#!/bin/bash

# Script to resize app icon to all required sizes
# Requires sips (built into macOS)

SOURCE_ICON="/Users/wsig/Library/Application Support/CleanShot/media/media_EtbRbqplnz/CleanShot 2025-07-12 at 04.13.28.png"
DEST_DIR="/Users/wsig/GitHub Builds/LeavnOfficial/Leavn/Assets.xcassets/AppIcon.appiconset"

# Ensure destination directory exists
mkdir -p "$DEST_DIR"

echo "Resizing app icon to all required sizes..."

# iPhone icons
sips -z 40 40 "$SOURCE_ICON" --out "$DEST_DIR/icon-20@2x.png"
sips -z 60 60 "$SOURCE_ICON" --out "$DEST_DIR/icon-20@3x.png"
sips -z 58 58 "$SOURCE_ICON" --out "$DEST_DIR/icon-29@2x.png"
sips -z 87 87 "$SOURCE_ICON" --out "$DEST_DIR/icon-29@3x.png"
sips -z 80 80 "$SOURCE_ICON" --out "$DEST_DIR/icon-40@2x.png"
sips -z 120 120 "$SOURCE_ICON" --out "$DEST_DIR/icon-40@3x.png"
sips -z 120 120 "$SOURCE_ICON" --out "$DEST_DIR/icon-60@2x.png"
sips -z 180 180 "$SOURCE_ICON" --out "$DEST_DIR/icon-60@3x.png"

# iPad icons
sips -z 20 20 "$SOURCE_ICON" --out "$DEST_DIR/icon-20.png"
sips -z 29 29 "$SOURCE_ICON" --out "$DEST_DIR/icon-29.png"
sips -z 40 40 "$SOURCE_ICON" --out "$DEST_DIR/icon-40.png"
sips -z 76 76 "$SOURCE_ICON" --out "$DEST_DIR/icon-76.png"
sips -z 152 152 "$SOURCE_ICON" --out "$DEST_DIR/icon-76@2x.png"
sips -z 167 167 "$SOURCE_ICON" --out "$DEST_DIR/icon-83.5@2x.png"

# App Store icon
sips -z 1024 1024 "$SOURCE_ICON" --out "$DEST_DIR/icon-1024.png"

echo "Icon resizing complete!"
echo "All icons have been created in: $DEST_DIR"