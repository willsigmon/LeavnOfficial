# Leavn - Modern iOS Bible Study App

<p align="center">
  <img src="docs/icon.png" alt="Leavn App Icon" width="150">
</p>

<p align="center">
  <strong>A modern iOS Bible app built with The Composable Architecture (TCA) and Swift 6.2</strong>
</p>

<p align="center">
  <a href="#features">Features</a> •
  <a href="#getting-started">Getting Started</a> •
  <a href="#documentation">Documentation</a> •
  <a href="#contributing">Contributing</a> •
  <a href="#license">License</a>
</p>

---

## Overview

Leavn is a modern iOS Bible study application that brings the Word of God to life through innovative technology. Built with SwiftUI and The Composable Architecture, it offers a seamless reading experience with AI-powered audio narration, life situation guidance, community features, and robust offline support.

## Features

### 📖 Bible Reading
- **Full ESV Bible**: Complete access to the English Standard Version via official API
- **Smart Navigation**: Intuitive book, chapter, and verse selection
- **Verse Highlighting**: Mark and save important passages
- **Cross-References**: Explore connected verses and themes
- **Reading Plans**: Follow structured Bible reading schedules
- **Offline Mode**: Download books for reading without internet

### 🎧 Audio Features
- **AI Narration**: High-quality text-to-speech powered by ElevenLabs
- **Multiple Voices**: Choose from various narrator voices
- **Playback Controls**: Speed adjustment, skip, and bookmarking
- **Background Audio**: Continue listening while using other apps
- **Sleep Timer**: Automatic shutdown after specified duration

### 💭 Life Situations
- **Emotional Support**: Find verses for anxiety, grief, joy, fear, and more
- **Curated Verses**: Hand-picked scriptures for specific life circumstances
- **Guided Prayers**: Contextual prayers for each situation
- **Personal Journey**: Track your spiritual growth through challenges

### 👥 Community
- **Prayer Wall**: Share and support prayer requests
- **Study Groups**: Join or create Bible study communities
- **Activity Feed**: See what others are reading and sharing
- **Anonymous Mode**: Participate privately when needed
- **Real-time Updates**: WebSocket-powered live interactions

### 📚 Personal Library
- **Bookmarks**: Save favorite verses and passages
- **Notes**: Add personal insights and reflections
- **Highlights**: Color-code verses by theme or importance
- **Search**: Find content across your personal library
- **Export**: Share your notes and highlights
- **Cloud Sync**: Access your library across devices

### ⚙️ Customization
- **Themes**: Light, dark, and auto-switching modes
- **Typography**: Adjustable font sizes and styles
- **Reading Preferences**: Verse numbers, red letters, paragraph mode
- **Notifications**: Daily verses and reading reminders
- **Data Management**: Control storage and privacy settings

## Getting Started

### Prerequisites

- **macOS**: 13.0+ (Ventura or later)
- **Xcode**: 15.0+ with iOS 18.0 SDK
- **Swift**: 6.2
- **Developer Account**: Apple Developer Program membership (for device testing)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/willsigmon/LeavnOfficial.git
   cd LeavnOfficial
   ```

2. **Open in Xcode**
   ```bash
   open Package.swift
   ```

3. **Wait for Swift Package Manager** to resolve dependencies

4. **Configure API Keys** (see [API Setup Guide](docs/API_KEYS_SETUP.md))

5. **Build and Run**
   - Select your target device or simulator
   - Press `Cmd+R` to build and run

### Quick Start

For a complete setup guide, see [Development Setup](docs/DEVELOPMENT_SETUP.md).

## Documentation

### Developer Guides
- [Architecture Overview](docs/ARCHITECTURE.md) - Understanding TCA and app structure
- [API Integration Guide](docs/API_GUIDE.md) - Working with external services
- [Testing Strategy](docs/TESTING.md) - Unit and integration testing
- [Deployment Process](docs/DEPLOYMENT.md) - Release and distribution

### Setup Guides
- [Development Environment](docs/DEVELOPMENT_SETUP.md) - Complete dev setup
- [API Keys Setup](docs/API_KEYS_SETUP.md) - Obtaining and configuring APIs
- [Xcode Configuration](docs/XCODE_SETUP.md) - Project settings
- [TestFlight Guide](docs/TESTFLIGHT_GUIDE.md) - Beta testing setup

### References
- [Features Documentation](docs/FEATURES.md) - Detailed feature descriptions
- [FAQ](docs/FAQ.md) - Common questions and answers
- [Troubleshooting](docs/TROUBLESHOOTING.md) - Solutions to common issues
- [Privacy Policy](docs/PRIVACY.md) - Data handling and user privacy
- [Terms of Service](docs/TERMS.md) - Usage terms and conditions

## Architecture

The app is built using modern iOS development practices:

- **The Composable Architecture (TCA)**: Unidirectional data flow and state management
- **SwiftUI**: Declarative UI with iOS 18's latest features
- **Swift Concurrency**: Async/await for all asynchronous operations
- **Dependency Injection**: Testable and modular service layer
- **Core Data**: Efficient local data persistence
- **Keychain Services**: Secure credential storage

For detailed architecture information, see [Architecture Guide](docs/ARCHITECTURE.md).

## API Services

### Required
- **ESV API**: Bible text and search functionality
  - Sign up at [api.esv.org](https://api.esv.org)
  - Free tier: 5,000 requests/day

### Optional
- **ElevenLabs API**: AI voice synthesis
  - Sign up at [elevenlabs.io](https://elevenlabs.io)
  - Various pricing tiers available

See [API Setup Guide](docs/API_KEYS_SETUP.md) for detailed instructions.

## Contributing

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details on:

- Code style and standards
- Submitting pull requests
- Reporting issues
- Feature requests
- Testing requirements

## Testing

Run the test suite:

```bash
# All tests
swift test

# Specific test target
swift test --filter LeavnAppTests

# With coverage
swift test --enable-code-coverage
```

See [Testing Guide](docs/TESTING.md) for comprehensive testing strategies.

## Deployment

### TestFlight

1. Update version and build numbers
2. Archive in Xcode
3. Upload to App Store Connect
4. Submit for TestFlight review

### App Store

1. Complete TestFlight beta testing
2. Prepare App Store metadata
3. Submit for App Review
4. Monitor and respond to feedback

See [Deployment Guide](docs/DEPLOYMENT.md) for detailed instructions.

## Support

- **Documentation**: See our [comprehensive docs](docs/)
- **Issues**: Report bugs via [GitHub Issues](https://github.com/willsigmon/LeavnOfficial/issues)
- **Email**: support@leavn.app
- **Website**: [leavn.app](https://leavn.app)

## License

Copyright © 2024 Leavn. All rights reserved.

This project is proprietary software. See [LICENSE](LICENSE) for details.

---

<p align="center">
  Made with ❤️ for the glory of God
</p>