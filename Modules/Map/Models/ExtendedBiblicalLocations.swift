import Foundation
import CoreLocation

extension BiblicalMapData {
    static let extendedLocations: [BiblicalLocation] = [
        // Mesopotamian Cities
        BiblicalLocation(
            name: "Ur",
            ancientName: "Ur of the Chaldees",
            modernName: "Tell el-Muqayyar",
            coordinate: CLLocationCoordinate2D(latitude: 30.9625, longitude: 46.1031),
            timePeriods: [.patriarchal],
            biblicalReferences: [
                BiblicalReference(book: "Genesis", chapter: 11, verse: 28, text: "Birthplace of Abraham"),
                BiblicalReference(book: "Genesis", chapter: 15, verse: 7, text: "I brought you out of Ur")
            ],
            description: "Ancient Sumerian city, birthplace of Abraham",
            significance: "Where God called Abraham to leave for the Promised Land",
            imageNames: ["ur_ancient"]
        ),
        
        BiblicalLocation(
            name: "Haran",
            ancientName: nil,
            modernName: "Harran",
            coordinate: CLLocationCoordinate2D(latitude: 36.8641, longitude: 39.0254),
            timePeriods: [.patriarchal],
            biblicalReferences: [
                BiblicalReference(book: "Genesis", chapter: 11, verse: 31, text: "They went as far as Haran"),
                BiblicalReference(book: "Genesis", chapter: 12, verse: 4, text: "Abraham left Haran")
            ],
            description: "Major trading center where Abraham's family settled",
            significance: "Abraham's departure point to Canaan",
            imageNames: ["haran_ancient"]
        ),
        
        BiblicalLocation(
            name: "Babylon",
            ancientName: "Babel",
            modernName: "Hillah",
            coordinate: CLLocationCoordinate2D(latitude: 32.5422, longitude: 44.4209),
            timePeriods: [.patriarchal, .dividedKingdom, .exile],
            biblicalReferences: [
                BiblicalReference(book: "Genesis", chapter: 11, verse: 9, text: "Tower of Babel"),
                BiblicalReference(book: "2 Kings", chapter: 25, verse: 1, text: "Nebuchadnezzar besieged Jerusalem"),
                BiblicalReference(book: "Daniel", chapter: 1, verse: 1, text: "Daniel taken to Babylon")
            ],
            description: "Capital of the Babylonian Empire",
            significance: "Site of Jewish exile, Daniel's visions",
            imageNames: ["babylon_ancient"]
        ),
        
        BiblicalLocation(
            name: "Nineveh",
            ancientName: nil,
            modernName: "Mosul",
            coordinate: CLLocationCoordinate2D(latitude: 36.3566, longitude: 43.1640),
            timePeriods: [.dividedKingdom],
            biblicalReferences: [
                BiblicalReference(book: "Jonah", chapter: 1, verse: 2, text: "Go to the great city of Nineveh"),
                BiblicalReference(book: "Nahum", chapter: 1, verse: 1, text: "An oracle concerning Nineveh")
            ],
            description: "Capital of the Assyrian Empire",
            significance: "City where Jonah preached, repented at his message",
            imageNames: ["nineveh_ancient"]
        ),
        
        // Egyptian Cities
        BiblicalLocation(
            name: "Memphis",
            ancientName: "Noph",
            modernName: "Mit Rahina",
            coordinate: CLLocationCoordinate2D(latitude: 29.8441, longitude: 31.2508),
            timePeriods: [.patriarchal, .exodus],
            biblicalReferences: [
                BiblicalReference(book: "Isaiah", chapter: 19, verse: 13, text: "The leaders of Memphis are deceived"),
                BiblicalReference(book: "Jeremiah", chapter: 46, verse: 19, text: "Memphis will be laid waste")
            ],
            description: "Ancient capital of Lower Egypt",
            significance: "Major Egyptian city during the time of Joseph and Moses",
            imageNames: ["memphis_ancient"]
        ),
        
        BiblicalLocation(
            name: "On",
            ancientName: "Heliopolis",
            modernName: "Ain Shams",
            coordinate: CLLocationCoordinate2D(latitude: 30.1288, longitude: 31.3389),
            timePeriods: [.patriarchal],
            biblicalReferences: [
                BiblicalReference(book: "Genesis", chapter: 41, verse: 45, text: "Daughter of Potiphera, priest of On")
            ],
            description: "Center of sun worship in ancient Egypt",
            significance: "Joseph's father-in-law was priest here",
            imageNames: ["on_ancient"]
        ),
        
        // Wilderness Locations
        BiblicalLocation(
            name: "Mount Sinai",
            ancientName: "Horeb",
            modernName: "Jebel Musa",
            coordinate: CLLocationCoordinate2D(latitude: 28.5393, longitude: 33.9733),
            timePeriods: [.exodus],
            biblicalReferences: [
                BiblicalReference(book: "Exodus", chapter: 19, verse: 20, text: "The Lord descended on Mount Sinai"),
                BiblicalReference(book: "1 Kings", chapter: 19, verse: 8, text: "Elijah traveled to Horeb")
            ],
            description: "Mountain where Moses received the Ten Commandments",
            significance: "Site of the covenant between God and Israel",
            imageNames: ["sinai_ancient"]
        ),
        
        BiblicalLocation(
            name: "Kadesh Barnea",
            ancientName: nil,
            modernName: "Ain el-Qudeirat",
            coordinate: CLLocationCoordinate2D(latitude: 30.6167, longitude: 34.4944),
            timePeriods: [.exodus],
            biblicalReferences: [
                BiblicalReference(book: "Numbers", chapter: 13, verse: 26, text: "They came back to Kadesh"),
                BiblicalReference(book: "Deuteronomy", chapter: 1, verse: 46, text: "You stayed in Kadesh many days")
            ],
            description: "Major campsite during the wilderness wandering",
            significance: "Where Israel refused to enter the Promised Land",
            imageNames: ["kadesh_ancient"]
        ),
        
        // Canaanite Cities
        BiblicalLocation(
            name: "Hebron",
            ancientName: "Kiriath Arba",
            modernName: "Al-Khalil",
            coordinate: CLLocationCoordinate2D(latitude: 31.5326, longitude: 35.0998),
            timePeriods: [.patriarchal, .conquest, .unitedKingdom],
            biblicalReferences: [
                BiblicalReference(book: "Genesis", chapter: 23, verse: 2, text: "Sarah died in Hebron"),
                BiblicalReference(book: "2 Samuel", chapter: 2, verse: 1, text: "David was anointed king in Hebron")
            ],
            description: "Ancient city of the patriarchs",
            significance: "Burial place of Abraham, Sarah, Isaac, Rebecca, Jacob, and Leah",
            imageNames: ["hebron_ancient"]
        ),
        
        BiblicalLocation(
            name: "Beersheba",
            ancientName: nil,
            modernName: "Be'er Sheva",
            coordinate: CLLocationCoordinate2D(latitude: 31.2518, longitude: 34.7913),
            timePeriods: [.patriarchal, .judges, .unitedKingdom],
            biblicalReferences: [
                BiblicalReference(book: "Genesis", chapter: 21, verse: 31, text: "Abraham made a treaty at Beersheba"),
                BiblicalReference(book: "1 Samuel", chapter: 8, verse: 2, text: "Samuel's sons were judges in Beersheba")
            ],
            description: "Southern boundary of ancient Israel",
            significance: "From Dan to Beersheba - the extent of Israel",
            imageNames: ["beersheba_ancient"]
        ),
        
        BiblicalLocation(
            name: "Shechem",
            ancientName: nil,
            modernName: "Nablus",
            coordinate: CLLocationCoordinate2D(latitude: 32.2154, longitude: 35.2743),
            timePeriods: [.patriarchal, .conquest, .judges],
            biblicalReferences: [
                BiblicalReference(book: "Genesis", chapter: 12, verse: 6, text: "Abraham built an altar at Shechem"),
                BiblicalReference(book: "Joshua", chapter: 24, verse: 1, text: "Joshua gathered all the tribes at Shechem")
            ],
            description: "First capital of the Northern Kingdom",
            significance: "Site of covenant renewal under Joshua",
            imageNames: ["shechem_ancient"]
        ),
        
        BiblicalLocation(
            name: "Shiloh",
            ancientName: nil,
            modernName: "Khirbet Seilun",
            coordinate: CLLocationCoordinate2D(latitude: 32.0556, longitude: 35.2892),
            timePeriods: [.conquest, .judges],
            biblicalReferences: [
                BiblicalReference(book: "Joshua", chapter: 18, verse: 1, text: "The Tent of Meeting was set up at Shiloh"),
                BiblicalReference(book: "1 Samuel", chapter: 1, verse: 3, text: "Elkanah went to Shiloh to worship")
            ],
            description: "Religious center before Jerusalem",
            significance: "Location of the Tabernacle for 369 years",
            imageNames: ["shiloh_ancient"]
        ),
        
        // Philistine Cities
        BiblicalLocation(
            name: "Gaza",
            ancientName: nil,
            modernName: "Gaza City",
            coordinate: CLLocationCoordinate2D(latitude: 31.5018, longitude: 34.4668),
            timePeriods: [.judges, .unitedKingdom],
            biblicalReferences: [
                BiblicalReference(book: "Judges", chapter: 16, verse: 21, text: "Samson ground grain in Gaza"),
                BiblicalReference(book: "Acts", chapter: 8, verse: 26, text: "Road that goes down from Jerusalem to Gaza")
            ],
            description: "Major Philistine city",
            significance: "Where Samson died destroying the temple",
            imageNames: ["gaza_ancient"]
        ),
        
        BiblicalLocation(
            name: "Ashkelon",
            ancientName: nil,
            modernName: "Ashkelon",
            coordinate: CLLocationCoordinate2D(latitude: 31.6658, longitude: 34.5715),
            timePeriods: [.judges, .unitedKingdom],
            biblicalReferences: [
                BiblicalReference(book: "Judges", chapter: 1, verse: 18, text: "Judah took Gaza, Ashkelon and Ekron"),
                BiblicalReference(book: "2 Samuel", chapter: 1, verse: 20, text: "Tell it not in Gath, proclaim it not in Ashkelon")
            ],
            description: "Coastal Philistine city",
            significance: "Major seaport and Philistine stronghold",
            imageNames: ["ashkelon_ancient"]
        ),
        
        // Northern Kingdom Cities
        BiblicalLocation(
            name: "Samaria",
            ancientName: nil,
            modernName: "Sebastia",
            coordinate: CLLocationCoordinate2D(latitude: 32.2808, longitude: 35.1952),
            timePeriods: [.dividedKingdom, .ministry],
            biblicalReferences: [
                BiblicalReference(book: "1 Kings", chapter: 16, verse: 24, text: "Omri built Samaria"),
                BiblicalReference(book: "John", chapter: 4, verse: 5, text: "Jesus came to a town in Samaria")
            ],
            description: "Capital of the Northern Kingdom",
            significance: "Where Jesus met the woman at the well",
            imageNames: ["samaria_ancient"]
        ),
        
        BiblicalLocation(
            name: "Dan",
            ancientName: "Laish",
            modernName: "Tel Dan",
            coordinate: CLLocationCoordinate2D(latitude: 33.2494, longitude: 35.6525),
            timePeriods: [.judges, .unitedKingdom, .dividedKingdom],
            biblicalReferences: [
                BiblicalReference(book: "Judges", chapter: 18, verse: 29, text: "They named it Dan"),
                BiblicalReference(book: "1 Kings", chapter: 12, verse: 29, text: "Jeroboam set up a golden calf in Dan")
            ],
            description: "Northernmost city of Israel",
            significance: "Northern boundary of Israel, site of idolatry",
            imageNames: ["dan_ancient"]
        ),
        
        // New Testament Cities
        BiblicalLocation(
            name: "Bethany",
            ancientName: nil,
            modernName: "Al-Eizariya",
            coordinate: CLLocationCoordinate2D(latitude: 31.7718, longitude: 35.2560),
            timePeriods: [.ministry],
            biblicalReferences: [
                BiblicalReference(book: "John", chapter: 11, verse: 1, text: "Lazarus of Bethany"),
                BiblicalReference(book: "Matthew", chapter: 26, verse: 6, text: "Jesus was in Bethany")
            ],
            description: "Village near Jerusalem",
            significance: "Home of Mary, Martha, and Lazarus",
            imageNames: ["bethany_ancient"]
        ),
        
        BiblicalLocation(
            name: "Caesarea Philippi",
            ancientName: "Paneas",
            modernName: "Banias",
            coordinate: CLLocationCoordinate2D(latitude: 33.2481, longitude: 35.6945),
            timePeriods: [.ministry],
            biblicalReferences: [
                BiblicalReference(book: "Matthew", chapter: 16, verse: 13, text: "Jesus went to Caesarea Philippi"),
                BiblicalReference(book: "Matthew", chapter: 16, verse: 16, text: "You are the Messiah, the Son of the living God")
            ],
            description: "Northern city at the base of Mount Hermon",
            significance: "Where Peter declared Jesus as the Messiah",
            imageNames: ["caesarea_philippi_ancient"]
        ),
        
        BiblicalLocation(
            name: "Caesarea Maritima",
            ancientName: nil,
            modernName: "Caesarea",
            coordinate: CLLocationCoordinate2D(latitude: 32.5014, longitude: 34.8925),
            timePeriods: [.ministry, .earlyChurch],
            biblicalReferences: [
                BiblicalReference(book: "Acts", chapter: 10, verse: 1, text: "Cornelius lived in Caesarea"),
                BiblicalReference(book: "Acts", chapter: 23, verse: 23, text: "Paul was taken to Caesarea")
            ],
            description: "Roman administrative center",
            significance: "Where Peter baptized the first Gentile convert",
            imageNames: ["caesarea_maritima_ancient"]
        ),
        
        // Paul's Journey Cities
        BiblicalLocation(
            name: "Tarsus",
            ancientName: nil,
            modernName: "Tarsus",
            coordinate: CLLocationCoordinate2D(latitude: 36.9177, longitude: 34.8789),
            timePeriods: [.earlyChurch],
            biblicalReferences: [
                BiblicalReference(book: "Acts", chapter: 9, verse: 11, text: "Saul of Tarsus"),
                BiblicalReference(book: "Acts", chapter: 21, verse: 39, text: "I am a Jew, from Tarsus")
            ],
            description: "Major city in Cilicia",
            significance: "Birthplace of Paul the Apostle",
            imageNames: ["tarsus_ancient"]
        ),
        
        BiblicalLocation(
            name: "Ephesus",
            ancientName: nil,
            modernName: "Selçuk",
            coordinate: CLLocationCoordinate2D(latitude: 37.9493, longitude: 27.3682),
            timePeriods: [.earlyChurch],
            biblicalReferences: [
                BiblicalReference(book: "Acts", chapter: 19, verse: 1, text: "Paul arrived at Ephesus"),
                BiblicalReference(book: "Revelation", chapter: 2, verse: 1, text: "To the church in Ephesus")
            ],
            description: "Major port city in Asia Minor",
            significance: "Where Paul spent three years, one of the seven churches",
            imageNames: ["ephesus_ancient"]
        ),
        
        BiblicalLocation(
            name: "Corinth",
            ancientName: nil,
            modernName: "Corinth",
            coordinate: CLLocationCoordinate2D(latitude: 37.9060, longitude: 22.8806),
            timePeriods: [.earlyChurch],
            biblicalReferences: [
                BiblicalReference(book: "Acts", chapter: 18, verse: 1, text: "Paul went to Corinth"),
                BiblicalReference(book: "1 Corinthians", chapter: 1, verse: 2, text: "To the church of God in Corinth")
            ],
            description: "Major Greek commercial center",
            significance: "Where Paul spent 18 months establishing the church",
            imageNames: ["corinth_ancient"]
        ),
        
        BiblicalLocation(
            name: "Athens",
            ancientName: nil,
            modernName: "Athens",
            coordinate: CLLocationCoordinate2D(latitude: 37.9838, longitude: 23.7275),
            timePeriods: [.earlyChurch],
            biblicalReferences: [
                BiblicalReference(book: "Acts", chapter: 17, verse: 16, text: "Paul was waiting in Athens"),
                BiblicalReference(book: "Acts", chapter: 17, verse: 22, text: "Paul stood on Mars Hill")
            ],
            description: "Center of Greek philosophy and learning",
            significance: "Where Paul preached to the philosophers",
            imageNames: ["athens_ancient"]
        ),
        
        BiblicalLocation(
            name: "Rome",
            ancientName: nil,
            modernName: "Rome",
            coordinate: CLLocationCoordinate2D(latitude: 41.9028, longitude: 12.4964),
            timePeriods: [.earlyChurch],
            biblicalReferences: [
                BiblicalReference(book: "Acts", chapter: 28, verse: 14, text: "And so we came to Rome"),
                BiblicalReference(book: "Romans", chapter: 1, verse: 7, text: "To all in Rome who are loved by God")
            ],
            description: "Capital of the Roman Empire",
            significance: "Where Paul was imprisoned and martyred",
            imageNames: ["rome_ancient"]
        )
    ]
}