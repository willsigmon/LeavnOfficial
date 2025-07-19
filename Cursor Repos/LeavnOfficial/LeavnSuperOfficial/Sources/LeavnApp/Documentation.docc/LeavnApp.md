# ``LeavnApp``

A modern iOS Bible app built with The Composable Architecture, featuring AI-powered narration and community features.

## Overview

LeavnApp provides a comprehensive Bible reading experience with modern iOS design patterns and architecture. Built using SwiftUI and The Composable Architecture (TCA), it offers a scalable, testable, and maintainable codebase.

### Key Features

- **Bible Reading**: Full ESV Bible access with beautiful typography
- **AI Narration**: Natural voice synthesis powered by ElevenLabs
- **Community**: Prayer wall and study groups for fellowship
- **Personal Library**: Bookmarks, notes, and highlights with sync
- **Offline Support**: Download content for reading without internet

## Topics

### Essentials

- <doc:GettingStarted>
- <doc:Architecture>
- <doc:Dependencies>

### Features

- ``BibleReducer``
- ``CommunityReducer``
- ``LibraryReducer``
- ``SettingsReducer``

### Services

- ``ESVClient``
- ``ElevenLabsClient``
- ``BibleService``
- ``AudioService``
- ``OfflineService``

### Models

- ``Book``
- ``Verse``
- ``BibleReference``
- ``Bookmark``
- ``Note``
- ``Prayer``

### Views

- ``BibleView``
- ``CommunityView``
- ``LibraryView``
- ``SettingsView``