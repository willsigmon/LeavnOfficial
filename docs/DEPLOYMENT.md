# Deployment Guide

Complete guide for deploying the Leavn Super Official app to TestFlight and the App Store.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Pre-Deployment Checklist](#pre-deployment-checklist)
- [Version Management](#version-management)
- [Building for Release](#building-for-release)
- [TestFlight Deployment](#testflight-deployment)
- [App Store Submission](#app-store-submission)
- [Post-Release Process](#post-release-process)
- [Troubleshooting](#troubleshooting)
- [Automation with Fastlane](#automation-with-fastlane)

## Prerequisites

### Apple Developer Account

1. **Enrollment**
   - Apple Developer Program membership ($99/year)
   - Organization or Individual account
   - D-U-N-S number (for organizations)

2. **Certificates & Profiles**
   ```bash
   # Using Fastlane Match (recommended)
   fastlane match appstore
   fastlane match development
   ```

3. **App Store Connect Access**
   - Admin or App Manager role
   - Two-factor authentication enabled

### Development Environment

- **Xcode**: 15.0+ with valid developer account
- **macOS**: 13.0+ (Ventura or later)
- **Fastlane**: Installed and configured
- **Git**: Clean working directory

## Pre-Deployment Checklist

### Code Quality

- [ ] All tests passing
  ```bash
  swift test
  ./Scripts/run-tests.sh
  ```

- [ ] No compiler warnings
- [ ] Code review completed
- [ ] Performance profiling done
- [ ] Memory leaks checked

### API Configuration

- [ ] Production API endpoints configured
- [ ] API keys removed from code
- [ ] Rate limiting implemented
- [ ] Error handling tested

### Security

- [ ] Keychain integration verified
- [ ] No hardcoded secrets
- [ ] Network security configured
- [ ] Privacy manifest updated

### UI/UX

- [ ] All screens tested on various devices
- [ ] Dark mode support verified
- [ ] Accessibility features working
- [ ] Localization complete (if applicable)

### Legal

- [ ] Privacy Policy URL valid
- [ ] Terms of Service URL valid
- [ ] Third-party licenses included
- [ ] Export compliance documented

## Version Management

### Semantic Versioning

Follow semantic versioning (MAJOR.MINOR.PATCH):

- **MAJOR**: Breaking changes
- **MINOR**: New features, backward compatible
- **PATCH**: Bug fixes

### Version Bumping

```bash
# Using the version bump script
./Scripts/CI/version-bump.sh patch  # 1.0.0 -> 1.0.1
./Scripts/CI/version-bump.sh minor  # 1.0.1 -> 1.1.0
./Scripts/CI/version-bump.sh major  # 1.1.0 -> 2.0.0
```

### Build Numbers

Build numbers must be unique and incrementing:

```swift
// In project settings
CURRENT_PROJECT_VERSION = 42  // Increment for each upload
MARKETING_VERSION = 1.0.0     // User-facing version
```

## Building for Release

### 1. Clean Build

```bash
# Clean build folder
rm -rf ~/Library/Developer/Xcode/DerivedData

# Or in Xcode
Product > Clean Build Folder (Shift+Cmd+K)
```

### 2. Update Configuration

```swift
// AppEnvironment.swift
static let current: AppEnvironment = .production

// Verify production settings
struct ProductionEnvironment {
    static let apiBaseURL = "https://api.leavn.app"
    static let websocketURL = "wss://ws.leavn.app"
    static let analyticsEnabled = true
    static let debugMenuEnabled = false
}
```

### 3. Archive Build

#### Using Xcode

1. Select Generic iOS Device or Any iOS Device
2. Product > Archive
3. Wait for archive to complete
4. Organizer window opens automatically

#### Using Command Line

```bash
xcodebuild archive \
  -scheme "Leavn" \
  -configuration Release \
  -archivePath ./build/Leavn.xcarchive \
  -destination "generic/platform=iOS"
```

### 4. Export IPA

```bash
xcodebuild -exportArchive \
  -archivePath ./build/Leavn.xcarchive \
  -exportPath ./build \
  -exportOptionsPlist ExportOptions.plist
```

## TestFlight Deployment

### 1. Upload to App Store Connect

#### Using Xcode Organizer

1. Open Organizer (Window > Organizer)
2. Select your archive
3. Click "Distribute App"
4. Choose "App Store Connect"
5. Select "Upload"
6. Follow the prompts

#### Using Fastlane

```bash
fastlane beta
```

### 2. TestFlight Configuration

#### Build Information

```yaml
What's New:
- Feature: Bible audio narration
- Feature: Community prayer wall
- Enhancement: Improved search
- Fix: Offline mode stability
- Fix: Memory optimization

Test Information:
Please test the following:
1. Bible navigation and reading
2. Audio playback functionality
3. Community features
4. Offline mode
5. Settings and customization
```

#### Beta App Review

Required information:
- **Demo Account**: Provide test credentials
- **Notes**: Special instructions for reviewers
- **Contact Info**: Developer contact

### 3. Tester Management

#### Internal Testing

- Add up to 100 internal testers
- No review required
- Immediate availability

```bash
# Add internal testers via Fastlane
fastlane add_internal_testers emails:"tester1@example.com,tester2@example.com"
```

#### External Testing

- Up to 10,000 external testers
- Requires Beta App Review
- Groups for organized testing

### 4. Crash Reporting

Monitor TestFlight crashes:

1. App Store Connect > TestFlight > Crashes
2. Integrate crash reporting service
3. Symbol upload for crash reports

```bash
# Upload dSYMs
fastlane upload_symbols_to_crashlytics
```

## App Store Submission

### 1. App Information

#### Basic Information

- **App Name**: Leavn - Bible Study
- **Subtitle**: Read, Listen, Share God's Word
- **Category**: Primary: Books, Secondary: Education
- **Content Rating**: 4+

#### Description

```markdown
Leavn brings the Bible to life with a beautiful reading experience, 
AI-powered audio narration, and vibrant community features.

FEATURES:
• Full ESV Bible with offline access
• AI voice narration for any passage
• Highlight, bookmark, and take notes
• Share prayer requests with the community
• Join Bible study groups
• Daily verses and reading plans
• Beautiful themes and customization

Start your journey with God's Word today!
```

### 2. Screenshots

Required sizes:
- **iPhone 6.7"**: 1290 x 2796
- **iPhone 6.5"**: 1242 x 2688 (optional)
- **iPhone 5.5"**: 1242 x 2208 (optional)
- **iPad 12.9"**: 2048 x 2732

Screenshot checklist:
- [ ] Home/Bible reading screen
- [ ] Audio playback
- [ ] Community features
- [ ] Library/bookmarks
- [ ] Settings/customization

### 3. App Preview Video (Optional)

- 15-30 seconds
- Same sizes as screenshots
- Showcase key features
- Include captions

### 4. Keywords

```
bible,esv,study,audio,christian,
scripture,verse,prayer,devotional,faith
```

### 5. Support Information

- **Support URL**: https://leavn.app/support
- **Privacy Policy**: https://leavn.app/privacy
- **Terms of Service**: https://leavn.app/terms
- **Copyright**: © 2024 Leavn. All rights reserved.

### 6. Review Information

#### Demo Account
```
Username: appreview@leavn.app
Password: ReviewTest123!
```

#### Review Notes
```
The app requires API keys for full functionality:
1. ESV API key is pre-configured for review
2. Audio features use ElevenLabs (optional)
3. Community features connect to our backend

Please test on iPhone and iPad for best experience.
```

### 7. Release Options

- **Automatic Release**: After approval
- **Manual Release**: Control timing
- **Phased Release**: 7-day rollout

## Post-Release Process

### 1. Monitor Performance

#### Crashes and Performance

```swift
// App Store Connect metrics to monitor
- Crash rate < 0.5%
- App launch time < 400ms
- Memory usage < 200MB
- Battery drain minimal
```

#### User Feedback

- App Store reviews
- TestFlight feedback
- Support emails
- Social media

### 2. Responding to Issues

#### Hotfix Process

1. Identify critical issue
2. Create hotfix branch
3. Fix and test thoroughly
4. Expedited review if needed

```bash
# Hotfix workflow
git checkout -b hotfix/1.0.1 main
# Make fixes
git commit -m "Fix critical crash in audio player"
fastlane hotfix
```

### 3. Analytics

Track key metrics:
- Daily Active Users (DAU)
- Session duration
- Feature adoption
- Crash-free sessions
- API usage

## Troubleshooting

### Common Issues

#### "Missing Compliance" Error

```xml
<!-- Add to Info.plist -->
<key>ITSAppUsesNonExemptEncryption</key>
<false/>
```

#### Invalid Binary

Common causes:
- Missing required device capabilities
- Invalid bundle identifier
- Provisioning profile mismatch
- Missing required keys in Info.plist

#### Beta Review Rejection

Common reasons:
- Crashes on launch
- Missing demo account
- Incomplete features
- Guideline violations

### Debug Release Issues

```bash
# Validate before upload
xcrun altool --validate-app \
  -f ./build/Leavn.ipa \
  -t ios \
  --apiKey YOUR_API_KEY \
  --apiIssuer YOUR_ISSUER_ID

# Check entitlements
codesign -d --entitlements - ./build/Leavn.app
```

## Automation with Fastlane

### Setup

```ruby
# Fastfile
default_platform(:ios)

platform :ios do
  desc "Submit to TestFlight"
  lane :beta do
    increment_build_number
    build_app(scheme: "Leavn")
    upload_to_testflight(
      skip_waiting_for_build_processing: true,
      groups: ["Beta Testers"]
    )
    slack(message: "New beta build uploaded!")
  end

  desc "Submit to App Store"
  lane :release do
    increment_version_number(bump_type: "patch")
    increment_build_number
    build_app(scheme: "Leavn")
    upload_to_app_store(
      submit_for_review: true,
      automatic_release: true,
      submission_information: {
        add_id_info_uses_idfa: false,
        export_compliance_uses_encryption: false
      }
    )
  end

  desc "Create screenshots"
  lane :screenshots do
    capture_screenshots
    frame_screenshots(white: true)
    upload_to_app_store(
      skip_binary_upload: true,
      skip_metadata: true
    )
  end
end
```

### CI/CD Integration

```yaml
# .github/workflows/deploy.yml
name: Deploy

on:
  push:
    tags:
      - 'v*'

jobs:
  deploy:
    runs-on: macos-13
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: '3.0'
          bundler-cache: true
      
      - name: Install certificates
        run: |
          fastlane match appstore --readonly
        env:
          MATCH_PASSWORD: ${{ secrets.MATCH_PASSWORD }}
          MATCH_GIT_BASIC_AUTHORIZATION: ${{ secrets.MATCH_GIT_AUTH }}
      
      - name: Deploy to TestFlight
        run: fastlane beta
        env:
          APP_STORE_CONNECT_API_KEY: ${{ secrets.ASC_API_KEY }}
```

## Release Checklist

### Pre-Release
- [ ] Version number updated
- [ ] Build number incremented
- [ ] Release notes prepared
- [ ] Screenshots updated
- [ ] All tests passing
- [ ] Performance profiled
- [ ] Crash-free on all devices

### Release
- [ ] Archive created
- [ ] Upload successful
- [ ] TestFlight processing complete
- [ ] Beta testers notified
- [ ] App Store submission prepared

### Post-Release
- [ ] Monitor crash reports
- [ ] Respond to reviews
- [ ] Track analytics
- [ ] Plan next release
- [ ] Update documentation

---

For detailed Fastlane configuration, see `fastlane/README.md`.