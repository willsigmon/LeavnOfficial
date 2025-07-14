import SwiftUI

public struct BookInfoSheet: View {
    let book: BibleBook
    @Environment(\.dismiss) private var dismiss
    @State private var showingMap = false
    @State private var selectedMapMode: MapMode = .modern
    
    public init(book: BibleBook) {
        self.book = book
    }
    
    public var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // Header with handle
                    headerHandle
                    
                    // Main content sections
                    VStack(spacing: 24) {
                        // Author Information Section
                        authorInformationSection
                        
                        // Chapter Information Section (like in screenshots)
                        chapterInformationSection
                        
                        // Key Themes Section
                        keyThemesSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 34) // Extra bottom padding for safe area
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarHidden(true)
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(0)
        .presentationBackground(.ultraThinMaterial)
        .sheet(isPresented: $showingMap) {
            NavigationView {
                VStack {
                    Text("Biblical Map")
                        .font(.title)
                        .padding()
                    Text("Interactive map showing locations relevant to \(book.name)")
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding()
                    Spacer()
                }
                .navigationTitle("Biblical Atlas")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            showingMap = false
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Header Handle
    private var headerHandle: some View {
        VStack(spacing: 16) {
            // Drag handle (iOS native style)
            RoundedRectangle(cornerRadius: 2.5)
                .fill(Color(.systemGray4))
                .frame(width: 36, height: 5)
                .padding(.top, 8)
            
            // Title and Done button
            HStack {
                Spacer()
                
                Text("Author Information")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button("Done") {
                    dismiss()
                }
                .font(.system(size: 17, weight: .regular))
                .foregroundColor(.accentColor)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 8)
        }
        .background(Color(.systemBackground))
    }
    
    // MARK: - Author Information Section
    private var authorInformationSection: some View {
        VStack(spacing: 16) {
            // Author avatar and basic info
            HStack(spacing: 16) {
                // Author avatar circle
                Circle()
                    .fill(Color(.systemGray5))
                    .frame(width: 60, height: 60)
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.secondary)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(bookInfo.author)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("Author of \(book.name)")
                        .font(.system(size: 15, weight: .regular))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            Divider()
                .padding(.vertical, 8)
            
            // About the Author section
            VStack(alignment: .leading, spacing: 12) {
                Text("About the Author")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text(bookInfo.authorBackground)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(.primary)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            // Historical Context section
            VStack(alignment: .leading, spacing: 12) {
                Text("Historical Context")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text(bookInfo.historicalContext)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(.primary)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            // Writing Style section
            VStack(alignment: .leading, spacing: 12) {
                Text("Writing Style")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text(writingStyleText)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(.primary)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }
    
    // MARK: - Chapter Information Section
    private var chapterInformationSection: some View {
        VStack(spacing: 16) {
            // Section header
            HStack {
                Text("Chapter Information")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button("Done") {
                    dismiss()
                }
                .font(.system(size: 17, weight: .regular))
                .foregroundColor(.accentColor)
            }
            
            // Location description
            Text(locationDescription)
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineSpacing(1)
                .padding(.horizontal, 16)
            
            // Map mode toggle
            HStack(spacing: 0) {
                Button(action: { selectedMapMode = .modern }) {
                    Text("Modern")
                        .font(.system(size: 13, weight: selectedMapMode == .modern ? .semibold : .regular))
                        .foregroundColor(selectedMapMode == .modern ? .primary : .secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(selectedMapMode == .modern ? Color(.systemBackground) : Color.clear)
                }
                
                Button(action: { selectedMapMode = .ancient }) {
                    Text("Ancient")
                        .font(.system(size: 13, weight: selectedMapMode == .ancient ? .semibold : .regular))
                        .foregroundColor(selectedMapMode == .ancient ? .primary : .secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(selectedMapMode == .ancient ? Color(.systemBackground) : Color.clear)
                }
            }
            .background(Color(.systemGray6))
            .cornerRadius(8)
            .padding(.horizontal, 16)
            
            // Map view placeholder (would show actual map)
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
                .frame(height: 200)
                .overlay(
                    VStack(spacing: 8) {
                        Image(systemName: "map.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.secondary)
                        Text("\(selectedMapMode == .modern ? "Modern" : "Ancient") Map View")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.secondary)
                        Text("Showing locations relevant to \(book.name)")
                            .font(.system(size: 13))
                            .foregroundColor(Color.secondary.opacity(0.7))
                            .multilineTextAlignment(.center)
                    }
                )
                .padding(.horizontal, 16)
            
            // Historical Timeline
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                    Text("Historical Timeline")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.primary)
                    Spacer()
                }
                .padding(.horizontal, 16)
                
                VStack(spacing: 12) {
                    ForEach(timelineEvents, id: \.date) { event in
                        HStack(spacing: 12) {
                            // Timeline dot
                            Circle()
                                .fill(event.isHighlighted ? Color.accentColor : Color(.systemGray4))
                                .frame(width: 8, height: 8)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(event.date)
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(event.isHighlighted ? .accentColor : .secondary)
                                
                                Text(event.title)
                                    .font(.system(size: 15, weight: .regular))
                                    .foregroundColor(.primary)
                            }
                            
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                    }
                }
            }
        }
        .padding(.vertical, 20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }
    
    // MARK: - Key Themes Section
    private var keyThemesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "sparkles")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                Text("Key Themes")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.primary)
                Spacer()
            }
            
            // Theme tags in a flowing layout
            FlowLayout(spacing: 8) {
                ForEach(bookInfo.keyThemes, id: \.self) { theme in
                    Text(theme)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color(.systemGray6))
                        .cornerRadius(16)
                }
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }
    
    // MARK: - Computed Properties
    private var bookInfo: BookContextualInfo {
        BookContextualInfo.info(for: book)
    }
    
    private var locationDescription: String {
        switch book.id.lowercased() {
        case "john":
            return "The holy city where Jesus had many important encounters, including with Nicodemus."
        case "genesis":
            return "The ancient Near East, from Mesopotamia through Canaan to Egypt."
        case "psalms":
            return "Centered in Jerusalem and the Temple, with references throughout Israel."
        default:
            return "Locations significant to the events and teachings in \(book.name)."
        }
    }
    
    private var writingStyleText: String {
        switch book.id.lowercased() {
        case "john":
            return "Simple vocabulary with profound theological depth. Emphasis on symbolism and spiritual meaning."
        case "genesis":
            return "Narrative prose with genealogies and covenant language. Foundational and declarative style."
        case "psalms":
            return "Hebrew poetry with parallelism, metaphor, and emotional expression. Musical and liturgical."
        default:
            return "Written in the distinctive style characteristic of its genre and historical period."
        }
    }
    
    private var timelineEvents: [TimelineEvent] {
        switch book.id.lowercased() {
        case "john":
            return [
                TimelineEvent(date: "4 BC", title: "Birth of Jesus", isHighlighted: false),
                TimelineEvent(date: "AD 27", title: "Jesus begins ministry", isHighlighted: true),
                TimelineEvent(date: "AD 28", title: "Ministry in Galilee", isHighlighted: false),
                TimelineEvent(date: "AD 30", title: "Crucifixion and Resurrection", isHighlighted: false)
            ]
        case "genesis":
            return [
                TimelineEvent(date: "Creation", title: "God creates the world", isHighlighted: true),
                TimelineEvent(date: "c. 2000 BC", title: "Abraham's calling", isHighlighted: false),
                TimelineEvent(date: "c. 1876 BC", title: "Jacob's family to Egypt", isHighlighted: false)
            ]
        case "psalms":
            return [
                TimelineEvent(date: "c. 1440 BC", title: "Moses writes Psalm 90", isHighlighted: false),
                TimelineEvent(date: "c. 1000 BC", title: "David's psalms", isHighlighted: true),
                TimelineEvent(date: "c. 970 BC", title: "Solomon's contributions", isHighlighted: false),
                TimelineEvent(date: "c. 586 BC", title: "Exile period psalms", isHighlighted: false)
            ]
        default:
            return [
                TimelineEvent(date: "Ancient", title: "Historical period", isHighlighted: true)
            ]
        }
    }
}

// MARK: - Supporting Types
enum MapMode {
    case modern, ancient
}

struct TimelineEvent {
    let date: String
    let title: String
    let isHighlighted: Bool
}

// MARK: - Flow Layout for Tags
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(
                x: bounds.minX + result.frames[index].minX,
                y: bounds.minY + result.frames[index].minY
            ), proposal: ProposedViewSize(result.frames[index].size))
        }
    }
}

struct FlowResult {
    var frames: [CGRect] = []
    var size: CGSize = .zero
    
    init(in maxWidth: CGFloat, subviews: LayoutSubviews, spacing: CGFloat) {
        var currentPosition = CGPoint.zero
        var lineHeight: CGFloat = 0
        var maxLineWidth: CGFloat = 0
        
        for subview in subviews {
            let subviewSize = subview.sizeThatFits(.unspecified)
            
            if currentPosition.x + subviewSize.width > maxWidth && currentPosition.x > 0 {
                // Move to next line
                currentPosition.x = 0
                currentPosition.y += lineHeight + spacing
                lineHeight = 0
            }
            
            frames.append(CGRect(origin: currentPosition, size: subviewSize))
            
            currentPosition.x += subviewSize.width + spacing
            lineHeight = max(lineHeight, subviewSize.height)
            maxLineWidth = max(maxLineWidth, currentPosition.x - spacing)
        }
        
        size = CGSize(width: maxLineWidth, height: currentPosition.y + lineHeight)
    }
}

// MARK: - Contextual Information Model

public struct BookContextualInfo {
    let author: String
    let authorLifespan: String?
    let authorBackground: String
    let dateWritten: String
    let timePeriod: String
    let historicalSetting: String
    let historicalContext: String
    let primaryLocation: String
    let keyLocations: [String]
    let geographicContext: String
    let keyThemes: [String]
    let quickFacts: [String]
    let description: String
    
    public static func info(for book: BibleBook) -> BookContextualInfo {
        switch book.id.lowercased() {
        case "genesis":
            return BookContextualInfo(
                author: "Moses",
                authorLifespan: "c. 1526-1406 BC",
                authorBackground: "Moses was a prophet, lawgiver, and leader who led the Israelites out of Egypt. " +
                                 "He received the Law at Mount Sinai and wrote the first five books of the Bible (Torah/Pentateuch).",
                dateWritten: "c. 1446-1406 BC",
                timePeriod: "Creation to Patriarchal Period",
                historicalSetting: "From creation through the time of the patriarchs in Canaan and Egypt",
                historicalContext: "Genesis covers the beginning of everything - creation, humanity, sin, and God's covenant with Abraham. " +
                                  "It sets the foundation for understanding God's relationship with humanity and His chosen people.",
                primaryLocation: "Mesopotamia, Canaan, Egypt",
                keyLocations: ["Garden of Eden", "Ur of the Chaldeans", "Haran", "Canaan", "Egypt"],
                geographicContext: "The narrative moves from Mesopotamia (modern Iraq) through the Promised Land " +
                                  "(Israel/Palestine) to Egypt, following the journeys of the patriarchs.",
                keyThemes: ["Creation", "Fall", "Covenant", "Promise", "Faith", "Redemption"],
                quickFacts: [
                    "First book of the Bible and Torah",
                    "Covers approximately 2,500 years of history", 
                    "Contains the first prophecy of the Messiah (3:15)",
                    "Establishes the Abrahamic Covenant"
                ],
                description: "The book of beginnings, establishing God's creation, humanity's fall, and the foundation of His redemptive plan through Abraham and his descendants."
            )
            
        case "john":
            return BookContextualInfo(
                author: "John the Apostle",
                authorLifespan: "c. 6-100 AD",
                authorBackground: "One of the twelve apostles, known as the 'disciple whom Jesus loved.' He was a fisherman before following Jesus and later became a prominent leader in the early church.",
                dateWritten: "c. 85-95 AD",
                timePeriod: "Jesus' Ministry (c. 30-33 AD)",
                historicalSetting: "Palestine during Roman occupation",
                historicalContext: "Written decades after the other Gospels to present Jesus as the divine Son of God. John wrote to strengthen believers' faith and counter early heresies about Christ's nature.",
                primaryLocation: "Palestine (Israel)",
                keyLocations: ["Jerusalem", "Galilee", "Samaria", "Bethany", "Capernaum"],
                geographicContext: "Jesus' ministry primarily in Palestine, with significant time in Jerusalem and around the Sea of Galilee.",
                keyThemes: ["Eternal Life", "Light vs. Darkness", "Truth", "Love", "Signs", "Glory"],
                quickFacts: [
                    "Contains the famous John 3:16 verse",
                    "Records seven 'I AM' statements of Jesus",
                    "Focuses on Jesus' divine nature",
                    "Written by an eyewitness to Jesus' ministry"
                ],
                description: "A unique Gospel emphasizing Jesus' divinity through carefully selected signs and teachings, written to inspire belief in Jesus as the Son of God."
            )
            
        case "psalms":
            return BookContextualInfo(
                author: "Multiple (primarily David)",
                authorLifespan: "David: c. 1040-970 BC",
                authorBackground: "King David wrote about half the psalms. Other contributors include Asaph, the Sons of Korah, Solomon, Moses, and anonymous writers. David was a shepherd, warrior, and king after God's own heart.",
                dateWritten: "c. 1440-586 BC",
                timePeriod: "From Moses to the Exile",
                historicalSetting: "Various periods of Israel's history",
                historicalContext: "A collection of songs, prayers, and poems used in worship. They express the full range of human emotion in relationship with God - praise, lament, thanksgiving, and petition.",
                primaryLocation: "Israel/Palestine",
                keyLocations: ["Jerusalem", "Temple", "Wilderness", "Zion"],
                geographicContext: "Centered in Israel with the Temple in Jerusalem as the focal point of worship, though many psalms reference the wilderness and various locations throughout the land.",
                keyThemes: ["Worship", "Trust", "Deliverance", "God's Faithfulness", "Righteousness", "Messianic Hope"],
                quickFacts: [
                    "150 individual psalms",
                    "The longest book in the Bible",
                    "Psalm 119 is the longest chapter in the Bible",
                    "Jesus quoted from Psalms more than any other book"
                ],
                description: "The hymnbook of ancient Israel, expressing every human emotion in worship and providing a model for honest communication with God."
            )
            
        default:
            return BookContextualInfo(
                author: "Various",
                authorLifespan: nil,
                authorBackground: "Biblical authors were inspired by God to write His Word.",
                dateWritten: "Various dates",
                timePeriod: "Biblical times",
                historicalSetting: "Ancient Near East",
                historicalContext: "Part of God's progressive revelation to humanity.",
                primaryLocation: "Middle East",
                keyLocations: ["Jerusalem", "Israel"],
                geographicContext: "Located in the ancient Near East.",
                keyThemes: ["Faith", "Redemption", "God's Love"],
                quickFacts: ["Part of the Bible", "Inspired by God"],
                description: "A book of the Bible containing God's revelation to humanity."
            )
        }
    }
}

// MARK: - Extensions

extension BibleBook {
    var icon: String {
        switch id.lowercased() {
        case "genesis": return "globe.americas"
        case "exodus": return "figure.walk"
        case "leviticus": return "flame"
        case "numbers": return "number.circle"
        case "deuteronomy": return "scroll"
        case "joshua": return "shield"
        case "judges": return "hammer"
        case "ruth": return "heart"
        case "1samuel", "2samuel": return "crown"
        case "1kings", "2kings": return "building.columns"
        case "1chronicles", "2chronicles": return "book.closed"
        case "ezra": return "building.2"
        case "nehemiah": return "hammer.circle"
        case "esther": return "crown.fill"
        case "job": return "questionmark.circle"
        case "psalms": return "music.note"
        case "proverbs": return "lightbulb"
        case "ecclesiastes": return "clock"
        case "songofsolomon": return "heart.circle"
        case "isaiah": return "megaphone"
        case "jeremiah": return "exclamationmark.triangle"
        case "lamentations": return "drop"
        case "ezekiel": return "eye"
        case "daniel": return "lion"
        case "hosea": return "heart.slash"
        case "joel": return "cloud.rain"
        case "amos": return "scalemass"
        case "obadiah": return "mountain.2"
        case "jonah": return "fish"
        case "micah": return "speaker.wave.2"
        case "nahum": return "bolt"
        case "habakkuk": return "questionmark.square"
        case "zephaniah": return "flame.circle"
        case "haggai": return "hammer.fill"
        case "zechariah": return "eye"
        case "malachi": return "envelope"
        case "matthew": return "person.3"
        case "mark": return "bolt.circle"
        case "luke": return "stethoscope"
        case "john": return "heart.circle.fill"
        case "acts": return "arrow.triangle.branch"
        case "romans": return "scalemass"
        case "1corinthians", "2corinthians": return "building.columns.circle"
        case "galatians": return "key"
        case "ephesians": return "shield.fill"
        case "philippians": return "smiley"
        case "colossians": return "crown.circle"
        case "1thessalonians", "2thessalonians": return "clock.arrow.2.circlepath"
        case "1timothy", "2timothy": return "person.crop.circle"
        case "titus": return "person.badge.plus"
        case "philemon": return "envelope.circle"
        case "hebrews": return "building.columns.fill"
        case "james": return "wrench.and.screwdriver"
        case "1peter", "2peter": return "key.fill"
        case "1john", "2john", "3john": return "heart.text.square"
        case "jude": return "exclamationmark.shield"
        case "revelation": return "eye.trianglebadge.exclamationmark"
        default: return "book.closed"
        }
    }
    
    var color: Color {
        switch testament {
        case .old: return .blue
        case .new: return .purple
        }
    }
}

// MARK: - Preview
#Preview {
    BookInfoSheet(book: BibleBook(id: "genesis", name: "Genesis", shortName: "Gen", testament: .old, chapterCount: 50, order: 1))
}
