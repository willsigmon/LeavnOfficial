import Foundation
import LeavnCore
import LeavnServices

public struct SearchBibleUseCase: UseCase {
    public typealias Input = SearchBibleInput
    public typealias Output = [BibleSearchResult]
    
    private let bibleService: BibleService
    
    public init(bibleService: BibleService) {
        self.bibleService = bibleService
    }
    
    public func execute(_ input: SearchBibleInput) async throws -> [BibleSearchResult] {
        guard !input.query.isEmpty else {
            throw LeavnError.validationError(message: "Search query cannot be empty")
        }
        
        return try await bibleService.search(
            query: input.query,
            translation: input.translation
        )
    }
}

public struct SearchBibleInput {
    public let query: String
    public let translation: String?
    
    public init(query: String, translation: String? = nil) {
        self.query = query
        self.translation = translation
    }
}