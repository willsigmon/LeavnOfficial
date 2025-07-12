#!/bin/bash

# Asset audit script for Unlimited Agent System
# Finds unused assets in the project

echo "🔍 ASSET AUDIT: Scanning for unused images and colors..."

# Find all asset references in Swift files
echo -e "\n📸 Collecting asset references from code..."
grep -r "Image(\"" Leavn/ --include="*.swift" | sed -n 's/.*Image("\([^"]*\)".*/\1/p' | sort | uniq > used_images.txt
grep -r "UIImage(named:" Leavn/ --include="*.swift" | sed -n 's/.*UIImage(named:[[:space:]]*"\([^"]*\)".*/\1/p' | sort | uniq >> used_images.txt
grep -r "Color(\"" Leavn/ --include="*.swift" | sed -n 's/.*Color("\([^"]*\)".*/\1/p' | sort | uniq > used_colors.txt

# Sort and deduplicate
sort used_images.txt | uniq > temp && mv temp used_images.txt
sort used_colors.txt | uniq > temp && mv temp used_colors.txt

# Find all assets in the project
echo -e "\n📦 Scanning Assets.xcassets..."
find Leavn/Resources/Assets.xcassets -name "*.imageset" -type d | sed 's/.*\/\([^/]*\)\.imageset/\1/' | sort > all_images.txt
find Leavn/Resources/Assets.xcassets -name "*.colorset" -type d | sed 's/.*\/\([^/]*\)\.colorset/\1/' | sort > all_colors.txt

# Find unused assets
echo -e "\n🚫 Unused Images:"
comm -23 all_images.txt used_images.txt

echo -e "\n🎨 Unused Colors:"
comm -23 all_colors.txt used_colors.txt

# Cleanup temp files
rm -f used_images.txt used_colors.txt all_images.txt all_colors.txt

echo -e "\n✅ Asset audit complete!"