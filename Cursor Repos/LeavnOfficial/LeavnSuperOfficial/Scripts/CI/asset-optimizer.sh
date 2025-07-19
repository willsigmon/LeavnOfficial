#!/bin/bash
# Asset Optimizer for LeavnSuperOfficial

set -e

# Configuration
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
ASSETS_DIR="$PROJECT_DIR/LeavnSuperOfficial/Assets.xcassets"
MAX_SIZE_KB=100

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Check dependencies
check_dependencies() {
    local deps=("pngquant" "jpegoptim" "svgo")
    local missing=()
    
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            missing+=("$dep")
        fi
    done
    
    if [ ${#missing[@]} -ne 0 ]; then
        echo -e "${RED}Missing dependencies: ${missing[*]}${NC}"
        echo "Install with: brew install ${missing[*]}"
        exit 1
    fi
}

# Optimize PNG files
optimize_png() {
    local file="$1"
    local original_size=$(stat -f%z "$file")
    
    # Run pngquant
    pngquant --force --quality=65-80 --skip-if-larger --strip --output "$file" -- "$file"
    
    local new_size=$(stat -f%z "$file")
    local saved=$((original_size - new_size))
    
    if [ $saved -gt 0 ]; then
        echo -e "${GREEN}✓ Optimized: $(basename "$file") (saved $(numfmt --to=iec $saved))${NC}"
    fi
}

# Optimize JPEG files
optimize_jpeg() {
    local file="$1"
    local original_size=$(stat -f%z "$file")
    
    # Run jpegoptim
    jpegoptim --quiet --strip-all --max=80 "$file"
    
    local new_size=$(stat -f%z "$file")
    local saved=$((original_size - new_size))
    
    if [ $saved -gt 0 ]; then
        echo -e "${GREEN}✓ Optimized: $(basename "$file") (saved $(numfmt --to=iec $saved))${NC}"
    fi
}

# Check for large assets
check_large_assets() {
    echo -e "${YELLOW}Checking for large assets...${NC}"
    
    find "$ASSETS_DIR" -type f \( -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" \) | while read -r file; do
        size_kb=$(($(stat -f%z "$file") / 1024))
        if [ $size_kb -gt $MAX_SIZE_KB ]; then
            echo -e "${RED}⚠ Large asset: $(basename "$file") (${size_kb}KB)${NC}"
        fi
    done
}

# Validate asset catalog
validate_assets() {
    echo -e "${YELLOW}Validating asset catalog...${NC}"
    
    # Check for missing Contents.json
    find "$ASSETS_DIR" -type d -name "*.imageset" -o -name "*.colorset" | while read -r dir; do
        if [ ! -f "$dir/Contents.json" ]; then
            echo -e "${RED}✗ Missing Contents.json in: $(basename "$dir")${NC}"
        fi
    done
    
    # Check for @2x and @3x versions
    find "$ASSETS_DIR" -name "*.imageset" -type d | while read -r imageset; do
        if [ -f "$imageset/Contents.json" ]; then
            # Simple check for scale factors
            if ! grep -q '"scale" : "2x"' "$imageset/Contents.json"; then
                echo -e "${YELLOW}⚠ Missing @2x variant in: $(basename "$imageset")${NC}"
            fi
            if ! grep -q '"scale" : "3x"' "$imageset/Contents.json"; then
                echo -e "${YELLOW}⚠ Missing @3x variant in: $(basename "$imageset")${NC}"
            fi
        fi
    done
}

# Generate missing app icon sizes
generate_app_icons() {
    local source_icon="$ASSETS_DIR/AppIcon.appiconset/App-Icon-1024x1024@1x.png"
    
    if [ ! -f "$source_icon" ]; then
        echo -e "${RED}Source app icon not found: $source_icon${NC}"
        return
    fi
    
    echo -e "${YELLOW}Generating app icon sizes...${NC}"
    
    # Define required sizes
    local sizes=(
        "20:1,2,3"
        "29:1,2,3"
        "40:1,2,3"
        "60:2,3"
        "76:1,2"
        "83.5:2"
    )
    
    for size_spec in "${sizes[@]}"; do
        IFS=':' read -r size scales <<< "$size_spec"
        IFS=',' read -ra scale_array <<< "$scales"
        
        for scale in "${scale_array[@]}"; do
            local filename="App-Icon-${size}x${size}@${scale}x.png"
            local output="$ASSETS_DIR/AppIcon.appiconset/$filename"
            
            if [ ! -f "$output" ]; then
                local pixel_size=$(echo "$size * $scale" | bc)
                sips -z $pixel_size $pixel_size "$source_icon" --out "$output" &>/dev/null
                echo -e "${GREEN}✓ Generated: $filename${NC}"
            fi
        done
    done
}

# Main function
main() {
    echo -e "${YELLOW}🎨 Asset Optimization for LeavnSuperOfficial${NC}"
    echo "================================================"
    
    # Check dependencies
    check_dependencies
    
    # Validate assets
    validate_assets
    
    # Check for large assets
    check_large_assets
    
    # Optimize assets
    echo -e "${YELLOW}Optimizing assets...${NC}"
    
    local total_saved=0
    
    # Optimize PNG files
    find "$ASSETS_DIR" -name "*.png" -type f | while read -r file; do
        optimize_png "$file"
    done
    
    # Optimize JPEG files
    find "$ASSETS_DIR" -name "*.jpg" -o -name "*.jpeg" -type f | while read -r file; do
        optimize_jpeg "$file"
    done
    
    echo -e "${GREEN}✅ Asset optimization complete!${NC}"
}

# Parse arguments
case "${1:-optimize}" in
    optimize)
        main
        ;;
    validate)
        validate_assets
        ;;
    icons)
        generate_app_icons
        ;;
    *)
        echo "Usage: $0 [optimize|validate|icons]"
        exit 1
        ;;
esac