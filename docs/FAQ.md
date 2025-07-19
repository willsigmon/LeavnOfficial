# Frequently Asked Questions (FAQ)

Common questions and answers about the Leavn Super Official Bible app.

## Table of Contents

- [General Questions](#general-questions)
- [Account & Setup](#account--setup)
- [Bible Reading](#bible-reading)
- [Audio Features](#audio-features)
- [Community Features](#community-features)
- [Technical Issues](#technical-issues)
- [Privacy & Security](#privacy--security)
- [Pricing & Subscriptions](#pricing--subscriptions)
- [Developer Questions](#developer-questions)

## General Questions

### What is Leavn?

Leavn is a modern Bible app that combines beautiful reading experiences with AI-powered audio narration and vibrant community features. It's designed to make engaging with Scripture more accessible and meaningful.

### Which Bible translation does Leavn use?

Leavn currently uses the English Standard Version (ESV) through an official API partnership. We chose the ESV for its accuracy and readability. Future updates may include additional translations.

### Is Leavn free to use?

Yes! Leavn is free to download and use. Core features including Bible reading, bookmarks, and basic audio are free. Some premium features may be offered in the future.

### What devices are supported?

- **iOS**: iPhone and iPad with iOS 18.0 or later
- **Devices**: All models that support iOS 18
- **Future**: Apple Watch and Mac versions planned

### Do I need an internet connection?

- **Reading**: Download books for offline reading
- **Audio**: Cache narration for offline playback
- **Community**: Requires internet connection
- **Sync**: Internet needed for cloud sync

## Account & Setup

### Do I need an account to use Leavn?

No account is required for basic features. You can:
- Read the Bible
- Create bookmarks and notes (stored locally)
- Use audio features

An account enables:
- Cloud sync across devices
- Community features
- Backup and restore

### How do I get API keys?

#### ESV API Key (Required)
1. Visit [api.esv.org](https://api.esv.org)
2. Create free account
3. Generate API key
4. Enter in app during setup

#### ElevenLabs API Key (Optional)
1. Visit [elevenlabs.io](https://elevenlabs.io)
2. Create account
3. Get API key from profile
4. Enter in app settings

### Can I use Leavn without API keys?

The app requires an ESV API key for Bible text. Without it, you cannot access Bible content. The ElevenLabs key is optional - without it, audio features will be disabled.

### How do I transfer data to a new device?

**With iCloud:**
1. Ensure iCloud sync is enabled
2. Sign in with same Apple ID
3. Data syncs automatically

**Without iCloud:**
1. Settings > Data > Export
2. Save backup file
3. On new device: Import backup

## Bible Reading

### How do I navigate to a specific verse?

**Method 1: Book Selector**
1. Tap current reference at top
2. Select book, chapter, verse
3. Tap "Go"

**Method 2: Search**
1. Use search bar
2. Type "John 3:16" format
3. Tap result

**Method 3: Quick Jump**
1. Tap verse number
2. Enter new verse
3. Press return

### Can I change the font size?

Yes! Go to Settings > Display > Font Size. You can:
- Adjust size from 12-32pt
- Change font family
- Adjust line spacing
- Set margin width

### How do I highlight verses?

1. **Long press** on any verse
2. Select **Highlight** from popup
3. Choose color
4. Tap **Save**

To remove: Long press highlighted verse > Remove Highlight

### What do the different highlight colors mean?

Colors are customizable, but common uses:
- 🟡 **Yellow**: Important verses
- 🟢 **Green**: Promises
- 🔵 **Blue**: Commands
- 🔴 **Red**: Warnings
- 🟣 **Purple**: Prophecy
- 🟠 **Orange**: Personal application
- 🩷 **Pink**: Love/relationships

### How do I create notes?

1. Long press any verse
2. Select **Add Note**
3. Type your thoughts
4. Add tags (optional)
5. Tap **Save**

Access notes: Library tab > Notes

## Audio Features

### How does AI narration work?

Leavn uses ElevenLabs AI to convert Bible text to natural-sounding speech. When you play audio:
1. Text is sent to ElevenLabs
2. AI generates speech
3. Audio streams to your device
4. Cached for offline playback

### Can I change the narrator voice?

Yes! Settings > Audio > Voice Selection offers:
- Rachel (Female, American)
- Josh (Male, American)  
- Elli (Female, British)
- Adam (Male, British)

### Why is audio not working?

Common solutions:
1. Check ElevenLabs API key in Settings
2. Ensure internet connection
3. Check monthly character limit
4. Try different voice
5. Restart app

### Can I adjust playback speed?

Yes, tap the speed button in audio controls:
- 0.5x - Half speed
- 0.75x - Slower
- 1.0x - Normal
- 1.25x - Slightly faster
- 1.5x - Faster
- 2.0x - Double speed

### How do I download audio for offline use?

1. Navigate to desired book
2. Tap download icon
3. Choose chapters
4. Select "Download with Audio"
5. Wait for completion

## Community Features

### What is the Prayer Wall?

A shared space where users can:
- Post prayer requests
- Pray for others
- Share encouragement
- Build community

All posts are moderated for safety.

### Can I post anonymously?

Yes! When creating a prayer request:
1. Toggle "Post Anonymously"
2. Your name won't be shown
3. You can still receive prayer counts

### How do Study Groups work?

Study Groups are communities within the app:
1. **Join**: Browse and join public groups
2. **Participate**: Discuss readings
3. **Schedule**: See group events
4. **Create**: Start your own group (coming soon)

### Is my activity visible to others?

You control visibility:
- **Private**: Only you see your activity
- **Friends**: Shared with connections
- **Public**: Visible in community feed

Change in Settings > Privacy

## Technical Issues

### The app is crashing, what should I do?

1. **Update**: Check App Store for updates
2. **Restart**: Force quit and reopen
3. **Reinstall**: Delete and reinstall app
4. **Report**: Send crash logs to support

### Bible text isn't loading

Troubleshooting steps:
1. Check internet connection
2. Verify ESV API key is entered
3. Check daily API limit (5000 requests)
4. Try different passage
5. Contact support if persists

### Search isn't finding results

- Use quotes for exact phrases: "God so loved"
- Check spelling
- Try broader terms
- Ensure search index is built (Settings > Advanced > Rebuild Search)

### Audio keeps stopping

Common fixes:
1. Check Low Power Mode (disable it)
2. Background App Refresh (enable for Leavn)
3. Check storage space
4. Update iOS
5. Reset audio settings

### Sync isn't working

1. Check iCloud settings
2. Ensure signed in with same Apple ID
3. Check iCloud storage space
4. Toggle sync off/on in Settings
5. Manual sync: pull down on Library

## Privacy & Security

### What data does Leavn collect?

**We collect minimal data:**
- Crash reports (anonymous)
- Basic usage statistics (optional)
- Your content (bookmarks, notes) for sync

**We never collect:**
- Personal information without consent
- Reading habits for advertising
- Location data
- Contact information

### Is my data secure?

Yes, we use industry standards:
- API keys in iOS Keychain
- HTTPS for all connections
- Local encryption for sensitive data
- No passwords stored in plain text

### Can I use Leavn anonymously?

Yes! Without an account you can:
- Read the Bible
- Create local bookmarks/notes
- Use audio features
- No data leaves your device

### How do I delete my data?

**Local data:**
Settings > Data > Clear All Data

**Account data:**
Settings > Account > Delete Account

This permanently removes all your data.

## Pricing & Subscriptions

### Is Leavn really free?

Yes! Core features are free forever:
- Bible reading
- Basic audio (with API key)
- Bookmarks and notes
- Search functionality

### Will there be paid features?

Potential premium features (not yet implemented):
- Extended audio limits
- Advanced study tools
- Exclusive content
- Priority support

### How do API costs work?

**ESV API:** Free tier includes 5000 requests/day
**ElevenLabs:** Free tier includes 10,000 characters/month

Most users never exceed free limits.

## Developer Questions

### Is Leavn open source?

Currently, Leavn is proprietary software. We may open source components in the future.

### What technology stack does Leavn use?

- **Language**: Swift 6.2
- **UI**: SwiftUI
- **Architecture**: The Composable Architecture (TCA)
- **Min iOS**: 18.0
- **Database**: Core Data
- **Networking**: URLSession with async/await

### Can I contribute to Leavn?

While the code is private, you can contribute by:
- Beta testing via TestFlight
- Reporting bugs
- Suggesting features
- Sharing with others

### How do I report bugs?

1. **In-app**: Settings > Help > Report Bug
2. **Email**: support@leavn.app
3. **GitHub**: Issues (when available)
4. **TestFlight**: Shake to report

### API rate limits?

**ESV API:**
- 5000 requests/day (free)
- 2 requests/second max

**ElevenLabs:**
- 10,000 characters/month (free)
- Rate limits vary by plan

### How is offline storage handled?

- Text stored in Core Data
- Audio cached in Documents
- Images in Caches directory
- Automatic cleanup of old data

---

Still have questions? Contact us at support@leavn.app