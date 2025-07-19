import Foundation
import Tagged

// MARK: - Type-Safe IDs
public typealias ChapterID = Tagged<(Book, chapter: ()), Int>
public typealias VerseID = Tagged<(Book, verse: ()), Int>

// MARK: - Bible Reference Models
public struct BibleReference: Equatable, Codable, Sendable {
    public let book: Book
    public let chapter: ChapterID
    public let verse: VerseID?
    
    public init(book: Book, chapter: Int, verse: Int? = nil) {
        self.book = book
        self.chapter = ChapterID(rawValue: chapter)
        self.verse = verse.map { VerseID(rawValue: $0) }
    }
    
    public var displayText: String {
        if let verse {
            return "\(book.name) \(chapter.rawValue):\(verse.rawValue)"
        } else {
            return "\(book.name) \(chapter.rawValue)"
        }
    }
    
    public var shortDisplayText: String {
        if let verse {
            return "\(book.abbreviation) \(chapter.rawValue):\(verse.rawValue)"
        } else {
            return "\(book.abbreviation) \(chapter.rawValue)"
        }
    }
}

public struct Verse: Equatable, Codable, Sendable, Identifiable {
    public let id: UUID
    public let reference: BibleReference
    public let text: String
    public let number: Int
    
    public init(id: UUID = UUID(), reference: BibleReference, text: String, number: Int) {
        self.id = id
        self.reference = reference
        self.text = text
        self.number = number
    }
}

public struct Chapter: Equatable, Codable, Sendable {
    public let book: Book
    public let number: ChapterID
    public let verses: [Verse]
    public let headings: [ChapterHeading]
    
    public init(book: Book, number: Int, verses: [Verse], headings: [ChapterHeading] = []) {
        self.book = book
        self.number = ChapterID(rawValue: number)
        self.verses = verses
        self.headings = headings
    }
}

public struct ChapterHeading: Equatable, Codable, Sendable {
    public let text: String
    public let startVerse: Int
    
    public init(text: String, startVerse: Int) {
        self.text = text
        self.startVerse = startVerse
    }
}

public enum Book: String, CaseIterable, Codable, Identifiable, Equatable, Sendable {
    // Old Testament
    case genesis = "Genesis"
    case exodus = "Exodus"
    case leviticus = "Leviticus"
    case numbers = "Numbers"
    case deuteronomy = "Deuteronomy"
    case joshua = "Joshua"
    case judges = "Judges"
    case ruth = "Ruth"
    case firstSamuel = "1 Samuel"
    case secondSamuel = "2 Samuel"
    case firstKings = "1 Kings"
    case secondKings = "2 Kings"
    case firstChronicles = "1 Chronicles"
    case secondChronicles = "2 Chronicles"
    case ezra = "Ezra"
    case nehemiah = "Nehemiah"
    case esther = "Esther"
    case job = "Job"
    case psalms = "Psalms"
    case proverbs = "Proverbs"
    case ecclesiastes = "Ecclesiastes"
    case songOfSolomon = "Song of Solomon"
    case isaiah = "Isaiah"
    case jeremiah = "Jeremiah"
    case lamentations = "Lamentations"
    case ezekiel = "Ezekiel"
    case daniel = "Daniel"
    case hosea = "Hosea"
    case joel = "Joel"
    case amos = "Amos"
    case obadiah = "Obadiah"
    case jonah = "Jonah"
    case micah = "Micah"
    case nahum = "Nahum"
    case habakkuk = "Habakkuk"
    case zephaniah = "Zephaniah"
    case haggai = "Haggai"
    case zechariah = "Zechariah"
    case malachi = "Malachi"
    
    // New Testament
    case matthew = "Matthew"
    case mark = "Mark"
    case luke = "Luke"
    case john = "John"
    case acts = "Acts"
    case romans = "Romans"
    case firstCorinthians = "1 Corinthians"
    case secondCorinthians = "2 Corinthians"
    case galatians = "Galatians"
    case ephesians = "Ephesians"
    case philippians = "Philippians"
    case colossians = "Colossians"
    case firstThessalonians = "1 Thessalonians"
    case secondThessalonians = "2 Thessalonians"
    case firstTimothy = "1 Timothy"
    case secondTimothy = "2 Timothy"
    case titus = "Titus"
    case philemon = "Philemon"
    case hebrews = "Hebrews"
    case james = "James"
    case firstPeter = "1 Peter"
    case secondPeter = "2 Peter"
    case firstJohn = "1 John"
    case secondJohn = "2 John"
    case thirdJohn = "3 John"
    case jude = "Jude"
    case revelation = "Revelation"
    
    public var id: String { rawValue }
    
    public var name: String { rawValue }
    
    public var abbreviation: String {
        switch self {
        case .genesis: return "Gen"
        case .exodus: return "Exod"
        case .leviticus: return "Lev"
        case .numbers: return "Num"
        case .deuteronomy: return "Deut"
        case .joshua: return "Josh"
        case .judges: return "Judg"
        case .ruth: return "Ruth"
        case .firstSamuel: return "1Sam"
        case .secondSamuel: return "2Sam"
        case .firstKings: return "1Kgs"
        case .secondKings: return "2Kgs"
        case .firstChronicles: return "1Chr"
        case .secondChronicles: return "2Chr"
        case .ezra: return "Ezra"
        case .nehemiah: return "Neh"
        case .esther: return "Esth"
        case .job: return "Job"
        case .psalms: return "Ps"
        case .proverbs: return "Prov"
        case .ecclesiastes: return "Eccl"
        case .songOfSolomon: return "Song"
        case .isaiah: return "Isa"
        case .jeremiah: return "Jer"
        case .lamentations: return "Lam"
        case .ezekiel: return "Ezek"
        case .daniel: return "Dan"
        case .hosea: return "Hos"
        case .joel: return "Joel"
        case .amos: return "Amos"
        case .obadiah: return "Obad"
        case .jonah: return "Jonah"
        case .micah: return "Mic"
        case .nahum: return "Nah"
        case .habakkuk: return "Hab"
        case .zephaniah: return "Zeph"
        case .haggai: return "Hag"
        case .zechariah: return "Zech"
        case .malachi: return "Mal"
        case .matthew: return "Matt"
        case .mark: return "Mark"
        case .luke: return "Luke"
        case .john: return "John"
        case .acts: return "Acts"
        case .romans: return "Rom"
        case .firstCorinthians: return "1Cor"
        case .secondCorinthians: return "2Cor"
        case .galatians: return "Gal"
        case .ephesians: return "Eph"
        case .philippians: return "Phil"
        case .colossians: return "Col"
        case .firstThessalonians: return "1Thess"
        case .secondThessalonians: return "2Thess"
        case .firstTimothy: return "1Tim"
        case .secondTimothy: return "2Tim"
        case .titus: return "Titus"
        case .philemon: return "Phlm"
        case .hebrews: return "Heb"
        case .james: return "Jas"
        case .firstPeter: return "1Pet"
        case .secondPeter: return "2Pet"
        case .firstJohn: return "1John"
        case .secondJohn: return "2John"
        case .thirdJohn: return "3John"
        case .jude: return "Jude"
        case .revelation: return "Rev"
        }
    }
    
    public var chapterCount: Int {
        switch self {
        case .genesis: return 50
        case .exodus: return 40
        case .leviticus: return 27
        case .numbers: return 36
        case .deuteronomy: return 34
        case .joshua: return 24
        case .judges: return 21
        case .ruth: return 4
        case .firstSamuel: return 31
        case .secondSamuel: return 24
        case .firstKings: return 22
        case .secondKings: return 25
        case .firstChronicles: return 29
        case .secondChronicles: return 36
        case .ezra: return 10
        case .nehemiah: return 13
        case .esther: return 10
        case .job: return 42
        case .psalms: return 150
        case .proverbs: return 31
        case .ecclesiastes: return 12
        case .songOfSolomon: return 8
        case .isaiah: return 66
        case .jeremiah: return 52
        case .lamentations: return 5
        case .ezekiel: return 48
        case .daniel: return 12
        case .hosea: return 14
        case .joel: return 3
        case .amos: return 9
        case .obadiah: return 1
        case .jonah: return 4
        case .micah: return 7
        case .nahum: return 3
        case .habakkuk: return 3
        case .zephaniah: return 3
        case .haggai: return 2
        case .zechariah: return 14
        case .malachi: return 4
        case .matthew: return 28
        case .mark: return 16
        case .luke: return 24
        case .john: return 21
        case .acts: return 28
        case .romans: return 16
        case .firstCorinthians: return 16
        case .secondCorinthians: return 13
        case .galatians: return 6
        case .ephesians: return 6
        case .philippians: return 4
        case .colossians: return 4
        case .firstThessalonians: return 5
        case .secondThessalonians: return 3
        case .firstTimothy: return 6
        case .secondTimothy: return 4
        case .titus: return 3
        case .philemon: return 1
        case .hebrews: return 13
        case .james: return 5
        case .firstPeter: return 5
        case .secondPeter: return 3
        case .firstJohn: return 5
        case .secondJohn: return 1
        case .thirdJohn: return 1
        case .jude: return 1
        case .revelation: return 22
        }
    }
    
    public var next: Book? {
        let allBooks = Book.allCases
        guard let currentIndex = allBooks.firstIndex(of: self),
              currentIndex < allBooks.count - 1 else { return nil }
        return allBooks[currentIndex + 1]
    }
    
    public var previous: Book? {
        let allBooks = Book.allCases
        guard let currentIndex = allBooks.firstIndex(of: self),
              currentIndex > 0 else { return nil }
        return allBooks[currentIndex - 1]
    }
    
    public var isOldTestament: Bool {
        guard let selfIndex = Book.allCases.firstIndex(of: self),
              let matthewIndex = Book.allCases.firstIndex(of: .matthew) else {
            return false
        }
        return selfIndex < matthewIndex
    }
    
    public var isNewTestament: Bool {
        !isOldTestament
    }
}