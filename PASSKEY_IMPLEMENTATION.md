# Passkey Authentication Implementation

## Overview
I've implemented the "Sign up with a passkey" flow for the Leavn app, providing a seamless and secure authentication experience using biometric authentication (Face ID/Touch ID).

## What's Been Implemented

### 1. PasskeyAuthenticationService
- Created `PasskeyAuthenticationService.swift` in `Packages/LeavnCore/Sources/LeavnServices/`
- Implements both registration and authentication flows
- Uses iOS 16+ AuthenticationServices framework
- Includes proper error handling and async/await support

### 2. Updated SignInView
- Added passkey sign-in button that appears after initial setup
- Seamless integration with existing Apple Sign In flow
- Automatic passkey registration after first Apple Sign In
- Persistent state to remember passkey setup

### 3. Associated Domains Configuration
- Updated `Leavn.entitlements` to include `webcredentials:leavn.app`
- Created `apple-app-site-association.json` template

## How It Works

### First Time User Flow:
1. User signs in with Apple ID
2. System automatically prompts to create a passkey
3. User authenticates with Face ID/Touch ID
4. Passkey is saved to iCloud Keychain
5. On next launch, user sees "Sign in with Passkey" option

### Returning User Flow:
1. User taps "Sign in with Passkey"
2. Face ID/Touch ID authentication
3. Instant sign in - no passwords needed!

## Setup Requirements

### 1. Update Team ID
In `apple-app-site-association.json`, replace `TEAMID` with your actual Apple Developer Team ID:
```json
"appID": "YOUR_TEAM_ID.com.leavn.app"
```

### 2. Host apple-app-site-association
The `apple-app-site-association.json` file must be hosted at:
- `https://leavn.app/.well-known/apple-app-site-association`
- Must be served with `Content-Type: application/json`
- Must be accessible without redirects

### 3. Server Implementation (Future)
Currently using mock challenge generation. For production:
- Implement challenge generation endpoint
- Implement credential registration endpoint
- Implement credential verification endpoint
- Store public keys securely

## Benefits

1. **Enhanced Security**: Uses public-key cryptography, immune to phishing
2. **Better UX**: One-tap sign in with biometrics
3. **Cross-Device Sync**: Works across all user's Apple devices via iCloud Keychain
4. **No Passwords**: Eliminates password fatigue and security risks

## Testing

1. Build and run the app on iOS 16+ device
2. Sign in with Apple ID
3. Accept passkey creation prompt
4. Force quit and relaunch app
5. Use "Sign in with Passkey" button

## Notes

- Passkeys require iOS 16 or later
- Currently using mock server endpoints
- Credentials are synced via iCloud Keychain
- Falls back to Apple Sign In on older iOS versions