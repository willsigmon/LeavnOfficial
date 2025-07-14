import SwiftUI
import LeavnServices

/// A card component for displaying Bible reading plan progress
/// Works across all platforms with adaptive layouts
public struct ReadingPlanCard: View {
    let readingPlan: BibleReadingPlan
    let onTap: () -> Void
    let onContinueReading: () -> Void
    
    @Environment(\.hapticManager) private var hapticManager
    
    public struct BibleReadingPlan {
        let id: UUID
        let title: String
        let description: String
        let duration: String // e.g., "365 days", "52 weeks"
        let currentDay: Int
        let totalDays: Int
        let todaysReading: [ReadingSection]
        let isCompleted: Bool
        let lastReadDate: Date?
        
        public struct ReadingSection {
            let book: String
            let chapters: String // e.g., "1-3", "5"
            let isCompleted: Bool
            
            public init(book: String, chapters: String, isCompleted: Bool = false) {
                self.book = book
                self.chapters = chapters
                self.isCompleted = isCompleted
            }
        }
        
        public var progressPercentage: Double {
            guard totalDays > 0 else { return 0 }
            return Double(currentDay) / Double(totalDays)
        }
        
        public var remainingDays: Int {
            max(0, totalDays - currentDay)
        }
        
        public init(
            id: UUID = UUID(),
            title: String,
            description: String,
            duration: String,
            currentDay: Int,
            totalDays: Int,
            todaysReading: [ReadingSection],
            isCompleted: Bool = false,
            lastReadDate: Date? = nil
        ) {
            self.id = id
            self.title = title
            self.description = description
            self.duration = duration
            self.currentDay = currentDay
            self.totalDays = totalDays
            self.todaysReading = todaysReading
            self.isCompleted = isCompleted
            self.lastReadDate = lastReadDate
        }
    }
    
    public init(
        readingPlan: BibleReadingPlan,
        onTap: @escaping () -> Void,
        onContinueReading: @escaping () -> Void
    ) {
        self.readingPlan = readingPlan
        self.onTap = onTap
        self.onContinueReading = onContinueReading
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(readingPlan.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(readingPlan.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                if readingPlan.isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.title2)
                }
            }
            
            // Progress section
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Day \(readingPlan.currentDay) of \(readingPlan.totalDays)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text("\(Int(readingPlan.progressPercentage * 100))%")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                }
                
                ProgressView(value: readingPlan.progressPercentage)
                    .tint(Color("BookmarkBlue"))
                    .background(Color(.systemGray5))
                
                if !readingPlan.isCompleted {
                    Text("\(readingPlan.remainingDays) days remaining")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Today's reading
            if !readingPlan.todaysReading.isEmpty && !readingPlan.isCompleted {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Today's Reading")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 8) {
                        ForEach(Array(readingPlan.todaysReading.enumerated()), id: \.offset) { _, section in
                            ReadingSectionView(section: section)
                        }
                    }
                }
            }
            
            // Action buttons
            HStack(spacing: 12) {
                if !readingPlan.isCompleted {
                    Button(action: { 
                        hapticManager.triggerFeedback(.success)
                        onContinueReading() 
                    }) {
                        Text("Continue Reading")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(Color("BookmarkBlue"))
                            .cornerRadius(8)
                    }
                }
                
                Button(action: { 
                    hapticManager.triggerFeedback(.medium)
                    onTap() 
                }) {
                    Text("View Plan")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(Color("BookmarkBlue"))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color("BookmarkBlue").opacity(0.1))
                        .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Reading Section View
private struct ReadingSectionView: View {
    let section: ReadingPlanCard.BibleReadingPlan.ReadingSection
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: section.isCompleted ? "checkmark.circle.fill" : "circle")
                .foregroundColor(section.isCompleted ? .green : .secondary)
                .font(.caption)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(section.book)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Text("Ch. \(section.chapters)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(Color(.systemGray6))
        .cornerRadius(6)
    }
}

// MARK: - Compact Reading Plan Card for Apple Watch
public struct CompactReadingPlanCard: View {
    let readingPlan: ReadingPlanCard.BibleReadingPlan
    let onTap: () -> Void
    
    @Environment(\.hapticManager) private var hapticManager
    
    public init(readingPlan: ReadingPlanCard.BibleReadingPlan, onTap: @escaping () -> Void) {
        self.readingPlan = readingPlan
        self.onTap = onTap
    }
    
    public var body: some View {
        Button(action: { 
            hapticManager.triggerFeedback(.medium)
            onTap() 
        }) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(readingPlan.title)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    if readingPlan.isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.caption)
                    }
                }
                
                Text("Day \(readingPlan.currentDay)/\(readingPlan.totalDays)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
                ProgressView(value: readingPlan.progressPercentage)
                    .tint(Color("BookmarkBlue"))
                    .scaleEffect(y: 0.5)
            }
            .padding(8)
            .background(Color(.systemGray6))
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview
struct ReadingPlanCard_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            ReadingPlanCard(
                readingPlan: ReadingPlanCard.BibleReadingPlan(
                    title: "One Year Bible",
                    description: "Read through the entire Bible in 365 days with a mix of Old Testament, New Testament, Psalms, and Proverbs.",
                    duration: "365 days",
                    currentDay: 127,
                    totalDays: 365,
                    todaysReading: [
                        .init(book: "Genesis", chapters: "8-10", isCompleted: true),
                        .init(book: "Matthew", chapters: "4", isCompleted: false),
                        .init(book: "Psalm", chapters: "15", isCompleted: false),
                        .init(book: "Proverbs", chapters: "5", isCompleted: false)
                    ],
                    lastReadDate: Date()
                ),
                onTap: {},
                onContinueReading: {}
            )
            
            ReadingPlanCard(
                readingPlan: ReadingPlanCard.BibleReadingPlan(
                    title: "New Testament in 30 Days",
                    description: "Focus on the life and teachings of Jesus and the early church.",
                    duration: "30 days",
                    currentDay: 30,
                    totalDays: 30,
                    todaysReading: [],
                    isCompleted: true,
                    lastReadDate: Date()
                ),
                onTap: {},
                onContinueReading: {}
            )
            
            CompactReadingPlanCard(
                readingPlan: ReadingPlanCard.BibleReadingPlan(
                    title: "Psalms & Proverbs",
                    description: "Wisdom literature",
                    duration: "31 days",
                    currentDay: 15,
                    totalDays: 31,
                    todaysReading: []
                ),
                onTap: {}
            )
        }
        .padding()
    }
}