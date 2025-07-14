# TestFlight Submission Guide for Leavn

## 🎯 Pre-Submission Checklist

### ✅ Completed Items
- [x] **Entitlements configured** - Push notifications, iCloud, App Groups
- [x] **Bundle Identifier set** - `com.leavn.app`
- [x] **Privacy keys added** - Camera, Location, Microphone, Photos, User Tracking
- [x] **Launch Screen created** - LaunchScreen.storyboard
- [x] **GoogleService-Info.plist added** - Placeholder ready for Firebase config
- [x] **Build script created** - `build_testflight.sh`

### ⚠️ Required Before Submission

1. **Apple Developer Account Setup**
   - [ ] Sign in to [App Store Connect](https://appstoreconnect.apple.com)
   - [ ] Create App ID for `com.leavn.app`
   - [ ] Create provisioning profiles (Development & Distribution)
   - [ ] Generate API key for automated uploads

2. **Firebase Configuration**
   - [ ] Replace placeholder values in `GoogleService-Info.plist`
   - [ ] Add Firebase project settings from Firebase Console

3. **Update Build Script**
   - [ ] Replace `YOUR_TEAM_ID` with your Apple Developer Team ID
   - [ ] Replace `YOUR_API_KEY` and `YOUR_ISSUER_ID` for App Store Connect API

## 🚀 Build & Upload Process

### Option 1: Using the Build Script (Recommended)
```bash
# Make the script executable
chmod +x build_testflight.sh

# Run the build script
./build_testflight.sh
```

### Option 2: Manual Build in Xcode

1. **Update Version/Build Number**
   - Open project in Xcode
   - Select project > Target > General
   - Update Version (e.g., 1.0.0)
   - Update Build (increment by 1)

2. **Select Generic iOS Device**
   - In Xcode toolbar, select "Any iOS Device (arm64)"

3. **Archive**
   - Product > Archive
   - Wait for build to complete

4. **Upload to TestFlight**
   - Window > Organizer
   - Select your archive
   - Click "Distribute App"
   - Choose "App Store Connect"
   - Select "Upload"
   - Follow prompts

## 📝 App Store Connect Setup

1. **Create New App**
   - Go to App Store Connect > My Apps
   - Click "+" > New App
   - Platform: iOS
   - Bundle ID: com.leavn.app
   - SKU: LEAVN001 (or similar)

2. **TestFlight Tab Configuration**
   - Add App Information
   - Add Test Information
   - Create Beta App Review submission

3. **Test Information Required**
   ```
   Beta App Description: 
   Leavn is a modern Bible study app that helps users engage with 
   scripture through AI-powered insights, community features, and 
   personalized reading plans.

   Beta App Review Instructions:
   1. Sign in with Apple ID
   2. Browse Bible chapters
   3. Try bookmarking verses
   4. Test AI insights feature
   5. Check offline functionality
   ```

## 🧪 Testing Groups

### Internal Testing
- Automatically available to team members
- No review required
- Limited to 100 testers

### External Testing
- Requires Beta App Review
- Up to 10,000 testers
- Create groups for different test focuses:
  - "Beta Testers" - General testing
  - "Church Leaders" - Ministry features
  - "Students" - Study tools

## 🐛 Common Issues & Solutions

### Build Errors
- **Signing issues**: Ensure automatic signing is enabled
- **Missing entitlements**: Check Capabilities tab in Xcode
- **Archive not showing**: Clean build folder (Shift+Cmd+K)

### Upload Errors
- **Invalid binary**: Check minimum iOS version (should be 15.0+)
- **Missing icons**: Add all required app icon sizes
- **Export compliance**: Add encryption exemption if no encryption

### TestFlight Issues
- **Build not appearing**: Wait 5-10 minutes for processing
- **Can't install**: Check device iOS version compatibility
- **Crashes on launch**: Check crash logs in Xcode Organizer

## 📱 Required App Store Assets

Before public release, prepare:
- [ ] App Icon (1024x1024)
- [ ] Screenshots (6.5", 5.5" displays)
- [ ] App Preview video (optional)
- [ ] App description
- [ ] Keywords
- [ ] Support URL
- [ ] Privacy Policy URL

## 🔐 Security Considerations

1. **API Keys**: Never commit real API keys
2. **Certificates**: Store securely in Keychain
3. **Provisioning**: Use App Store Connect for management
4. **Privacy**: Ensure GDPR/CCPA compliance

## 📞 Support

- **Apple Developer Support**: https://developer.apple.com/support/
- **TestFlight Documentation**: https://developer.apple.com/testflight/
- **App Store Connect Help**: https://help.apple.com/app-store-connect/

---

**Next Steps:**
1. Get Apple Developer account credentials
2. Update Firebase configuration
3. Run build script or build manually
4. Submit to TestFlight
5. Invite beta testers

Good luck with your TestFlight submission! 🎉