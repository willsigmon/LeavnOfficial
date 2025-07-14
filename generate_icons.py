#!/usr/bin/env python3

import os
import subprocess
import sys

def generate_icons(source_path):
    """Generate all required iOS app icon sizes from a 1024x1024 source image."""
    
    iconset_path = "Leavn/Assets.xcassets/AppIcon.appiconset"
    
    # Define all required icon sizes
    icon_sizes = [
        # iPhone Notification - 20pt
        ("icon-20@2x.png", 40, 40),
        ("icon-20@3x.png", 60, 60),
        
        # iPhone Settings - 29pt
        ("icon-29@2x.png", 58, 58),
        ("icon-29@3x.png", 87, 87),
        
        # iPhone Spotlight - 40pt
        ("icon-40@2x.png", 80, 80),
        ("icon-40@3x.png", 120, 120),
        
        # iPhone App - 60pt
        ("icon-60@2x.png", 120, 120),
        ("icon-60@3x.png", 180, 180),
        
        # iPad Notification - 20pt
        ("icon-20.png", 20, 20),
        
        # iPad Settings - 29pt
        ("icon-29.png", 29, 29),
        
        # iPad Spotlight - 40pt
        ("icon-40.png", 40, 40),
        
        # iPad App - 76pt
        ("icon-76.png", 76, 76),
        ("icon-76@2x.png", 152, 152),
        
        # iPad Pro App - 83.5pt
        ("icon-83.5@2x.png", 167, 167),
        
        # App Store - 1024pt
        ("icon-1024.png", 1024, 1024),
    ]
    
    print(f"🎨 Generating icons from: {source_path}")
    
    for filename, width, height in icon_sizes:
        output_path = os.path.join(iconset_path, filename)
        cmd = [
            "sips",
            "-z", str(height), str(width),
            source_path,
            "--out", output_path
        ]
        
        try:
            subprocess.run(cmd, check=True, capture_output=True)
            print(f"✅ Generated: {filename} ({width}x{height})")
        except subprocess.CalledProcessError as e:
            print(f"❌ Failed to generate {filename}: {e}")
            return False
    
    print("\n🎉 All icons generated successfully!")
    print(f"📁 Location: {iconset_path}")
    return True

if __name__ == "__main__":
    # Use the new purple Bible icon
    source_icon = "/Users/wsig/Cursor Repos/LeavnOfficial/purple_bible_icon_white_bg.png"
    
    if not os.path.exists(source_icon):
        print(f"❌ Source icon not found: {source_icon}")
        sys.exit(1)
    
    generate_icons(source_icon)