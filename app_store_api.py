#!/usr/bin/env python3
"""
App Store Connect API Integration Module

This module provides functions to interact with the App Store Connect API for:
- JWT token generation using .p8 key files
- Retrieving app IDs for specific bundle identifiers
- Finding the latest TestFlight builds
- Sending beta testing invitations
- Comprehensive error handling and retry logic

Requirements:
- PyJWT library for JWT token generation
- cryptography library for ES256 signature
- requests library for HTTP requests
- python-dotenv for environment variable management

Author: Leavn Development Team
Version: 1.0.0
"""

import os
import sys
import time
import base64
import json
import logging
import argparse
from datetime import datetime, timedelta
from typing import Dict, List, Optional, Tuple, Any
from pathlib import Path
import jwt
import requests
from cryptography.hazmat.primitives import serialization
from cryptography.hazmat.primitives.asymmetric import ec
from dotenv import load_dotenv

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('app_store_api.log'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

class AppStoreConnectAPIError(Exception):
    """Custom exception for App Store Connect API errors"""
    
    def __init__(self, message: str, status_code: Optional[int] = None, response: Optional[Dict] = None):
        self.message = message
        self.status_code = status_code
        self.response = response
        super().__init__(self.message)

class RetryConfig:
    """Configuration for retry logic"""
    
    def __init__(self, max_retries: int = 3, base_delay: float = 1.0, max_delay: float = 60.0):
        self.max_retries = max_retries
        self.base_delay = base_delay
        self.max_delay = max_delay

class AppStoreConnectAPI:
    """
    App Store Connect API client with comprehensive error handling and retry logic
    """
    
    BASE_URL = "https://api.appstoreconnect.apple.com/v1"
    TOKEN_EXPIRY_MINUTES = 20  # Apple's maximum is 20 minutes
    
    def __init__(self, credentials_path: Optional[str] = None):
        """
        Initialize the API client
        
        Args:
            credentials_path: Path to credentials directory, defaults to ./.credentials
        """
        self.credentials_path = credentials_path or "./.credentials"
        self.api_key_id = None
        self.issuer_id = None
        self.private_key_path = None
        self.private_key = None
        self.current_token = None
        self.token_expires_at = None
        self.retry_config = RetryConfig()
        
        # Load credentials
        self._load_credentials()
        self._load_private_key()
    
    def _load_credentials(self):
        """Load API credentials from environment file"""
        env_file = Path(self.credentials_path) / "api_credentials.env"
        
        if not env_file.exists():
            raise AppStoreConnectAPIError(
                f"Credentials file not found: {env_file}\n"
                "Please run './setup_api_credentials.sh' to set up your credentials"
            )
        
        # Load environment variables from file
        load_dotenv(env_file)
        
        self.api_key_id = os.getenv("APP_STORE_API_KEY_ID")
        self.issuer_id = os.getenv("APP_STORE_API_ISSUER_ID") 
        self.private_key_path = os.getenv("APP_STORE_API_PRIVATE_KEY_PATH")
        
        # Expand environment variables in the private key path
        if self.private_key_path:
            self.private_key_path = os.path.expandvars(self.private_key_path)
            # Handle $(pwd) specifically
            if '$(pwd)' in self.private_key_path:
                current_dir = os.getcwd()
                self.private_key_path = self.private_key_path.replace('$(pwd)', current_dir)
        
        # Validate required credentials
        if not all([self.api_key_id, self.issuer_id, self.private_key_path]):
            missing = []
            if not self.api_key_id:
                missing.append("APP_STORE_API_KEY_ID")
            if not self.issuer_id:
                missing.append("APP_STORE_API_ISSUER_ID")
            if not self.private_key_path:
                missing.append("APP_STORE_API_PRIVATE_KEY_PATH")
            
            raise AppStoreConnectAPIError(
                f"Missing required credentials: {', '.join(missing)}"
            )
        
        logger.info("API credentials loaded successfully")
        logger.debug(f"API Key ID: {self.api_key_id}")
        logger.debug(f"Issuer ID: {self.issuer_id}")
        logger.debug(f"Private Key Path: {self.private_key_path}")
    
    def _load_private_key(self):
        """Load and validate the private key file"""
        key_path = Path(self.private_key_path)
        
        if not key_path.exists():
            raise AppStoreConnectAPIError(
                f"Private key file not found: {key_path}\n"
                f"Expected: AuthKey_{self.api_key_id}.p8"
            )
        
        try:
            with open(key_path, 'rb') as key_file:
                self.private_key = serialization.load_pem_private_key(
                    key_file.read(),
                    password=None
                )
            
            # Validate key type
            if not isinstance(self.private_key, ec.EllipticCurvePrivateKey):
                raise AppStoreConnectAPIError(
                    "Private key must be an Elliptic Curve key for ES256 algorithm"
                )
            
            logger.info("Private key loaded and validated successfully")
            
        except Exception as e:
            raise AppStoreConnectAPIError(
                f"Failed to load private key: {str(e)}"
            )
    
    def generate_jwt_token(self) -> str:
        """
        Generate JWT token using the .p8 key file
        
        Returns:
            str: JWT token for App Store Connect API authentication
            
        Raises:
            AppStoreConnectAPIError: If token generation fails
        """
        try:
            # Check if current token is still valid
            if (self.current_token and self.token_expires_at and 
                datetime.utcnow() < self.token_expires_at - timedelta(minutes=1)):
                logger.debug("Using existing valid JWT token")
                return self.current_token
            
            # Create JWT payload
            now = datetime.utcnow()
            expiry = now + timedelta(minutes=self.TOKEN_EXPIRY_MINUTES)
            
            payload = {
                'iss': self.issuer_id,
                'exp': int(expiry.timestamp()),
                'aud': 'appstoreconnect-v1'
            }
            
            # Create JWT header
            headers = {
                'kid': self.api_key_id,
                'alg': 'ES256',
                'typ': 'JWT'
            }
            
            # Generate token
            token = jwt.encode(
                payload=payload,
                key=self.private_key,
                algorithm='ES256',
                headers=headers
            )
            
            # Update cached token
            self.current_token = token
            self.token_expires_at = expiry
            
            logger.info("JWT token generated successfully")
            logger.debug(f"Token expires at: {expiry}")
            
            return token
            
        except Exception as e:
            raise AppStoreConnectAPIError(
                f"Failed to generate JWT token: {str(e)}"
            )
    
    def _make_request(self, method: str, endpoint: str, params: Optional[Dict] = None, 
                     data: Optional[Dict] = None) -> Dict:
        """
        Make authenticated request to App Store Connect API with retry logic
        
        Args:
            method: HTTP method (GET, POST, etc.)
            endpoint: API endpoint (without base URL)
            params: Query parameters
            data: Request body data
            
        Returns:
            Dict: API response data
            
        Raises:
            AppStoreConnectAPIError: If request fails after retries
        """
        url = f"{self.BASE_URL}/{endpoint.lstrip('/')}"
        
        for attempt in range(self.retry_config.max_retries + 1):
            try:
                # Generate fresh token for each attempt
                token = self.generate_jwt_token()
                
                headers = {
                    'Authorization': f'Bearer {token}',
                    'Content-Type': 'application/json'
                }
                
                logger.debug(f"Making {method} request to {url} (attempt {attempt + 1})")
                
                # Make request
                response = requests.request(
                    method=method,
                    url=url,
                    headers=headers,
                    params=params,
                    json=data,
                    timeout=30
                )
                
                # Handle response
                if response.status_code == 200:
                    return response.json()
                elif response.status_code == 201:
                    return response.json()
                elif response.status_code in [401, 403]:
                    # Authentication/authorization errors - don't retry
                    error_detail = ""
                    try:
                        error_data = response.json()
                        if 'errors' in error_data and error_data['errors']:
                            error_detail = error_data['errors'][0].get('detail', '')
                    except:
                        error_detail = response.text
                    
                    raise AppStoreConnectAPIError(
                        f"Authentication failed: {error_detail}",
                        status_code=response.status_code,
                        response=error_data if 'error_data' in locals() else None
                    )
                elif response.status_code == 404:
                    # Resource not found - don't retry
                    raise AppStoreConnectAPIError(
                        f"Resource not found: {endpoint}",
                        status_code=response.status_code
                    )
                elif response.status_code == 429:
                    # Rate limited - wait longer before retry
                    if attempt < self.retry_config.max_retries:
                        delay = min(self.retry_config.base_delay * (2 ** attempt) * 2, 
                                  self.retry_config.max_delay)
                        logger.warning(f"Rate limited, waiting {delay} seconds before retry...")
                        time.sleep(delay)
                        continue
                    else:
                        raise AppStoreConnectAPIError(
                            "Rate limit exceeded",
                            status_code=response.status_code
                        )
                else:
                    # Other errors - retry with exponential backoff
                    if attempt < self.retry_config.max_retries:
                        delay = min(self.retry_config.base_delay * (2 ** attempt), 
                                  self.retry_config.max_delay)
                        logger.warning(f"Request failed with status {response.status_code}, "
                                     f"retrying in {delay} seconds...")
                        time.sleep(delay)
                        continue
                    else:
                        try:
                            error_data = response.json()
                        except:
                            error_data = {"detail": response.text}
                        
                        raise AppStoreConnectAPIError(
                            f"Request failed with status {response.status_code}",
                            status_code=response.status_code,
                            response=error_data
                        )
                        
            except requests.RequestException as e:
                if attempt < self.retry_config.max_retries:
                    delay = min(self.retry_config.base_delay * (2 ** attempt), 
                              self.retry_config.max_delay)
                    logger.warning(f"Network error: {str(e)}, retrying in {delay} seconds...")
                    time.sleep(delay)
                    continue
                else:
                    raise AppStoreConnectAPIError(f"Network error: {str(e)}")
    
    def get_app_id(self, bundle_id: str = "com.leavn.app") -> str:
        """
        Retrieve the app ID for the specified bundle identifier
        
        Args:
            bundle_id: Bundle identifier (defaults to com.leavn.app)
            
        Returns:
            str: App ID
            
        Raises:
            AppStoreConnectAPIError: If app not found or request fails
        """
        try:
            logger.info(f"Retrieving app ID for bundle: {bundle_id}")
            
            params = {
                'filter[bundleId]': bundle_id,
                'fields[apps]': 'bundleId,name,sku'
            }
            
            response = self._make_request('GET', '/apps', params=params)
            
            if not response.get('data'):
                raise AppStoreConnectAPIError(
                    f"No app found with bundle ID: {bundle_id}"
                )
            
            app_data = response['data'][0]
            app_id = app_data['id']
            app_name = app_data['attributes']['name']
            
            logger.info(f"Found app: {app_name} (ID: {app_id})")
            return app_id
            
        except AppStoreConnectAPIError:
            raise
        except Exception as e:
            raise AppStoreConnectAPIError(f"Failed to retrieve app ID: {str(e)}")
    
    def get_latest_build(self, app_id: Optional[str] = None, bundle_id: str = "com.leavn.app") -> Dict:
        """
        Find the most recent TestFlight build
        
        Args:
            app_id: App ID (if not provided, will be retrieved using bundle_id)
            bundle_id: Bundle identifier (used if app_id not provided)
            
        Returns:
            Dict: Build information including version, build number, and status
            
        Raises:
            AppStoreConnectAPIError: If no builds found or request fails
        """
        try:
            if not app_id:
                app_id = self.get_app_id(bundle_id)
            
            logger.info(f"Retrieving latest build for app ID: {app_id}")
            
            params = {
                'filter[app]': app_id,
                'sort': '-uploadedDate',
                'limit': '1',
                'fields[builds]': 'version,buildNumber,processingState,uploadedDate',
                'include': 'app'
            }
            
            response = self._make_request('GET', '/builds', params=params)
            
            if not response.get('data'):
                raise AppStoreConnectAPIError(
                    f"No builds found for app ID: {app_id}"
                )
            
            build_data = response['data'][0]
            build_info = {
                'id': build_data['id'],
                'version': build_data['attributes']['version'],
                'build_number': build_data['attributes']['buildNumber'],
                'processing_state': build_data['attributes']['processingState'],
                'uploaded_date': build_data['attributes']['uploadedDate']
            }
            
            logger.info(f"Latest build: {build_info['version']} ({build_info['build_number']}) "
                       f"- Status: {build_info['processing_state']}")
            
            return build_info
            
        except AppStoreConnectAPIError:
            raise
        except Exception as e:
            raise AppStoreConnectAPIError(f"Failed to retrieve latest build: {str(e)}")
    
    def invite_tester(self, email: str, first_name: str, last_name: str, 
                     app_id: Optional[str] = None, bundle_id: str = "com.leavn.app") -> Dict:
        """
        Send beta testing invitation via API
        
        Args:
            email: Tester's email address
            first_name: Tester's first name
            last_name: Tester's last name
            app_id: App ID (if not provided, will be retrieved using bundle_id)
            bundle_id: Bundle identifier (used if app_id not provided)
            
        Returns:
            Dict: Invitation result including tester ID and status
            
        Raises:
            AppStoreConnectAPIError: If invitation fails
        """
        try:
            if not app_id:
                app_id = self.get_app_id(bundle_id)
            
            logger.info(f"Inviting tester: {email} ({first_name} {last_name})")
            
            # Check if tester already exists
            existing_tester = self._find_existing_tester(email)
            
            if existing_tester:
                logger.info(f"Tester {email} already exists, adding to app...")
                tester_id = existing_tester['id']
            else:
                # Create new beta tester
                logger.info(f"Creating new beta tester: {email}")
                tester_data = {
                    'data': {
                        'type': 'betaTesters',
                        'attributes': {
                            'email': email,
                            'firstName': first_name,
                            'lastName': last_name
                        }
                    }
                }
                
                response = self._make_request('POST', '/betaTesters', data=tester_data)
                tester_id = response['data']['id']
                logger.info(f"Created beta tester with ID: {tester_id}")
            
            # Add tester to app
            self._add_tester_to_app(tester_id, app_id)
            
            # Get latest build and add tester to it
            latest_build = self.get_latest_build(app_id)
            if latest_build['processing_state'] == 'PROCESSING':
                logger.warning("Latest build is still processing, tester will be added when ready")
            else:
                self._add_tester_to_build(tester_id, latest_build['id'])
            
            result = {
                'tester_id': tester_id,
                'email': email,
                'status': 'invited',
                'app_id': app_id,
                'build_id': latest_build['id'],
                'build_version': latest_build['version']
            }
            
            logger.info(f"Successfully invited tester {email}")
            return result
            
        except AppStoreConnectAPIError:
            raise
        except Exception as e:
            raise AppStoreConnectAPIError(f"Failed to invite tester {email}: {str(e)}")
    
    def _find_existing_tester(self, email: str) -> Optional[Dict]:
        """Find existing beta tester by email"""
        try:
            params = {
                'filter[email]': email,
                'fields[betaTesters]': 'email,firstName,lastName'
            }
            
            response = self._make_request('GET', '/betaTesters', params=params)
            
            if response.get('data'):
                return response['data'][0]
            return None
            
        except AppStoreConnectAPIError:
            # If we can't check, assume tester doesn't exist
            logger.warning(f"Could not check for existing tester {email}")
            return None
    
    def _add_tester_to_app(self, tester_id: str, app_id: str):
        """Add beta tester to app"""
        try:
            relationship_data = {
                'data': {
                    'type': 'apps',
                    'id': app_id
                }
            }
            
            self._make_request('POST', f'/betaTesters/{tester_id}/relationships/apps', 
                             data=relationship_data)
            logger.debug(f"Added tester {tester_id} to app {app_id}")
            
        except AppStoreConnectAPIError as e:
            if e.status_code == 409:
                # Tester already added to app
                logger.debug(f"Tester {tester_id} already added to app {app_id}")
            else:
                raise
    
    def _add_tester_to_build(self, tester_id: str, build_id: str):
        """Add beta tester to specific build"""
        try:
            relationship_data = {
                'data': [
                    {
                        'type': 'betaTesters',
                        'id': tester_id
                    }
                ]
            }
            
            self._make_request('POST', f'/builds/{build_id}/relationships/individualTesters', 
                             data=relationship_data)
            logger.debug(f"Added tester {tester_id} to build {build_id}")
            
        except AppStoreConnectAPIError as e:
            if e.status_code == 409:
                # Tester already added to build
                logger.debug(f"Tester {tester_id} already added to build {build_id}")
            else:
                raise
    
    def invite_multiple_testers(self, testers: List[Dict], app_id: Optional[str] = None, 
                              bundle_id: str = "com.leavn.app") -> Dict:
        """
        Invite multiple beta testers
        
        Args:
            testers: List of tester dictionaries with 'email', 'first_name', 'last_name'
            app_id: App ID (if not provided, will be retrieved using bundle_id)
            bundle_id: Bundle identifier (used if app_id not provided)
            
        Returns:
            Dict: Summary of invitation results
        """
        if not app_id:
            app_id = self.get_app_id(bundle_id)
        
        results = {
            'successful': [],
            'failed': [],
            'already_invited': [],
            'total': len(testers)
        }
        
        logger.info(f"Inviting {len(testers)} testers...")
        
        for i, tester in enumerate(testers, 1):
            try:
                logger.info(f"Processing tester {i}/{len(testers)}: {tester['email']}")
                
                result = self.invite_tester(
                    email=tester['email'],
                    first_name=tester['first_name'],
                    last_name=tester['last_name'],
                    app_id=app_id
                )
                
                results['successful'].append({
                    'email': tester['email'],
                    'tester_id': result['tester_id']
                })
                
            except AppStoreConnectAPIError as e:
                if "already exists" in str(e).lower():
                    results['already_invited'].append({
                        'email': tester['email'],
                        'error': str(e)
                    })
                else:
                    results['failed'].append({
                        'email': tester['email'],
                        'error': str(e)
                    })
                logger.error(f"Failed to invite {tester['email']}: {str(e)}")
            
            # Add small delay to avoid rate limiting
            time.sleep(0.5)
        
        logger.info(f"Invitation complete: {len(results['successful'])} successful, "
                   f"{len(results['failed'])} failed, {len(results['already_invited'])} already invited")
        
        return results

# Convenience functions for standalone usage
def generate_jwt_token(credentials_path: Optional[str] = None) -> str:
    """
    Generate JWT token using the .p8 key file
    
    Args:
        credentials_path: Path to credentials directory
        
    Returns:
        str: JWT token
    """
    api = AppStoreConnectAPI(credentials_path)
    return api.generate_jwt_token()

def get_app_id(bundle_id: str = "com.leavn.app", credentials_path: Optional[str] = None) -> str:
    """
    Retrieve the app ID for bundle com.leavn.app
    
    Args:
        bundle_id: Bundle identifier
        credentials_path: Path to credentials directory
        
    Returns:
        str: App ID
    """
    api = AppStoreConnectAPI(credentials_path)
    return api.get_app_id(bundle_id)

def get_latest_build(app_id: Optional[str] = None, bundle_id: str = "com.leavn.app", 
                    credentials_path: Optional[str] = None) -> Dict:
    """
    Find the most recent TestFlight build
    
    Args:
        app_id: App ID (if not provided, will be retrieved)
        bundle_id: Bundle identifier
        credentials_path: Path to credentials directory
        
    Returns:
        Dict: Build information
    """
    api = AppStoreConnectAPI(credentials_path)
    return api.get_latest_build(app_id, bundle_id)

def invite_tester(email: str, first_name: str, last_name: str, app_id: Optional[str] = None, 
                 bundle_id: str = "com.leavn.app", credentials_path: Optional[str] = None) -> Dict:
    """
    Send beta testing invitation via API
    
    Args:
        email: Tester's email address
        first_name: Tester's first name
        last_name: Tester's last name
        app_id: App ID (if not provided, will be retrieved)
        bundle_id: Bundle identifier
        credentials_path: Path to credentials directory
        
    Returns:
        Dict: Invitation result
    """
    api = AppStoreConnectAPI(credentials_path)
    return api.invite_tester(email, first_name, last_name, app_id, bundle_id)

# Example usage and testing functions
def check_build_status(api: AppStoreConnectAPI, bundle_id: str = "com.leavn.app") -> bool:
    """
    Check if the latest build is ready for testing
    
    Args:
        api: AppStoreConnectAPI instance
        bundle_id: Bundle identifier
        
    Returns:
        bool: True if build is ready, False otherwise
    """
    try:
        print("\n🏗️  Checking if the latest build is ready for testing...")
        app_id = api.get_app_id(bundle_id)
        latest_build = api.get_latest_build(app_id)
        
        print(f"\n✅ Latest build found:")
        print(f"   Version: {latest_build['version']}")
        print(f"   Build Number: {latest_build['build_number']}")
        print(f"   Status: {latest_build['processing_state']}")
        print(f"   Uploaded: {latest_build['uploaded_date']}")
        
        if latest_build['processing_state'] == 'READY_FOR_TESTING':
            print(f"\n✅ Build is ready for testing!")
            return True
        else:
            print(f"\n⚠️  Build is not ready yet. Current state: {latest_build['processing_state']}")
            return False
            
    except Exception as e:
        print(f"\n❌ Error checking build status: {str(e)}")
        return False


def show_invitation_status(api: AppStoreConnectAPI, app_id: Optional[str] = None) -> None:
    """
    Show status of previously sent invitations
    
    Args:
        api: AppStoreConnectAPI instance
        app_id: App ID (if not provided, will be retrieved)
    """
    try:
        print("\n📬 Checking status of previously sent invitations...")
        
        if not app_id:
            app_id = api.get_app_id("com.leavn.app")
        
        # Get beta testers
        headers = {'Authorization': f'Bearer {api.generate_jwt_token()}'}
        response = api._make_request(
            method='GET',
            endpoint=f'/apps/{app_id}/betaTesters',
            headers=headers
        )
        
        if response.get('data'):
            testers = response['data']
            print(f"\n📊 Total beta testers: {len(testers)}")
            
            # Group by invitation status
            invited = [t for t in testers if t.get('attributes', {}).get('inviteType')]
            accepted = [t for t in testers if t.get('attributes', {}).get('state') == 'ACCEPTED']
            
            print(f"\n✉️  Invitations sent: {len(invited)}")
            print(f"✅ Invitations accepted: {len(accepted)}")
            print(f"⏳ Pending acceptance: {len(invited) - len(accepted)}")
            
            # Show recent invitations
            print("\n📋 Recent invitations (last 10):")
            recent_testers = sorted(testers, 
                                   key=lambda x: x.get('attributes', {}).get('addedDate', ''), 
                                   reverse=True)[:10]
            
            for tester in recent_testers:
                attrs = tester.get('attributes', {})
                email = attrs.get('email', 'Unknown')
                state = attrs.get('state', 'Unknown')
                added_date = attrs.get('addedDate', 'Unknown')
                
                status_icon = "✅" if state == 'ACCEPTED' else "⏳"
                print(f"   {status_icon} {email:<30} - Status: {state:<10} - Added: {added_date}")
        else:
            print("\n⚠️  No beta testers found")
            
    except Exception as e:
        print(f"\n❌ Error checking invitation status: {str(e)}")


def validate_emails_dry_run(emails: List[str]) -> Dict[str, List[str]]:
    """
    Validate emails without sending invitations
    
    Args:
        emails: List of email addresses to validate
        
    Returns:
        Dict with 'valid' and 'invalid' email lists
    """
    import re
    
    print("\n✉️  Validating emails without sending invitations...")
    
    # Email validation regex
    email_pattern = re.compile(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
    
    valid_emails = []
    invalid_emails = []
    
    for email in emails:
        if email_pattern.match(email.strip()):
            valid_emails.append(email.strip())
        else:
            invalid_emails.append(email.strip())
    
    # Remove duplicates
    valid_emails = list(set(valid_emails))
    
    print(f"\n📊 Validation Results:")
    print(f"   Total emails provided: {len(emails)}")
    print(f"   Valid emails: {len(valid_emails)}")
    print(f"   Invalid emails: {len(invalid_emails)}")
    print(f"   Duplicates removed: {len(emails) - len(valid_emails) - len(invalid_emails)}")
    
    if invalid_emails:
        print("\n❌ Invalid emails:")
        for email in invalid_emails:
            print(f"   - {email}")
    
    if valid_emails:
        print("\n✅ Valid emails (ready to send):")
        for i, email in enumerate(valid_emails[:10], 1):  # Show first 10
            print(f"   {i}. {email}")
        if len(valid_emails) > 10:
            print(f"   ... and {len(valid_emails) - 10} more")
    
    return {'valid': valid_emails, 'invalid': invalid_emails}


def process_and_send_invitations(api: AppStoreConnectAPI, emails: List[str], 
                               bundle_id: str = "com.leavn.app") -> None:
    """
    Process and send invitations to testers
    
    Args:
        api: AppStoreConnectAPI instance
        emails: List of email addresses
        bundle_id: Bundle identifier
    """
    try:
        print("\n✉️  Processing and sending invitations...")
        
        # Validate emails first
        validation_result = validate_emails_dry_run(emails)
        valid_emails = validation_result['valid']
        
        if not valid_emails:
            print("\n⚠️  No valid emails to process")
            return
        
        # Get app ID
        app_id = api.get_app_id(bundle_id)
        
        # Process invitations in batches
        batch_results = api.invite_testers_batch(
            testers=[(email, "TestFlight", "Tester") for email in valid_emails],
            app_id=app_id
        )
        
        # Show results
        print(f"\n📊 Invitation Results:")
        print(f"   ✅ Successful: {len(batch_results['successful'])}")
        print(f"   ❌ Failed: {len(batch_results['failed'])}")
        print(f"   ⚠️  Already invited: {len(batch_results['already_invited'])}")
        
        if batch_results['failed']:
            print("\n❌ Failed invitations:")
            for failure in batch_results['failed']:
                print(f"   - {failure['email']}: {failure['error']}")
        
        if batch_results['already_invited']:
            print("\n⚠️  Already invited:")
            for email in batch_results['already_invited'][:10]:  # Show first 10
                print(f"   - {email}")
            if len(batch_results['already_invited']) > 10:
                print(f"   ... and {len(batch_results['already_invited']) - 10} more")
                
    except Exception as e:
        print(f"\n❌ Error processing invitations: {str(e)}")


def main():
    """
    Main entry point with command-line interface
    """
    parser = argparse.ArgumentParser(
        description="TestFlight Invitation Management Script for Leavn App",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s --check-build          # Check if latest build is ready
  %(prog)s --status               # Show invitation status
  %(prog)s --dry-run              # Validate emails without sending
  %(prog)s                        # Process and send invitations (default)

Notes:
  - Ensure API credentials are set up via setup_api_credentials.sh
  - Log files are created in the app_store_api.log file
  - Maximum 50 invitations recommended per batch
        """
    )
    
    parser.add_argument(
        '--check-build', 
        action='store_true', 
        help='Check if latest build is ready for testing'
    )
    parser.add_argument(
        '--status', 
        action='store_true', 
        help='Show status of previously sent invitations'
    )
    parser.add_argument(
        '--dry-run', 
        action='store_true', 
        help='Validate emails without sending invitations'
    )
    parser.add_argument(
        '--emails', 
        nargs='+', 
        help='Email addresses to process (space-separated)'
    )
    parser.add_argument(
        '--bundle-id',
        default='com.leavn.app',
        help='Bundle identifier (default: com.leavn.app)'
    )
    
    args = parser.parse_args()
    
    # Initialize API client
    try:
        api = AppStoreConnectAPI()
    except AppStoreConnectAPIError as e:
        print(f"\n❌ Failed to initialize API client: {e.message}")
        print("\nPlease ensure you have run './setup_api_credentials.sh' first")
        return 1
    
    try:
        # Handle different commands
        if args.check_build:
            success = check_build_status(api, args.bundle_id)
            return 0 if success else 1
            
        elif args.status:
            show_invitation_status(api)
            return 0
            
        elif args.dry_run:
            if not args.emails:
                print("\n⚠️  No emails provided. Use --emails option to specify email addresses.")
                return 1
            validate_emails_dry_run(args.emails)
            return 0
            
        else:
            # Default behavior: process and send invitations
            if not args.emails:
                # Example emails for demonstration
                print("\n⚠️  No emails provided. Using example emails for demonstration.")
                print("   Use --emails option to specify real email addresses.")
                example_emails = [
                    "tester1@example.com",
                    "tester2@example.com",
                    "tester3@example.com"
                ]
                process_and_send_invitations(api, example_emails, args.bundle_id)
            else:
                process_and_send_invitations(api, args.emails, args.bundle_id)
            return 0
            
    except KeyboardInterrupt:
        print("\n\n⚠️  Operation cancelled by user")
        return 130
    except Exception as e:
        print(f"\n❌ Unexpected error: {str(e)}")
        logger.exception("Unexpected error in main")
        return 1

if __name__ == "__main__":
    sys.exit(main())
