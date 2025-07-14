#!/bin/bash

# Fix imports in LeavnServices files
echo "Fixing imports in LeavnServices..."

# List of files that need fixing
files=(
    "/Users/wsig/GitHub Builds/LeavnOfficial/Core/LeavnCore/Sources/LeavnServices/DIContainer.swift"
    "/Users/wsig/GitHub Builds/LeavnOfficial/Core/LeavnCore/Sources/LeavnServices/Mocks/MockServices.swift"
    "/Users/wsig/GitHub Builds/LeavnOfficial/Core/LeavnCore/Sources/LeavnServices/Services/AudioService.swift"
    "/Users/wsig/GitHub Builds/LeavnOfficial/Core/LeavnCore/Sources/LeavnServices/Services/AudioPlayerViewModel.swift"
    "/Users/wsig/GitHub Builds/LeavnOfficial/Core/LeavnCore/Sources/LeavnServices/Services/ElevenLabsService.swift"
    "/Users/wsig/GitHub Builds/LeavnOfficial/Core/LeavnCore/Sources/LeavnServices/Services/VerseNarrationService.swift"
    "/Users/wsig/GitHub Builds/LeavnOfficial/Core/LeavnCore/Sources/LeavnServices/Services/VoiceConfigurationService.swift"
    "/Users/wsig/GitHub Builds/LeavnOfficial/Core/LeavnCore/Sources/LeavnServices/Services/BibleServiceConfiguration.swift"
    "/Users/wsig/GitHub Builds/LeavnOfficial/Core/LeavnCore/Sources/LeavnServices/Services/BibleCacheManager.swift"
    "/Users/wsig/GitHub Builds/LeavnOfficial/Core/LeavnCore/Sources/LeavnServices/Services/BibleService.swift"
    "/Users/wsig/GitHub Builds/LeavnOfficial/Core/LeavnCore/Sources/LeavnServices/Services/AuthenticationService.swift"
    "/Users/wsig/GitHub Builds/LeavnOfficial/Core/LeavnCore/Sources/LeavnServices/Services/HapticManager.swift"
)

for file in "${files[@]}"; do
    if [ -f "$file" ]; then
        echo "Processing $file..."
        # Remove internal imports
        sed -i '' '/^import LeavnCore$/d' "$file"
        sed -i '' '/^import NetworkingKit$/d' "$file"
        sed -i '' '/^import PersistenceKit$/d' "$file"
        sed -i '' '/^import AnalyticsKit$/d' "$file"
        sed -i '' '/^import DesignSystem$/d' "$file"
        sed -i '' '/^import LeavnSettings$/d' "$file"
    fi
done

echo "Done!"