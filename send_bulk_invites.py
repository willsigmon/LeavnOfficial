#!/usr/bin/env python3
"""
Script to send TestFlight invitations to multiple email addresses from a file
"""

import sys
import time
from app_store_api import AppStoreConnectAPI

def read_emails_from_file(filename):
    """Read email addresses from a file, one per line"""
    emails = []
    try:
        with open(filename, 'r') as f:
            for line in f:
                email = line.strip()
                if email and '@' in email:  # Basic validation
                    emails.append(email)
    except FileNotFoundError:
        print(f"❌ Error: File '{filename}' not found!")
        return []
    except Exception as e:
        print(f"❌ Error reading file: {str(e)}")
        return []
    
    return emails

def main():
    # Read emails from file
    email_file = "testflight_emails.txt"
    print(f"📧 Reading emails from {email_file}...")
    
    emails = read_emails_from_file(email_file)
    
    if not emails:
        print("❌ No valid emails found in the file!")
        return 1
    
    print(f"✅ Found {len(emails)} email addresses to invite")
    
    try:
        # Initialize API client
        print(f"\n🚀 Initializing App Store Connect API...")
        api = AppStoreConnectAPI()
        
        # Get app ID
        print(f"📱 Finding app with bundle ID: com.leavn.app")
        app_id = api.get_app_id("com.leavn.app")
        
        if not app_id:
            print("❌ App not found!")
            return 1
            
        print(f"✅ Found app ID: {app_id}")
        
        # Get latest build
        print(f"\n🔍 Finding latest TestFlight build...")
        build_info = api.get_latest_testflight_build(app_id)
        
        if not build_info:
            print("❌ No TestFlight build found!")
            return 1
            
        build_id = build_info['id']
        build_version = build_info.get('attributes', {}).get('version', 'Unknown')
        build_uploaded = build_info.get('attributes', {}).get('uploadedDate', 'Unknown')
        
        print(f"✅ Found build: Version {build_version}")
        print(f"   Build ID: {build_id}")
        print(f"   Uploaded: {build_uploaded}")
        
        # Send invitations
        print(f"\n📨 Sending TestFlight invitations...")
        print(f"{'='*60}")
        
        successful = []
        failed = []
        
        for i, email in enumerate(emails, 1):
            print(f"\n[{i}/{len(emails)}] Sending invitation to: {email}")
            
            try:
                success = api.send_testflight_invitation(email, app_id)
                
                if success:
                    print(f"   ✅ Invitation sent successfully!")
                    successful.append(email)
                else:
                    print(f"   ❌ Failed to send invitation")
                    failed.append(email)
                    
            except Exception as e:
                print(f"   ❌ Error: {str(e)}")
                failed.append(email)
            
            # Add a small delay between requests to avoid rate limiting
            if i < len(emails):
                time.sleep(1)
        
        # Summary
        print(f"\n{'='*60}")
        print(f"📊 Summary:")
        print(f"   Total emails: {len(emails)}")
        print(f"   ✅ Successful: {len(successful)}")
        print(f"   ❌ Failed: {len(failed)}")
        
        if successful:
            print(f"\n✅ Successfully invited:")
            for email in successful:
                print(f"   - {email}")
        
        if failed:
            print(f"\n❌ Failed to invite:")
            for email in failed:
                print(f"   - {email}")
        
        print(f"\n📬 Next steps for invited testers:")
        print(f"   1. Check their email for TestFlight invitation")
        print(f"   2. Accept the TestFlight invitation")
        print(f"   3. Install TestFlight app if not already installed")
        print(f"   4. Download and test the Leavn app!")
        
        return 0 if not failed else 1
        
    except Exception as e:
        print(f"\n❌ Unexpected error: {str(e)}")
        return 1

if __name__ == "__main__":
    sys.exit(main())
