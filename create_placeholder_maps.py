#!/usr/bin/env python3

import os
from PIL import Image, ImageDraw, ImageFont

# Create placeholder map images
map_sets = [
    "Map_Exodus_Ancient",
    "Map_Exodus_Modern", 
    "Map_Genesis",
    "Map_Genesis_Ancient",
    "Map_Genesis_Modern",
    "Map_Psalms_Ancient",
    "Map_Psalms_Modern"
]

base_path = "Leavn/Assets.xcassets"

for map_name in map_sets:
    folder_path = os.path.join(base_path, f"{map_name}.imageset")
    
    # Create images at different scales
    sizes = [(100, 100), (200, 200), (300, 300)]
    filenames = [f"{map_name}.png", f"{map_name}@2x.png", f"{map_name}@3x.png"]
    
    for size, filename in zip(sizes, filenames):
        # Create a simple placeholder image
        img = Image.new('RGB', size, color='#F0F0F0')
        draw = ImageDraw.Draw(img)
        
        # Draw a border
        draw.rectangle([0, 0, size[0]-1, size[1]-1], outline='#CCCCCC', width=2)
        
        # Add text
        text = map_name.replace('_', '\n').replace('Map\n', '')
        try:
            font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", size=int(size[0]/10))
        except:
            font = None
        
        # Calculate text position
        if font:
            bbox = draw.textbbox((0, 0), text, font=font)
            text_width = bbox[2] - bbox[0]
            text_height = bbox[3] - bbox[1]
        else:
            text_width = len(text) * 6
            text_height = 10
            
        x = (size[0] - text_width) // 2
        y = (size[1] - text_height) // 2
        
        draw.text((x, y), text, fill='#666666', font=font)
        
        # Save the image
        filepath = os.path.join(folder_path, filename)
        img.save(filepath)
        print(f"Created: {filepath}")

print("\nPlaceholder images created successfully!")
print("Now clean and rebuild in Xcode.")