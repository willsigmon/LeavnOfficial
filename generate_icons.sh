#!/bin/bash

# Generate App Icons from 1024x1024 source
# Usage: ./generate_icons.sh source_icon.png

SOURCE=$1
ICONSET_PATH="Leavn/Assets.xcassets/AppIcon.appiconset"

if [ -z "$SOURCE" ]; then
    echo "Usage: $0 <source_icon_1024x1024.png>"
    exit 1
fi

if [ ! -f "$SOURCE" ]; then
    echo "Error: Source file not found: $SOURCE"
    exit 1
fi

echo "Generating icons from: $SOURCE"

# iPhone Notification - 20pt
sips -z 40 40 "$SOURCE" --out "$ICONSET_PATH/icon-20@2x.png"
sips -z 60 60 "$SOURCE" --out "$ICONSET_PATH/icon-20@3x.png"

# iPhone Settings - 29pt  
sips -z 58 58 "$SOURCE" --out "$ICONSET_PATH/icon-29@2x.png"
sips -z 87 87 "$SOURCE" --out "$ICONSET_PATH/icon-29@3x.png"

# iPhone Spotlight - 40pt
sips -z 80 80 "$SOURCE" --out "$ICONSET_PATH/icon-40@2x.png"
sips -z 120 120 "$SOURCE" --out "$ICONSET_PATH/icon-40@3x.png"

# iPhone App - 60pt
sips -z 120 120 "$SOURCE" --out "$ICONSET_PATH/icon-60@2x.png"
sips -z 180 180 "$SOURCE" --out "$ICONSET_PATH/icon-60@3x.png"

# iPad Notification - 20pt
sips -z 20 20 "$SOURCE" --out "$ICONSET_PATH/icon-20.png"

# iPad Settings - 29pt
sips -z 29 29 "$SOURCE" --out "$ICONSET_PATH/icon-29.png"

# iPad Spotlight - 40pt  
sips -z 40 40 "$SOURCE" --out "$ICONSET_PATH/icon-40.png"

# iPad App - 76pt
sips -z 76 76 "$SOURCE" --out "$ICONSET_PATH/icon-76.png"
sips -z 152 152 "$SOURCE" --out "$ICONSET_PATH/icon-76@2x.png"

# iPad Pro App - 83.5pt
sips -z 167 167 "$SOURCE" --out "$ICONSET_PATH/icon-83.5@2x.png"

# App Store - 1024pt
cp "$SOURCE" "$ICONSET_PATH/icon-1024.png"

echo "✅ Icons generated successfully!"
echo "📁 Location: $ICONSET_PATH"