# EMERGENCY FIX: Duplicate GUID Error

## The Nuclear Option

Since the GUID `PACKAGE:1OJ5W07399N9252HQLWU0QSAFZ3TLA8XH::MAINGROUP` persists even after cleaning, we need to completely rebuild the package dependencies.

## Option 1: Remove ALL Package Dependencies (Recommended)

1. **Close Xcode completely**

2. **In Terminal:**
```bash
cd "/Users/wsig/Cursor Repos/LeavnOfficial"

# Backup project file
cp Leavn.xcodeproj/project.pbxproj Leavn.xcodeproj/project.pbxproj.backup

# Remove ALL Swift Package Manager integration
rm -rf .swiftpm
rm -rf .build
rm -f Package.resolved
rm -rf Leavn.xcodeproj/project.xcworkspace/xcshareddata/swiftpm
rm -rf Leavn.xcodeproj/project.xcworkspace/xcuserdata
rm -rf ~/Library/Developer/Xcode/DerivedData/*
```

3. **Open Xcode**

4. **Remove Package Dependencies:**
   - Click on the project (blue icon) in navigator
   - Select the project (not target) in the editor
   - Go to "Package Dependencies" tab
   - Select each package and click "-" to remove ALL of them

5. **Clean:**
   - Product → Clean Build Folder (⇧⌘K)
   - File → Packages → Reset Package Caches

6. **Re-add Packages:**
   - Click "+" in Package Dependencies
   - Add Local Package → Browse to `Packages/LeavnCore`
   - Click "+" again
   - Add Local Package → Browse to `Modules`

7. **Re-add Framework Dependencies:**
   - Select your app target
   - Go to General → Frameworks, Libraries, and Embedded Content
   - Click "+" and add back:
     - LeavnCore
     - LeavnServices
     - DesignSystem
     - LeavnBible
     - LeavnSearch
     - LeavnLibrary
     - LeavnSettings
     - AuthenticationModule
     - LeavnOnboarding

## Option 2: Create New Project (Last Resort)

If Option 1 doesn't work:

1. Create a new Xcode project with the same name
2. Copy over all source files EXCEPT:
   - .xcodeproj
   - .xcworkspace
   - Package.resolved
3. Re-add packages fresh

## Option 3: Manual Project File Surgery

If you're comfortable with text editing:

1. Open `Leavn.xcodeproj/project.pbxproj` in a text editor
2. Search for `PACKAGE:` - if found, this shouldn't be there
3. Remove any lines containing package GUIDs that look suspicious
4. Save and try again

## The Root Cause

This error typically happens when:
- The same package is added multiple times
- Package.swift files exist in subdirectories when they shouldn't
- Xcode's internal package resolution cache is corrupted
- The project file has been manually edited or merged incorrectly