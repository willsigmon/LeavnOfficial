#!/bin/bash

# Generate Xcode project using XcodeGen or Tuist

set -euo pipefail

echo "=== Generating Xcode Project ==="

# Check if we have project.yml (XcodeGen)
if [ -f "project.yml" ]; then
    if command -v xcodegen >/dev/null 2>&1; then
        echo "→ Using XcodeGen..."
        xcodegen generate
        echo "✓ Project generated successfully"
    else
        echo "✗ XcodeGen not found. Install it with: brew install xcodegen"
        exit 1
    fi
    
# Check if we have Project.swift (Tuist)
elif [ -f "Project.swift" ]; then
    if command -v tuist >/dev/null 2>&1; then
        echo "→ Using Tuist..."
        tuist clean
        tuist fetch
        tuist generate
        echo "✓ Project generated successfully"
    else
        echo "✗ Tuist not found. Install it with: curl -Ls https://install.tuist.io | bash"
        exit 1
    fi
    
else
    echo "✗ No project configuration found (project.yml or Project.swift)"
    exit 1
fi

echo ""
echo "Project generation complete!"
echo "Open Leavn.xcworkspace or Leavn.xcodeproj to start developing."