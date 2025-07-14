#!/usr/bin/env python3
"""Verify all fixes are properly applied"""

import os
import re

def check_file_contains(filepath, pattern, description):
    """Check if a file contains a specific pattern"""
    try:
        with open(filepath, 'r') as f:
            content = f.read()
            if re.search(pattern, content, re.MULTILINE | re.DOTALL):
                print(f"✅ {description}")
                return True
            else:
                print(f"❌ {description} - NOT FOUND")
                return False
    except Exception as e:
        print(f"❌ {description} - ERROR: {e}")
        return False

def main():
    print("🔍 Verifying all fixes are in place...\n")
    
    all_good = True
    
    # Check 1: BibleView uses @StateObject
    all_good &= check_file_contains(
        "Modules/Bible/Views/BibleView.swift",
        r"@StateObject private var viewModel = BibleViewModel\(\)",
        "BibleView: Using @StateObject for viewModel"
    )
    
    # Check 2: Timeout implementation in BibleView
    all_good &= check_file_contains(
        "Modules/Bible/Views/BibleView.swift",
        r"try await Task\.sleep\(nanoseconds: 10_000_000_000\)",
        "BibleView: 10-second timeout implemented"
    )
    
    # Check 3: CloudKit disabled in DEBUG
    all_good &= check_file_contains(
        "Packages/LeavnCore/Sources/LeavnCore/Persistence/PersistenceController.swift",
        r"#if DEBUG.*CloudKit sync disabled in debug mode",
        "PersistenceController: CloudKit disabled in DEBUG"
    )
    
    # Check 4: Core Data model as resource
    all_good &= check_file_contains(
        "Packages/LeavnCore/Package.swift",
        r"resources:.*\.process\(\"Persistence/LeavnDataModel\.xcdatamodeld\"\)",
        "Package.swift: Core Data model included as resource"
    )
    
    # Check 5: DIContainer initialization check
    all_good &= check_file_contains(
        "Leavn/App/LeavnApp.swift",
        r"if diContainer\.isInitialized",
        "LeavnApp: DIContainer initialization check"
    )
    
    # Check 6: Loading screen implementation
    all_good &= check_file_contains(
        "Leavn/App/LeavnApp.swift",
        r"ProgressView\(\).*Text\(\"Loading\.\.\.\"\)",
        "LeavnApp: Loading screen implemented"
    )
    
    # Check 7: Environment objects passed correctly
    all_good &= check_file_contains(
        "Leavn/Views/ContentView.swift",
        r"\.environmentObject\(navigationCoordinator\)",
        "ContentView: NavigationCoordinator passed"
    )
    
    # Check 8: Module imports in MainTabView
    all_good &= check_file_contains(
        "Leavn/Views/MainTabView.swift",
        r"import LeavnBible.*import LeavnSearch.*import LeavnLibrary.*import LeavnSettings",
        "MainTabView: All required modules imported"
    )
    
    # Check 9: Firebase disabled
    all_good &= check_file_contains(
        "Packages/LeavnCore/Sources/LeavnServices/DIContainer.swift",
        r"// communityService = FirebaseCommunityService",
        "DIContainer: Firebase disabled"
    )
    
    # Check 10: ServiceError timeout case
    all_good &= check_file_contains(
        "Packages/LeavnCore/Sources/LeavnCore/SharedTypes.swift",
        r"case timeout",
        "SharedTypes: ServiceError.timeout case added"
    )
    
    print("\n" + "="*50)
    if all_good:
        print("✅ All fixes verified! The app should build and run successfully.")
        print("\nNext steps:")
        print("1. Open Xcode")
        print("2. Clean Build Folder (⇧⌘K)")
        print("3. Build and Run (⌘R)")
        print("4. Test all 5 tabs")
    else:
        print("❌ Some fixes are missing. Please review the errors above.")
    
    return 0 if all_good else 1

if __name__ == "__main__":
    exit(main())