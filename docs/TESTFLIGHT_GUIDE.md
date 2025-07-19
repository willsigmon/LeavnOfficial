# TestFlight Beta Testing Guide

Complete guide for setting up and managing TestFlight beta testing for the Leavn Super Official app.

## Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Initial Setup](#initial-setup)
- [Uploading Builds](#uploading-builds)
- [Managing Testers](#managing-testers)
- [Beta App Review](#beta-app-review)
- [Testing Workflow](#testing-workflow)
- [Gathering Feedback](#gathering-feedback)
- [Best Practices](#best-practices)
- [Troubleshooting](#troubleshooting)

## Overview

TestFlight is Apple's platform for beta testing iOS apps before App Store release. It allows you to:

- Distribute beta builds to testers
- Gather feedback and crash reports
- Test on real devices
- Validate app before submission

### Key Concepts

- **Internal Testing**: Up to 100 testers, no review required
- **External Testing**: Up to 10,000 testers, requires Beta App Review
- **Build Expiration**: Builds expire after 90 days
- **Groups**: Organize testers by role or feature

## Prerequisites

### Developer Requirements

1. **Apple Developer Account**
   - Enrolled in Apple Developer Program ($99/year)
   - Admin or App Manager role

2. **App Store Connect Access**
   - Account with appropriate permissions
   - Two-factor authentication enabled

3. **Certificates & Profiles**
   - Valid distribution certificate
   - App Store provisioning profile

### App Requirements

1. **Bundle Identifier**
   ```
   com.yourcompany.leavn
   ```

2. **Version and Build Numbers**
   ```
   Version: 1.0.0 (user-facing)
   Build: 1 (must increment each upload)
   ```

3. **App Icons and Launch Screen**
   - All required sizes included
   - No placeholder images

## Initial Setup

### 1. Create App in App Store Connect

1. Log in to [App Store Connect](https://appstoreconnect.apple.com)
2. My Apps > + > New App
3. Fill in details:
   ```
   Platform: iOS
   Name: Leavn - Bible Study
   Primary Language: English (U.S.)
   Bundle ID: com.yourcompany.leavn
   SKU: LEAVN-001
   ```

### 2. Configure TestFlight

1. Navigate to your app
2. Select "TestFlight" tab
3. Complete Test Information:

```yaml
Beta App Description:
  Leavn brings the Bible to life with beautiful reading, 
  AI narration, and community features.

Beta App Review Information:
  First Name: Your Name
  Last Name: Your Surname
  Email: beta@yourcompany.com
  Phone: +1 234 567 8900

Demo Account:
  Username: testuser@leavn.app
  Password: TestPassword123!
  
Notes:
  - ESV API key is pre-configured
  - Test audio features with any Bible passage
  - Community features available in Settings
```

### 3. Export Compliance

Add to Info.plist:
```xml
<key>ITSAppUsesNonExemptEncryption</key>
<false/>
```

Or answer questions in App Store Connect.

## Uploading Builds

### Method 1: Xcode Upload

1. **Archive the App**
   ```
   1. Select "Any iOS Device" as destination
   2. Product > Archive
   3. Wait for archive to complete
   ```

2. **Upload to App Store Connect**
   ```
   1. Organizer opens automatically
   2. Select your archive
   3. Click "Distribute App"
   4. Choose "App Store Connect"
   5. Select "Upload"
   6. Follow prompts
   ```

3. **Wait for Processing**
   - Usually 5-30 minutes
   - Email notification when ready

### Method 2: Fastlane Upload

```bash
# Configure Fastlane
fastlane init

# Upload to TestFlight
fastlane beta

# With changelog
fastlane beta changelog:"Fixed audio playback issues"
```

Fastfile configuration:
```ruby
lane :beta do
  increment_build_number
  build_app(scheme: "Leavn")
  upload_to_testflight(
    skip_waiting_for_build_processing: true,
    changelog: "Latest improvements and bug fixes"
  )
end
```

### Method 3: CI/CD Upload

```yaml
# GitHub Actions example
- name: Build and Upload
  run: |
    fastlane beta
  env:
    APP_STORE_CONNECT_API_KEY_ID: ${{ secrets.ASC_KEY_ID }}
    APP_STORE_CONNECT_API_ISSUER_ID: ${{ secrets.ASC_ISSUER_ID }}
    APP_STORE_CONNECT_API_KEY_CONTENT: ${{ secrets.ASC_KEY_CONTENT }}
```

## Managing Testers

### Internal Testing

1. **Add Internal Testers**
   ```
   TestFlight > Internal Testing > + 
   Enter email addresses
   ```

2. **Characteristics**
   - Immediate access to builds
   - No review required
   - Limited to 100 testers
   - Must have App Store Connect account

3. **Best For**
   - Development team
   - QA testers
   - Stakeholders

### External Testing

1. **Create Test Groups**
   ```
   TestFlight > External Testing > + > New Group
   
   Examples:
   - Beta Testers (general users)
   - Power Users (experienced testers)
   - Accessibility Testers
   - International Testers
   ```

2. **Add External Testers**
   ```
   Select Group > Testers > +
   Add by email or public link
   ```

3. **Public TestFlight Link**
   ```
   1. Select group
   2. Enable public link
   3. Set tester limit
   4. Share link
   ```

### Tester Information

Track important details:
- Name and email
- Device types
- iOS versions
- Testing focus areas
- Feedback quality

## Beta App Review

### Submission Requirements

1. **Complete Test Information**
   - What to test
   - Demo account
   - Contact information

2. **Build Notes**
   ```
   What's New in This Build:
   - Feature: Audio narration for any passage
   - Feature: Community prayer wall
   - Fix: Improved offline stability
   - Fix: Memory optimization
   
   Test Focus:
   - Bible navigation and search
   - Audio playback on all devices
   - Community features
   - Offline mode
   ```

3. **Review Guidelines**
   - No crashes on launch
   - Core features functional
   - No placeholder content
   - Appropriate content rating

### Common Rejection Reasons

1. **Crashes or Major Bugs**
   - Test thoroughly before submission
   - Check crash reports

2. **Incomplete Features**
   - Disable unfinished features
   - Provide clear test instructions

3. **Missing Information**
   - Demo account not working
   - Unclear test notes
   - Contact info invalid

## Testing Workflow

### Pre-Release Checklist

- [ ] Version number updated
- [ ] Build number incremented
- [ ] All tests passing
- [ ] No compiler warnings
- [ ] Performance profiled
- [ ] Memory leaks checked
- [ ] Tested on multiple devices

### Testing Plan

#### Phase 1: Internal Testing (1-2 days)
```
Testers: Development team
Focus: Smoke testing, critical paths
Devices: Latest iOS, various models
```

#### Phase 2: Limited External (3-5 days)
```
Testers: 50-100 power users
Focus: Core features, performance
Feedback: Via TestFlight and forms
```

#### Phase 3: Broad External (1-2 weeks)
```
Testers: 500-1000 users
Focus: Edge cases, diverse devices
Metrics: Crash rates, engagement
```

### Test Scenarios

1. **First Launch Experience**
   - Onboarding flow
   - API key setup
   - Initial content loading

2. **Core Features**
   - Bible navigation
   - Search functionality
   - Audio playback
   - Offline mode

3. **Edge Cases**
   - Poor network conditions
   - Low storage
   - Background/foreground
   - Device rotation

## Gathering Feedback

### TestFlight Feedback

1. **In-App Feedback**
   - Testers shake device or screenshot
   - Provide feedback directly
   - Includes device info

2. **Crash Reports**
   - Automatic collection
   - Symbolicated in App Store Connect
   - Group by similarity

### External Feedback Tools

1. **Feedback Form**
   ```
   Google Forms / Typeform with:
   - Feature ratings
   - Bug reports
   - Suggestions
   - Device information
   ```

2. **Analytics Integration**
   ```swift
   // Track beta events
   Analytics.track("beta_feature_used", properties: [
       "feature": "audio_playback",
       "version": "1.0.0",
       "build": "42"
   ])
   ```

3. **Beta Communication**
   - Slack channel
   - Email updates
   - In-app announcements

### Feedback Response

1. **Acknowledge Receipt**
   ```
   Thanks for your feedback on [issue].
   We're investigating and will update you.
   ```

2. **Track Issues**
   ```
   GitHub Issues / Jira with:
   - Reporter info
   - Device/OS details
   - Reproduction steps
   - Priority level
   ```

3. **Update Testers**
   ```
   Build 43 Fixes:
   ✓ Audio playback crash (reported by 15 testers)
   ✓ Search performance (reported by 8 testers)
   ```

## Best Practices

### Version Management

1. **Semantic Versioning**
   ```
   1.0.0 - Initial release
   1.0.1 - Bug fixes
   1.1.0 - New features
   2.0.0 - Major update
   ```

2. **Build Numbers**
   ```bash
   # Auto-increment
   agvtool next-version -all
   
   # Or in Fastlane
   increment_build_number
   ```

### Communication

1. **Welcome Email Template**
   ```
   Subject: Welcome to Leavn Beta Testing!
   
   Thank you for joining our beta program!
   
   Getting Started:
   1. Accept TestFlight invitation
   2. Install Leavn app
   3. Use demo account or create your own
   
   What to Test:
   - Bible reading and navigation
   - Audio narration features
   - Community features
   - Report any issues
   
   How to Provide Feedback:
   - In TestFlight app
   - Email: beta@leavn.app
   - Slack: [invite link]
   ```

2. **Update Notifications**
   ```
   New Build Available (v1.0.0 build 45)
   
   What's New:
   - Fixed audio sync issues
   - Improved search speed
   - Added verse sharing
   
   Please update and test these areas!
   ```

### Metrics to Track

1. **Adoption Metrics**
   - Install rate
   - Active testers
   - Sessions per tester

2. **Quality Metrics**
   - Crash-free sessions
   - Performance scores
   - Memory usage

3. **Engagement Metrics**
   - Feature usage
   - Session duration
   - Feedback submitted

## Troubleshooting

### Build Processing Issues

#### "Processing" Stuck

```bash
# Check status
xcrun altool --list-apps \
  --apiKey YOUR_KEY \
  --apiIssuer YOUR_ISSUER

# Re-upload if needed
xcrun altool --upload-app \
  -f path/to/app.ipa \
  -t ios \
  --apiKey YOUR_KEY \
  --apiIssuer YOUR_ISSUER
```

#### Invalid Binary

Common causes:
- Missing required device capabilities
- Invalid provisioning profile
- Incorrect version/build number
- Missing Info.plist keys

### Tester Issues

#### Can't Install App

1. **Check device compatibility**
   - iOS version
   - Device type
   - Storage space

2. **Verify tester status**
   - Invitation accepted
   - Correct Apple ID
   - TestFlight app installed

#### Not Receiving Invitations

1. **Check email**
   - Spam folder
   - Correct address
   - Apple ID matches

2. **Resend invitation**
   - Remove and re-add
   - Use public link

### Crash Reporting

#### Symbolication Failed

1. **Upload dSYMs**
   ```bash
   # Find dSYMs
   find ~/Library/Developer/Xcode/Archives \
     -name "*.dSYM"
   
   # Upload to App Store Connect
   xcrun altool --upload-symbols \
     -f path/to/dSYMs.zip
   ```

2. **Enable in Xcode**
   ```
   Build Settings > Debug Information Format
   = DWARF with dSYM File
   ```

## Post-Beta Process

### Preparing for Release

1. **Analyze Feedback**
   - Priority issues fixed
   - Feature requests noted
   - Performance acceptable

2. **Final Testing**
   - Regression testing
   - Release candidate build
   - Sign-off from stakeholders

3. **Documentation Updates**
   - Release notes
   - Known issues
   - Support documentation

### Transitioning to Production

1. **Thank Beta Testers**
   ```
   Thank you for testing Leavn!
   
   Your feedback helped us:
   - Fix 47 bugs
   - Improve performance by 30%
   - Add 5 requested features
   
   Watch for our App Store release!
   ```

2. **Prepare App Store Submission**
   - Screenshots
   - Description
   - Keywords
   - Categories

3. **Plan Launch**
   - Marketing materials
   - Support ready
   - Monitoring setup

---

For more information, see [Deployment Guide](DEPLOYMENT.md) or [Apple's TestFlight Documentation](https://developer.apple.com/testflight/).