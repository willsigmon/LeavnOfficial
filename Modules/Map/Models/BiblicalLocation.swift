import Foundation
import CoreLocation

public struct BiblicalLocation: Identifiable, Sendable {
    public let id = UUID()
    public let name: String
    public let ancientName: String?
    public let modernName: String?
    public let coordinate: CLLocationCoordinate2D
    public let timePeriods: [TimePeriod]
    public let biblicalReferences: [BiblicalReference]
    public let description: String
    public let significance: String?
    public let imageNames: [String]
    
    public init(name: String, ancientName: String? = nil, modernName: String? = nil, 
                coordinate: CLLocationCoordinate2D, timePeriods: [TimePeriod], 
                biblicalReferences: [BiblicalReference], description: String, 
                significance: String? = nil, imageNames: [String] = []) {
        self.name = name
        self.ancientName = ancientName
        self.modernName = modernName
        self.coordinate = coordinate
        self.timePeriods = timePeriods
        self.biblicalReferences = biblicalReferences
        self.description = description
        self.significance = significance
        self.imageNames = imageNames
    }
}

public struct BiblicalReference: Sendable {
    public let book: String
    public let chapter: Int
    public let verse: Int?
    public let text: String
    
    public init(book: String, chapter: Int, verse: Int? = nil, text: String) {
        self.book = book
        self.chapter = chapter
        self.verse = verse
        self.text = text
    }
}

public enum TimePeriod: String, CaseIterable, Sendable {
    case patriarchal = "Patriarchal (2000-1500 BC)"
    case exodus = "Exodus & Conquest (1500-1200 BC)"
    case judges = "Judges (1200-1000 BC)"
    case unitedKingdom = "United Kingdom (1000-930 BC)"
    case dividedKingdom = "Divided Kingdom (930-586 BC)"
    case exile = "Exile & Return (586-400 BC)"
    case intertestamental = "Intertestamental (400-5 BC)"
    case ministry = "Jesus' Ministry (5 BC-30 AD)"
    case earlyChurch = "Early Church (30-100 AD)"
    case conquest = "Conquest (1400-1200 BC)"
    
    public var dateRange: String {
        switch self {
        case .patriarchal: return "2000-1500 BC"
        case .exodus: return "1500-1200 BC"
        case .judges: return "1200-1000 BC"
        case .unitedKingdom: return "1000-930 BC"
        case .dividedKingdom: return "930-586 BC"
        case .exile: return "586-400 BC"
        case .intertestamental: return "400-5 BC"
        case .ministry: return "5 BC-30 AD"
        case .earlyChurch: return "30-100 AD"
        case .conquest: return "1400-1200 BC"
        }
    }
}

public struct AncientRoute: Identifiable, Sendable {
    public let id = UUID()
    public let name: String
    public let type: RouteType
    public let timePeriod: TimePeriod
    public let waypoints: [CLLocationCoordinate2D]
    public let description: String
    public let biblicalReferences: [BiblicalReference]
    
    public init(name: String, type: RouteType, timePeriod: TimePeriod, 
                waypoints: [CLLocationCoordinate2D], description: String, 
                biblicalReferences: [BiblicalReference]) {
        self.name = name
        self.type = type
        self.timePeriod = timePeriod
        self.waypoints = waypoints
        self.description = description
        self.biblicalReferences = biblicalReferences
    }
}

public enum RouteType: Sendable {
    case exodus
    case conquest
    case trade
    case missionary
    case pilgrimage
    case military
    case ministry
}

public struct AncientTerritory: Identifiable {
    public let id = UUID()
    public let name: String
    public let timePeriod: TimePeriod
    public let boundaries: [CLLocationCoordinate2D]
    public let capital: BiblicalLocation?
    public let description: String
    
    public init(name: String, timePeriod: TimePeriod, boundaries: [CLLocationCoordinate2D], 
                capital: BiblicalLocation? = nil, description: String) {
        self.name = name
        self.timePeriod = timePeriod
        self.boundaries = boundaries
        self.capital = capital
        self.description = description
    }
}