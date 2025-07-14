import Foundation
import SwiftUI
import Combine

@MainActor
class CommunityViewModel: ObservableObject {
    @Published var posts: [CommunityPost] = []
    @Published var groups: [CommunityGroup] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    private let communityService: CommunityServiceProtocol
    private let analyticsService: AnalyticsServiceProtocol
    private let userDataManager: UserDataManagerProtocol
    
    init(
        communityService: CommunityServiceProtocol? = nil,
        analyticsService: AnalyticsServiceProtocol? = nil,
        userDataManager: UserDataManagerProtocol? = nil
    ) {
        let container = DIContainer.shared
        self.communityService = communityService ?? container.communityService
        self.analyticsService = analyticsService ?? container.analyticsService
        self.userDataManager = userDataManager ?? container.userDataManager
        
        Task {
            await loadCommunityData()
        }
    }
    
    func loadCommunityData() async {
        isLoading = true
        error = nil
        
        do {
            // Load posts from service
            posts = try await communityService.getPosts()
            
            // For now, create mock groups since the service doesn't have groups yet
            groups = [
                CommunityGroup(id: "1", name: "Bible Study", memberCount: 25),
                CommunityGroup(id: "2", name: "Prayer Warriors", memberCount: 40),
                CommunityGroup(id: "3", name: "Youth Ministry", memberCount: 60),
                CommunityGroup(id: "4", name: "Women's Fellowship", memberCount: 35)
            ]
            
            analyticsService.track(event: "community_loaded", properties: [
                "posts_count": posts.count,
                "groups_count": groups.count
            ])
        } catch {
            self.error = error
            print("Failed to load community data: \(error)")
            
            // Fallback to mock data if service fails
            posts = [
                CommunityPost(
                    id: "1",
                    userId: "user1",
                    content: "Blessed by today's sermon on faith and perseverance!",
                    createdAt: Date()
                ),
                CommunityPost(
                    id: "2",
                    userId: "user2",
                    content: "Prayer request: Please pray for healing for my family.",
                    createdAt: Date().addingTimeInterval(-3600)
                )
            ]
        }
        
        isLoading = false
    }
    
    func createPost(content: String) async {
        guard let currentUser = userDataManager.currentUser else {
            print("No user logged in")
            return
        }
        
        let newPost = CommunityPost(
            id: UUID().uuidString,
            userId: currentUser.id,
            content: content,
            createdAt: Date()
        )
        
        do {
            try await communityService.createPost(newPost)
            await loadCommunityData()
            
            analyticsService.track(event: "post_created", properties: [
                "content_length": content.count
            ])
        } catch {
            self.error = error
            print("Failed to create post: \(error)")
        }
    }
    
    func deletePost(_ post: CommunityPost) async {
        do {
            try await communityService.deletePost(post.id)
            await loadCommunityData()
            
            analyticsService.track(event: "post_deleted", properties: [
                "post_id": post.id
            ])
        } catch {
            self.error = error
            print("Failed to delete post: \(error)")
        }
    }
    
    func joinGroup(_ group: CommunityGroup) {
        // TODO: Implement group joining when backend is ready
        analyticsService.track(event: "group_joined", properties: [
            "group_id": group.id,
            "group_name": group.name
        ])
    }
    
    func leaveGroup(_ group: CommunityGroup) {
        // TODO: Implement group leaving when backend is ready
        analyticsService.track(event: "group_left", properties: [
            "group_id": group.id,
            "group_name": group.name
        ])
    }
    
    func likePost(_ post: CommunityPost) {
        // TODO: Implement post liking when backend is ready
        analyticsService.track(event: "post_liked", properties: [
            "post_id": post.id
        ])
    }
    
    func reportPost(_ post: CommunityPost, reason: String) {
        // TODO: Implement post reporting when backend is ready
        analyticsService.track(event: "post_reported", properties: [
            "post_id": post.id,
            "reason": reason
        ])
    }
}

// MARK: - Extended Community Post
extension CommunityPost {
    var author: String {
        // In a real app, this would look up the user by userId
        return "User \(userId.prefix(4))"
    }
    
    var timestamp: Date {
        return createdAt
    }
}

// MARK: - Community Group Model
struct CommunityGroup: Identifiable {
    let id: String
    let name: String
    let memberCount: Int
}