# Building Without Firebase

## You DON'T need Firebase for TestFlight!

The app is designed to work without Firebase. The community features will simply be disabled.

### Option 1: Remove Firebase (Recommended for TestFlight)
1. Delete `Leavn/GoogleService-Info.plist`
2. Build normally - the app will work fine without it

### Option 2: Use Mock Community Service
The app already has mock services that simulate community features without Firebase.

### Option 3: Add Firebase Later
You can always add Firebase in a future update when you're ready to enable community features.

## Quick Build Instructions (No Firebase)

1. Delete the placeholder Firebase file:
```bash
rm Leavn/GoogleService-Info.plist
```

2. Open Xcode and build:
- Open `Leavn.xcodeproj`
- Sign in with your Apple ID
- Product → Archive
- Upload to TestFlight

That's it! The app will work perfectly without Firebase. Community features will use mock data.

## What Works Without Firebase:
✅ Bible reading and navigation
✅ Bookmarks and notes (stored locally)
✅ AI insights (using OpenAI)
✅ Reading plans
✅ All core Bible study features
✅ iCloud sync for personal data

## What's Disabled Without Firebase:
❌ Community posts
❌ Study groups
❌ Challenges
(These features gracefully degrade to mock data)

---

**Bottom line: You can submit to TestFlight right now without Firebase!**