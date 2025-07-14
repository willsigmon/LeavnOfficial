#!/bin/bash

# App Icon Generation Script for Leavn
# This script helps generate all required app icon sizes

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print functions
print_section() {
    echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}▶ $1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

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

# Icon size definitions for all platforms
declare -A IOS_SIZES=(
    ["20x20@2x"]="40"
    ["20x20@3x"]="60"
    ["29x29@2x"]="58"
    ["29x29@3x"]="87"
    ["40x40@2x"]="80"
    ["40x40@3x"]="120"
    ["60x60@2x"]="120"
    ["60x60@3x"]="180"
    ["1024x1024"]="1024"
)

declare -A MACOS_SIZES=(
    ["16x16"]="16"
    ["16x16@2x"]="32"
    ["32x32"]="32"
    ["32x32@2x"]="64"
    ["128x128"]="128"
    ["128x128@2x"]="256"
    ["256x256"]="256"
    ["256x256@2x"]="512"
    ["512x512"]="512"
    ["512x512@2x"]="1024"
)

declare -A WATCH_SIZES=(
    ["24x24@2x"]="48"
    ["27.5x27.5@2x"]="55"
    ["29x29@2x"]="58"
    ["29x29@3x"]="87"
    ["40x40@2x"]="80"
    ["44x44@2x"]="88"
    ["50x50@2x"]="100"
    ["86x86@2x"]="172"
    ["98x98@2x"]="196"
    ["108x108@2x"]="216"
    ["1024x1024"]="1024"
)

declare -A VISION_SIZES=(
    ["512x512@2x"]="1024"
)

# Check if source icon exists
check_source_icon() {
    local source_icon="$1"
    
    if [ ! -f "$source_icon" ]; then
        print_error "Source icon not found: $source_icon"
        print_info "Place your master icon (1024x1024 PNG) at: $source_icon"
        return 1
    fi
    
    # Check if it's actually an image (basic check)
    if ! file "$source_icon" | grep -q "image"; then
        print_error "Source file is not a valid image: $source_icon"
        return 1
    fi
    
    print_status "✓ Source icon found: $source_icon"
    return 0
}

# Generate icons using sips (macOS built-in)
generate_icon_sips() {
    local source="$1"
    local output="$2"
    local size="$3"
    
    if command -v sips >/dev/null 2>&1; then
        sips -z "$size" "$size" "$source" --out "$output" >/dev/null 2>&1
        return $?
    else
        return 1
    fi
}

# Generate icons using ImageMagick (if available)
generate_icon_imagemagick() {
    local source="$1"
    local output="$2"
    local size="$3"
    
    if command -v convert >/dev/null 2>&1; then
        convert "$source" -resize "${size}x${size}" "$output" >/dev/null 2>&1
        return $?
    else
        return 1
    fi
}

# Generate a single icon
generate_single_icon() {
    local source="$1"
    local output="$2"
    local size="$3"
    local name="$4"
    
    print_status "Generating $name (${size}x${size})"
    
    # Create output directory if it doesn't exist
    mkdir -p "$(dirname "$output")"
    
    # Try sips first (native macOS), then ImageMagick
    if generate_icon_sips "$source" "$output" "$size"; then
        print_status "✓ Generated: $output"
    elif generate_icon_imagemagick "$source" "$output" "$size"; then
        print_status "✓ Generated: $output"
    else
        print_error "Failed to generate: $output"
        print_info "Install ImageMagick: brew install imagemagick"
        return 1
    fi
}

# Generate iOS icons
generate_ios_icons() {
    local source="$1"
    local output_dir="Resources/Assets.xcassets/AppIcon.appiconset"
    
    print_section "Generating iOS Icons"
    
    for key in "${!IOS_SIZES[@]}"; do
        local size="${IOS_SIZES[$key]}"
        local filename="ios-${key}.png"
        local output="$output_dir/$filename"
        
        generate_single_icon "$source" "$output" "$size" "iOS $key"
    done
}

# Generate macOS icons
generate_macos_icons() {
    local source="$1"
    local output_dir="Resources/Assets.xcassets/AppIcon.appiconset"
    
    print_section "Generating macOS Icons"
    
    for key in "${!MACOS_SIZES[@]}"; do
        local size="${MACOS_SIZES[$key]}"
        local filename="macos-${key}.png"
        local output="$output_dir/$filename"
        
        generate_single_icon "$source" "$output" "$size" "macOS $key"
    done
}

# Generate watchOS icons
generate_watch_icons() {
    local source="$1"
    local output_dir="Resources/Assets.xcassets/AppIcon.appiconset"
    
    print_section "Generating watchOS Icons"
    
    for key in "${!WATCH_SIZES[@]}"; do
        local size="${WATCH_SIZES[$key]}"
        local filename="watch-${key}.png"
        local output="$output_dir/$filename"
        
        generate_single_icon "$source" "$output" "$size" "watchOS $key"
    done
}

# Generate visionOS icons
generate_vision_icons() {
    local source="$1"
    local output_dir="Resources/Assets.xcassets/AppIcon.appiconset"
    
    print_section "Generating visionOS Icons"
    
    for key in "${!VISION_SIZES[@]}"; do
        local size="${VISION_SIZES[$key]}"
        local filename="vision-${key}.png"
        local output="$output_dir/$filename"
        
        generate_single_icon "$source" "$output" "$size" "visionOS $key"
    done
}

# Update Contents.json with generated filenames
update_contents_json() {
    local contents_file="Resources/Assets.xcassets/AppIcon.appiconset/Contents.json"
    
    print_section "Updating Contents.json"
    
    # Backup original
    if [ -f "$contents_file" ]; then
        cp "$contents_file" "$contents_file.backup"
        print_status "✓ Backed up existing Contents.json"
    fi
    
    # This is a placeholder - in practice, you'd want to programmatically update
    # the JSON to include the actual filenames
    print_warning "⚠️  Contents.json update requires manual adjustment"
    print_info "Add filename properties to the images array in $contents_file"
}

# Create placeholder icons (for development)
create_placeholder_icons() {
    print_section "Creating Placeholder Icons"
    
    local output_dir="Resources/Assets.xcassets/AppIcon.appiconset"
    
    # Create a simple placeholder using sips if no source icon available
    if command -v sips >/dev/null 2>&1; then
        # Create a 1024x1024 colored rectangle as placeholder
        local temp_icon="/tmp/leavn_placeholder.png"
        
        # Use osascript to create a simple colored image
        osascript << EOF
tell application "Image Events"
    launch
    set newImage to make new image with properties {dimensions:{1024, 1024}}
    save newImage in file "$temp_icon" as PNG
end tell
EOF

        if [ -f "$temp_icon" ]; then
            print_status "✓ Created placeholder base icon"
            
            # Generate all sizes from placeholder
            generate_ios_icons "$temp_icon"
            generate_macos_icons "$temp_icon"
            generate_watch_icons "$temp_icon"
            generate_vision_icons "$temp_icon"
            
            # Clean up
            rm -f "$temp_icon"
        else
            print_error "Failed to create placeholder icon"
        fi
    else
        print_error "Cannot create placeholder icons - sips not available"
    fi
}

# Validate generated icons
validate_icons() {
    print_section "Validating Generated Icons"
    
    local output_dir="Resources/Assets.xcassets/AppIcon.appiconset"
    local icon_count=0
    
    for file in "$output_dir"/*.png; do
        if [ -f "$file" ]; then
            ((icon_count++))
            local size=$(file "$file" | grep -o '[0-9]\+x[0-9]\+' | head -1)
            print_status "✓ Found icon: $(basename "$file") [$size]"
        fi
    done
    
    print_status "Total icons generated: $icon_count"
    
    if [ "$icon_count" -gt 0 ]; then
        print_status "✅ Icon generation completed successfully"
    else
        print_error "❌ No icons were generated"
    fi
}

# Main execution
main() {
    print_section "🎨 Leavn App Icon Generator"
    
    local source_icon="${1:-Resources/AppIcon-Master.png}"
    
    print_info "Source icon: $source_icon"
    print_info "Output: Resources/Assets.xcassets/AppIcon.appiconset/"
    
    if check_source_icon "$source_icon"; then
        # Generate from source icon
        generate_ios_icons "$source_icon"
        generate_macos_icons "$source_icon"
        generate_watch_icons "$source_icon"
        generate_vision_icons "$source_icon"
        update_contents_json
    else
        # Create placeholders for development
        print_warning "No source icon found - creating development placeholders"
        create_placeholder_icons
    fi
    
    validate_icons
    
    print_section "📋 Next Steps"
    print_info "1. Replace placeholder with actual app icon design"
    print_info "2. Update Contents.json with proper filename mappings"
    print_info "3. Test icons in Xcode simulator"
    print_info "4. Validate icons for App Store submission"
}

# Usage information
show_usage() {
    echo "App Icon Generator for Leavn"
    echo ""
    echo "Usage:"
    echo "  $0 [source_icon.png]"
    echo ""
    echo "Examples:"
    echo "  $0                              # Use default Resources/AppIcon-Master.png"
    echo "  $0 my-icon.png                  # Use custom source icon"
    echo ""
    echo "Requirements:"
    echo "  - Source icon should be 1024x1024 PNG"
    echo "  - macOS with sips, or ImageMagick installed"
    echo ""
    echo "Generated icons will be placed in:"
    echo "  Resources/Assets.xcassets/AppIcon.appiconset/"
}

# Handle command line arguments
if [ "${1:-}" = "--help" ] || [ "${1:-}" = "-h" ]; then
    show_usage
    exit 0
fi

# Run the generator
main "$@"