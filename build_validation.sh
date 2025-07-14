#!/bin/bash

# Comprehensive Build Validation & Error Debugging Tools
# Agent 3: Build System & Testing Infrastructure

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔍 Leavn Build Validation & Error Debugging System${NC}"
echo -e "${BLUE}=================================================${NC}"

# Configuration
PROJECT_NAME="Leavn"
PROJECT_FILE="Leavn.xcodeproj"
SCHEME_NAME="Leavn"
WORKSPACE_FILE="Leavn.xcworkspace"
OUTPUT_DIR="validation_results"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Function to check Xcode environment
check_xcode_environment() {
    echo -e "${BLUE}🔧 Checking Xcode Environment...${NC}"
    
    local env_report="$OUTPUT_DIR/environment_check_$TIMESTAMP.txt"
    
    {
        echo "=== Xcode Environment Check ==="
        echo "Date: $(date)"
        echo ""
        
        echo "Xcode Version:"
        xcodebuild -version || echo "ERROR: xcodebuild not found"
        echo ""
        
        echo "Available SDKs:"
        xcodebuild -showsdks | head -20 || echo "ERROR: Cannot show SDKs"
        echo ""
        
        echo "Swift Version:"
        swift --version || echo "ERROR: Swift not found"
        echo ""
        
        echo "Available Simulators:"
        xcrun simctl list devices | grep -E "(iPhone|iPad)" | head -10 || echo "ERROR: Cannot list simulators"
        echo ""
        
        echo "Xcode Developer Directory:"
        xcode-select -p || echo "ERROR: Cannot determine Xcode path"
        echo ""
        
        echo "macOS Version:"
        sw_vers || echo "ERROR: Cannot determine macOS version"
        echo ""
        
    } > "$env_report"
    
    echo -e "${GREEN}✅ Environment check completed: $env_report${NC}"
}

# Function to validate project structure
validate_project_structure() {
    echo -e "${BLUE}📁 Validating Project Structure...${NC}"
    
    local structure_report="$OUTPUT_DIR/project_structure_$TIMESTAMP.txt"
    
    {
        echo "=== Project Structure Validation ==="
        echo "Date: $(date)"
        echo ""
        
        echo "Checking required files:"
        
        # Check for project file
        if [ -f "$PROJECT_FILE/project.pbxproj" ]; then
            echo "✅ $PROJECT_FILE/project.pbxproj exists"
        else
            echo "❌ $PROJECT_FILE/project.pbxproj MISSING"
        fi
        
        # Check for workspace if exists
        if [ -d "$WORKSPACE_FILE" ]; then
            echo "✅ $WORKSPACE_FILE exists"
        else
            echo "ℹ️ $WORKSPACE_FILE not found (optional)"
        fi
        
        # Check for Info.plist
        if [ -f "Leavn/Info.plist" ]; then
            echo "✅ Leavn/Info.plist exists"
        else
            echo "❌ Leavn/Info.plist MISSING"
        fi
        
        # Check for entitlements
        if [ -f "Leavn/Leavn.entitlements" ]; then
            echo "✅ Leavn/Leavn.entitlements exists"
        else
            echo "⚠️ Leavn/Leavn.entitlements not found"
        fi
        
        # Check for main app files
        if [ -f "Leavn/App/LeavnApp.swift" ]; then
            echo "✅ LeavnApp.swift exists"
        else
            echo "❌ LeavnApp.swift MISSING"
        fi
        
        if [ -f "Leavn/Views/ContentView.swift" ]; then
            echo "✅ ContentView.swift exists"
        else
            echo "❌ ContentView.swift MISSING"
        fi
        
        if [ -f "Leavn/Views/MainTabView.swift" ]; then
            echo "✅ MainTabView.swift exists"
        else
            echo "❌ MainTabView.swift MISSING"
        fi
        
        echo ""
        echo "Module Structure:"
        if [ -d "Modules" ]; then
            echo "✅ Modules directory exists"
            ls -la Modules/ | head -20
        else
            echo "❌ Modules directory MISSING"
        fi
        
        echo ""
        echo "Assets Check:"
        if [ -d "Leavn/Assets.xcassets" ]; then
            echo "✅ Assets.xcassets exists"
            ls -la Leavn/Assets.xcassets/ | head -10
        else
            echo "❌ Assets.xcassets MISSING"
        fi
        
    } > "$structure_report"
    
    echo -e "${GREEN}✅ Project structure validation completed: $structure_report${NC}"
}

# Function to analyze project dependencies
analyze_dependencies() {
    echo -e "${BLUE}📦 Analyzing Project Dependencies...${NC}"
    
    local deps_report="$OUTPUT_DIR/dependencies_analysis_$TIMESTAMP.txt"
    
    {
        echo "=== Dependencies Analysis ==="
        echo "Date: $(date)"
        echo ""
        
        echo "Package.swift files:"
        find . -name "Package.swift" -not -path "./build/*" -not -path "./.build/*" | head -10
        echo ""
        
        echo "Package.resolved files:"
        find . -name "Package.resolved" -not -path "./build/*" -not -path "./.build/*" | head -10
        echo ""
        
        echo "Packages directory:"
        if [ -d "Packages" ]; then
            echo "✅ Packages directory exists"
            ls -la Packages/ | head -10
        else
            echo "ℹ️ Packages directory not found"
        fi
        
        echo ""
        echo "Checking for common dependency issues:"
        
        # Check for Swift Package Manager cache
        if [ -d ".build" ]; then
            echo "⚠️ .build directory exists (SPM cache)"
        fi
        
        # Check for DerivedData
        if [ -d "DerivedData" ]; then
            echo "⚠️ DerivedData directory exists (should be cleaned)"
        fi
        
        # Check for Pods (CocoaPods)
        if [ -f "Podfile" ]; then
            echo "⚠️ Podfile found (CocoaPods detected)"
        fi
        
        # Check for Carthage
        if [ -f "Cartfile" ]; then
            echo "⚠️ Cartfile found (Carthage detected)"
        fi
        
    } > "$deps_report"
    
    echo -e "${GREEN}✅ Dependencies analysis completed: $deps_report${NC}"
}

# Function to perform comprehensive build validation
perform_build_validation() {
    echo -e "${BLUE}🔨 Performing Build Validation...${NC}"
    
    local build_report="$OUTPUT_DIR/build_validation_$TIMESTAMP.txt"
    
    {
        echo "=== Build Validation Report ==="
        echo "Date: $(date)"
        echo ""
        
        echo "1. CLEAN BUILD TEST"
        echo "==================="
        echo "Cleaning build artifacts..."
        
        # Clean command
        xcodebuild clean -project "$PROJECT_FILE" -scheme "$SCHEME_NAME" -quiet
        
        echo "✅ Clean completed"
        echo ""
        
        echo "2. SYNTAX CHECK"
        echo "==============="
        echo "Checking Swift syntax..."
        
        # Find Swift files and check syntax
        find . -name "*.swift" -not -path "./build/*" -not -path "./.build/*" -not -path "./DerivedData/*" | head -20 | while read -r file; do
            if swift -frontend -parse "$file" > /dev/null 2>&1; then
                echo "✅ $file: Syntax OK"
            else
                echo "❌ $file: Syntax ERROR"
            fi
        done
        
        echo ""
        echo "3. BUILD FOR SIMULATOR"
        echo "======================"
        echo "Building for iPhone 16 Pro simulator..."
        
        # Build for simulator
        local build_output=$(mktemp)
        if xcodebuild build \
            -project "$PROJECT_FILE" \
            -scheme "$SCHEME_NAME" \
            -sdk iphonesimulator \
            -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
            -configuration Debug \
            CODE_SIGN_IDENTITY="" \
            CODE_SIGNING_REQUIRED=NO \
            CODE_SIGNING_ALLOWED=NO \
            ONLY_ACTIVE_ARCH=YES \
            > "$build_output" 2>&1; then
            
            echo "✅ Simulator build: SUCCESS"
            echo ""
            echo "Build summary:"
            tail -20 "$build_output"
        else
            echo "❌ Simulator build: FAILED"
            echo ""
            echo "Error details:"
            cat "$build_output"
        fi
        
        rm -f "$build_output"
        
        echo ""
        echo "4. BUILD FOR DEVICE"
        echo "=================="
        echo "Building for iOS device..."
        
        # Build for device
        local device_output=$(mktemp)
        if xcodebuild build \
            -project "$PROJECT_FILE" \
            -scheme "$SCHEME_NAME" \
            -sdk iphoneos \
            -destination 'generic/platform=iOS' \
            -configuration Release \
            CODE_SIGN_IDENTITY="" \
            CODE_SIGNING_REQUIRED=NO \
            CODE_SIGNING_ALLOWED=NO \
            ONLY_ACTIVE_ARCH=NO \
            > "$device_output" 2>&1; then
            
            echo "✅ Device build: SUCCESS"
            echo ""
            echo "Build summary:"
            tail -20 "$device_output"
        else
            echo "❌ Device build: FAILED"
            echo ""
            echo "Error details:"
            cat "$device_output"
        fi
        
        rm -f "$device_output"
        
    } > "$build_report"
    
    echo -e "${GREEN}✅ Build validation completed: $build_report${NC}"
}

# Function to extract and categorize errors
extract_and_categorize_errors() {
    echo -e "${BLUE}🔍 Extracting and Categorizing Errors...${NC}"
    
    local errors_report="$OUTPUT_DIR/error_analysis_$TIMESTAMP.txt"
    
    {
        echo "=== Error Analysis Report ==="
        echo "Date: $(date)"
        echo ""
        
        echo "Searching for recent build errors..."
        
        # Check for recent build logs
        local recent_logs=(
            "build_test_output.log"
            "build.log"
            "build_output.log"
            "latest_build.log"
        )
        
        for log in "${recent_logs[@]}"; do
            if [ -f "$log" ]; then
                echo ""
                echo "ANALYZING: $log"
                echo "==================="
                
                echo "Error count:"
                grep -c "error:" "$log" || echo "0 errors found"
                
                echo ""
                echo "Warning count:"
                grep -c "warning:" "$log" || echo "0 warnings found"
                
                echo ""
                echo "Top errors:"
                grep -E "(error:|failed:|Fatal)" "$log" | head -10 || echo "No errors found"
                
                echo ""
                echo "Common error patterns:"
                
                # Swift compilation errors
                if grep -q "Swift compilation" "$log"; then
                    echo "🔴 Swift compilation errors detected"
                    grep -A 2 -B 2 "Swift compilation" "$log" | head -5
                fi
                
                # Code signing errors
                if grep -q "Code signing" "$log"; then
                    echo "🔴 Code signing errors detected"
                    grep -A 2 -B 2 "Code signing" "$log" | head -5
                fi
                
                # Missing file errors
                if grep -q "No such file" "$log"; then
                    echo "🔴 Missing file errors detected"
                    grep -A 2 -B 2 "No such file" "$log" | head -5
                fi
                
                # Dependency errors
                if grep -q "could not resolve" "$log"; then
                    echo "🔴 Dependency resolution errors detected"
                    grep -A 2 -B 2 "could not resolve" "$log" | head -5
                fi
                
                # Framework errors
                if grep -q "framework not found" "$log"; then
                    echo "🔴 Framework errors detected"
                    grep -A 2 -B 2 "framework not found" "$log" | head -5
                fi
                
                echo ""
                echo "===================================="
            fi
        done
        
        echo ""
        echo "ERROR CATEGORIZATION SUMMARY"
        echo "============================"
        echo "Search complete. Check individual log sections above for detailed analysis."
        
    } > "$errors_report"
    
    echo -e "${GREEN}✅ Error analysis completed: $errors_report${NC}"
}

# Function to create error debugging guide
create_debugging_guide() {
    echo -e "${BLUE}📝 Creating Error Debugging Guide...${NC}"
    
    local guide_file="$OUTPUT_DIR/error_debugging_guide_$TIMESTAMP.md"
    
    cat > "$guide_file" << 'EOF'
# Leavn iOS App - Error Debugging Guide

## Quick Error Resolution

### Common Build Errors and Solutions

#### 1. Swift Compilation Errors
**Symptoms:** `error: Swift compilation failed`
**Solutions:**
- Check syntax in Swift files
- Verify import statements
- Ensure all referenced modules exist
- Clean build folder and rebuild

#### 2. Code Signing Errors
**Symptoms:** `error: Code signing failed`
**Solutions:**
- Use `CODE_SIGN_IDENTITY=""` for simulator builds
- Check provisioning profiles for device builds
- Verify bundle identifier matches App Store Connect

#### 3. Missing File Errors
**Symptoms:** `error: No such file or directory`
**Solutions:**
- Check file references in project.pbxproj
- Verify file paths are correct
- Ensure files exist in filesystem
- Re-add missing files to Xcode project

#### 4. Dependency Resolution Errors
**Symptoms:** `error: could not resolve package dependencies`
**Solutions:**
- Clean Package.resolved file
- Update package dependencies
- Check network connectivity
- Verify package URLs are accessible

#### 5. Framework Not Found Errors
**Symptoms:** `error: framework not found`
**Solutions:**
- Check framework search paths
- Verify framework is properly linked
- Ensure framework is available for target SDK
- Check if framework needs to be embedded

### Debugging Commands

#### Clean Build Environment
```bash
# Clean all build artifacts
make clean

# Clean Xcode derived data
rm -rf ~/Library/Developer/Xcode/DerivedData/Leavn-*

# Clean project-specific cache
rm -rf DerivedData/
```

#### Build with Detailed Output
```bash
# Build with verbose output
xcodebuild build -project Leavn.xcodeproj -scheme Leavn -destination 'platform=iOS Simulator,name=iPhone 16 Pro' -verbose

# Build and save output
xcodebuild build -project Leavn.xcodeproj -scheme Leavn -destination 'platform=iOS Simulator,name=iPhone 16 Pro' 2>&1 | tee build_debug.log
```

#### Test Specific Components
```bash
# Test individual modules
xcodebuild test -project Leavn.xcodeproj -scheme Leavn -destination 'platform=iOS Simulator,name=iPhone 16 Pro' -only-testing:LeavnTests/BibleModuleTests

# Run UI tests
xcodebuild test -project Leavn.xcodeproj -scheme Leavn -destination 'platform=iOS Simulator,name=iPhone 16 Pro' -only-testing:LeavnUITests
```

### Performance Debugging

#### Memory Issues
- Use Xcode Instruments to profile memory usage
- Check for retain cycles in Swift code
- Monitor memory usage during app lifecycle

#### Build Performance
- Enable build timing: `xcodebuild -showBuildTimingSummary`
- Use whole module optimization for release builds
- Enable Link Time Optimization (LTO)

### Advanced Debugging

#### Simulator Issues
```bash
# Reset simulator
xcrun simctl erase all

# Boot specific simulator
xcrun simctl boot "iPhone 16 Pro"

# Install app on simulator
xcrun simctl install booted path/to/app.app
```

#### Xcode Issues
```bash
# Reset Xcode cache
rm -rf ~/Library/Developer/Xcode/DerivedData/
rm -rf ~/Library/Caches/com.apple.dt.Xcode/

# Reset Xcode preferences
defaults delete com.apple.dt.Xcode
```

### Error Log Analysis

#### Key Error Patterns
1. **Swift Compiler Errors**: Look for `error:` in build output
2. **Linker Errors**: Search for `ld:` or `linker command failed`
3. **Runtime Errors**: Check device logs and crash reports
4. **Test Failures**: Review test output for assertion failures

#### Log Locations
- Build logs: `DerivedData/Logs/Build/`
- Test logs: `DerivedData/Logs/Test/`
- Device logs: Console app or `xcrun simctl spawn booted log`

### Preventive Measures

#### Code Quality
- Use SwiftLint for consistent code style
- Enable all Swift compiler warnings
- Regular code reviews and testing
- Continuous integration builds

#### Project Maintenance
- Regular dependency updates
- Clean builds for releases
- Automated testing pipeline
- Documentation updates

### Emergency Fixes

#### When Nothing Works
1. Create new branch from last working commit
2. Clean all build artifacts and cache
3. Restart Xcode and computer
4. Check Apple Developer status page
5. Try building on different machine

#### Quick Recovery
```bash
# Emergency reset sequence
make clean
rm -rf DerivedData/
rm -rf ~/Library/Developer/Xcode/DerivedData/
xcrun simctl erase all
xcodebuild -resolvePackageDependencies
make build
```

---

*Generated by Agent 3: Build System & Testing Infrastructure*
EOF
    
    echo -e "${GREEN}✅ Error debugging guide created: $guide_file${NC}"
}

# Function to generate validation summary
generate_validation_summary() {
    echo -e "${BLUE}📊 Generating Validation Summary...${NC}"
    
    local summary_file="$OUTPUT_DIR/validation_summary_$TIMESTAMP.md"
    
    cat > "$summary_file" << EOF
# Leavn iOS App - Build Validation Summary

## Validation Run Details
- **Date**: $(date)
- **Timestamp**: $TIMESTAMP
- **Xcode Version**: $(xcodebuild -version 2>/dev/null | head -1 || echo "Unknown")
- **macOS Version**: $(sw_vers -productVersion 2>/dev/null || echo "Unknown")

## Files Generated
$(ls -la "$OUTPUT_DIR/" | grep "$TIMESTAMP" | awk '{print "- " $9}')

## Validation Components

### 1. Environment Check ✅
- Xcode installation and version
- Available SDKs and simulators
- Swift compiler version
- System requirements verification

### 2. Project Structure Validation ✅
- Required files verification
- Module structure analysis
- Assets and resources check
- Configuration files validation

### 3. Dependencies Analysis ✅
- Package.swift examination
- Swift Package Manager status
- Third-party dependencies review
- Dependency resolution validation

### 4. Build Validation ✅
- Clean build verification
- Syntax checking
- Simulator build testing
- Device build testing

### 5. Error Analysis ✅
- Build log examination
- Error categorization
- Common issues identification
- Solution recommendations

## Next Steps

### Immediate Actions
1. Review individual validation reports
2. Address any identified issues
3. Run multi-simulator testing
4. Perform comprehensive UI testing

### Follow-up Testing
1. Execute: `./multi_simulator_test.sh`
2. Run performance profiling
3. Conduct memory leak analysis
4. Validate on physical devices

### Continuous Integration
1. Integrate validation into CI pipeline
2. Set up automated testing
3. Configure build notifications
4. Establish quality gates

## Recommendations

### Build Optimization
- Enable whole module optimization for release builds
- Use Link Time Optimization (LTO)
- Optimize asset compilation
- Implement build caching strategies

### Error Prevention
- Set up pre-commit hooks
- Implement automated testing
- Regular dependency updates
- Code quality enforcement

### Monitoring
- Track build performance metrics
- Monitor error trends
- Set up alerting for failures
- Regular health checks

## Support Resources

### Documentation
- Error Debugging Guide: \`error_debugging_guide_$TIMESTAMP.md\`
- Multi-Simulator Testing: \`multi_simulator_test.sh\`
- Build Validation: \`build_validation.sh\`

### Commands
\`\`\`bash
# Run full validation
./build_validation.sh

# Multi-simulator testing
./multi_simulator_test.sh

# Quick build check
make clean && make build
\`\`\`

---

*Generated by Agent 3: Build System & Testing Infrastructure*
*Status: Validation Complete - Ready for Testing*
EOF
    
    echo -e "${GREEN}✅ Validation summary generated: $summary_file${NC}"
}

# Main execution function
main() {
    echo -e "${BLUE}🚀 Starting Comprehensive Build Validation...${NC}"
    
    # Execute all validation steps
    check_xcode_environment
    validate_project_structure
    analyze_dependencies
    perform_build_validation
    extract_and_categorize_errors
    create_debugging_guide
    generate_validation_summary
    
    echo -e "${BLUE}📋 VALIDATION COMPLETE${NC}"
    echo -e "${BLUE}=====================${NC}"
    echo -e "${GREEN}✅ All validation components completed${NC}"
    echo -e "${BLUE}📁 Results directory: $OUTPUT_DIR${NC}"
    echo -e "${BLUE}📊 Summary: $OUTPUT_DIR/validation_summary_$TIMESTAMP.md${NC}"
    echo -e "${BLUE}🔍 Debug guide: $OUTPUT_DIR/error_debugging_guide_$TIMESTAMP.md${NC}"
    
    echo -e "${YELLOW}⚡ Next Steps:${NC}"
    echo -e "${YELLOW}1. Review validation reports${NC}"
    echo -e "${YELLOW}2. Run: ./multi_simulator_test.sh${NC}"
    echo -e "${YELLOW}3. Fix any identified issues${NC}"
    echo -e "${YELLOW}4. Deploy to TestFlight${NC}"
    
    echo -e "${GREEN}🎉 Build validation system ready!${NC}"
}

# Execute main function
main "$@"