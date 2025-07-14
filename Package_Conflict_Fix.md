# Package Conflict Resolution

## Issue
The build failed with: "The workspace contains multiple references with the same GUID"

## Root Cause
There are conflicting Package.swift files in subdirectories:
- `Modules/Map/Package.swift` (empty)
- `Modules/Onboarding/Package.swift` (empty)
- `Modules/Discover/Package.swift` (empty)

These should not exist because these modules are defined as targets in the main `Modules/Package.swift`.

## Solution

### Option 1: Run the fix script
```bash
chmod +x fix_package_conflicts.sh
./fix_package_conflicts.sh
```

### Option 2: Manual fix
1. Delete the conflicting files:
   ```bash
   rm Modules/Map/Package.swift
   rm Modules/Onboarding/Package.swift
   rm Modules/Discover/Package.swift
   ```

2. Clean Xcode caches:
   ```bash
   rm -rf ~/Library/Developer/Xcode/DerivedData/Leavn-*
   rm -rf ~/Library/Caches/org.swift.swiftpm
   ```

3. In Xcode:
   - File > Packages > Reset Package Caches
   - Product > Clean Build Folder (⌘⇧K)
   - Build again

## Prevention
Only the following Package.swift files should exist:
- `/Packages/LeavnCore/Package.swift` - Core package definition
- `/Modules/Package.swift` - All app modules definition

Individual modules should NOT have their own Package.swift files.