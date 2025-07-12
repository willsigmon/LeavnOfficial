import Foundation

// MARK: - Repository Protocols

public protocol LibraryRepositoryProtocol {
    func fetchAllItems() async throws -> [LibraryItem]
    func fetchItems(ofType type: LibraryItemType) async throws -> [LibraryItem]
    func fetchItem(withId id: UUID) async throws -> LibraryItem?
    func saveItem(_ item: LibraryItem) async throws
    func updateItem(_ item: LibraryItem) async throws
    func deleteItem(withId id: UUID) async throws
    func searchItems(query: String) async throws -> [LibraryItem]
    func fetchItemsByTag(_ tag: String) async throws -> [LibraryItem]
}

// MARK: - Use Case Protocols

public protocol GetLibraryItemsUseCaseProtocol {
    func execute() async throws -> [LibraryItem]
    func execute(ofType type: LibraryItemType) async throws -> [LibraryItem]
}

public protocol SaveLibraryItemUseCaseProtocol {
    func execute(item: LibraryItem) async throws
}

// MARK: - Data Source Protocols

public protocol LibraryRemoteDataSourceProtocol {
    func fetchAllItems() async throws -> [LibraryItem]
    func fetchItems(ofType type: LibraryItemType) async throws -> [LibraryItem]
    func fetchItem(withId id: UUID) async throws -> LibraryItem?
    func saveItem(_ item: LibraryItem) async throws
    func updateItem(_ item: LibraryItem) async throws
    func deleteItem(withId id: UUID) async throws
    func searchItems(query: String) async throws -> [LibraryItem]
    func fetchItemsByTag(_ tag: String) async throws -> [LibraryItem]
}

public protocol LibraryLocalDataSourceProtocol {
    func fetchAllItems() async throws -> [LibraryItem]
    func fetchItems(ofType type: LibraryItemType) async throws -> [LibraryItem]
    func fetchItem(withId id: UUID) async throws -> LibraryItem?
    func saveItem(_ item: LibraryItem) async throws
    func updateItem(_ item: LibraryItem) async throws
    func deleteItem(withId id: UUID) async throws
    func searchItems(query: String) async throws -> [LibraryItem]
    func fetchItemsByTag(_ tag: String) async throws -> [LibraryItem]
}

// MARK: - Models (if not already in LeavnCore)

public enum LibraryItemType: String, Codable, CaseIterable {
    case bookmark = "bookmark"
    case note = "note"
    case highlight = "highlight"
    case readingPlan = "readingPlan"
    case devotion = "devotion"
    case prayerRequest = "prayerRequest"
}

public struct LibraryItem: Identifiable, Codable, Equatable {
    public let id: UUID
    public let type: LibraryItemType
    public let title: String
    public let content: String?
    public let verse: LibraryVerse?
    public let createdAt: Date
    public let updatedAt: Date
    public let tags: [String]
    public let color: String?
    
    public init(
        id: UUID = UUID(),
        type: LibraryItemType,
        title: String,
        content: String? = nil,
        verse: LibraryVerse? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        tags: [String] = [],
        color: String? = nil
    ) {
        self.id = id
        self.type = type
        self.title = title
        self.content = content
        self.verse = verse
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.tags = tags
        self.color = color
    }
}

public struct LibraryVerse: Codable, Equatable {
    public let bookId: String
    public let bookName: String
    public let chapter: Int
    public let verse: Int
    public let text: String
    public let translation: String
    
    public init(
        bookId: String,
        bookName: String,
        chapter: Int,
        verse: Int,
        text: String,
        translation: String
    ) {
        self.bookId = bookId
        self.bookName = bookName
        self.chapter = chapter
        self.verse = verse
        self.text = text
        self.translation = translation
    }
    
    public var reference: String {
        "\(bookName) \(chapter):\(verse)"
    }
}