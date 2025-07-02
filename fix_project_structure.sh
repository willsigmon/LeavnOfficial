#!/bin/bash

# Backup the project file
cp "/Users/wsig/Desktop/Leavn/Leavn.xcodeproj/project.pbxproj" "/Users/wsig/Desktop/Leavn/Leavn.xcodeproj/project.pbxproj.backup.$(date +%Y%m%d%H%M%S)"

# Fix file references in the project file
sed -i '' 's|/Leavn/Leavn/Leavn/|/Leavn/Leavn/|g' "/Users/wsig/Desktop/Leavn/Leavn.xcodeproj/project.pbxproj"

echo "Project file references have been updated. Please open the project in Xcode and verify the changes."
