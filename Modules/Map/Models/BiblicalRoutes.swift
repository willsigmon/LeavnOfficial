import Foundation
import CoreLocation

extension BiblicalMapData {
    static let extendedRoutes: [AncientRoute] = [
        // Abraham's Journey
        AncientRoute(
            name: "Abraham's Journey to Canaan",
            type: .pilgrimage,
            timePeriod: .patriarchal,
            waypoints: [
                CLLocationCoordinate2D(latitude: 30.9625, longitude: 46.1031), // Ur
                CLLocationCoordinate2D(latitude: 36.8641, longitude: 39.0254), // Haran
                CLLocationCoordinate2D(latitude: 33.5138, longitude: 36.2765), // Damascus
                CLLocationCoordinate2D(latitude: 32.2154, longitude: 35.2743), // Shechem
                CLLocationCoordinate2D(latitude: 31.7718, longitude: 35.2560), // Bethel
                CLLocationCoordinate2D(latitude: 31.5326, longitude: 35.0998), // Hebron
                CLLocationCoordinate2D(latitude: 31.2518, longitude: 34.7913)  // Beersheba
            ],
            description: "The journey of faith from Mesopotamia to the Promised Land",
            biblicalReferences: [
                BiblicalReference(book: "Genesis", chapter: 12, verse: 1, text: "Leave your country and go to the land I will show you")
            ]
        ),
        
        // Exodus Route - Detailed
        AncientRoute(
            name: "The Exodus: Egypt to Mount Sinai",
            type: .exodus,
            timePeriod: .exodus,
            waypoints: [
                CLLocationCoordinate2D(latitude: 30.7988, longitude: 31.8285), // Rameses
                CLLocationCoordinate2D(latitude: 30.5852, longitude: 32.2654), // Succoth
                CLLocationCoordinate2D(latitude: 30.1234, longitude: 32.3456), // Etham
                CLLocationCoordinate2D(latitude: 29.9792, longitude: 32.5498), // Red Sea crossing
                CLLocationCoordinate2D(latitude: 29.5000, longitude: 33.0000), // Wilderness of Shur
                CLLocationCoordinate2D(latitude: 29.1961, longitude: 33.1505), // Marah
                CLLocationCoordinate2D(latitude: 29.0500, longitude: 33.3000), // Elim
                CLLocationCoordinate2D(latitude: 28.7500, longitude: 33.4500), // Wilderness of Sin
                CLLocationCoordinate2D(latitude: 28.5393, longitude: 33.9733)  // Mount Sinai
            ],
            description: "The miraculous journey from slavery to the covenant at Sinai",
            biblicalReferences: [
                BiblicalReference(book: "Exodus", chapter: 13, verse: 18, text: "God led the people around by the desert road")
            ]
        ),
        
        // Wilderness Wandering
        AncientRoute(
            name: "40 Years in the Wilderness",
            type: .pilgrimage,
            timePeriod: .exodus,
            waypoints: [
                CLLocationCoordinate2D(latitude: 28.5393, longitude: 33.9733), // Mount Sinai
                CLLocationCoordinate2D(latitude: 29.1833, longitude: 34.1333), // Wilderness of Paran
                CLLocationCoordinate2D(latitude: 30.6167, longitude: 34.4944), // Kadesh Barnea
                CLLocationCoordinate2D(latitude: 30.1958, longitude: 35.1042), // Mount Hor
                CLLocationCoordinate2D(latitude: 30.9750, longitude: 35.7333), // Plains of Moab
                CLLocationCoordinate2D(latitude: 31.7833, longitude: 35.7333)  // Mount Nebo
            ],
            description: "Israel's 40-year journey in the wilderness",
            biblicalReferences: [
                BiblicalReference(book: "Numbers", chapter: 33, verse: 1, text: "These are the stages in the journey of the Israelites")
            ]
        ),
        
        // Joshua's Conquest
        AncientRoute(
            name: "Joshua's Central Campaign",
            type: .conquest,
            timePeriod: .conquest,
            waypoints: [
                CLLocationCoordinate2D(latitude: 31.7833, longitude: 35.7333), // Jordan crossing
                CLLocationCoordinate2D(latitude: 31.8701, longitude: 35.4436), // Jericho
                CLLocationCoordinate2D(latitude: 31.8667, longitude: 35.2667), // Ai
                CLLocationCoordinate2D(latitude: 31.8488, longitude: 35.1486), // Gibeon
                CLLocationCoordinate2D(latitude: 31.7676, longitude: 35.0238), // Makkedah
                CLLocationCoordinate2D(latitude: 31.5875, longitude: 34.9480), // Libnah
                CLLocationCoordinate2D(latitude: 31.5165, longitude: 34.8515), // Lachish
                CLLocationCoordinate2D(latitude: 31.5326, longitude: 35.0998)  // Hebron
            ],
            description: "The swift central campaign that divided Canaan",
            biblicalReferences: [
                BiblicalReference(book: "Joshua", chapter: 10, verse: 40, text: "Joshua subdued the whole region")
            ]
        ),
        
        // Return from Exile
        AncientRoute(
            name: "Return from Babylon",
            type: .pilgrimage,
            timePeriod: .exile,
            waypoints: [
                CLLocationCoordinate2D(latitude: 32.5422, longitude: 44.4209), // Babylon
                CLLocationCoordinate2D(latitude: 33.3152, longitude: 44.3661), // Baghdad area
                CLLocationCoordinate2D(latitude: 34.3000, longitude: 43.8000), // Along Euphrates
                CLLocationCoordinate2D(latitude: 35.4667, longitude: 40.1000), // Northern route
                CLLocationCoordinate2D(latitude: 36.2028, longitude: 37.1342), // Aleppo
                CLLocationCoordinate2D(latitude: 33.5138, longitude: 36.2765), // Damascus
                CLLocationCoordinate2D(latitude: 31.7683, longitude: 35.2137)  // Jerusalem
            ],
            description: "The joyful return of the Jewish exiles under Zerubbabel and Ezra",
            biblicalReferences: [
                BiblicalReference(book: "Ezra", chapter: 1, verse: 3, text: "Let him go up to Jerusalem and build the temple")
            ]
        ),
        
        // Jesus' Ministry Journey
        AncientRoute(
            name: "Jesus' Galilean Ministry",
            type: .ministry,
            timePeriod: .ministry,
            waypoints: [
                CLLocationCoordinate2D(latitude: 32.7021, longitude: 35.2978), // Nazareth
                CLLocationCoordinate2D(latitude: 32.8808, longitude: 35.5752), // Capernaum
                CLLocationCoordinate2D(latitude: 32.8147, longitude: 35.5907), // Bethsaida
                CLLocationCoordinate2D(latitude: 32.7494, longitude: 35.5977), // Sea of Galilee (walking on water)
                CLLocationCoordinate2D(latitude: 32.8780, longitude: 35.6396), // Chorazin
                CLLocationCoordinate2D(latitude: 32.7589, longitude: 35.5369), // Mount of Beatitudes
                CLLocationCoordinate2D(latitude: 32.9060, longitude: 35.3073)  // Cana
            ],
            description: "Jesus' ministry around the Sea of Galilee",
            biblicalReferences: [
                BiblicalReference(book: "Matthew", chapter: 4, verse: 23, text: "Jesus went throughout Galilee, teaching in their synagogues")
            ]
        ),
        
        // Jesus' Final Journey
        AncientRoute(
            name: "Jesus' Final Journey to Jerusalem",
            type: .pilgrimage,
            timePeriod: .ministry,
            waypoints: [
                CLLocationCoordinate2D(latitude: 32.8808, longitude: 35.5752), // Capernaum
                CLLocationCoordinate2D(latitude: 33.2481, longitude: 35.6945), // Caesarea Philippi
                CLLocationCoordinate2D(latitude: 32.6833, longitude: 35.6833), // Mount Tabor (Transfiguration)
                CLLocationCoordinate2D(latitude: 32.5833, longitude: 35.5500), // Through Samaria
                CLLocationCoordinate2D(latitude: 31.8701, longitude: 35.4436), // Jericho
                CLLocationCoordinate2D(latitude: 31.7718, longitude: 35.2560), // Bethany
                CLLocationCoordinate2D(latitude: 31.7683, longitude: 35.2137)  // Jerusalem
            ],
            description: "The final journey to Jerusalem for Passover",
            biblicalReferences: [
                BiblicalReference(book: "Luke", chapter: 9, verse: 51, text: "Jesus resolutely set out for Jerusalem")
            ]
        ),
        
        // Paul's Second Journey
        AncientRoute(
            name: "Paul's Second Missionary Journey",
            type: .missionary,
            timePeriod: .earlyChurch,
            waypoints: [
                CLLocationCoordinate2D(latitude: 36.2028, longitude: 36.1607), // Antioch
                CLLocationCoordinate2D(latitude: 37.0066, longitude: 37.3823), // Through Syria
                CLLocationCoordinate2D(latitude: 37.5763, longitude: 32.8072), // Lystra
                CLLocationCoordinate2D(latitude: 40.1885, longitude: 29.0610), // Troas
                CLLocationCoordinate2D(latitude: 40.6403, longitude: 22.9353), // Philippi
                CLLocationCoordinate2D(latitude: 40.6323, longitude: 22.4682), // Thessalonica
                CLLocationCoordinate2D(latitude: 40.5168, longitude: 22.2025), // Berea
                CLLocationCoordinate2D(latitude: 37.9838, longitude: 23.7275), // Athens
                CLLocationCoordinate2D(latitude: 37.9060, longitude: 22.8806), // Corinth
                CLLocationCoordinate2D(latitude: 37.9493, longitude: 27.3682), // Ephesus
                CLLocationCoordinate2D(latitude: 31.7683, longitude: 35.2137)  // Jerusalem
            ],
            description: "Paul's journey bringing the Gospel to Europe",
            biblicalReferences: [
                BiblicalReference(book: "Acts", chapter: 16, verse: 9, text: "Come over to Macedonia and help us")
            ]
        ),
        
        // Paul's Third Journey
        AncientRoute(
            name: "Paul's Third Missionary Journey",
            type: .missionary,
            timePeriod: .earlyChurch,
            waypoints: [
                CLLocationCoordinate2D(latitude: 36.2028, longitude: 36.1607), // Antioch
                CLLocationCoordinate2D(latitude: 39.9208, longitude: 32.8541), // Galatia
                CLLocationCoordinate2D(latitude: 38.4237, longitude: 38.1358), // Phrygia
                CLLocationCoordinate2D(latitude: 37.9493, longitude: 27.3682), // Ephesus (3 years)
                CLLocationCoordinate2D(latitude: 40.6403, longitude: 22.9353), // Macedonia
                CLLocationCoordinate2D(latitude: 37.9060, longitude: 22.8806), // Greece
                CLLocationCoordinate2D(latitude: 40.1885, longitude: 29.0610), // Troas
                CLLocationCoordinate2D(latitude: 39.1063, longitude: 26.5567), // Assos
                CLLocationCoordinate2D(latitude: 38.4309, longitude: 27.1388), // Miletus
                CLLocationCoordinate2D(latitude: 32.5014, longitude: 34.8925), // Caesarea
                CLLocationCoordinate2D(latitude: 31.7683, longitude: 35.2137)  // Jerusalem
            ],
            description: "Paul's extended ministry in Ephesus and final journey to Jerusalem",
            biblicalReferences: [
                BiblicalReference(book: "Acts", chapter: 20, verse: 22, text: "I am going to Jerusalem, not knowing what will happen")
            ]
        ),
        
        // Paul's Journey to Rome
        AncientRoute(
            name: "Paul's Journey to Rome",
            type: .missionary,
            timePeriod: .earlyChurch,
            waypoints: [
                CLLocationCoordinate2D(latitude: 31.7683, longitude: 35.2137), // Jerusalem
                CLLocationCoordinate2D(latitude: 32.5014, longitude: 34.8925), // Caesarea
                CLLocationCoordinate2D(latitude: 33.8938, longitude: 35.5018), // Sidon
                CLLocationCoordinate2D(latitude: 35.1264, longitude: 33.4299), // Cyprus
                CLLocationCoordinate2D(latitude: 36.0319, longitude: 28.9893), // Myra
                CLLocationCoordinate2D(latitude: 35.3387, longitude: 25.1442), // Crete
                CLLocationCoordinate2D(latitude: 35.8978, longitude: 14.5372), // Malta (shipwreck)
                CLLocationCoordinate2D(latitude: 37.0682, longitude: 15.2853), // Syracuse
                CLLocationCoordinate2D(latitude: 40.8518, longitude: 14.2681), // Puteoli
                CLLocationCoordinate2D(latitude: 41.9028, longitude: 12.4964)  // Rome
            ],
            description: "Paul's perilous journey as a prisoner to appeal to Caesar",
            biblicalReferences: [
                BiblicalReference(book: "Acts", chapter: 27, verse: 1, text: "It was decided that we would sail for Italy")
            ]
        )
    ]
}