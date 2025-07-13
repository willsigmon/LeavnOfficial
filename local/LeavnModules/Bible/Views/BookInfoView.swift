import SwiftUI
import LeavnCore
import MapKit

public struct BookInfoView: View {
    let book: BibleBook
    let chapter: Int
    @Environment(\.dismiss) private var dismiss
    
    public var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Book Header
                    bookHeader
                    
                    // Author Section
                    authorSection
                    
                    // Writing Period
                    writingPeriodSection
                    
                    // Geographic Location
                    geographicSection
                    
                    // Key Themes
                    themesSection
                    
                    // Historical Context
                    historicalContextSection
                    
                    // Archaeological Findings
                    archaeologySection
                }
                .padding()
            }
            .navigationTitle("Book Information")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
    
    private var bookHeader: some View {
        VStack(alignment: .center, spacing: 12) {
            Text(book.name)
                .font(.largeTitle.bold())
            
            HStack(spacing: 20) {
                Label("\(book.chapterCount) Chapters", systemImage: "book.pages")
                Label(book.testament.rawValue, systemImage: "scroll")
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
    }
    
    private var authorSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Author", systemImage: "person.circle.fill")
                .font(.headline)
                .foregroundColor(.primary)
            
            Text(authorInfo(for: book))
                .font(.body)
                .foregroundColor(.secondary)
            
            if let authorBackground = authorBackground(for: book) {
                Text(authorBackground)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top, 4)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.regularMaterial)
        )
    }
    
    private var writingPeriodSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Written", systemImage: "calendar")
                .font(.headline)
            
            Text(writingPeriod(for: book))
                .font(.body)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.regularMaterial)
        )
    }
    
    private var geographicSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Geographic Setting", systemImage: "map")
                .font(.headline)
            
            Text(geographicSetting(for: book))
                .font(.body)
                .foregroundColor(.secondary)
            
            // Map View
            Map(initialPosition: .region(mapRegion(for: book))) {
                ForEach(locations(for: book)) { location in
                    Annotation(location.name, coordinate: location.coordinate) {
                        VStack {
                            Image(systemName: "mappin.circle.fill")
                                .font(.title)
                                .foregroundColor(.accentColor)
                            Text(location.name)
                                .font(.caption)
                                .padding(4)
                                .background(Color.white)
                                .cornerRadius(4)
                        }
                    }
                }
            }
            .frame(height: 200)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.regularMaterial)
        )
    }
    
    private var themesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Key Themes", systemImage: "lightbulb")
                .font(.headline)
            
            ForEach(themes(for: book), id: \.self) { theme in
                HStack {
                    Image(systemName: "chevron.right.circle.fill")
                        .font(.caption)
                        .foregroundColor(.accentColor)
                    Text(theme)
                        .font(.body)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.regularMaterial)
        )
    }
    
    private var historicalContextSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Historical Context", systemImage: "clock.arrow.circlepath")
                .font(.headline)
            
            Text(historicalContext(for: book))
                .font(.body)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.regularMaterial)
        )
    }
    
    private var archaeologySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Archaeological Insights", systemImage: "fossil.shell")
                .font(.headline)
            
            Text(archaeologicalFindings(for: book))
                .font(.body)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.regularMaterial)
        )
    }
    
    // MARK: - Data Methods
    
    private func authorInfo(for book: BibleBook) -> String {
        switch book.id {
        case "genesis", "exodus", "leviticus", "numbers", "deuteronomy":
            return "Moses"
        case "joshua":
            return "Joshua (with later editors)"
        case "psalms":
            return "Various authors including David, Asaph, and the sons of Korah"
        case "proverbs":
            return "Solomon, Agur, Lemuel, and other wise men"
        case "isaiah":
            return "Isaiah son of Amoz"
        case "matthew":
            return "Matthew (Levi), the tax collector turned apostle"
        case "mark":
            return "John Mark, companion of Peter"
        case "luke":
            return "Luke, the physician and companion of Paul"
        case "john":
            return "John, the beloved disciple"
        case "acts":
            return "Luke, the physician"
        case "romans", "1_corinthians", "2_corinthians", "galatians", "ephesians", "philippians", "colossians", "1_thessalonians", "2_thessalonians", "1_timothy", "2_timothy", "titus", "philemon":
            return "Paul the Apostle"
        case "hebrews":
            return "Unknown (possibly Paul, Barnabas, or Apollos)"
        case "james":
            return "James, the brother of Jesus"
        case "1_peter", "2_peter":
            return "Peter the Apostle"
        case "1_john", "2_john", "3_john":
            return "John the Apostle"
        case "revelation":
            return "John the Apostle (while exiled on Patmos)"
        default:
            return "Traditional authorship"
        }
    }
    
    private func authorBackground(for book: BibleBook) -> String? {
        switch book.id {
        case "matthew":
            return "A former tax collector who became one of Jesus' twelve disciples. His Jewish background is evident in his Gospel's emphasis on fulfilled prophecy."
        case "luke":
            return "A Gentile physician and historian who carefully investigated the events of Jesus' life. Also wrote the book of Acts."
        case "paul":
            return "Former Pharisee who persecuted Christians before his dramatic conversion on the road to Damascus. Became the apostle to the Gentiles."
        default:
            return nil
        }
    }
    
    private func writingPeriod(for book: BibleBook) -> String {
        switch book.id {
        case "genesis", "exodus", "leviticus", "numbers", "deuteronomy":
            return "~1400-1200 BC"
        case "psalms":
            return "~1000-400 BC (collected over centuries)"
        case "isaiah":
            return "~740-680 BC"
        case "matthew":
            return "~AD 60-70"
        case "mark":
            return "~AD 55-65"
        case "luke":
            return "~AD 60-80"
        case "john":
            return "~AD 85-95"
        case "acts":
            return "~AD 62-64"
        case "romans":
            return "~AD 57"
        case "revelation":
            return "~AD 95"
        default:
            return "See scholarly sources for dating"
        }
    }
    
    private func geographicSetting(for book: BibleBook) -> String {
        switch book.id {
        case "genesis":
            return "Mesopotamia, Canaan, and Egypt"
        case "exodus":
            return "Egypt, Sinai Peninsula, and the wilderness"
        case "matthew", "mark", "luke", "john":
            return "Israel/Palestine, primarily Galilee, Judea, and Jerusalem"
        case "acts":
            return "Jerusalem, Judea, Samaria, and throughout the Roman Empire"
        case "romans":
            return "Written from Corinth to the church in Rome"
        case "revelation":
            return "Written from Patmos to seven churches in Asia Minor"
        default:
            return "Ancient Near East"
        }
    }
    
    private func mapRegion(for book: BibleBook) -> MKCoordinateRegion {
        switch book.id {
        case "genesis":
            return MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 31.5, longitude: 35.0),
                span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10)
            )
        case "matthew", "mark", "luke", "john":
            return MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 31.7683, longitude: 35.2137),
                span: MKCoordinateSpan(latitudeDelta: 2, longitudeDelta: 2)
            )
        default:
            return MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 31.7683, longitude: 35.2137),
                span: MKCoordinateSpan(latitudeDelta: 5, longitudeDelta: 5)
            )
        }
    }
    
    private func locations(for book: BibleBook) -> [MapLocation] {
        switch book.id {
        case "genesis":
            return [
                MapLocation(name: "Eden (Traditional)", coordinate: CLLocationCoordinate2D(latitude: 33.5, longitude: 44.4)),
                MapLocation(name: "Ur", coordinate: CLLocationCoordinate2D(latitude: 30.9, longitude: 46.1)),
                MapLocation(name: "Haran", coordinate: CLLocationCoordinate2D(latitude: 36.9, longitude: 39.0)),
                MapLocation(name: "Canaan", coordinate: CLLocationCoordinate2D(latitude: 31.5, longitude: 35.0))
            ]
        case "matthew", "mark", "luke", "john":
            return [
                MapLocation(name: "Jerusalem", coordinate: CLLocationCoordinate2D(latitude: 31.7683, longitude: 35.2137)),
                MapLocation(name: "Bethlehem", coordinate: CLLocationCoordinate2D(latitude: 31.7054, longitude: 35.2024)),
                MapLocation(name: "Nazareth", coordinate: CLLocationCoordinate2D(latitude: 32.7021, longitude: 35.2978)),
                MapLocation(name: "Capernaum", coordinate: CLLocationCoordinate2D(latitude: 32.8806, longitude: 35.5751))
            ]
        default:
            return [
                MapLocation(name: "Jerusalem", coordinate: CLLocationCoordinate2D(latitude: 31.7683, longitude: 35.2137))
            ]
        }
    }
    
    private func themes(for book: BibleBook) -> [String] {
        switch book.id {
        case "genesis":
            return ["Creation", "Fall and Redemption", "Covenant", "Faith and Obedience", "God's Sovereignty"]
        case "exodus":
            return ["Deliverance", "God's Presence", "Law and Covenant", "Worship", "Freedom from Bondage"]
        case "psalms":
            return ["Worship and Praise", "Lament and Trust", "God's Character", "Messianic Hope", "Wisdom"]
        case "matthew":
            return ["Jesus as Messiah", "Kingdom of Heaven", "Fulfillment of Prophecy", "Discipleship", "New Covenant"]
        case "john":
            return ["Jesus as God", "Eternal Life", "Light vs Darkness", "Belief and Unbelief", "Love"]
        case "romans":
            return ["Justification by Faith", "Grace", "Sin and Redemption", "Life in the Spirit", "God's Sovereignty"]
        default:
            return ["Faith", "God's Sovereignty", "Redemption", "Hope"]
        }
    }
    
    private func historicalContext(for book: BibleBook) -> String {
        switch book.id {
        case "genesis":
            return "Genesis was written to provide the Israelites with an account of their origins and God's covenant relationship with their ancestors. " +
                   "It establishes foundational truths about God, humanity, sin, and redemption."
        case "exodus":
            return "Written to record Israel's deliverance from Egypt and establishment as God's covenant nation. " +
                   "The events occurred during the New Kingdom period of Egypt (likely under Ramesses II)."
        case "matthew":
            return "Written to Jewish Christians to demonstrate that Jesus is the promised Messiah. " +
                   "Written during a time of growing tension between the church and synagogue."
        case "romans":
            return "Written to the church in Rome before Paul's visit there. " +
                   "Addresses the relationship between Jewish and Gentile believers and presents a systematic exposition of the gospel."
        default:
            return "This book was written in a specific historical context that shaped its message and themes."
        }
    }
    
    private func archaeologicalFindings(for book: BibleBook) -> String {
        switch book.id {
        case "genesis":
            return "Tablets from Nuzi and Mari provide cultural parallels to patriarchal customs. " +
                   "The Epic of Gilgamesh offers flood narrative parallels. " +
                   "Archaeological evidence supports the existence of cities mentioned in Genesis."
        case "exodus":
            return "The Merneptah Stele (c. 1208 BC) contains the earliest extra-biblical reference to Israel. " +
                   "Excavations at Pi-Ramesses and Pithom support the biblical account of Hebrew slavery in Egypt."
        case "matthew", "mark", "luke", "john":
            return "The Pilate Stone confirms Pontius Pilate as prefect. " +
                   "The Pool of Bethesda and Pool of Siloam have been excavated. " +
                   "First-century synagogues in Galilee match Gospel descriptions."
        case "acts":
            return "Inscriptions confirm the accuracy of Luke's use of local titles. " +
                   "The Gallio inscription dates Paul's time in Corinth. " +
                   "Archaeological findings support Luke's detailed knowledge of first-century geography."
        default:
            return "Archaeological discoveries continue to illuminate the historical and cultural background of this biblical book."
        }
    }
}

struct MapLocation: Identifiable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
}