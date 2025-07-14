#!/usr/bin/env python3
"""Test build script for Leavn app"""

import subprocess
import os
import sys
import re

def run_command(cmd, description):
    """Run a command and return success status"""
    print(f"\n🔄 {description}...")
    try:
        result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
        if result.returncode == 0:
            print(f"✅ {description} succeeded")
            return True, result.stdout
        else:
            print(f"❌ {description} failed")
            print(f"Error: {result.stderr[:500]}...")
            return False, result.stderr
    except Exception as e:
        print(f"❌ Exception: {e}")
        return False, str(e)

def extract_errors(output):
    """Extract error messages from build output"""
    error_patterns = [
        r"error: (.+)",
        r"fatal error: (.+)",
        r"Failed to (.+)",
        r"cannot find (.+)",
        r"No such (.+)"
    ]
    
    errors = []
    for pattern in error_patterns:
        matches = re.findall(pattern, output, re.IGNORECASE | re.MULTILINE)
        errors.extend(matches)
    
    return errors[:10]  # Return first 10 errors

def main():
    print("🧪 Testing Leavn build...")
    
    # Change to project directory
    project_dir = os.path.dirname(os.path.abspath(__file__))
    os.chdir(project_dir)
    
    # Clean build
    success, _ = run_command(
        "xcodebuild clean -project Leavn.xcodeproj -scheme Leavn -quiet",
        "Cleaning build artifacts"
    )
    
    # Build for simulator
    build_cmd = """xcodebuild build \
        -project Leavn.xcodeproj \
        -scheme "Leavn" \
        -sdk iphonesimulator \
        -destination 'platform=iOS Simulator,name=iPhone 16 Pro Max' \
        CODE_SIGN_IDENTITY="" \
        CODE_SIGNING_REQUIRED=NO \
        CODE_SIGNING_ALLOWED=NO"""
    
    success, output = run_command(build_cmd, "Building for simulator")
    
    # Save output
    with open("build_test_output.log", "w") as f:
        f.write(output)
    
    if success:
        print("\n✅ Build succeeded!")
        print("Check build_test_output.log for full output")
    else:
        print("\n❌ Build failed!")
        errors = extract_errors(output)
        if errors:
            print("\n📋 Found errors:")
            for i, error in enumerate(errors, 1):
                print(f"{i}. {error}")
        
        # Check for specific common issues
        if "No such module" in output:
            print("\n💡 Tip: Try 'File > Packages > Reset Package Caches' in Xcode")
        if "Failed to build module" in output:
            print("\n💡 Tip: Try cleaning DerivedData")
        if "Code signing" in output:
            print("\n💡 Tip: Code signing is disabled for this test build")
    
    return 0 if success else 1

if __name__ == "__main__":
    sys.exit(main())