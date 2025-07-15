import Foundation
import SwiftUI
import Combine

@MainActor
public final class CommunityViewModel: BaseViewModel {
    @Published public var posts: [CommunityPost] = []
    @Published public var groups: [CommunityGroup] = []
    @Published public var isLoading: Bool = false
    @Published public var newPostText: String = ""
    
    private let communityService: CommunityServiceProtocol
    
    public init(communityService: CommunityServiceProtocol, analyticsService: AnalyticsServiceProtocol? = nil) {
        self.communityService = communityService
        super.init(analyticsService: analyticsService)
        
        Task {
            await loadInitialData()
        }
    }
    
    public func loadInitialData() async {
        isLoading = true
        
        do {
            async let postsTask = communityService.getFeedPosts(limit: 20)
            async let groupsTask = communityService.getUserGroups()
            
            posts = try await postsTask
            groups = try await groupsTask
        } catch {
            handleError(error)
        }
        
        isLoading = false
    }
    
    public func createPost() async {
        guard !newPostText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        do {
            let newPost = try await communityService.createPost(content: newPostText, groupId: nil)
            posts.insert(newPost, at: 0)
            newPostText = ""
        } catch {
            handleError(error)
        }
    }
    
    public func likePost(_ postId: String) async {
        do {
            try await communityService.likePost(postId: postId)
            // Update local state
            if let index = posts.firstIndex(where: { $0.id == postId }) {
                var updatedPost = posts[index]
                updatedPost = CommunityPost(
                    id: updatedPost.id,
                    authorId: updatedPost.authorId,
                    authorName: updatedPost.authorName,
                    content: updatedPost.content,
                    timestamp: updatedPost.timestamp,
                    likes: updatedPost.likes + 1,
                    comments: updatedPost.comments,
                    groupId: updatedPost.groupId,
                    groupName: updatedPost.groupName
                )
                posts[index] = updatedPost
            }
        } catch {
            handleError(error)
        }
    }
    
    public func joinGroup(_ groupId: String) async {
        do {
            try await communityService.joinGroup(groupId: groupId)
            await loadInitialData() // Refresh to show updated groups
        } catch {
            handleError(error)
        }
    }
    
    public func leaveGroup(_ groupId: String) async {
        do {
            try await communityService.leaveGroup(groupId: groupId)
            groups.removeAll { $0.id == groupId }
        } catch {
            handleError(error)
        }
    }
}