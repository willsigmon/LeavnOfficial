import Foundation
import CoreData
import Combine

// MARK: - Default Community Service
public final class DefaultCommunityService: CommunityServiceProtocol {
    private let networkService: NetworkServiceProtocol
    private let context: NSManagedObjectContext
    private let userDataManager: UserDataManagerProtocol
    
    // Cache for offline support
    private var cachedPosts: [CommunityPost] = []
    private let cacheQueue = DispatchQueue(label: "community.cache", attributes: .concurrent)
    
    public init(
        networkService: NetworkServiceProtocol,
        context: NSManagedObjectContext,
        userDataManager: UserDataManagerProtocol
    ) {
        self.networkService = networkService
        self.context = context
        self.userDataManager = userDataManager
        
        // Load cached posts on init
        Task {
            await loadCachedPosts()
        }
    }
    
    public func getPosts() async throws -> [CommunityPost] {
        do {
            // Try to fetch from network
            let endpoint = Endpoint(path: "/api/community/posts", method: .get)
            let response: PostsResponse = try await networkService.request(endpoint)
            
            let posts = response.posts.map { post in
                CommunityPost(
                    id: post.id,
                    userId: post.userId,
                    content: post.content,
                    createdAt: post.createdAt
                )
            }
            
            // Cache the posts
            await cachePosts(posts)
            
            return posts
        } catch {
            // If network fails, return cached posts
            return await getCachedPosts()
        }
    }
    
    public func createPost(_ post: CommunityPost) async throws {
        guard let currentUser = userDataManager.currentUser else {
            throw LeavnError.authenticationError("Must be logged in to create posts")
        }
        
        let endpoint = Endpoint(
            path: "/api/community/posts",
            method: .post,
            parameters: [
                "userId": currentUser.id,
                "content": post.content
            ]
        )
        
        do {
            let _: PostResponse = try await networkService.request(endpoint)
            
            // Refresh posts list
            _ = try? await getPosts()
        } catch {
            // For offline mode, add to local cache
            var newPost = post
            newPost.id = UUID().uuidString
            newPost.userId = currentUser.id
            
            await cacheQueue.async(flags: .barrier) {
                self.cachedPosts.insert(newPost, at: 0)
            }
            
            // Queue for sync when online
            await queuePostForSync(newPost)
        }
    }
    
    public func deletePost(_ postId: String) async throws {
        let endpoint = Endpoint(
            path: "/api/community/posts/\(postId)",
            method: .delete
        )
        
        do {
            let _: EmptyResponse = try await networkService.request(endpoint)
            
            // Remove from cache
            await cacheQueue.async(flags: .barrier) {
                self.cachedPosts.removeAll { $0.id == postId }
            }
        } catch {
            // For offline, just remove from cache
            await cacheQueue.async(flags: .barrier) {
                self.cachedPosts.removeAll { $0.id == postId }
            }
        }
    }
    
    // MARK: - Private Helpers
    
    private func loadCachedPosts() async {
        do {
            let posts = try await context.perform {
                let request: NSFetchRequest<CachedPost> = CachedPost.fetchRequest()
                request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
                request.fetchLimit = 50
                
                let cachedPosts = try self.context.fetch(request)
                return cachedPosts.map { cached in
                    CommunityPost(
                        id: cached.id ?? UUID().uuidString,
                        userId: cached.userId ?? "",
                        content: cached.content ?? "",
                        createdAt: cached.createdAt ?? Date()
                    )
                }
            }
            
            await cacheQueue.async(flags: .barrier) {
                self.cachedPosts = posts
            }
        } catch {
            print("Failed to load cached posts: \(error)")
        }
    }
    
    private func cachePosts(_ posts: [CommunityPost]) async {
        // Update in-memory cache
        await cacheQueue.async(flags: .barrier) {
            self.cachedPosts = posts
        }
        
        // Update Core Data cache
        do {
            try await context.perform {
                // Clear old cache
                let deleteRequest: NSFetchRequest<NSFetchRequestResult> = CachedPost.fetchRequest()
                let batchDelete = NSBatchDeleteRequest(fetchRequest: deleteRequest)
                try self.context.execute(batchDelete)
                
                // Save new posts
                for post in posts {
                    let cachedPost = CachedPost(context: self.context)
                    cachedPost.id = post.id
                    cachedPost.userId = post.userId
                    cachedPost.content = post.content
                    cachedPost.createdAt = post.createdAt
                }
                
                try self.context.save()
            }
        } catch {
            print("Failed to cache posts: \(error)")
        }
    }
    
    private func getCachedPosts() async -> [CommunityPost] {
        await withCheckedContinuation { continuation in
            cacheQueue.async {
                continuation.resume(returning: self.cachedPosts)
            }
        }
    }
    
    private func queuePostForSync(_ post: CommunityPost) async {
        // In production, this would queue the post for sync when network is available
        do {
            try await context.perform {
                let pendingPost = PendingPost(context: self.context)
                pendingPost.id = post.id
                pendingPost.userId = post.userId
                pendingPost.content = post.content
                pendingPost.createdAt = post.createdAt
                pendingPost.syncStatus = "pending"
                
                try self.context.save()
            }
        } catch {
            print("Failed to queue post for sync: \(error)")
        }
    }
}

// MARK: - Response Models
private struct PostsResponse: Codable {
    let posts: [PostData]
}

private struct PostResponse: Codable {
    let post: PostData
}

private struct PostData: Codable {
    let id: String
    let userId: String
    let content: String
    let createdAt: Date
}

private struct EmptyResponse: Codable {}

// MARK: - Core Data Entities
@objc(CachedPost)
public class CachedPost: NSManagedObject {
    @NSManaged public var id: String?
    @NSManaged public var userId: String?
    @NSManaged public var content: String?
    @NSManaged public var createdAt: Date?
}

extension CachedPost {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CachedPost> {
        return NSFetchRequest<CachedPost>(entityName: "CachedPost")
    }
}

@objc(PendingPost)
public class PendingPost: NSManagedObject {
    @NSManaged public var id: String?
    @NSManaged public var userId: String?
    @NSManaged public var content: String?
    @NSManaged public var createdAt: Date?
    @NSManaged public var syncStatus: String?
}

extension PendingPost {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<PendingPost> {
        return NSFetchRequest<PendingPost>(entityName: "PendingPost")
    }
}

// MARK: - Community Post Extension
extension CommunityPost {
    public init(id: String, userId: String, content: String, createdAt: Date) {
        self.id = id
        self.userId = userId
        self.content = content
        self.createdAt = createdAt
    }
}