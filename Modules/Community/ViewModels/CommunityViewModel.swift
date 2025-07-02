//
//  CommunityViewModel.swift
//  Leavn
//
//  Created by Will Sigmon on 6/30/25.
//

import Foundation
import LeavnCore
import LeavnServices
import SwiftUI

@MainActor
public final class CommunityViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published public private(set) var posts: [CommunityPost] = []
    @Published public private(set) var groups: [StudyGroup] = []
    @Published public private(set) var challenges: [Challenge] = []
    @Published public private(set) var unreadNotifications = 0
    @Published public private(set) var isLoading = false
    @Published public private(set) var error: Error?
    @Published public private(set) var currentUser: User?
    
    // MARK: - Services
    private let syncService: SyncServiceProtocol
    private let analyticsService: AnalyticsServiceProtocol
    private let userService: UserServiceProtocol
    
    // MARK: - Initialization
    public init(
        syncService: SyncServiceProtocol? = nil,
        analyticsService: AnalyticsServiceProtocol? = nil,
        userService: UserServiceProtocol? = nil
    ) {
        self.syncService = syncService ?? DIContainer.shared.syncService!
        self.analyticsService = analyticsService ?? DIContainer.shared.analyticsService!
        self.userService = userService ?? DIContainer.shared.userService!
        
        // Load current user
        Task { [weak self] in
            do {
                self?.currentUser = try await self?.userService.getCurrentUser()
            } catch {
                print("Failed to load current user: \(error)")
            }
        }
        
        Task {
            await loadCommunityData()
        }
    }
    
    // MARK: - Public Methods
    
    @MainActor
    public func loadCommunityData() async {
        isLoading = true
        
        do {
            async let postsTask = loadPosts()
            async let groupsTask = loadGroups()
            async let challengesTask = loadChallenges()
            async let notificationsTask = getUnreadNotificationCount()
            
            let (posts, groups, challenges, unreadCount) = await (try postsTask, try groupsTask, try challengesTask, notificationsTask)
            
            self.posts = posts
            self.groups = groups
            self.challenges = challenges
            self.unreadNotifications = unreadCount
            
        } catch {
            self.error = error
            print("Failed to load community data: \(error)")
        }
        
        isLoading = false
    }
    
    public func createPost(text: String, verseReference: String? = nil, groupId: String? = nil) async {
        do {
            guard let currentUser = try await userService.getCurrentUser() else { return }
            
            let post = CommunityPost(
                id: UUID().uuidString,
                userId: currentUser.id,
                userName: currentUser.name,
                userAvatar: nil,
                text: text,
                verseReference: verseReference,
                groupId: groupId,
                timestamp: Date(),
                likes: [],
                comments: [],
                isLikedByUser: false
            )
            
            // Add optimistically
            posts.insert(post, at: 0)
            
            // Track analytics
            let event = AnalyticsEvent(
                name: "post_created",
                parameters: [
                    "has_verse": String(verseReference != nil),
                    "has_group": String(groupId != nil)
                ]
            )
            await analyticsService.track(event: event)
            
        } catch {
            print("Failed to create post: \(error)")
            self.error = error
        }
    }
    
    public func likePost(_ postId: String) async {
        guard let index = posts.firstIndex(where: { $0.id == postId }) else { return }
        guard let currentUserId = currentUser?.id else { return }
        
        // Toggle like status
        posts[index].isLikedByUser.toggle()
        
        // Update likes array
        if posts[index].isLikedByUser {
            posts[index].likes.append(currentUserId)
        } else {
            posts[index].likes.removeAll { $0 == currentUserId }
        }
        
        // Track analytics
        let event = AnalyticsEvent(name: "post_liked", parameters: ["post_id": postId])
        await analyticsService.track(event: event)
    }
    
    public func commentOnPost(_ postId: String, text: String) async {
        guard let index = posts.firstIndex(where: { $0.id == postId }) else { return }
        guard let currentUser = currentUser else { return }
        
        let comment = Comment(
            id: UUID().uuidString,
            userId: currentUser.id,
            userName: currentUser.name,
            text: text,
            timestamp: Date()
        )
        
        // Optimistic update
        posts[index].comments.append(comment)
        
        // Track analytics
        let event = AnalyticsEvent(name: "comment_added", parameters: ["post_id": postId])
        await analyticsService.track(event: event)
    }
    
    public func joinGroup(_ groupId: String) async {
        guard let index = groups.firstIndex(where: { $0.id == groupId }) else { return }
        guard let currentUserId = currentUser?.id else { return }
        
        // Optimistic update
        groups[index].memberIds.append(currentUserId)
        groups[index].isJoined = true
        
        // Track analytics
        let event = AnalyticsEvent(name: "group_joined", parameters: ["group_id": groupId])
        await analyticsService.track(event: event)
    }
    
    public func joinChallenge(_ challengeId: String) async {
        guard let index = challenges.firstIndex(where: { $0.id == challengeId }) else { return }
        guard let currentUserId = currentUser?.id else { return }
        
        // Optimistic update
        challenges[index].participantIds.append(currentUserId)
        challenges[index].isJoined = true
        
        // Track analytics
        let event = AnalyticsEvent(name: "challenge_joined", parameters: ["challenge_id": challengeId])
        await analyticsService.track(event: event)
    }
    
    // MARK: - Private Methods
    
    private func loadPosts() async -> [CommunityPost] {
        // TODO: Implement CommunityServiceProtocol and fetch from server
        // For now, return empty array instead of mock data
        return []
    }
    
    private func loadGroups() async -> [StudyGroup] {
        // TODO: Implement CommunityServiceProtocol and fetch from server
        // For now, return empty array instead of mock data
        return []
    }
    
    private func loadChallenges() async -> [Challenge] {
        // TODO: Implement CommunityServiceProtocol and fetch from server
        // For now, return empty array instead of mock data
        return []
    }
    
    private func getUnreadNotificationCount() async -> Int {
        // TODO: Implement CommunityServiceProtocol and fetch from server
        // For now, return 0 instead of hardcoded 3
        return 0
    }
}

// MARK: - Models
public struct CommunityPost: Identifiable, Sendable {
    public let id: String
    public let userId: String
    public let userName: String
    public let userAvatar: String?
    public let text: String
    public let verseReference: String?
    public let groupId: String?
    public let timestamp: Date
    public var likes: [String]
    public var comments: [Comment]
    public var isLikedByUser: Bool
}

public struct Comment: Identifiable, Sendable {
    public let id: String
    public let userId: String
    public let userName: String
    public let text: String
    public let timestamp: Date
}

public struct StudyGroup: Identifiable, Sendable {
    public let id: String
    public let name: String
    public let description: String
    public let memberCount: Int
    public var memberIds: [String]
    public var isJoined: Bool
    public let lastActivity: Date
    public let icon: String
    public let color: Color
}

public struct Challenge: Identifiable, Sendable {
    public let id: String
    public let title: String
    public let description: String
    public let duration: String
    public let participantCount: Int
    public var participantIds: [String]
    public let progress: Double
    public var isJoined: Bool
    public let startDate: Date
    public let endDate: Date
    public let icon: String
    public let color: Color
}
