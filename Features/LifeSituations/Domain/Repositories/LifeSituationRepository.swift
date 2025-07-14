import Foundation

public protocol LifeSituationRepository: Repository {
    func getLifeSituations() async throws -> [LifeSituation]
    func getLifeSituation(by id: String) async throws -> LifeSituation?
    func searchLifeSituations(query: String) async throws -> [LifeSituation]
    func getRecentlyViewed() async throws -> [LifeSituation]
    func markAsViewed(_ situation: LifeSituation) async throws
    func getFavorites() async throws -> [LifeSituation]
    func toggleFavorite(_ situation: LifeSituation) async throws
}