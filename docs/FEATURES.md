# Features Documentation

Comprehensive guide to all features in the Leavn Super Official Bible app.

## Table of Contents

- [Bible Reading](#bible-reading)
- [Audio Features](#audio-features)
- [Community Features](#community-features)
- [Personal Library](#personal-library)
- [Search & Discovery](#search--discovery)
- [Customization & Settings](#customization--settings)
- [Offline Support](#offline-support)
- [Accessibility](#accessibility)
- [Data & Privacy](#data--privacy)

## Bible Reading

### Core Reading Experience

#### Navigation
- **Book Selection**: Grid view of all 66 Bible books
- **Chapter Selection**: Numbered grid for quick access
- **Verse Navigation**: Swipe between chapters
- **Jump to Verse**: Direct verse number input
- **Reading History**: Recently read passages

#### Text Display
```swift
// Customizable reading options
- Verse numbers (on/off)
- Paragraph mode
- Red letter text for Jesus' words
- Section headings
- Cross-reference indicators
```

#### Reading Features
1. **Continuous Scrolling**
   - Smooth chapter transitions
   - Auto-load next chapter
   - Progress indicator

2. **Reference View**
   - Tap verse for options
   - View cross-references
   - See original language
   - Share options

3. **Split Screen** (iPad)
   - Compare translations
   - View commentary
   - Side-by-side reading

### Text Interaction

#### Highlighting
- **Colors**: 7 theme colors
- **Styles**: Solid, underline, or margin dot
- **Organization**: By color, date, or book
- **Sync**: Across all devices

#### Selection Actions
```
Long press on text:
├── Highlight
├── Add Note
├── Bookmark
├── Copy
├── Share
└── Speak
```

## Audio Features

### AI Narration

#### Voice Options
1. **ElevenLabs Voices**
   - Rachel (Female, American)
   - Josh (Male, American)
   - Elli (Female, British)
   - Adam (Male, British)

2. **Voice Settings**
   ```swift
   struct VoiceSettings {
       var speed: Float = 1.0        // 0.5x - 2.0x
       var stability: Float = 0.5    // Voice consistency
       var clarity: Float = 0.5      // Voice clarity
   }
   ```

#### Playback Controls
- **Player UI**
  - Play/Pause
  - Skip forward/back (15 seconds)
  - Chapter skip
  - Speed control
  - Sleep timer

- **Background Audio**
  - Continue while using other apps
  - Lock screen controls
  - Now Playing integration
  - CarPlay support

#### Audio Features
1. **Auto-play Next Chapter**
2. **Bookmark Audio Position**
3. **Download for Offline**
4. **Queue Management**

### Audio Settings
```yaml
Speed Options: 0.5x, 0.75x, 1.0x, 1.25x, 1.5x, 2.0x
Sleep Timer: 15, 30, 45, 60, 90 minutes, End of chapter
Skip Duration: 10s, 15s, 30s, 60s
```

## Community Features

### Prayer Wall

#### Creating Prayers
```swift
struct Prayer {
    let title: String           // Required, 100 chars max
    let content: String         // Required, 500 chars max
    let category: Category      // Healing, Family, Work, etc.
    let isAnonymous: Bool       // Optional anonymity
    let allowComments: Bool     // Enable responses
}
```

#### Interaction
- **Pray Button**: Increment prayer count
- **Comments**: Encouragement and support
- **Reporting**: Flag inappropriate content
- **Filtering**: By category, date, or popularity

### Study Groups

#### Group Types
1. **Public Groups**
   - Open to all users
   - Discoverable in search
   - Moderated by admins

2. **Private Groups**
   - Invitation only
   - Hidden from search
   - Admin approval required

#### Group Features
- **Discussion Boards**
- **Reading Plans**
- **Event Calendar**
- **Member Directory**
- **Resource Sharing**

### Activity Feed

#### Feed Items
```
- John highlighted John 3:16
- Sarah completed Genesis reading plan
- Prayer request: "Healing for my mother"
- New group: "Women's Bible Study"
- Mike shared a note on Romans 8
```

#### Privacy Controls
- **Visibility**: Public, Friends, Private
- **Sharing**: Opt-in for each activity type
- **Blocking**: Hide specific users

## Personal Library

### Bookmarks

#### Organization
- **Folders**: Custom categories
- **Tags**: Multiple tags per bookmark
- **Smart Collections**: Auto-organize by criteria
- **Search**: Full-text search in bookmarks

#### Features
```swift
struct Bookmark {
    let reference: BibleReference
    let note: String?
    let color: UIColor
    let tags: [String]
    let dateCreated: Date
    let folder: Folder?
}
```

### Notes

#### Note Types
1. **Verse Notes**: Attached to specific verses
2. **Chapter Notes**: General chapter thoughts
3. **Study Notes**: Standalone theological notes
4. **Prayer Journal**: Dated prayer entries

#### Rich Text Editor
- **Formatting**: Bold, italic, underline
- **Lists**: Bullet and numbered
- **Links**: Scripture references auto-link
- **Images**: Attach photos (Premium)

### Reading Plans

#### Built-in Plans
1. **Bible in a Year**: Traditional chronological
2. **New Testament in 90 Days**
3. **Psalms and Proverbs**: 30-day wisdom
4. **Gospels**: 40-day Jesus focus
5. **Topical Plans**: Love, Faith, Hope themes

#### Custom Plans
```yaml
Create Your Own:
- Select books/chapters
- Set daily goals
- Choose duration
- Add reminders
- Track progress
```

### Downloads

#### Offline Content
- **Whole Books**: Download for offline reading
- **Audio Cache**: Pre-download narration
- **Study Resources**: Commentary and notes
- **Media**: Images and maps

#### Storage Management
```swift
// Automatic cleanup options
- Keep recent (30 days)
- Keep bookmarked
- Manual selection
- Storage limit setting
```

## Search & Discovery

### Bible Search

#### Search Types
1. **Exact Phrase**: "God so loved"
2. **All Words**: God love world
3. **Any Word**: faith OR hope
4. **Proximity**: "Jesus wept" NEAR tomb

#### Search Filters
- **Books**: Limit to specific books
- **Testament**: Old, New, or both
- **Range**: Custom verse ranges
- **Exclude**: -word to exclude

#### Search Results
```
Display Options:
├── Verse context (±2 verses)
├── Highlight search terms
├── Group by book
├── Sort by relevance/order
└── Export results
```

### Smart Suggestions

#### While You Type
- **Verse References**: "joh 3" → John 3
- **Book Names**: "gen" → Genesis
- **Common Phrases**: "lord is my" → shepherd
- **Topics**: "love" → related verses

## Customization & Settings

### Appearance

#### Themes
1. **Light Mode**: Clean, paper-like
2. **Dark Mode**: OLED-friendly black
3. **Sepia Mode**: Warm reading tone
4. **Auto Mode**: Follow system setting

#### Typography
```swift
struct TextSettings {
    var fontSize: CGFloat       // 12-32pt
    var fontFamily: FontFamily  // System, Serif, Sans
    var lineSpacing: CGFloat    // 1.0-2.0
    var margins: EdgeInsets     // Narrow, Normal, Wide
}
```

### Reading Preferences

#### Display Options
- **Verse Numbers**: Inline, margin, or hidden
- **Footnotes**: Show, hide, or inline
- **Headings**: Section titles on/off
- **Red Letters**: Highlight Jesus' words
- **Paragraph Mode**: Traditional or modern

### Notifications

#### Daily Reminders
1. **Verse of the Day**: Morning inspiration
2. **Reading Plan**: Progress reminders
3. **Prayer Time**: Scheduled alerts
4. **Community**: Group activities

#### Notification Settings
```yaml
Customization:
- Time: Set specific times
- Frequency: Daily, weekly, custom
- Sound: Choose alert tone
- Badge: App icon number
```

## Offline Support

### Smart Caching

#### Automatic Downloads
- **Recent Passages**: Last 10 chapters
- **Bookmarked Content**: All bookmarked verses
- **Current Plan**: Today's reading
- **Predictive**: Next likely chapter

#### Manual Downloads
1. Select book or range
2. Choose quality (text only/with audio)
3. Monitor progress
4. Manage storage

### Offline Features

#### Available Offline
- ✅ Reading downloaded content
- ✅ Viewing bookmarks/notes
- ✅ Playing cached audio
- ✅ Local search

#### Requires Internet
- ❌ New passage loading
- ❌ Community features
- ❌ Audio generation
- ❌ Cross-reference lookup

## Accessibility

### VoiceOver Support

#### Full Integration
- **All UI elements labeled**
- **Gesture hints provided**
- **Reading flow optimized**
- **Actions announced**

#### Bible-Specific
```swift
// Custom rotor actions
- Navigate by verse
- Jump to chapter
- Skip to next highlight
- Read footnotes
```

### Visual Accessibility

#### Display Options
1. **High Contrast Mode**
2. **Reduce Transparency**
3. **Bold Text Option**
4. **Color Blind Modes**

#### Dynamic Type
- Respects system font size
- UI scales appropriately
- Maintains readability
- Preserves layout

### Motor Accessibility

#### Gesture Alternatives
- **Tap targets**: Minimum 44x44pt
- **Swipe alternatives**: Buttons available
- **Long press options**: Also in menus
- **Shake to undo**: Can be disabled

## Data & Privacy

### Data Storage

#### Local Storage
```swift
// Encrypted Core Data
- Bookmarks and notes
- Reading history
- User preferences
- Downloaded content

// Keychain
- API keys
- Authentication tokens
- Sensitive settings
```

#### Cloud Sync (Optional)
- **iCloud**: Bookmarks and notes
- **Sign in with Apple**: Anonymous option
- **Export**: JSON/PDF backup
- **Import**: Restore from backup

### Privacy Features

#### Anonymous Mode
- No account required
- Local storage only
- No analytics
- No social features

#### Data Controls
1. **Export All Data**: Complete backup
2. **Delete Account**: Full removal
3. **Clear History**: Reading tracks
4. **Reset App**: Fresh start

### Security

#### Protection
- **Keychain**: Hardware encryption
- **App Transport Security**: HTTPS only
- **No tracking**: No third-party analytics
- **Minimal permissions**: Only essential

---

For implementation details, see the source code in `Sources/LeavnApp/Features/`.