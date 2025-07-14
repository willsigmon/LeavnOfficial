# Fix for Duplicate Package GUID Issue

## Problem
The error "PACKAGE:1Q6KPZ62BA8C83NIUGJB23TUB9LCUTAF8::MAINGROUP" indicates that the same Swift package is being referenced multiple times in your Xcode workspace, causing a GUID collision.

## Root Cause
Your project has both:
- `project.yml` (XcodeGen configuration)
- `Project.swift` (Tuist configuration)

This creates confusion and can lead to duplicate package references when the project is generated.

## Immediate Fix (Manual Steps)

### Step 1: Close Xcode
Close any open Xcode windows for this project.

### Step 2: Remove Current Project
```bash
cd "/Users/wsig/GitHub Builds/LeavnOfficial"
rm -rf Leavn.xcodeproj
```

### Step 3: Clean Package Caches
```bash
rm -rf ~/Library/Caches/org.swift.swiftpm
rm -rf .swiftpm
rm -rf .build
```

### Step 4: Choose One Configuration System
Since you have Tuist's `Project.swift` already set up, we'll use that:

```bash
# Backup the XcodeGen config
mv project.yml project.yml.backup

# If Tuist isn't installed
brew install tuist
```

### Step 5: Generate Fresh Project
```bash
# Fetch dependencies
tuist fetch

# Generate project
tuist generate
```

### Step 6: Open and Reset in Xcode
```bash
open Leavn.xcodeproj
```

In Xcode:
1. File → Packages → Reset Package Caches
2. File → Packages → Update to Latest Package Versions
3. Wait for package resolution to complete
4. Build the project (⌘B)

## Alternative: Using the Scripts

### Option 1: Interactive Cleanup Script
```bash
bash Scripts/clean-duplicate-packages.sh
```
This will guide you through the process interactively.

### Option 2: Quick Fix Script
```bash
bash Scripts/quick-fix-packages.sh
```
This applies the fix automatically using Tuist.

## Prevention
To prevent this issue in the future:
1. Use only one project generation tool (either Tuist OR XcodeGen, not both)
2. Add the unused config file to `.gitignore`
3. Document which tool your team uses in the README

## Verification
After the fix, you should:
- See no duplicate package errors
- Be able to build all targets successfully
- Have proper package resolution in Xcode

## If Issues Persist
1. Delete DerivedData: `rm -rf ~/Library/Developer/Xcode/DerivedData/*`
2. Restart your Mac
3. Check that local packages exist at:
   - `Core/LeavnCore/Package.swift`
   - `Core/LeavnModules/Package.swift`