import Foundation
import Dependencies
import IdentifiedCollections

// MARK: - Community Service
@MainActor
public struct CommunityService: Sendable {
    // Prayer Wall
    public var fetchPrayers: @Sendable (PrayerFilter?) async throws -> IdentifiedArrayOf<Prayer>
    public var createPrayer: @Sendable (Prayer) async throws -> Prayer
    public var updatePrayer: @Sendable (Prayer) async throws -> Prayer
    public var deletePrayer: @Sendable (PrayerID) async throws -> Void
    public var prayForPrayer: @Sendable (PrayerID) async throws -> Prayer
    public var reportPrayer: @Sendable (PrayerID, String) async throws -> Void
    
    // Groups
    public var fetchGroups: @Sendable (GroupFilter?) async throws -> IdentifiedArrayOf<Group>
    public var fetchGroup: @Sendable (GroupID) async throws -> Group
    public var createGroup: @Sendable (Group) async throws -> Group
    public var updateGroup: @Sendable (Group) async throws -> Group
    public var deleteGroup: @Sendable (GroupID) async throws -> Void
    public var joinGroup: @Sendable (GroupID) async throws -> Group
    public var leaveGroup: @Sendable (GroupID) async throws -> Void
    
    // Activity Feed
    public var fetchActivityFeed: @Sendable () async throws -> IdentifiedArrayOf<CommunityActivity>
    public var fetchUserActivity: @Sendable (UserID) async throws -> IdentifiedArrayOf<CommunityActivity>
}

// MARK: - Filters
public struct PrayerFilter: Equatable, Sendable {
    public var category: PrayerCategory?
    public var status: Prayer.PrayerStatus?
    public var groupId: GroupID?
    public var userId: UserID?
    public var searchText: String?
    public var sortBy: PrayerSortOption
    
    public enum PrayerSortOption: String, CaseIterable, Sendable {
        case newest = "Newest"
        case mostPrayed = "Most Prayed"
        case recentlyAnswered = "Recently Answered"
    }
    
    public init(
        category: PrayerCategory? = nil,
        status: Prayer.PrayerStatus? = nil,
        groupId: GroupID? = nil,
        userId: UserID? = nil,
        searchText: String? = nil,
        sortBy: PrayerSortOption = .newest
    ) {
        self.category = category
        self.status = status
        self.groupId = groupId
        self.userId = userId
        self.searchText = searchText
        self.sortBy = sortBy
    }
}

public struct GroupFilter: Equatable, Sendable {
    public var category: GroupCategory?
    public var searchText: String?
    public var showPrivate: Bool
    public var sortBy: GroupSortOption
    
    public enum GroupSortOption: String, CaseIterable, Sendable {
        case newest = "Newest"
        case mostMembers = "Most Members"
        case alphabetical = "Alphabetical"
        case mostActive = "Most Active"
    }
    
    public init(
        category: GroupCategory? = nil,
        searchText: String? = nil,
        showPrivate: Bool = false,
        sortBy: GroupSortOption = .mostMembers
    ) {
        self.category = category
        self.searchText = searchText
        self.showPrivate = showPrivate
        self.sortBy = sortBy
    }
}

// MARK: - API Client
private struct CommunityAPIClient {
    @Dependency(\.apiKeyManager) var apiKeyManager
    @Dependency(\.userDefaults) var userDefaults
    
    let baseURL = URL(string: "https://api.leavnapp.com/v1")!
    
    func makeRequest(
        endpoint: String,
        method: String = "GET",
        body: Data? = nil
    ) async throws -> (Data, URLResponse) {
        var request = URLRequest(url: baseURL.appendingPathComponent(endpoint))
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Add authentication token if available
        if let token = userDefaults.authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        if let body = body {
            request.httpBody = body
        }
        
        return try await URLSession.shared.data(for: request)
    }
}

// MARK: - Dependency Implementation
extension CommunityService: DependencyKey {
    public static let liveValue = Self(
        fetchPrayers: { filter in
            let client = CommunityAPIClient()
            
            var endpoint = "prayers"
            var queryItems: [URLQueryItem] = []
            
            if let category = filter?.category {
                queryItems.append(URLQueryItem(name: "category", value: category.rawValue))
            }
            if let status = filter?.status {
                queryItems.append(URLQueryItem(name: "status", value: status.rawValue))
            }
            if let groupId = filter?.groupId {
                queryItems.append(URLQueryItem(name: "groupId", value: groupId.rawValue.uuidString))
            }
            if let searchText = filter?.searchText {
                queryItems.append(URLQueryItem(name: "q", value: searchText))
            }
            
            if !queryItems.isEmpty {
                var components = URLComponents(string: endpoint)!
                components.queryItems = queryItems
                endpoint = components.string!
            }
            
            let (data, _) = try await client.makeRequest(endpoint: endpoint)
            let prayers = try JSONDecoder().decode([Prayer].self, from: data)
            
            return IdentifiedArray(uniqueElements: prayers)
        },
        createPrayer: { prayer in
            let client = CommunityAPIClient()
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            
            let body = try encoder.encode(prayer)
            let (data, _) = try await client.makeRequest(
                endpoint: "prayers",
                method: "POST",
                body: body
            )
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(Prayer.self, from: data)
        },
        updatePrayer: { prayer in
            let client = CommunityAPIClient()
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            
            let body = try encoder.encode(prayer)
            let (data, _) = try await client.makeRequest(
                endpoint: "prayers/\(prayer.id.rawValue)",
                method: "PUT",
                body: body
            )
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(Prayer.self, from: data)
        },
        deletePrayer: { prayerId in
            let client = CommunityAPIClient()
            _ = try await client.makeRequest(
                endpoint: "prayers/\(prayerId.rawValue)",
                method: "DELETE"
            )
        },
        prayForPrayer: { prayerId in
            let client = CommunityAPIClient()
            let (data, _) = try await client.makeRequest(
                endpoint: "prayers/\(prayerId.rawValue)/pray",
                method: "POST"
            )
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(Prayer.self, from: data)
        },
        reportPrayer: { prayerId, reason in
            let client = CommunityAPIClient()
            let body = try JSONEncoder().encode(["reason": reason])
            _ = try await client.makeRequest(
                endpoint: "prayers/\(prayerId.rawValue)/report",
                method: "POST",
                body: body
            )
        },
        fetchGroups: { filter in
            let client = CommunityAPIClient()
            
            var endpoint = "groups"
            var queryItems: [URLQueryItem] = []
            
            if let category = filter?.category {
                queryItems.append(URLQueryItem(name: "category", value: category.rawValue))
            }
            if let searchText = filter?.searchText {
                queryItems.append(URLQueryItem(name: "q", value: searchText))
            }
            if let showPrivate = filter?.showPrivate, showPrivate {
                queryItems.append(URLQueryItem(name: "includePrivate", value: "true"))
            }
            
            if !queryItems.isEmpty {
                var components = URLComponents(string: endpoint)!
                components.queryItems = queryItems
                endpoint = components.string!
            }
            
            let (data, _) = try await client.makeRequest(endpoint: endpoint)
            let groups = try JSONDecoder().decode([Group].self, from: data)
            
            return IdentifiedArray(uniqueElements: groups)
        },
        fetchGroup: { groupId in
            let client = CommunityAPIClient()
            let (data, _) = try await client.makeRequest(endpoint: "groups/\(groupId.rawValue)")
            return try JSONDecoder().decode(Group.self, from: data)
        },
        createGroup: { group in
            let client = CommunityAPIClient()
            let body = try JSONEncoder().encode(group)
            let (data, _) = try await client.makeRequest(
                endpoint: "groups",
                method: "POST",
                body: body
            )
            
            return try JSONDecoder().decode(Group.self, from: data)
        },
        updateGroup: { group in
            let client = CommunityAPIClient()
            let body = try JSONEncoder().encode(group)
            let (data, _) = try await client.makeRequest(
                endpoint: "groups/\(group.id.rawValue)",
                method: "PUT",
                body: body
            )
            
            return try JSONDecoder().decode(Group.self, from: data)
        },
        deleteGroup: { groupId in
            let client = CommunityAPIClient()
            _ = try await client.makeRequest(
                endpoint: "groups/\(groupId.rawValue)",
                method: "DELETE"
            )
        },
        joinGroup: { groupId in
            let client = CommunityAPIClient()
            let (data, _) = try await client.makeRequest(
                endpoint: "groups/\(groupId.rawValue)/join",
                method: "POST"
            )
            
            return try JSONDecoder().decode(Group.self, from: data)
        },
        leaveGroup: { groupId in
            let client = CommunityAPIClient()
            _ = try await client.makeRequest(
                endpoint: "groups/\(groupId.rawValue)/leave",
                method: "POST"
            )
        },
        fetchActivityFeed: {
            let client = CommunityAPIClient()
            let (data, _) = try await client.makeRequest(endpoint: "activity/feed")
            let activities = try JSONDecoder().decode([CommunityActivity].self, from: data)
            
            return IdentifiedArray(uniqueElements: activities)
        },
        fetchUserActivity: { userId in
            let client = CommunityAPIClient()
            let (data, _) = try await client.makeRequest(endpoint: "activity/user/\(userId.rawValue)")
            let activities = try JSONDecoder().decode([CommunityActivity].self, from: data)
            
            return IdentifiedArray(uniqueElements: activities)
        }
    )
    
    public static let testValue = Self(
        fetchPrayers: { _ in [] },
        createPrayer: { $0 },
        updatePrayer: { $0 },
        deletePrayer: { _ in },
        prayForPrayer: { _ in
            Prayer(
                title: "Test Prayer",
                content: "Test content",
                authorId: UserID(UUID()),
                authorName: "Test User",
                category: .general
            )
        },
        reportPrayer: { _, _ in },
        fetchGroups: { _ in [] },
        fetchGroup: { _ in
            Group(
                name: "Test Group",
                description: "Test description",
                createdBy: UserID(UUID()),
                category: .general
            )
        },
        createGroup: { $0 },
        updateGroup: { $0 },
        deleteGroup: { _ in },
        joinGroup: { _ in
            Group(
                name: "Test Group",
                description: "Test description",
                createdBy: UserID(UUID()),
                category: .general
            )
        },
        leaveGroup: { _ in },
        fetchActivityFeed: { [] },
        fetchUserActivity: { _ in [] }
    )
}

// MARK: - Dependency Values
extension DependencyValues {
    public var communityService: CommunityService {
        get { self[CommunityService.self] }
        set { self[CommunityService.self] = newValue }
    }
}