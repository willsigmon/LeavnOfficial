# API Keys Setup Guide

Detailed instructions for obtaining and configuring API keys for the Leavn Super Official app.

## Table of Contents

- [Overview](#overview)
- [ESV API Setup](#esv-api-setup)
- [ElevenLabs API Setup](#elevenlabs-api-setup)
- [Configuring Keys in the App](#configuring-keys-in-the-app)
- [Security Best Practices](#security-best-practices)
- [Testing API Keys](#testing-api-keys)
- [Troubleshooting](#troubleshooting)

## Overview

The Leavn app requires API keys for full functionality:

| Service | Required | Purpose | Free Tier |
|---------|----------|---------|-----------|
| ESV API | ✅ Yes | Bible text and search | 5,000 requests/day |
| ElevenLabs | ❌ No | AI voice narration | 10,000 characters/month |

## ESV API Setup

### Step 1: Create an Account

1. Visit [api.esv.org](https://api.esv.org)
2. Click "Get Started" or "Sign Up"
3. Fill out the registration form:
   - Name
   - Email address
   - Organization (optional)
   - Intended use: "Personal Bible App"

### Step 2: Verify Email

1. Check your email for verification link
2. Click the link to activate your account
3. Log in to the ESV API dashboard

### Step 3: Generate API Key

1. Navigate to "API Keys" in your dashboard
2. Click "Create New API Key"
3. Configure your key:
   ```
   Name: Leavn App
   Description: iOS Bible reading app
   Allowed Domains: (leave empty for mobile apps)
   ```
4. Click "Generate Key"
5. **Important**: Copy the key immediately (shown only once)

### Step 4: Understand Limits

**Free Tier Limits:**
- 5,000 requests per day
- Rate limit: 2 requests per second
- No commercial use
- Attribution required

**What counts as a request:**
- Getting a passage
- Searching for text
- Getting cross-references

### Example API Key Format

```
Token: a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6
```

## ElevenLabs API Setup

### Step 1: Create an Account

1. Visit [elevenlabs.io](https://elevenlabs.io)
2. Click "Sign Up"
3. Choose sign-up method:
   - Email/Password
   - Google
   - GitHub

### Step 2: Choose a Plan

**Free Tier:**
- 10,000 characters/month
- 3 custom voices
- Standard quality

**Starter ($5/month):**
- 30,000 characters/month
- 10 custom voices
- High quality

### Step 3: Generate API Key

1. Log in to ElevenLabs dashboard
2. Click on your profile picture
3. Select "Profile + API key"
4. Click "Generate API Key"
5. Copy the key (can be regenerated if lost)

### Step 4: Select Voices

1. Go to "Voice Library"
2. Browse available voices
3. Note voice IDs for configuration:

**Recommended Voices:**
```
Rachel (Female): 21m00Tcm4TlvDq8ikWAM
Josh (Male): TxGEqnHWrfWFTfGW9XjX
Elli (Female): MF3mGyEYCl7XYWbV9V6O
Adam (Male): pNInz6obpgDQGcFmaJgB
```

### Example API Key Format

```
xi-api-key: sk_a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0
```

## Configuring Keys in the App

### Method 1: First Launch Setup

When you first launch the app, you'll be guided through setup:

1. **Welcome Screen** → Tap "Get Started"
2. **API Setup** → Enter your ESV API key
3. **Audio Setup** (Optional) → Enter ElevenLabs key
4. **Verify** → App tests the keys
5. **Complete** → Start using the app

### Method 2: Settings Configuration

If you skip initial setup or need to update keys:

1. Open the app
2. Navigate to **Settings** tab
3. Tap **API Configuration**
4. Enter or update your keys:

```
ESV API Key: [Enter your ESV key]
ElevenLabs API Key: [Enter your ElevenLabs key]
```

5. Tap **Save**
6. App verifies and stores keys securely

### Method 3: Debug Menu (Development Only)

For development builds:

1. Go to Settings
2. Tap version number 5 times
3. Debug menu appears
4. Select "Configure API Keys"

## Security Best Practices

### 1. Never Commit Keys

```bash
# .gitignore should include
.env
.env.*
*.keys
Config/Secrets.swift
```

### 2. Use Environment Variables for CI/CD

```yaml
# GitHub Actions example
env:
  ESV_API_KEY: ${{ secrets.ESV_API_KEY }}
  ELEVENLABS_API_KEY: ${{ secrets.ELEVENLABS_API_KEY }}
```

### 3. Keychain Storage

The app stores keys securely in iOS Keychain:

```swift
// Keys are encrypted and protected
// Access requires device unlock
// Not included in backups by default
```

### 4. Key Rotation

**When to rotate keys:**
- Suspected compromise
- Team member leaves
- Regular security practice (quarterly)

**How to rotate:**
1. Generate new key in provider dashboard
2. Update in app settings
3. Revoke old key
4. Monitor for issues

### 5. Separate Keys by Environment

```swift
struct APIKeys {
    static var esvKey: String {
        #if DEBUG
        return ProcessInfo.processInfo.environment["ESV_DEV_KEY"] ?? ""
        #else
        return KeychainManager.shared.getESVKey() ?? ""
        #endif
    }
}
```

## Testing API Keys

### ESV API Test

```bash
# Test via curl
curl -H "Authorization: Token YOUR_API_KEY" \
  "https://api.esv.org/v3/passage/text/?q=John+3:16"

# Expected response
{
  "passages": ["[16] For God so loved the world..."],
  "query": "John 3:16"
}
```

### ElevenLabs API Test

```bash
# Get voices to test key
curl -X GET \
  -H "xi-api-key: YOUR_API_KEY" \
  "https://api.elevenlabs.io/v1/voices"

# Expected: List of available voices
```

### In-App Testing

1. **Settings** → **API Configuration**
2. Tap **Test ESV Connection**
3. Tap **Test ElevenLabs Connection**
4. Check for success messages

## Troubleshooting

### ESV API Issues

#### "Invalid API Key"

**Causes:**
- Key copied incorrectly
- Key not activated
- Wrong environment

**Solutions:**
1. Re-copy key from dashboard
2. Ensure no extra spaces
3. Check key format includes "Token " prefix

#### "Rate Limit Exceeded"

**Causes:**
- Too many requests
- Shared IP hitting limits

**Solutions:**
1. Implement caching
2. Reduce request frequency
3. Upgrade plan if needed

### ElevenLabs API Issues

#### "Insufficient Credits"

**Causes:**
- Monthly limit reached
- Free tier exhausted

**Solutions:**
1. Check usage in dashboard
2. Wait for monthly reset
3. Upgrade plan
4. Implement local caching

#### "Voice Not Found"

**Causes:**
- Invalid voice ID
- Voice removed/changed

**Solutions:**
1. Update voice IDs from dashboard
2. Use default voices
3. Let users select voice

### General Issues

#### Keys Not Saving

**Causes:**
- Keychain access denied
- iOS restrictions

**Solutions:**
1. Check device settings
2. Reinstall app
3. Reset keychain access

#### Keys Work in Debug but Not Release

**Causes:**
- Different bundle IDs
- Keychain access groups

**Solutions:**
1. Verify entitlements
2. Check provisioning profiles
3. Use same keychain group

## API Key Management Tips

### For Individual Developers

1. Use personal keys for development
2. Don't share keys with others
3. Monitor usage regularly
4. Set up usage alerts

### For Teams

1. **Development Keys**
   - Shared test keys
   - Lower limits acceptable
   - Rotate monthly

2. **Production Keys**
   - Restricted access
   - Higher tier plans
   - Monitor closely
   - Audit access

3. **Key Distribution**
   ```bash
   # Use encrypted secrets manager
   # 1Password, Bitwarden, etc.
   
   # Or environment-specific config
   # Development: .env.development
   # Staging: .env.staging
   # Production: Managed by CI/CD
   ```

### Usage Monitoring

1. **ESV Dashboard**
   - Daily request count
   - Error rates
   - Popular endpoints

2. **ElevenLabs Dashboard**
   - Character usage
   - Voice statistics
   - Generation history

3. **In-App Analytics**
   - Track API calls
   - Monitor failures
   - Cache hit rates

## Next Steps

After configuring your API keys:

1. Test basic functionality
2. Configure voice preferences
3. Test offline mode
4. Monitor usage
5. Set up alerts for limits

---

For additional help, see [API Integration Guide](API_GUIDE.md) or contact support.