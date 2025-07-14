#!/usr/bin/env python3
"""
Quick script to send a TestFlight invite to a single email address
"""

import sys
from app_store_api import AppStoreConnectAPI

def main():
    # Email to invite
    email = "wjsigmon@gmail.com"
    
    try:
        # Initialize API client
        print(f"🚀 Initializing App Store Connect API...")
        api = AppStoreConnectAPI()
        
        # Get app ID
        print(f"📱 Finding app with bundle ID: com.leavn.app")
        app_id = api.get_app_id("com.leavn.app")
        
        if not app_id:
            print("❌ App not found!")
            return 1
            
        print(f"✅ Found app ID: {app_id}")
        
        # Get latest build
        print(f"🔍 Finding latest TestFlight build...")
        build_info = api.get_latest_testflight_build(app_id)
        
        if not build_info:
            print("❌ No TestFlight build found!")
            return 1
            
        build_id = build_info['id']
        build_version = build_info.get('attributes', {}).get('version', 'Unknown')
        build_number = build_info.get('attributes', {}).get('uploadedDate', 'Unknown')
        
        print(f"✅ Found build: Version {build_version} (ID: {build_id})")
        
        # Send invitation
        print(f"📧 Sending TestFlight invitation to: {email}")
        success = api.send_testflight_invitation(email, app_id)
        
        if success:
            print(f"✅ TestFlight invitation sent successfully to {email}!")
            print(f"\n📬 Next steps:")
            print(f"   1. Check your email at {email}")
            print(f"   2. Accept the TestFlight invitation")
            print(f"   3. Install TestFlight app if not already installed")
            print(f"   4. Download and test the Leavn app!")
        else:
            print(f"❌ Failed to send invitation")
            return 1
            
    except Exception as e:
        print(f"❌ Error: {str(e)}")
        return 1
        
    return 0

if __name__ == "__main__":
    sys.exit(main())
