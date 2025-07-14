#!/bin/bash

# Xcode 26 Beta Stability & Crash Fix Script
# This script addresses known issues with Xcode 26 beta that can cause SIGABRT crashes

set -e

echo "🔧 Xcode 26 Beta Stability Fix"
echo "==============================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 1. Force kill Xcode and clean state
echo -e "${BLUE}1. Cleaning Xcode state...${NC}"
killall Xcode 2>/dev/null || true
killall "Xcode Previews" 2>/dev/null || true
killall "XCBBuildService" 2>/dev/null || true
sleep 2

# 2. Clear all Xcode caches and derived data
echo -e "${BLUE}2. Clearing caches...${NC}"
rm -rf ~/Library/Developer/Xcode/DerivedData/
rm -rf ~/Library/Caches/com.apple.dt.Xcode/
rm -rf ~/Library/Developer/CoreSimulator/Caches/
rm -rf ~/Library/Developer/Xcode/iOS\ DeviceSupport/
rm -rf ~/Library/Preferences/com.apple.dt.Xcode.plist

# 3. Clear project-specific caches
echo -e "${BLUE}3. Clearing project caches...${NC}"
rm -rf .build/
rm -rf build/
find . -name "*.xcuserstate" -delete
find . -name "xcuserdata" -type d -exec rm -rf {} + 2>/dev/null || true

# 4. Check for Swift 6 concurrency issues that crash Xcode
echo -e "${BLUE}4. Checking for problematic Swift 6 patterns...${NC}"

# Check for unsafe concurrency patterns
if grep -r "@objc" Packages/ Modules/ Leavn/ 2>/dev/null | grep -q "actor\|@MainActor"; then
    echo -e "${YELLOW}⚠️  Found @objc + actor combinations that may crash Xcode beta${NC}"
fi

# Check for large SwiftUI files that crash the compiler
find . -name "*.swift" -exec wc -l {} + | awk '$1 > 1000 {print $2 " has " $1 " lines (may crash Xcode beta)"}' | head -5

# 5. Create Xcode beta-friendly build settings
echo -e "${BLUE}5. Applying Xcode beta workarounds...${NC}"

# Create a temporary xcconfig for beta stability
cat > XcodeBetaFixes.xcconfig << 'EOF'
// Xcode 26 Beta Stability Fixes

// Reduce compiler stress
SWIFT_COMPILATION_MODE = singlefile
COMPILER_INDEX_STORE_ENABLE = NO
ENABLE_PREVIEWS = NO

// Disable problematic features in beta
ENABLE_USER_SCRIPT_SANDBOXING = NO
ENABLE_TESTING_SEARCH_PATHS = NO

// Reduce memory usage
SWIFT_ENABLE_BATCH_MODE = NO
SWIFT_WHOLE_MODULE_OPTIMIZATION = NO

// Disable beta-unstable features
MTL_ENABLE_DEBUG_INFO = NO
ENABLE_BITCODE = NO
EOF

# 6. Check for known problematic configurations
echo -e "${BLUE}6. Checking configuration...${NC}"

# Check if project uses features known to crash Xcode beta
if grep -q "SWIFT_VERSION = 6.0" Configurations/Base.xcconfig; then
    echo -e "${YELLOW}⚠️  Swift 6.0 detected - known to cause Xcode beta crashes${NC}"
    echo -e "${YELLOW}   Consider temporarily downgrading to Swift 5.9 if crashes persist${NC}"
fi

if grep -q "SWIFT_STRICT_CONCURRENCY = complete" project.yml; then
    echo -e "${YELLOW}⚠️  Strict concurrency enabled - may trigger Xcode beta bugs${NC}"
    echo -e "${YELLOW}   Consider temporarily setting to 'targeted' if crashes persist${NC}"
fi

# 7. Reset Xcode preferences to defaults
echo -e "${BLUE}7. Resetting Xcode preferences...${NC}"
defaults delete com.apple.dt.Xcode 2>/dev/null || true

# 8. Create a safe launch script
echo -e "${BLUE}8. Creating safe Xcode launch script...${NC}"
cat > launch_xcode_safely.sh << 'EOF'
#!/bin/bash
# Safe Xcode launch for beta versions

echo "🚀 Launching Xcode with beta-safe settings..."

# Set environment variables for stability
export XCODE_DISABLE_AUTOMATIC_SCHEME_CREATION=1
export SWIFT_DETERMINISTIC_HASHING=1
export MALLOC_SCRIBBLE=1

# Launch with reduced functionality for stability
open -a "Xcode-beta" --args -UseModernBuildSystem=YES -DisableDocumentVersioning=YES

echo "✅ Xcode launched with stability settings"
EOF

chmod +x launch_xcode_safely.sh

# 9. Create emergency fallback build
echo -e "${BLUE}9. Creating emergency fallback build settings...${NC}"
cat > EmergencyBuild.xcconfig << 'EOF'
// Emergency fallback settings for when Xcode beta crashes

// Downgrade Swift version if needed
SWIFT_VERSION = 5.9

// Disable all beta features
SWIFT_STRICT_CONCURRENCY = minimal
ENABLE_PREVIEWS = NO
ENABLE_TESTING_SEARCH_PATHS = NO
ENABLE_USER_SCRIPT_SANDBOXING = NO

// Use legacy build system
UseModernBuildSystem = NO

// Minimal optimization to reduce compiler stress
SWIFT_OPTIMIZATION_LEVEL = -Onone
GCC_OPTIMIZATION_LEVEL = 0
EOF

# 10. Provide recovery instructions
echo -e "${GREEN}✅ Xcode Beta Fixes Applied!${NC}"
echo ""
echo -e "${YELLOW}Next Steps:${NC}"
echo "1. Use './launch_xcode_safely.sh' to start Xcode"
echo "2. If crashes persist, temporarily include 'EmergencyBuild.xcconfig' in your project"
echo "3. Consider using Xcode 15.4 stable instead of beta for critical work"
echo ""
echo -e "${YELLOW}If you still get crashes:${NC}"
echo "• File a bug report with Apple (FB number from crash)"
echo "• Use 'sudo dtruss -p [Xcode PID]' to get more debugging info"
echo "• Try building from command line: 'xcodebuild clean build'"
echo ""
echo -e "${BLUE}Generated Files:${NC}"
echo "- XcodeBetaFixes.xcconfig"
echo "- EmergencyBuild.xcconfig"
echo "- launch_xcode_safely.sh" 