import Foundation

public protocol CompareTranslationsUseCaseProtocol {
    func execute(bookId: String, chapter: Int, verse: Int, translations: [BibleTranslation]) async throws -> [BibleVerse]
}

public struct CompareTranslationsUseCase: CompareTranslationsUseCaseProtocol {
    private let repository: BibleRepositoryProtocol
    
    public init(repository: BibleRepositoryProtocol) {
        self.repository = repository
    }
    
    public func execute(bookId: String, chapter: Int, verse: Int, translations: [BibleTranslation]) async throws -> [BibleVerse] {
        // Fetch verses in all requested translations
        let verses = try await repository.fetchVersesInTranslations(
            bookId: bookId,
            chapter: chapter,
            verse: verse,
            translations: translations
        )
        
        // Sort by translation order
        return verses.sorted { first, second in
            guard let firstIndex = translations.firstIndex(where: { $0.rawValue == first.translation }),
                  let secondIndex = translations.firstIndex(where: { $0.rawValue == second.translation }) else {
                return false
            }
            return firstIndex < secondIndex
        }
    }
}