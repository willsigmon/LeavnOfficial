#!/usr/bin/env python3
"""
Final cleanup script to remove .DS_Store files and optionally clean DerivedData
"""

import os
import shutil
import sys

def delete_ds_store_files(root_dir):
    """Delete all .DS_Store files"""
    ds_store_path = os.path.join(root_dir, '.DS_Store')
    if os.path.exists(ds_store_path):
        try:
            os.remove(ds_store_path)
            print(f"✓ Deleted: {ds_store_path}")
            return 1
        except Exception as e:
            print(f"✗ Error deleting {ds_store_path}: {str(e)}")
            return 0
    else:
        print("No .DS_Store files found in the root directory")
        return 0

def clean_derived_data(root_dir):
    """Clean DerivedData directory"""
    derived_data_path = os.path.join(root_dir, 'DerivedData')
    if os.path.exists(derived_data_path):
        response = input("\nDerivedData directory found (Xcode build cache).\nThis can be safely deleted and will be regenerated on next build.\nDelete DerivedData? (y/n): ")
        if response.lower() == 'y':
            try:
                shutil.rmtree(derived_data_path)
                print(f"✓ Deleted: {derived_data_path}")
                return True
            except Exception as e:
                print(f"✗ Error deleting {derived_data_path}: {str(e)}")
                return False
    return False

def main():
    root_directory = "/Users/wsig/Cursor Repos/LeavnOfficial"
    
    print("Hidden Files Cleanup")
    print("=" * 60)
    
    # Delete .DS_Store files
    deleted_count = delete_ds_store_files(root_directory)
    
    # Ask about DerivedData
    derived_data_cleaned = clean_derived_data(root_directory)
    
    # Summary
    print("\n" + "=" * 60)
    print("Cleanup Summary:")
    print("=" * 60)
    print(f"• .DS_Store files deleted: {deleted_count}")
    print(f"• DerivedData cleaned: {'Yes' if derived_data_cleaned else 'No'}")
    print("\nCleanup complete!")

if __name__ == "__main__":
    main()