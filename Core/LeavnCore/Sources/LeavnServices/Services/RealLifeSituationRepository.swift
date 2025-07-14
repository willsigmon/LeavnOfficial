import Foundation
import CoreData

// MARK: - Real Life Situation Repository
public final class RealLifeSituationRepository: LifeSituationRepositoryProtocol {
    private let networkService: NetworkServiceProtocol
    private let bibleService: BibleServiceProtocol
    private let context: NSManagedObjectContext
    private let dataProvider = LifeSituationsDataProvider.shared
    
    // Track viewed and favorite situations
    private var viewedSituations: Set<String> = []
    private var favoriteSituations: Set<String> = []
    
    public init(
        networkService: NetworkServiceProtocol,
        bibleService: BibleServiceProtocol,
        context: NSManagedObjectContext
    ) {
        self.networkService = networkService
        self.bibleService = bibleService
        self.context = context
        
        // Load user preferences
        Task {
            await loadUserPreferences()
        }
    }
    
    public func getSituations() async throws -> [LifeSituation] {
        // First, try to get updated situations from the network
        do {
            let endpoint = Endpoint(path: "/api/life-situations", method: .get)
            let response: LifeSituationsResponse = try await networkService.request(endpoint)
            
            // Cache the situations
            await cacheSituations(response.situations)
            
            return response.situations
        } catch {
            // Fall back to local data
            return dataProvider.getAllSituations()
        }
    }
    
    public func getSituation(id: String) async throws -> LifeSituation? {
        // Try cache first
        if let cached = await getCachedSituation(id: id) {
            return cached
        }
        
        // Try network
        do {
            let endpoint = Endpoint(path: "/api/life-situations/\(id)", method: .get)
            let response: LifeSituationResponse = try await networkService.request(endpoint)
            return response.situation
        } catch {
            // Fall back to local data
            return dataProvider.getAllSituations().first { $0.id == id }
        }
    }
    
    public func getRelatedVerses(for situationId: String) async throws -> [BibleVerse] {
        guard let situation = try await getSituation(id: situationId) else {
            return []
        }
        
        var verses: [BibleVerse] = []
        
        // Fetch full verse text for each reference
        for reference in situation.verses {
            do {
                let verse = try await bibleService.getVerse(
                    reference: reference.reference,
                    translation: "ESV"
                )
                verses.append(verse)
            } catch {
                print("Failed to fetch verse \(reference.reference): \(error)")
            }
        }
        
        return verses
    }
    
    public func getRelatedContent(for situationId: String) async throws -> [RelatedContent] {
        // Try to fetch from network
        do {
            let endpoint = Endpoint(path: "/api/life-situations/\(situationId)/related", method: .get)
            let response: RelatedContentResponse = try await networkService.request(endpoint)
            return response.content
        } catch {
            // Return default related content
            guard let situation = try await getSituation(id: situationId) else {
                return []
            }
            
            return [
                RelatedContent(
                    id: UUID().uuidString,
                    type: .article,
                    title: "Understanding \(situation.title)",
                    description: "Deep dive into biblical perspectives",
                    url: nil
                ),
                RelatedContent(
                    id: UUID().uuidString,
                    type: .video,
                    title: "Testimonies: \(situation.title)",
                    description: "Real stories of God's faithfulness",
                    url: nil
                ),
                RelatedContent(
                    id: UUID().uuidString,
                    type: .podcast,
                    title: "Biblical Counseling: \(situation.title)",
                    description: "Practical wisdom from Scripture",
                    url: nil
                )
            ]
        }
    }
    
    public func searchSituations(query: String) async throws -> [LifeSituation] {
        let allSituations = try await getSituations()
        let lowercasedQuery = query.lowercased()
        
        return allSituations.filter { situation in
            situation.title.lowercased().contains(lowercasedQuery) ||
            situation.description.lowercased().contains(lowercasedQuery) ||
            situation.tags.contains { $0.lowercased().contains(lowercasedQuery) }
        }
    }
    
    public func getRecentlyViewed() async throws -> [LifeSituation] {
        let allSituations = try await getSituations()
        return allSituations.filter { viewedSituations.contains($0.id) }
    }
    
    public func markAsViewed(_ situationId: String) async throws {
        viewedSituations.insert(situationId)
        await saveUserPreferences()
    }
    
    public func getFavorites() async throws -> [LifeSituation] {
        let allSituations = try await getSituations()
        return allSituations.filter { favoriteSituations.contains($0.id) }
    }
    
    public func toggleFavorite(_ situationId: String) async throws {
        if favoriteSituations.contains(situationId) {
            favoriteSituations.remove(situationId)
        } else {
            favoriteSituations.insert(situationId)
        }
        await saveUserPreferences()
    }
    
    // MARK: - Private Helpers
    
    private func loadUserPreferences() async {
        do {
            try await context.perform {
                let request: NSFetchRequest<UserPreference> = UserPreference.fetchRequest()
                request.predicate = NSPredicate(format: "key == %@ OR key == %@", "viewed_situations", "favorite_situations")
                
                let preferences = try self.context.fetch(request)
                
                for preference in preferences {
                    if preference.key == "viewed_situations",
                       let data = preference.value?.data(using: .utf8),
                       let ids = try? JSONDecoder().decode(Set<String>.self, from: data) {
                        self.viewedSituations = ids
                    } else if preference.key == "favorite_situations",
                              let data = preference.value?.data(using: .utf8),
                              let ids = try? JSONDecoder().decode(Set<String>.self, from: data) {
                        self.favoriteSituations = ids
                    }
                }
            }
        } catch {
            print("Failed to load user preferences: \(error)")
        }
    }
    
    private func saveUserPreferences() async {
        do {
            try await context.perform {
                // Save viewed situations
                let viewedRequest: NSFetchRequest<UserPreference> = UserPreference.fetchRequest()
                viewedRequest.predicate = NSPredicate(format: "key == %@", "viewed_situations")
                
                let viewedPref = (try? self.context.fetch(viewedRequest).first) ?? UserPreference(context: self.context)
                viewedPref.key = "viewed_situations"
                
                if let data = try? JSONEncoder().encode(self.viewedSituations) {
                    viewedPref.value = String(data: data, encoding: .utf8)
                }
                
                // Save favorite situations
                let favoriteRequest: NSFetchRequest<UserPreference> = UserPreference.fetchRequest()
                favoriteRequest.predicate = NSPredicate(format: "key == %@", "favorite_situations")
                
                let favoritePref = (try? self.context.fetch(favoriteRequest).first) ?? UserPreference(context: self.context)
                favoritePref.key = "favorite_situations"
                
                if let data = try? JSONEncoder().encode(self.favoriteSituations) {
                    favoritePref.value = String(data: data, encoding: .utf8)
                }
                
                try self.context.save()
            }
        } catch {
            print("Failed to save user preferences: \(error)")
        }
    }
    
    private func getCachedSituation(id: String) async -> LifeSituation? {
        do {
            return try await context.perform {
                let request: NSFetchRequest<CachedLifeSituation> = CachedLifeSituation.fetchRequest()
                request.predicate = NSPredicate(format: "id == %@", id)
                request.fetchLimit = 1
                
                guard let cached = try self.context.fetch(request).first else {
                    return nil
                }
                
                // Convert cached entity to model
                return self.convertToLifeSituation(cached)
            }
        } catch {
            return nil
        }
    }
    
    private func cacheSituations(_ situations: [LifeSituation]) async {
        do {
            try await context.perform {
                // Clear old cache
                let deleteRequest: NSFetchRequest<NSFetchRequestResult> = CachedLifeSituation.fetchRequest()
                let batchDelete = NSBatchDeleteRequest(fetchRequest: deleteRequest)
                try self.context.execute(batchDelete)
                
                // Save new situations
                for situation in situations {
                    let cached = CachedLifeSituation(context: self.context)
                    cached.id = situation.id
                    cached.title = situation.title
                    cached.situationDescription = situation.description
                    cached.category = situation.category.rawValue
                    cached.iconName = situation.iconName
                    cached.tags = situation.tags.joined(separator: ",")
                    
                    // Save verses as JSON
                    if let versesData = try? JSONEncoder().encode(situation.verses) {
                        cached.verses = String(data: versesData, encoding: .utf8)
                    }
                    
                    // Save prayers as JSON
                    if let prayersData = try? JSONEncoder().encode(situation.prayers) {
                        cached.prayers = String(data: prayersData, encoding: .utf8)
                    }
                    
                    // Save resources as JSON
                    if let resourcesData = try? JSONEncoder().encode(situation.resources) {
                        cached.resources = String(data: resourcesData, encoding: .utf8)
                    }
                }
                
                try self.context.save()
            }
        } catch {
            print("Failed to cache situations: \(error)")
        }
    }
    
    private func convertToLifeSituation(_ cached: CachedLifeSituation) -> LifeSituation? {
        guard let id = cached.id,
              let title = cached.title,
              let description = cached.situationDescription,
              let categoryRaw = cached.category,
              let category = LifeSituationCategory(rawValue: categoryRaw) else {
            return nil
        }
        
        // Decode verses
        var verses: [BibleReference] = []
        if let versesString = cached.verses,
           let versesData = versesString.data(using: .utf8),
           let decodedVerses = try? JSONDecoder().decode([BibleReference].self, from: versesData) {
            verses = decodedVerses
        }
        
        // Decode prayers
        var prayers: [Prayer] = []
        if let prayersString = cached.prayers,
           let prayersData = prayersString.data(using: .utf8),
           let decodedPrayers = try? JSONDecoder().decode([Prayer].self, from: prayersData) {
            prayers = decodedPrayers
        }
        
        // Decode resources
        var resources: [ResourceLink] = []
        if let resourcesString = cached.resources,
           let resourcesData = resourcesString.data(using: .utf8),
           let decodedResources = try? JSONDecoder().decode([ResourceLink].self, from: resourcesData) {
            resources = decodedResources
        }
        
        return LifeSituation(
            id: id,
            title: title,
            description: description,
            category: category,
            verses: verses,
            prayers: prayers,
            resources: resources,
            iconName: cached.iconName ?? "heart.circle.fill",
            tags: cached.tags?.components(separatedBy: ",") ?? []
        )
    }
}

// MARK: - Response Models
private struct LifeSituationsResponse: Codable {
    let situations: [LifeSituation]
}

private struct LifeSituationResponse: Codable {
    let situation: LifeSituation
}

private struct RelatedContentResponse: Codable {
    let content: [RelatedContent]
}

// MARK: - Core Data Entities
@objc(CachedLifeSituation)
public class CachedLifeSituation: NSManagedObject {
    @NSManaged public var id: String?
    @NSManaged public var title: String?
    @NSManaged public var situationDescription: String?
    @NSManaged public var category: String?
    @NSManaged public var verses: String? // JSON encoded
    @NSManaged public var prayers: String? // JSON encoded
    @NSManaged public var resources: String? // JSON encoded
    @NSManaged public var iconName: String?
    @NSManaged public var tags: String? // Comma separated
    @NSManaged public var lastUpdated: Date?
}

extension CachedLifeSituation {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CachedLifeSituation> {
        return NSFetchRequest<CachedLifeSituation>(entityName: "CachedLifeSituation")
    }
}

@objc(UserPreference)
public class UserPreference: NSManagedObject {
    @NSManaged public var key: String?
    @NSManaged public var value: String?
    @NSManaged public var lastUpdated: Date?
}

extension UserPreference {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserPreference> {
        return NSFetchRequest<UserPreference>(entityName: "UserPreference")
    }
}