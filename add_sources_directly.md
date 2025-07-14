# Add Sources Directly to Project

Since package references are causing issues, we'll add the source files directly to the Xcode project.

## Steps to Complete in Xcode:

### 1. Open the Project
Open `/Users/wsig/Cursor Repos/LeavnOfficial/Leavn.xcodeproj` in Xcode

### 2. Add LeavnCore Sources
1. Right-click on the project navigator
2. Select "Add Files to Leavn..."
3. Navigate to `Packages/LeavnCore/Sources`
4. Select all folders:
   - `DesignSystem`
   - `LeavnCore`
   - `LeavnServices`
5. Make sure "Create groups" is selected
6. Make sure your app target is checked
7. Click "Add"

### 3. Add Module Sources
Repeat the process for each module:

1. **Bible Module**:
   - Add `Modules/Bible` folder
   
2. **Search Module**:
   - Add `Modules/Search` folder
   
3. **Library Module**:
   - Add `Modules/Library` folder
   
4. **Settings Module**:
   - Add `Modules/Settings` folder
   
5. **Authentication Module**:
   - Add `Modules/Authentication` folder
   
6. **Community Module**:
   - Add `Modules/Community` folder
   
7. **Map Module**:
   - Add `Modules/Map` folder
   
8. **Onboarding Module**:
   - Add `Modules/Onboarding` folder

### 4. Clean and Build
1. Product → Clean Build Folder (⇧⌘K)
2. Build the project

## Benefits of This Approach:
- No package dependency issues
- No GUID conflicts
- Faster builds
- Easier debugging
- Direct control over all source files

## Note:
This converts your modular package structure into a monolithic app, but eliminates all package-related issues. You can always convert back to packages later once the GUID issue is resolved.