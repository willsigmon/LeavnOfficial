#!/bin/bash

echo "🔨 Building and launching Leavn app..."

# Build the app
xcodebuild -scheme "Leavn" -sdk iphonesimulator -configuration Debug build

# Launch in simulator
xcrun simctl boot "iPhone 15 Pro" 2>/dev/null || true
xcrun simctl install booted build/Debug-iphonesimulator/Leavn.app
xcrun simctl launch --console booted com.leavn.app

echo "✅ App launched. Check console output above for debug logs."