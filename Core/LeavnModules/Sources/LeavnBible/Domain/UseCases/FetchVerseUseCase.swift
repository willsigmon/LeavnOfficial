import Foundation

public struct FetchVerseUseCase: UseCase {
    public typealias Input = String // Bible reference
    public typealias Output = BibleVerse
    
    private let bibleService: BibleService
    
    public init(bibleService: BibleService) {
        self.bibleService = bibleService
    }
    
    public func execute(_ input: String) async throws -> BibleVerse {
        guard input.isValidBibleReference else {
            throw LeavnError.validationError(message: "Invalid Bible reference format")
        }
        
        return try await bibleService.fetchVerse(reference: input)
    }
}