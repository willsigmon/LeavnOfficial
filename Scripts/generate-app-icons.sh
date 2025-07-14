#!/bin/bash

# Simple App Icon Generation Script for Leavn
# This script generates all required app icon sizes using sips

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print functions
print_status() {
    echo -e "${GREEN}[ICON]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

# Generate a single icon using sips
generate_icon() {
    local source="$1"
    local output="$2"
    local size="$3"
    local name="$4"
    
    print_status "Generating $name (${size}x${size})"
    
    # Create output directory if it doesn't exist
    /bin/mkdir -p "$(/usr/bin/dirname "$output")"
    
    # Use sips to resize
    if /usr/bin/sips -z "$size" "$size" "$source" --out "$output" >/dev/null 2>&1; then
        print_status "✓ Generated: $output"
    else
        print_error "Failed to generate: $output"
        return 1
    fi
}

# Main execution
main() {
    echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}▶ 🎨 Leavn App Icon Generator${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    local source_icon="${1:-Resources/AppIcon-Master.png}"
    local output_dir="Resources/Assets.xcassets/AppIcon.appiconset"
    
    print_info "Source icon: $source_icon"
    print_info "Output: $output_dir"
    
    # Check if source exists
    if [ ! -f "$source_icon" ]; then
        print_error "Source icon not found: $source_icon"
        exit 1
    fi
    
    # Create output directory
    /bin/mkdir -p "$output_dir"
    
    # iOS Icons
    print_info "Generating iOS Icons..."
    generate_icon "$source_icon" "$output_dir/ios-20x20@2x.png" 40 "iOS 20x20@2x"
    generate_icon "$source_icon" "$output_dir/ios-20x20@3x.png" 60 "iOS 20x20@3x"
    generate_icon "$source_icon" "$output_dir/ios-29x29@2x.png" 58 "iOS 29x29@2x"
    generate_icon "$source_icon" "$output_dir/ios-29x29@3x.png" 87 "iOS 29x29@3x"
    generate_icon "$source_icon" "$output_dir/ios-40x40@2x.png" 80 "iOS 40x40@2x"
    generate_icon "$source_icon" "$output_dir/ios-40x40@3x.png" 120 "iOS 40x40@3x"
    generate_icon "$source_icon" "$output_dir/ios-60x60@2x.png" 120 "iOS 60x60@2x"
    generate_icon "$source_icon" "$output_dir/ios-60x60@3x.png" 180 "iOS 60x60@3x"
    generate_icon "$source_icon" "$output_dir/ios-1024x1024.png" 1024 "iOS App Store"
    
    # iPad Icons
    print_info "Generating iPad Icons..."
    generate_icon "$source_icon" "$output_dir/ipad-20x20.png" 20 "iPad 20x20"
    generate_icon "$source_icon" "$output_dir/ipad-20x20@2x.png" 40 "iPad 20x20@2x"
    generate_icon "$source_icon" "$output_dir/ipad-29x29.png" 29 "iPad 29x29"
    generate_icon "$source_icon" "$output_dir/ipad-29x29@2x.png" 58 "iPad 29x29@2x"
    generate_icon "$source_icon" "$output_dir/ipad-40x40.png" 40 "iPad 40x40"
    generate_icon "$source_icon" "$output_dir/ipad-40x40@2x.png" 80 "iPad 40x40@2x"
    generate_icon "$source_icon" "$output_dir/ipad-76x76.png" 76 "iPad 76x76"
    generate_icon "$source_icon" "$output_dir/ipad-76x76@2x.png" 152 "iPad 76x76@2x"
    generate_icon "$source_icon" "$output_dir/ipad-83.5x83.5@2x.png" 167 "iPad Pro"
    
    # macOS Icons
    print_info "Generating macOS Icons..."
    generate_icon "$source_icon" "$output_dir/macos-16x16.png" 16 "macOS 16x16"
    generate_icon "$source_icon" "$output_dir/macos-16x16@2x.png" 32 "macOS 16x16@2x"
    generate_icon "$source_icon" "$output_dir/macos-32x32.png" 32 "macOS 32x32"
    generate_icon "$source_icon" "$output_dir/macos-32x32@2x.png" 64 "macOS 32x32@2x"
    generate_icon "$source_icon" "$output_dir/macos-128x128.png" 128 "macOS 128x128"
    generate_icon "$source_icon" "$output_dir/macos-128x128@2x.png" 256 "macOS 128x128@2x"
    generate_icon "$source_icon" "$output_dir/macos-256x256.png" 256 "macOS 256x256"
    generate_icon "$source_icon" "$output_dir/macos-256x256@2x.png" 512 "macOS 256x256@2x"
    generate_icon "$source_icon" "$output_dir/macos-512x512.png" 512 "macOS 512x512"
    generate_icon "$source_icon" "$output_dir/macos-512x512@2x.png" 1024 "macOS 512x512@2x"
    
    # watchOS Icons
    print_info "Generating watchOS Icons..."
    generate_icon "$source_icon" "$output_dir/watch-24x24@2x.png" 48 "watchOS 24x24@2x"
    generate_icon "$source_icon" "$output_dir/watch-27.5x27.5@2x.png" 55 "watchOS 27.5x27.5@2x"
    generate_icon "$source_icon" "$output_dir/watch-29x29@2x.png" 58 "watchOS 29x29@2x"
    generate_icon "$source_icon" "$output_dir/watch-29x29@3x.png" 87 "watchOS 29x29@3x"
    generate_icon "$source_icon" "$output_dir/watch-40x40@2x.png" 80 "watchOS 40x40@2x"
    generate_icon "$source_icon" "$output_dir/watch-44x44@2x.png" 88 "watchOS 44x44@2x"
    generate_icon "$source_icon" "$output_dir/watch-50x50@2x.png" 100 "watchOS 50x50@2x"
    generate_icon "$source_icon" "$output_dir/watch-86x86@2x.png" 172 "watchOS 86x86@2x"
    generate_icon "$source_icon" "$output_dir/watch-98x98@2x.png" 196 "watchOS 98x98@2x"
    generate_icon "$source_icon" "$output_dir/watch-108x108@2x.png" 216 "watchOS 108x108@2x"
    generate_icon "$source_icon" "$output_dir/watch-1024x1024.png" 1024 "watchOS App Store"
    
    # visionOS Icons
    print_info "Generating visionOS Icons..."
    generate_icon "$source_icon" "$output_dir/vision-512x512@2x.png" 1024 "visionOS 512x512@2x"
    
    # Count generated icons
    local icon_count=$(/bin/ls -1 "$output_dir"/*.png 2>/dev/null | /usr/bin/wc -l | /usr/bin/tr -d ' ')
    
    echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}▶ 📋 Summary${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    print_status "Total icons generated: $icon_count"
    
    if [ "$icon_count" -gt 0 ]; then
        print_status "✅ Icon generation completed successfully"
        
        echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${BLUE}▶ 📋 Next Steps${NC}"
        echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        print_info "1. Update Contents.json with proper filename mappings"
        print_info "2. Test icons in Xcode simulator"
        print_info "3. Validate icons for App Store submission"
    else
        print_error "❌ No icons were generated"
    fi
}

# Run the generator
main "$@"