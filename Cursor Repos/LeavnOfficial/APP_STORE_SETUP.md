# App Store Setup Guide

## Prerequisites

1. **Apple Developer Account**: Ensure you have an active Apple Developer membership
2. **App Store Connect Access**: Admin or App Manager role
3. **Certificates & Profiles**: Development and Distribution certificates set up in Xcode

## Configuration Steps

### 1. Update Team ID
Replace `YOUR_TEAM_ID` in the following files:
- `ExportOptions.plist`
- `Scripts/build-testflight.sh`

Find your Team ID in:
- Apple Developer Portal → Membership → Team ID
- Xcode → Preferences → Accounts → Your Apple ID → Team Details

### 2. Create App Store Connect API Key
1. Go to App Store Connect → Users and Access → Keys
2. Click "+" to create a new key
3. Name: "Leavn CI/CD"
4. Access: App Manager
5. Download the .p8 file and save it securely
6. Note the Key ID and Issuer ID

Update in `Scripts/build-testflight.sh`:
- `YOUR_API_KEY` → Your Key ID
- `YOUR_ISSUER_ID` → Your Issuer ID

### 3. Export Compliance
If you've received an export compliance code:
1. Update `YOUR_COMPLIANCE_CODE` in `ExportCompliance.plist`
2. If not needed, set `ITSAppUsesNonExemptEncryption` to `false`

### 4. Create App in App Store Connect
1. Go to App Store Connect → My Apps → "+"
2. Platform: iOS
3. App Name: Leavn
4. Primary Language: English (U.S.)
5. Bundle ID: com.leavn.app
6. SKU: LEAVN001

### 5. App Information

#### Categories
- Primary: Lifestyle
- Secondary: Education

#### Age Rating
- Infrequent/Mild Mature/Suggestive Themes (religious content)
- No violence, gambling, or inappropriate content

#### Privacy Policy URL
`https://leavn.app/privacy`

#### Support URL
`https://leavn.app/support`

### 6. App Description

**Subtitle** (30 chars max):
"Daily Bible & Community"

**Description**:
```
Leavn brings the Bible to life with a beautiful reading experience, AI-powered insights, and a vibrant faith community.

KEY FEATURES:

📖 BEAUTIFUL BIBLE READING
• Clean, distraction-free interface
• Multiple translations (ESV and more coming soon)
• Smooth navigation between chapters
• Offline reading capability

🎧 AUDIO EXPERIENCE
• Natural voice narration powered by AI
• Multiple voice options
• Adjustable playback speed
• Background audio support

📝 STUDY TOOLS
• Highlight verses in multiple colors
• Add personal notes and reflections
• Bookmark favorite passages
• Cross-references and context

🔍 SMART SEARCH
• Find verses quickly
• Search by topic or keyword
• AI-powered semantic search
• Discover related passages

👥 FAITH COMMUNITY
• Share prayer requests
• Join Bible study groups
• Daily devotionals
• Encourage others in their journey

📅 READING PLANS
• Chronological, thematic, and custom plans
• Track your progress
• Daily reminders
• Flexible scheduling

🌙 PERSONALIZATION
• Dark mode support
• Adjustable font sizes
• Multiple themes
• Reading preferences

Start your journey with Leavn today and experience the Bible in a whole new way!
```

### 7. Keywords
```
bible,scripture,devotional,prayer,christian,faith,study,audio bible,reading plan,community
```

### 8. Screenshots Required
- 6.7" Display (iPhone 15 Pro Max): 1290 x 2796
- 6.5" Display (iPhone 14 Plus): 1284 x 2778
- 5.5" Display (iPhone 8 Plus): 1242 x 2208
- 12.9" iPad Pro: 2048 x 2732

Screenshot suggestions:
1. Bible reading view with highlighted verse
2. Audio player interface
3. Community feed
4. Search results
5. Reading plan progress
6. Settings/customization

### 9. TestFlight Information

**What to Test**:
```
Thank you for testing Leavn! Please focus on:

1. Bible Reading: Navigate between books and chapters
2. Audio: Test playback with different voices
3. Search: Try finding specific verses
4. Community: Create posts and interact
5. Offline: Test without internet connection

Report issues to: beta@leavn.app
```

**Test Group Name**: "Early Access"

### 10. Release Notes Template
```
Version 1.0 - Initial Release

• Beautiful Bible reading experience
• AI-powered audio narration
• Community features
• Highlighting and notes
• Reading plans
• Offline support
• Dark mode

We're excited to share Leavn with you! This is our first release, and we'd love your feedback.
```

## Pre-Submission Checklist

- [ ] All API keys configured
- [ ] No hardcoded test data
- [ ] Privacy policy live at URL
- [ ] Support page live at URL
- [ ] Screenshots prepared
- [ ] App icon in all required sizes
- [ ] Launch screen configured
- [ ] Export compliance handled
- [ ] TestFlight build uploaded
- [ ] Internal testing completed
- [ ] External beta group invited

## Build & Deploy

```bash
# Run from project root
./Scripts/build-testflight.sh
```

## Support

For assistance with App Store submission:
- Email: support@leavn.app
- Documentation: https://leavn.app/docs