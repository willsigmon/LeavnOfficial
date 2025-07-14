#!/usr/bin/env python3
"""
Fix app icon by removing alpha channel
"""
import os
from PIL import Image

def remove_alpha_channel(input_path, output_path):
    """Remove alpha channel from PNG image"""
    # Open the image
    img = Image.open(input_path)
    
    # Check if image has alpha channel
    if img.mode in ('RGBA', 'LA'):
        # Create a white background
        background = Image.new('RGB', img.size, (255, 255, 255))
        
        # Paste the image on the white background
        if img.mode == 'RGBA':
            background.paste(img, mask=img.split()[3])  # Use alpha channel as mask
        else:
            background.paste(img, mask=img.split()[1])  # Use alpha channel as mask
        
        # Save without alpha
        background.save(output_path, 'PNG', optimize=True)
        print(f"✅ Removed alpha channel from {os.path.basename(input_path)}")
        return True
    else:
        # No alpha channel, just copy
        img.save(output_path, 'PNG', optimize=True)
        print(f"ℹ️  {os.path.basename(input_path)} has no alpha channel, copied as-is")
        return False

def main():
    icon_path = "/Users/wsig/Cursor Repos/LeavnOfficial/Leavn/Assets.xcassets/AppIcon.appiconset/icon-1024.png"
    
    if not os.path.exists(icon_path):
        print(f"❌ Icon not found at {icon_path}")
        return
    
    # Create backup
    backup_path = icon_path + ".backup"
    if not os.path.exists(backup_path):
        os.rename(icon_path, backup_path)
        print(f"📦 Created backup at {os.path.basename(backup_path)}")
    
    # Remove alpha channel
    remove_alpha_channel(backup_path, icon_path)
    
    print("\n✨ App icon fixed! The 1024x1024 icon now has no alpha channel.")
    print("🔄 Please clean build folder (Cmd+Shift+K) and archive again.")

if __name__ == "__main__":
    main()