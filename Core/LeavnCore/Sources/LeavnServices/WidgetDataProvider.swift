import Foundation
import WidgetKit

// MARK: - Widget Data Provider
/// Provides data formatted for iOS widgets
public final class WidgetDataProvider {
    private let verseOfTheDayService: VerseOfTheDayServiceProtocol
    private let bibleService: BibleServiceProtocol
    
    public init(verseOfTheDayService: VerseOfTheDayServiceProtocol, bibleService: BibleServiceProtocol) {
        self.verseOfTheDayService = verseOfTheDayService
        self.bibleService = bibleService
    }
    
    /// Get timeline entries for the verse of the day widget
    public func getVerseTimeline(for configuration: VerseWidgetConfiguration) async throws -> [VerseTimelineEntry] {
        var entries: [VerseTimelineEntry] = []
        let currentDate = Date()
        
        // Create entries for the next 7 days
        for dayOffset in 0..<7 {
            guard let date = Calendar.current.date(byAdding: .day, value: dayOffset, to: currentDate) else {
                continue
            }
            
            let verse = try await verseOfTheDayService.getVerseForDate(date, translation: configuration.translation)
            let entry = VerseTimelineEntry(
                date: date,
                verse: WidgetVerse(
                    text: verse.text,
                    reference: verse.reference,
                    translation: verse.translation,
                    date: date
                ),
                configuration: configuration
            )
            entries.append(entry)
        }
        
        return entries
    }
    
    /// Get a placeholder entry for widget gallery
    public func getPlaceholderEntry() -> VerseTimelineEntry {
        VerseTimelineEntry(
            date: Date(),
            verse: WidgetVerse(
                text: "For God so loved the world, that he gave his only Son, that whoever believes in him should not perish but have eternal life.",
                reference: "John 3:16",
                translation: "ESV",
                date: Date()
            ),
            configuration: VerseWidgetConfiguration()
        )
    }
    
    /// Refresh widget data
    public func refreshWidget() {
        WidgetCenter.shared.reloadAllTimelines()
    }
}

// MARK: - Widget Configuration
public struct VerseWidgetConfiguration {
    public let translation: BibleTranslation
    public let fontSize: WidgetFontSize
    public let showTranslation: Bool
    public let colorScheme: WidgetColorScheme
    
    public init(
        translation: BibleTranslation = BibleTranslation(
            id: "ESV",
            name: "English Standard Version",
            abbreviation: "ESV",
            language: "English"
        ),
        fontSize: WidgetFontSize = .medium,
        showTranslation: Bool = true,
        colorScheme: WidgetColorScheme = .automatic
    ) {
        self.translation = translation
        self.fontSize = fontSize
        self.showTranslation = showTranslation
        self.colorScheme = colorScheme
    }
}

// MARK: - Widget Models
public struct VerseTimelineEntry: TimelineEntry {
    public let date: Date
    public let verse: WidgetVerse
    public let configuration: VerseWidgetConfiguration
    
    public init(date: Date, verse: WidgetVerse, configuration: VerseWidgetConfiguration) {
        self.date = date
        self.verse = verse
        self.configuration = configuration
    }
}

public enum WidgetFontSize: String, CaseIterable {
    case small
    case medium
    case large
    
    public var textSize: Double {
        switch self {
        case .small: return 14
        case .medium: return 16
        case .large: return 18
        }
    }
    
    public var referenceSize: Double {
        switch self {
        case .small: return 12
        case .medium: return 14
        case .large: return 16
        }
    }
}

public enum WidgetColorScheme: String, CaseIterable {
    case automatic
    case light
    case dark
    case sunrise
    case sunset
    
    public var backgroundColor: String {
        switch self {
        case .automatic: return "systemBackground"
        case .light: return "white"
        case .dark: return "black"
        case .sunrise: return "sunriseGradient"
        case .sunset: return "sunsetGradient"
        }
    }
    
    public var textColor: String {
        switch self {
        case .automatic: return "label"
        case .light: return "black"
        case .dark: return "white"
        case .sunrise: return "darkText"
        case .sunset: return "lightText"
        }
    }
}