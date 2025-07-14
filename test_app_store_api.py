#!/usr/bin/env python3
"""
Test script for App Store Connect API integration

This script tests the core functionality of the App Store Connect API integration module.
It will test:
1. JWT token generation
2. App ID retrieval for com.leavn.app
3. Latest build retrieval
4. Credential validation

Note: This script does not test actual tester invitations to avoid creating test data.
"""

import sys
import traceback
from app_store_api import AppStoreConnectAPI, AppStoreConnectAPIError

def test_jwt_token_generation():
    """Test JWT token generation"""
    print("🔑 Testing JWT token generation...")
    try:
        api = AppStoreConnectAPI()
        token = api.generate_jwt_token()
        
        # Basic validation
        if not token or len(token) < 100:
            raise Exception("Token appears to be invalid or too short")
        
        if not token.count('.') == 2:
            raise Exception("Token doesn't have expected JWT structure (header.payload.signature)")
        
        print(f"✅ JWT token generated successfully: {token[:50]}...")
        print(f"   Token length: {len(token)} characters")
        return True
        
    except Exception as e:
        print(f"❌ JWT token generation failed: {str(e)}")
        return False

def test_app_id_retrieval():
    """Test app ID retrieval for com.leavn.app"""
    print("\n📱 Testing app ID retrieval...")
    try:
        api = AppStoreConnectAPI()
        app_id = api.get_app_id("com.leavn.app")
        
        # Basic validation
        if not app_id or len(app_id) < 10:
            raise Exception("App ID appears to be invalid or too short")
        
        print(f"✅ App ID retrieved successfully: {app_id}")
        return app_id
        
    except AppStoreConnectAPIError as e:
        print(f"❌ App ID retrieval failed: {e.message}")
        if e.status_code:
            print(f"   Status Code: {e.status_code}")
        return None
    except Exception as e:
        print(f"❌ App ID retrieval failed: {str(e)}")
        return None

def test_latest_build_retrieval(app_id):
    """Test latest build retrieval"""
    print("\n🏗️ Testing latest build retrieval...")
    try:
        api = AppStoreConnectAPI()
        latest_build = api.get_latest_build(app_id)
        
        # Basic validation
        required_fields = ['id', 'version', 'build_number', 'processing_state', 'uploaded_date']
        for field in required_fields:
            if field not in latest_build:
                raise Exception(f"Missing required field in build info: {field}")
        
        print(f"✅ Latest build retrieved successfully:")
        print(f"   Build ID: {latest_build['id']}")
        print(f"   Version: {latest_build['version']}")
        print(f"   Build Number: {latest_build['build_number']}")
        print(f"   Processing State: {latest_build['processing_state']}")
        print(f"   Uploaded Date: {latest_build['uploaded_date']}")
        return latest_build
        
    except AppStoreConnectAPIError as e:
        print(f"❌ Latest build retrieval failed: {e.message}")
        if e.status_code:
            print(f"   Status Code: {e.status_code}")
        return None
    except Exception as e:
        print(f"❌ Latest build retrieval failed: {str(e)}")
        return None

def test_credentials_validation():
    """Test credentials validation"""
    print("\n🔐 Testing credentials validation...")
    try:
        api = AppStoreConnectAPI()
        
        # Check if all required credentials are loaded
        if not api.api_key_id:
            raise Exception("API Key ID not loaded")
        if not api.issuer_id:
            raise Exception("Issuer ID not loaded")
        if not api.private_key_path:
            raise Exception("Private key path not loaded")
        if not api.private_key:
            raise Exception("Private key not loaded")
        
        print(f"✅ All credentials validated successfully:")
        print(f"   API Key ID: {api.api_key_id}")
        print(f"   Issuer ID: {api.issuer_id}")
        print(f"   Private Key Path: {api.private_key_path}")
        print(f"   Private Key Type: {type(api.private_key).__name__}")
        return True
        
    except Exception as e:
        print(f"❌ Credentials validation failed: {str(e)}")
        return False

def test_convenience_functions():
    """Test the standalone convenience functions"""
    print("\n🔧 Testing convenience functions...")
    try:
        from app_store_api import generate_jwt_token, get_app_id, get_latest_build
        
        # Test standalone JWT generation
        token = generate_jwt_token()
        if not token or len(token) < 100:
            raise Exception("Convenience JWT function failed")
        print(f"✅ Convenience JWT function works: {token[:30]}...")
        
        # Test standalone app ID retrieval
        app_id = get_app_id("com.leavn.app")
        if not app_id:
            raise Exception("Convenience app ID function failed")
        print(f"✅ Convenience app ID function works: {app_id}")
        
        # Test standalone build retrieval
        latest_build = get_latest_build(app_id)
        if not latest_build or 'version' not in latest_build:
            raise Exception("Convenience build function failed")
        print(f"✅ Convenience build function works: {latest_build['version']}")
        
        return True
        
    except Exception as e:
        print(f"❌ Convenience functions test failed: {str(e)}")
        return False

def main():
    """Run all tests"""
    print("🧪 App Store Connect API Integration Test Suite")
    print("=" * 60)
    
    test_results = []
    
    # Test 1: Credentials validation
    test_results.append(("Credentials Validation", test_credentials_validation()))
    
    # Test 2: JWT token generation
    test_results.append(("JWT Token Generation", test_jwt_token_generation()))
    
    # Test 3: App ID retrieval
    app_id = test_app_id_retrieval()
    test_results.append(("App ID Retrieval", app_id is not None))
    
    # Test 4: Latest build retrieval (only if app ID was retrieved)
    if app_id:
        latest_build = test_latest_build_retrieval(app_id)
        test_results.append(("Latest Build Retrieval", latest_build is not None))
    else:
        test_results.append(("Latest Build Retrieval", False))
        print("\n⚠️ Skipping build retrieval test due to app ID failure")
    
    # Test 5: Convenience functions
    test_results.append(("Convenience Functions", test_convenience_functions()))
    
    # Print summary
    print("\n" + "=" * 60)
    print("📊 Test Summary:")
    print("=" * 60)
    
    passed = 0
    total = len(test_results)
    
    for test_name, result in test_results:
        status = "✅ PASS" if result else "❌ FAIL"
        print(f"{status} {test_name}")
        if result:
            passed += 1
    
    print("-" * 60)
    print(f"Results: {passed}/{total} tests passed")
    
    if passed == total:
        print("\n🎉 All tests passed! Your App Store Connect API integration is working correctly.")
        return 0
    else:
        print(f"\n⚠️ {total - passed} test(s) failed. Please check the error messages above.")
        return 1

if __name__ == "__main__":
    try:
        exit_code = main()
        sys.exit(exit_code)
    except KeyboardInterrupt:
        print("\n\n⏹️ Test interrupted by user")
        sys.exit(1)
    except Exception as e:
        print(f"\n\n💥 Unexpected error during testing: {str(e)}")
        print("\nFull traceback:")
        traceback.print_exc()
        sys.exit(1)
