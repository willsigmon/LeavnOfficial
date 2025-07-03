# ✈️ Leavn - Plane Testing Setup

## Quick Device Setup (2 minutes)

### 1. Open Project
```bash
make open
```

### 2. Configure Signing (in Xcode)
1. Select **Leavn** target
2. Go to **Signing & Capabilities** tab
3. Set **Team** to your Apple Developer account
4. Set **Bundle Identifier** to something unique like `com.yourname.leavn`

### 3. Build & Install
1. Connect your iPhone/iPad
2. Select your device in the destination menu
3. Press **⌘R** to build and install
4. **Trust** the developer certificate on your device:
   - Settings → General → VPN & Device Management
   - Find your developer profile and trust it

### 4. Ready for Flight! 🛫

## App Features to Test
- ✅ **Bible Reading** - Offline-first, works without internet
- ✅ **Search** - Find verses and passages
- ✅ **Bookmarks** - Save your favorite verses
- ✅ **Notes** - Add personal study notes
- ✅ **Reading Plans** - Structured Bible study
- ✅ **Apple Sign-In** - Seamless authentication
- ✅ **iCloud Sync** - Your data syncs across devices

## Flight Mode Features
- All Bible content works offline
- Your notes and bookmarks are locally stored
- Reading progress continues without internet
- Sync will resume when you have connectivity

## Troubleshooting
- **Build fails?** Check Team ID in project settings
- **Won't install?** Trust the developer certificate
- **App crashes?** Check Console.app for logs

---
**Built with:** Swift 6, SwiftUI, iOS 18+  
**Platforms:** iPhone, iPad (with Catalyst support for Mac) 