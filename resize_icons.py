#!/usr/bin/env python3
"""
Resize app icon to all required sizes for iOS app
Requires: pip install Pillow
"""

from PIL import Image
import os

SOURCE_ICON = "/Users/wsig/Library/Application Support/CleanShot/media/media_EtbRbqplnz/CleanShot 2025-07-12 at 04.13.28.png"
DEST_DIR = "/Users/wsig/GitHub Builds/LeavnOfficial/Leavn/Assets.xcassets/AppIcon.appiconset"

# Icon sizes needed
icon_sizes = [
    ("icon-20.png", 20, 20),
    ("icon-20@2x.png", 40, 40),
    ("icon-20@3x.png", 60, 60),
    ("icon-29.png", 29, 29),
    ("icon-29@2x.png", 58, 58),
    ("icon-29@3x.png", 87, 87),
    ("icon-40.png", 40, 40),
    ("icon-40@2x.png", 80, 80),
    ("icon-40@3x.png", 120, 120),
    ("icon-60@2x.png", 120, 120),
    ("icon-60@3x.png", 180, 180),
    ("icon-76.png", 76, 76),
    ("icon-76@2x.png", 152, 152),
    ("icon-83.5@2x.png", 167, 167),
    ("icon-1024.png", 1024, 1024),
]

def main():
    # Ensure destination directory exists
    os.makedirs(DEST_DIR, exist_ok=True)
    
    # Load the source image
    print(f"Loading source icon: {SOURCE_ICON}")
    source_img = Image.open(SOURCE_ICON)
    
    # Convert to RGBA if needed
    if source_img.mode != 'RGBA':
        source_img = source_img.convert('RGBA')
    
    print("Resizing app icon to all required sizes...")
    
    for filename, width, height in icon_sizes:
        dest_path = os.path.join(DEST_DIR, filename)
        
        # Create a copy and resize
        resized = source_img.copy()
        resized.thumbnail((width, height), Image.Resampling.LANCZOS)
        
        # Create new image with exact dimensions (in case of aspect ratio issues)
        new_img = Image.new('RGBA', (width, height), (0, 0, 0, 0))
        
        # Paste resized image centered
        x = (width - resized.width) // 2
        y = (height - resized.height) // 2
        new_img.paste(resized, (x, y))
        
        # Save as PNG
        new_img.save(dest_path, 'PNG')
        print(f"Created: {filename} ({width}x{height})")
    
    print(f"\nIcon resizing complete!")
    print(f"All icons have been created in: {DEST_DIR}")

if __name__ == "__main__":
    main()