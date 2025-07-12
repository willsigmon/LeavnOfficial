import WidgetKit
import SwiftUI
import LeavnServices

struct Provider: TimelineProvider {
    private let bibleService = DIContainer.shared.bibleService  // Inject from shared DIContainer

    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), verse: "John 3:16 - For God so loved the world...")
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        #if swift(>=6.0)  // iOS 18+ dynamic fetch
        bibleService.getDailyVerse { result in
            let verse: String
            switch result {
            case .success(let dailyVerse):
                verse = "\(dailyVerse.reference) - \(dailyVerse.text)"
            case .failure:
                verse = "John 3:16 - For God so loved the world..."  // Fallback
            }
            let entry = SimpleEntry(date: Date(), verse: verse)
            completion(entry)
        }
        #else
        let entry = SimpleEntry(date: Date(), verse: "John 3:16 - For God so loved the world...")
        completion(entry)
        #endif
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            #if swift(>=6.0)
            bibleService.getDailyVerse { result in
                let verse: String
                switch result {
                case .success(let dailyVerse):
                    verse = "\(dailyVerse.reference) - \(dailyVerse.text)"
                case .failure:
                    verse = "John 3:16 - For God so loved the world..."
                }
                let entry = SimpleEntry(date: entryDate, verse: verse)
                entries.append(entry)
            }
            #else
            let entry = SimpleEntry(date: entryDate, verse: "John 3:16 - For God so loved the world...")
            entries.append(entry)
            #endif
        }
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let verse: String
}

struct DailyVerseWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        Text(entry.verse)
            .foregroundStyle(.tint)
            .widgetAccentable(true)
            .containerBackground(.fill.tertiary, for: .widget)
    }
}

struct DailyVerseWidget: Widget {
    let kind: String = "DailyVerseWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            DailyVerseWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Daily Verse")
        .description("Displays a daily Bible verse.")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryRectangular])
    }
} 