#!/usr/bin/env python3
"""
Debug script to test App Store Connect API authentication
"""

import os
import sys
import requests
from app_store_api import AppStoreConnectAPI

def main():
    try:
        # Initialize API
        api = AppStoreConnectAPI()
        
        print("🔍 Debug Information:")
        print(f"   API Key ID: {os.getenv('APP_STORE_API_KEY_ID')}")
        print(f"   Issuer ID: {os.getenv('APP_STORE_API_ISSUER_ID')}")
        print(f"   Private Key Path: {os.getenv('APP_STORE_API_PRIVATE_KEY_PATH')}")
        
        # Generate JWT token
        token = api.generate_jwt_token()
        print(f"\n🔑 JWT Token generated:")
        print(f"   Token (first 50 chars): {token[:50]}...")
        
        # Try a simple API request
        headers = {
            'Authorization': f'Bearer {token}',
            'Content-Type': 'application/json'
        }
        
        # Test with apps endpoint
        url = "https://api.appstoreconnect.apple.com/v1/apps"
        print(f"\n📡 Testing API request to: {url}")
        
        response = requests.get(url, headers=headers)
        
        print(f"\n📊 Response:")
        print(f"   Status Code: {response.status_code}")
        print(f"   Headers: {dict(response.headers)}")
        
        if response.status_code != 200:
            print(f"\n❌ Error Response Body:")
            print(response.text)
        else:
            print(f"\n✅ Success! API authentication is working.")
            
    except Exception as e:
        print(f"\n❌ Exception: {str(e)}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    main()
