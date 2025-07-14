# 🚀 TestFlight Quick Start

## What I've Done For You

### ✅ Fixed & Added:
1. **LaunchScreen.storyboard** - Created launch screen
2. **GoogleService-Info.plist** - Added placeholder (needs your Firebase config)
3. **Privacy Keys** - Added all required privacy descriptions
4. **Entitlements** - Configured for push notifications, iCloud, app groups
5. **Build Script** - `build_testflight.sh` for automated builds
6. **Pre-flight Check** - `preflight_check.sh` to verify everything

### 📱 Bundle Configuration:
- Bundle ID: `com.leavn.app`
- Version: 1.0.0
- Build: 1
- Minimum iOS: 15.0

## 🔥 Quick Steps to TestFlight

### 1. Run Pre-flight Check
```bash
chmod +x preflight_check.sh
./preflight_check.sh
```

### 2. Update These Files:
- **GoogleService-Info.plist** - Replace with your Firebase config
- **build_testflight.sh** - Add your Team ID and API credentials

### 3. Build & Upload
```bash
chmod +x build_testflight.sh
./build_testflight.sh
```

Or manually in Xcode:
1. Open `Leavn.xcodeproj`
2. Select "Any iOS Device" 
3. Product → Archive
4. Distribute → App Store Connect → Upload

### 4. In App Store Connect:
1. Create new app with bundle ID `com.leavn.app`
2. Go to TestFlight tab
3. Add test information
4. Invite testers

## ⚠️ Before You Submit:

**Must Have:**
- [ ] Apple Developer Account ($99/year)
- [ ] Signed into Xcode with Apple ID
- [ ] Firebase project created
- [ ] Real GoogleService-Info.plist from Firebase

**Should Update:**
- [ ] Team ID in build script
- [ ] App Store Connect API key (optional, for automation)

## 🆘 Need Help?

Check `TESTFLIGHT_GUIDE.md` for detailed instructions and troubleshooting.

---

**You're 90% ready!** Just need your developer credentials and Firebase config. 🎉