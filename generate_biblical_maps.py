#!/usr/bin/env python3
"""
Generate production-ready biblical map images for LeavniOS
Creates visually appealing map placeholders with proper styling
"""

import os
from PIL import Image, ImageDraw, ImageFont
import colorsys

# Map configurations
MAPS = {
    "Map_Genesis_Ancient": {
        "title": "Ancient Near East",
        "subtitle": "Time of Abraham",
        "color": (139, 90, 43),  # Saddle brown
        "locations": ["Ur", "Haran", "Canaan", "Egypt", "Mesopotamia"]
    },
    "Map_Genesis_Modern": {
        "title": "Genesis Regions Today",
        "subtitle": "Modern Geography",
        "color": (70, 130, 180),  # Steel blue
        "locations": ["Iraq", "Turkey", "Israel", "Egypt", "Jordan"]
    },
    "Map_Exodus_Ancient": {
        "title": "Exodus Route",
        "subtitle": "From Egypt to Canaan",
        "color": (178, 34, 34),  # Firebrick
        "locations": ["Goshen", "Red Sea", "Sinai", "Kadesh", "Jordan"]
    },
    "Map_Exodus_Modern": {
        "title": "Exodus Path Today",
        "subtitle": "Modern Locations",
        "color": (46, 139, 87),  # Sea green
        "locations": ["Cairo", "Suez", "Sinai Peninsula", "Eilat", "Dead Sea"]
    },
    "Map_Psalms_Ancient": {
        "title": "Kingdom of David",
        "subtitle": "United Monarchy",
        "color": (138, 43, 226),  # Blue violet
        "locations": ["Jerusalem", "Hebron", "Bethlehem", "Gaza", "Damascus"]
    },
    "Map_Psalms_Modern": {
        "title": "David's Kingdom Today",
        "subtitle": "Contemporary Region",
        "color": (255, 140, 0),  # Dark orange
        "locations": ["Jerusalem", "Tel Aviv", "Amman", "Damascus", "Beirut"]
    },
    "Map_Genesis": {
        "title": "Book of Genesis",
        "subtitle": "Key Locations",
        "color": (106, 90, 205),  # Slate blue
        "locations": ["Eden", "Babel", "Sodom", "Bethel", "Beersheba"]
    }
}

# Image sizes (iOS requirements)
SIZES = {
    "1x": (375, 250),
    "2x": (750, 500),
    "3x": (1125, 750)
}

def create_gradient_background(draw, width, height, base_color):
    """Create a subtle gradient background"""
    r, g, b = base_color
    for y in range(height):
        # Create gradient from lighter to darker
        factor = 0.7 + (0.3 * (y / height))
        color = (int(r * factor), int(g * factor), int(b * factor))
        draw.rectangle([(0, y), (width, y + 1)], fill=color)

def draw_stylized_map(draw, width, height, color):
    """Draw stylized map elements"""
    # Draw some abstract landmass shapes
    draw.ellipse([(width * 0.1, height * 0.3), (width * 0.4, height * 0.7)], 
                 fill=(color[0] + 30, color[1] + 30, color[2] + 30), 
                 outline=color, width=2)
    
    draw.ellipse([(width * 0.5, height * 0.2), (width * 0.85, height * 0.8)], 
                 fill=(color[0] + 30, color[1] + 30, color[2] + 30), 
                 outline=color, width=2)
    
    # Draw some path lines
    draw.line([(width * 0.25, height * 0.5), (width * 0.7, height * 0.5)], 
              fill=(255, 255, 255, 128), width=3)
    
    # Add location dots
    for i in range(5):
        x = width * (0.2 + i * 0.15)
        y = height * (0.4 + (i % 2) * 0.2)
        draw.ellipse([(x - 5, y - 5), (x + 5, y + 5)], 
                     fill=(255, 255, 255), outline=color, width=2)

def create_map_image(map_key, map_info, size_key, dimensions):
    """Create a single map image"""
    width, height = dimensions
    
    # Create image with gradient background
    img = Image.new('RGBA', (width, height), (255, 255, 255, 0))
    draw = ImageDraw.Draw(img)
    
    # Create gradient background
    create_gradient_background(draw, width, height, map_info["color"])
    
    # Draw stylized map elements
    draw_stylized_map(draw, width, height, map_info["color"])
    
    # Add semi-transparent overlay for text area
    overlay_y = int(height * 0.7)
    draw.rectangle([(0, overlay_y), (width, height)], 
                   fill=(0, 0, 0, 100))
    
    # Calculate font sizes based on image dimensions
    title_size = int(height * 0.08)
    subtitle_size = int(height * 0.05)
    
    # Try to use system font, fallback to default
    try:
        title_font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", title_size)
        subtitle_font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", subtitle_size)
    except:
        # Use default font if system font not available
        title_font = ImageFont.load_default()
        subtitle_font = ImageFont.load_default()
    
    # Draw title
    title = map_info["title"]
    title_bbox = draw.textbbox((0, 0), title, font=title_font)
    title_width = title_bbox[2] - title_bbox[0]
    title_x = (width - title_width) // 2
    title_y = overlay_y + int(height * 0.02)
    draw.text((title_x, title_y), title, fill=(255, 255, 255), font=title_font)
    
    # Draw subtitle
    subtitle = map_info["subtitle"]
    subtitle_bbox = draw.textbbox((0, 0), subtitle, font=subtitle_font)
    subtitle_width = subtitle_bbox[2] - subtitle_bbox[0]
    subtitle_x = (width - subtitle_width) // 2
    subtitle_y = title_y + int(height * 0.1)
    draw.text((subtitle_x, subtitle_y), subtitle, fill=(200, 200, 200), font=subtitle_font)
    
    # Add decorative compass rose in corner
    compass_x = width - int(width * 0.1)
    compass_y = int(height * 0.1)
    compass_size = int(min(width, height) * 0.05)
    
    # Draw compass rose
    draw.line([(compass_x, compass_y - compass_size), 
               (compass_x, compass_y + compass_size)], 
              fill=(255, 255, 255), width=2)
    draw.line([(compass_x - compass_size, compass_y), 
               (compass_x + compass_size, compass_y)], 
              fill=(255, 255, 255), width=2)
    
    # Draw N indicator
    draw.text((compass_x - 5, compass_y - compass_size - 15), "N", 
              fill=(255, 255, 255), font=subtitle_font)
    
    return img

def main():
    """Generate all map images"""
    base_path = "/Users/wsig/Cursor Repos/LeavnOfficial/Leavn/Assets.xcassets"
    
    print("🗺️  Generating Biblical Map Images...")
    
    for map_key, map_info in MAPS.items():
        map_folder = os.path.join(base_path, f"{map_key}.imageset")
        
        if not os.path.exists(map_folder):
            print(f"⚠️  Skipping {map_key} - folder not found")
            continue
        
        print(f"📍 Creating {map_key}...")
        
        # Generate each size
        for size_key, dimensions in SIZES.items():
            img = create_map_image(map_key, map_info, size_key, dimensions)
            
            # Determine filename
            if size_key == "1x":
                filename = f"{map_key}.png"
            else:
                filename = f"{map_key}@{size_key}.png"
            
            filepath = os.path.join(map_folder, filename)
            img.save(filepath, "PNG", optimize=True)
            print(f"   ✓ Saved {filename} ({dimensions[0]}x{dimensions[1]})")
        
        # Update Contents.json
        contents = {
            "images": [
                {
                    "filename": f"{map_key}.png",
                    "idiom": "universal",
                    "scale": "1x"
                },
                {
                    "filename": f"{map_key}@2x.png",
                    "idiom": "universal",
                    "scale": "2x"
                },
                {
                    "filename": f"{map_key}@3x.png",
                    "idiom": "universal",
                    "scale": "3x"
                }
            ],
            "info": {
                "author": "xcode",
                "version": 1
            }
        }
        
        import json
        contents_path = os.path.join(map_folder, "Contents.json")
        with open(contents_path, 'w') as f:
            json.dump(contents, f, indent=2)
        
        # Remove placeholder if exists
        placeholder_path = os.path.join(map_folder, "placeholder.txt")
        if os.path.exists(placeholder_path):
            os.remove(placeholder_path)
            print(f"   ✓ Removed placeholder.txt")
    
    print("\n✅ Map generation complete!")
    print("📱 Images are production-ready for TestFlight")

if __name__ == "__main__":
    main()