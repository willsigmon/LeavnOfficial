#!/usr/bin/env python3
"""
Remove package references from Xcode project file to fix duplicate GUID issue
"""
import re
import shutil
from datetime import datetime

# Backup the original file
project_file = "Leavn.xcodeproj/project.pbxproj"
backup_file = f"Leavn.xcodeproj/project.pbxproj.backup.{datetime.now().strftime('%Y%m%d_%H%M%S')}"
shutil.copy2(project_file, backup_file)
print(f"✅ Created backup: {backup_file}")

# Read the project file
with open(project_file, 'r') as f:
    content = f.read()

# Remove the file references for Modules and LeavnCore
# These are the problematic references causing Xcode to look for packages
file_refs_to_remove = [
    'D49A4D05BB33E7768C607F50',  # Modules
    'D53240BA11B824F2FCC1D7C8'   # LeavnCore
]

lines_to_remove = []
lines = content.split('\n')

# Find and mark lines to remove
for i, line in enumerate(lines):
    for ref in file_refs_to_remove:
        if ref in line:
            # Remove the entire file reference block
            lines_to_remove.append(i)
            print(f"🗑️  Removing file reference: {line.strip()}")

# Also remove from the Packages group
in_packages_group = False
packages_group_start = -1
for i, line in enumerate(lines):
    if '/* Packages */ = {' in line:
        in_packages_group = True
        packages_group_start = i
    elif in_packages_group and line.strip() == '};':
        in_packages_group = False
    elif in_packages_group:
        for ref in file_refs_to_remove:
            if ref in line:
                lines_to_remove.append(i)
                print(f"🗑️  Removing from Packages group: {line.strip()}")

# Remove lines in reverse order to maintain indices
for i in sorted(set(lines_to_remove), reverse=True):
    del lines[i]

# Write the modified content back
with open(project_file, 'w') as f:
    f.write('\n'.join(lines))

print("\n✅ Successfully removed package references!")
print("\n📝 Next steps:")
print("1. Close Xcode if open")
print("2. Delete DerivedData: rm -rf ~/Library/Developer/Xcode/DerivedData/")
print("3. Open Xcode and try building again")
print("\nIf you need to restore, use: cp " + backup_file + " " + project_file)