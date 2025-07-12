#!/bin/bash

# Script to check for duplicate GUIDs in Xcode project file

PROJECT_FILE="Leavn.xcodeproj/project.pbxproj"

if [ ! -f "$PROJECT_FILE" ]; then
    echo "Error: $PROJECT_FILE not found"
    exit 1
fi

echo "Checking for duplicate GUIDs in $PROJECT_FILE..."
echo "================================================"

# Extract all GUIDs (24-character hex strings) and find duplicates
duplicates=$(grep -o '[A-F0-9]\{24\}' "$PROJECT_FILE" | sort | uniq -d)

if [ -z "$duplicates" ]; then
    echo "✅ No duplicate GUIDs found!"
else
    echo "⚠️  Found duplicate GUIDs:"
    echo "$duplicates"
    echo ""
    echo "Details for each duplicate:"
    echo "---------------------------"
    
    while IFS= read -r guid; do
        echo ""
        echo "GUID: $guid"
        echo "Found in lines:"
        grep -n "$guid" "$PROJECT_FILE" | head -5
        echo "..."
    done <<< "$duplicates"
    
    echo ""
    echo "To fix:"
    echo "1. Open $PROJECT_FILE in a text editor"
    echo "2. Search for each duplicate GUID"
    echo "3. Ensure each object has a unique GUID"
    echo "4. Or regenerate the project with 'make generate'"
fi