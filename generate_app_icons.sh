#!/bin/bash

# Script to generate all required app icon sizes from a source image
# Usage: ./generate_app_icons.sh source_icon.png

if [ -z "$1" ]; then
    echo "Usage: $0 source_icon.png"
    exit 1
fi

SOURCE_ICON="$1"
ICON_DIR="/Users/wsig/Cursor Repos/LeavnOfficial/Leavn/Assets.xcassets/AppIcon.appiconset"

if [ ! -f "$SOURCE_ICON" ]; then
    echo "Error: Source icon file not found: $SOURCE_ICON"
    exit 1
fi

echo "Generating app icons from: $SOURCE_ICON"
echo "Output directory: $ICON_DIR"

# Generate all required sizes
sips -z 20 20 "$SOURCE_ICON" --out "$ICON_DIR/icon-20.png"
sips -z 40 40 "$SOURCE_ICON" --out "$ICON_DIR/icon-20@2x.png"
sips -z 60 60 "$SOURCE_ICON" --out "$ICON_DIR/icon-20@3x.png"
sips -z 29 29 "$SOURCE_ICON" --out "$ICON_DIR/icon-29.png"
sips -z 58 58 "$SOURCE_ICON" --out "$ICON_DIR/icon-29@2x.png"
sips -z 87 87 "$SOURCE_ICON" --out "$ICON_DIR/icon-29@3x.png"
sips -z 40 40 "$SOURCE_ICON" --out "$ICON_DIR/icon-40.png"
sips -z 80 80 "$SOURCE_ICON" --out "$ICON_DIR/icon-40@2x.png"
sips -z 120 120 "$SOURCE_ICON" --out "$ICON_DIR/icon-40@3x.png"
sips -z 120 120 "$SOURCE_ICON" --out "$ICON_DIR/icon-60@2x.png"
sips -z 180 180 "$SOURCE_ICON" --out "$ICON_DIR/icon-60@3x.png"
sips -z 76 76 "$SOURCE_ICON" --out "$ICON_DIR/icon-76.png"
sips -z 152 152 "$SOURCE_ICON" --out "$ICON_DIR/icon-76@2x.png"
sips -z 167 167 "$SOURCE_ICON" --out "$ICON_DIR/icon-83.5@2x.png"
sips -z 1024 1024 "$SOURCE_ICON" --out "$ICON_DIR/icon-1024.png"

echo "All icons generated successfully!"

# List generated files
echo -e "\nGenerated icons:"
ls -la "$ICON_DIR"/*.png | awk '{print $9, $5}'