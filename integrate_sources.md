# Integrating Package Sources into Main Project

Since the Swift Package Manager is causing duplicate GUID issues, we need to add all source files directly to the Xcode project.

## Steps to Add Sources to Xcode Project

### 1. Add LeavnCore Sources
1. In Xcode, right-click on the project navigator
2. Select "Add Files to 'Leavn'..."
3. Navigate to `Packages/LeavnCore/Sources`
4. Select all three folders:
   - `LeavnCore`
   - `LeavnServices` 
   - `DesignSystem`
5. Make sure "Create groups" is selected
6. Make sure "Add to targets: Leavn" is checked
7. Click "Add"

### 2. Add Module Sources
1. Right-click on the project navigator again
2. Select "Add Files to 'Leavn'..."
3. Navigate to `Modules` folder
4. Select these folders:
   - `Authentication`
   - `Bible`
   - `Community`
   - `Discover`
   - `Library`
   - `Map`
   - `Onboarding`
   - `Search`
   - `Settings`
5. Make sure "Create groups" is selected
6. Make sure "Add to targets: Leavn" is checked
7. Click "Add"

### 3. Remove Import Statements
After adding the files, you'll need to remove the module import statements from your Swift files since all code is now in the same module:

**Files to update:**
- `Leavn/App/LeavnApp.swift` - Remove `import LeavnServices`
- `Leavn/Views/ContentView.swift` - Remove `import LeavnCore`
- `Leavn/Views/MainTabView.swift` - Remove all module imports

### 4. Clean and Build
1. Clean Build Folder (⌘⇧K)
2. Build (⌘B)

## Alternative: Automated Script

If you prefer, here's what needs to happen programmatically:
1. Copy all source files from packages to main project
2. Update project.pbxproj to include all files
3. Remove module imports from Swift files