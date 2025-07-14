import Foundation
import CoreLocation

public class BiblicalMapData {
    @MainActor public static let shared = BiblicalMapData()
    
    public lazy var locations: [BiblicalLocation] = {
        return baseLocations + BiblicalMapData.extendedLocations
    }()
    
    private let baseLocations: [BiblicalLocation] = [
        // Major Cities - Old Testament
        BiblicalLocation(
            name: "Jerusalem",
            ancientName: "Jebus",
            modernName: "Jerusalem",
            coordinate: CLLocationCoordinate2D(latitude: 31.7683, longitude: 35.2137),
            timePeriods: TimePeriod.allCases,
            biblicalReferences: [
                BiblicalReference(book: "2 Samuel", chapter: 5, verse: 6, text: "David captured the fortress of Zion"),
                BiblicalReference(book: "Matthew", chapter: 21, verse: 1, text: "Jesus entered Jerusalem")
            ],
            description: "The holy city, capital of Israel and Judah",
            significance: "Center of Jewish worship, site of the Temple",
            imageNames: ["jerusalem_ancient"]
        ),
        
        BiblicalLocation(
            name: "Bethlehem",
            ancientName: "Ephrath",
            modernName: "Beit Lahm",
            coordinate: CLLocationCoordinate2D(latitude: 31.7054, longitude: 35.2024),
            timePeriods: [.patriarchal, .judges, .unitedKingdom, .dividedKingdom, .ministry],
            biblicalReferences: [
                BiblicalReference(book: "Micah", chapter: 5, verse: 2, text: "But you, Bethlehem Ephrathah"),
                BiblicalReference(book: "Luke", chapter: 2, verse: 4, text: "Joseph went to Bethlehem")
            ],
            description: "City of David, birthplace of Jesus",
            significance: "Birthplace of King David and Jesus Christ",
            imageNames: ["bethlehem_ancient"]
        ),
        
        BiblicalLocation(
            name: "Jericho",
            ancientName: "City of Palms",
            modernName: "Ariha",
            coordinate: CLLocationCoordinate2D(latitude: 31.8701, longitude: 35.4436),
            timePeriods: [.exodus, .judges, .unitedKingdom, .ministry],
            biblicalReferences: [
                BiblicalReference(book: "Joshua", chapter: 6, verse: 20, text: "The walls of Jericho fell"),
                BiblicalReference(book: "Luke", chapter: 19, verse: 1, text: "Jesus entered Jericho")
            ],
            description: "One of the oldest inhabited cities in the world",
            significance: "First city conquered by Israel in Canaan",
            imageNames: ["jericho_ancient"]
        ),
        
        // Egypt locations
        BiblicalLocation(
            name: "Rameses",
            ancientName: "Pi-Ramesses",
            modernName: "Qantir",
            coordinate: CLLocationCoordinate2D(latitude: 30.7988, longitude: 31.8285),
            timePeriods: [.exodus],
            biblicalReferences: [
                BiblicalReference(book: "Exodus", chapter: 1, verse: 11, text: "They built Pithom and Rameses")
            ],
            description: "Store city built by Hebrew slaves",
            significance: "Starting point of the Exodus",
            imageNames: ["rameses_ancient"]
        ),
        
        // New Testament locations
        BiblicalLocation(
            name: "Capernaum",
            ancientName: "Kfar Nahum",
            modernName: "Tell Hum",
            coordinate: CLLocationCoordinate2D(latitude: 32.8808, longitude: 35.5752),
            timePeriods: [.ministry, .earlyChurch],
            biblicalReferences: [
                BiblicalReference(book: "Matthew", chapter: 4, verse: 13, text: "Jesus went and lived in Capernaum")
            ],
            description: "Jesus' ministry headquarters",
            significance: "Center of Jesus' Galilean ministry",
            imageNames: ["capernaum_ancient"]
        ),
        
        BiblicalLocation(
            name: "Nazareth",
            ancientName: nil,
            modernName: "Nazareth",
            coordinate: CLLocationCoordinate2D(latitude: 32.7021, longitude: 35.2978),
            timePeriods: [.ministry],
            biblicalReferences: [
                BiblicalReference(book: "Luke", chapter: 2, verse: 39, text: "They returned to Nazareth")
            ],
            description: "Hometown of Jesus",
            significance: "Where Jesus grew up",
            imageNames: ["nazareth_ancient"]
        ),
        
        // Paul's mission locations
        BiblicalLocation(
            name: "Damascus",
            ancientName: nil,
            modernName: "Damascus",
            coordinate: CLLocationCoordinate2D(latitude: 33.5138, longitude: 36.2765),
            timePeriods: [.patriarchal, .unitedKingdom, .dividedKingdom, .earlyChurch],
            biblicalReferences: [
                BiblicalReference(book: "Acts", chapter: 9, verse: 3, text: "As he neared Damascus")
            ],
            description: "Ancient trade center",
            significance: "Site of Paul's conversion",
            imageNames: ["damascus_ancient"]
        ),
        
        BiblicalLocation(
            name: "Antioch",
            ancientName: nil,
            modernName: "Antakya",
            coordinate: CLLocationCoordinate2D(latitude: 36.2028, longitude: 36.1607),
            timePeriods: [.earlyChurch],
            biblicalReferences: [
                BiblicalReference(book: "Acts", chapter: 11, verse: 26, text: "The disciples were called Christians first at Antioch")
            ],
            description: "Early church center",
            significance: "First Gentile church, missionary hub",
            imageNames: ["antioch_ancient"]
        )
    ]
    
    public lazy var routes: [AncientRoute] = {
        return baseRoutes + BiblicalMapData.extendedRoutes
    }()
    
    private let baseRoutes: [AncientRoute] = [
        AncientRoute(
            name: "The Exodus Route",
            type: .exodus,
            timePeriod: .exodus,
            waypoints: [
                CLLocationCoordinate2D(latitude: 30.7988, longitude: 31.8285), // Rameses
                CLLocationCoordinate2D(latitude: 30.5852, longitude: 32.2654), // Succoth
                CLLocationCoordinate2D(latitude: 29.9792, longitude: 32.5498), // Red Sea crossing
                CLLocationCoordinate2D(latitude: 28.5506, longitude: 33.9764), // Mount Sinai
                CLLocationCoordinate2D(latitude: 30.3312, longitude: 35.4407)  // Kadesh Barnea
            ],
            description: "The route taken by Israel from Egypt to the Promised Land",
            biblicalReferences: [
                BiblicalReference(book: "Exodus", chapter: 13, verse: 17, text: "God did not lead them by way of the Philistines")
            ]
        ),
        
        AncientRoute(
            name: "Paul's First Missionary Journey",
            type: .missionary,
            timePeriod: .earlyChurch,
            waypoints: [
                CLLocationCoordinate2D(latitude: 36.2028, longitude: 36.1607), // Antioch
                CLLocationCoordinate2D(latitude: 35.1264, longitude: 33.4299), // Cyprus
                CLLocationCoordinate2D(latitude: 36.8969, longitude: 30.7133), // Perga
                CLLocationCoordinate2D(latitude: 38.3235, longitude: 31.1879), // Antioch Pisidia
                CLLocationCoordinate2D(latitude: 37.8714, longitude: 32.4933), // Iconium
                CLLocationCoordinate2D(latitude: 37.5763, longitude: 32.8072), // Lystra
                CLLocationCoordinate2D(latitude: 37.3488, longitude: 33.2574)  // Derbe
            ],
            description: "Paul's first journey spreading the Gospel to the Gentiles",
            biblicalReferences: [
                BiblicalReference(book: "Acts", chapter: 13, verse: 4, text: "They sailed from Seleucia to Cyprus")
            ]
        )
    ]
    
    public let territories: [AncientTerritory] = [
        AncientTerritory(
            name: "Kingdom of Israel",
            timePeriod: .unitedKingdom,
            boundaries: [
                CLLocationCoordinate2D(latitude: 33.2767, longitude: 35.2023), // Dan
                CLLocationCoordinate2D(latitude: 31.0461, longitude: 34.8516), // Beersheba
                CLLocationCoordinate2D(latitude: 31.7683, longitude: 35.2137), // Jerusalem
                CLLocationCoordinate2D(latitude: 32.2211, longitude: 35.2544)  // Jordan River
            ],
            capital: nil, // Jerusalem
            description: "United Kingdom under Saul, David, and Solomon"
        ),
        
        AncientTerritory(
            name: "Northern Kingdom (Israel)",
            timePeriod: .dividedKingdom,
            boundaries: [
                CLLocationCoordinate2D(latitude: 33.2767, longitude: 35.2023), // Dan
                CLLocationCoordinate2D(latitude: 32.2808, longitude: 35.2028), // Samaria
                CLLocationCoordinate2D(latitude: 31.9522, longitude: 35.2332), // Bethel
                CLLocationCoordinate2D(latitude: 32.7940, longitude: 35.5298)  // Sea of Galilee
            ],
            capital: nil, // Samaria
            description: "Northern Kingdom after the division"
        )
    ]
}