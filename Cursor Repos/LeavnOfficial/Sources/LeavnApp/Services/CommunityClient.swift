import Dependencies
import Foundation

// Empty response for DELETE/POST operations that return no body
struct EmptyResponse: Codable {}

struct CommunityClient {
    var loadPrayers: @Sendable () async throws -> [Prayer]
    var submitPrayer: @Sendable (Prayer) async throws -> Prayer
    var prayFor: @Sendable (Prayer.ID) async throws -> Prayer
    var deletePrayer: @Sendable (Prayer.ID) async throws -> Bool
    
    var loadMyGroups: @Sendable () async throws -> [Group]
    var loadDiscoverGroups: @Sendable () async throws -> [Group]
    var joinGroup: @Sendable (Group.ID) async throws -> Bool
    var leaveGroup: @Sendable (Group.ID) async throws -> Bool
}

extension CommunityClient: DependencyKey {
    static let liveValue = Self(
        loadPrayers: {
            @Dependency(\.networkLayer) var network
            @Dependency(\.authClient) var auth
            
            let token = try await auth.getCurrentToken()
            let headers = token.map { ["Authorization": "Bearer \($0)"] } ?? [:]
            
            return try await network.request(
                endpoint: "/prayers",
                method: .get,
                headers: headers,
                responseType: [Prayer].self
            )
        },
        submitPrayer: { prayer in
            @Dependency(\.networkLayer) var network
            @Dependency(\.authClient) var auth
            
            let token = try await auth.getCurrentToken()
            let headers = token.map { ["Authorization": "Bearer \($0)"] } ?? [:]
            
            return try await network.request(
                endpoint: "/prayers",
                method: .post,
                headers: headers,
                body: prayer,
                responseType: Prayer.self
            )
        },
        prayFor: { prayerId in
            @Dependency(\.networkLayer) var network
            @Dependency(\.authClient) var auth
            
            let token = try await auth.getCurrentToken()
            let headers = token.map { ["Authorization": "Bearer \($0)"] } ?? [:]
            
            return try await network.request(
                endpoint: "/prayers/\(prayerId)/pray",
                method: .post,
                headers: headers,
                responseType: Prayer.self
            )
        },
        deletePrayer: { prayerId in
            @Dependency(\.networkLayer) var network
            @Dependency(\.authClient) var auth
            
            let token = try await auth.getCurrentToken()
            let headers = token.map { ["Authorization": "Bearer \($0)"] } ?? [:]
            
            _ = try await network.request(
                endpoint: "/prayers/\(prayerId)",
                method: .delete,
                headers: headers,
                responseType: EmptyResponse.self
            )
            
            return true
        },
        loadMyGroups: {
            @Dependency(\.networkLayer) var network
            @Dependency(\.authClient) var auth
            
            let token = try await auth.getCurrentToken()
            let headers = token.map { ["Authorization": "Bearer \($0)"] } ?? [:]
            
            return try await network.request(
                endpoint: "/groups/my",
                method: .get,
                headers: headers,
                responseType: [Group].self
            )
        },
        loadDiscoverGroups: {
            @Dependency(\.networkLayer) var network
            @Dependency(\.authClient) var auth
            
            let token = try await auth.getCurrentToken()
            let headers = token.map { ["Authorization": "Bearer \($0)"] } ?? [:]
            
            return try await network.request(
                endpoint: "/groups/discover",
                method: .get,
                headers: headers,
                responseType: [Group].self
            )
        },
        joinGroup: { groupId in
            @Dependency(\.networkLayer) var network
            @Dependency(\.authClient) var auth
            
            let token = try await auth.getCurrentToken()
            let headers = token.map { ["Authorization": "Bearer \($0)"] } ?? [:]
            
            _ = try await network.request(
                endpoint: "/groups/\(groupId)/join",
                method: .post,
                headers: headers,
                responseType: EmptyResponse.self
            )
            
            return true
        },
        leaveGroup: { groupId in
            @Dependency(\.networkLayer) var network
            @Dependency(\.authClient) var auth
            
            let token = try await auth.getCurrentToken()
            let headers = token.map { ["Authorization": "Bearer \($0)"] } ?? [:]
            
            _ = try await network.request(
                endpoint: "/groups/\(groupId)/leave",
                method: .delete,
                headers: headers,
                responseType: EmptyResponse.self
            )
            
            return true
        }
    )
}

extension DependencyValues {
    var communityClient: CommunityClient {
        get { self[CommunityClient.self] }
        set { self[CommunityClient.self] = newValue }
    }
}

enum CommunityError: LocalizedError {
    case networkError
    case unauthorized
    case notFound
    
    var errorDescription: String? {
        switch self {
        case .networkError:
            return "Unable to connect to the community server"
        case .unauthorized:
            return "You must be logged in to perform this action"
        case .notFound:
            return "The requested resource was not found"
        }
    }
}