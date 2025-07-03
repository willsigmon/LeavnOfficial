import Foundation
import LeavnCore

#if canImport(FirebaseCore)
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
#endif

// Import community models
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
    
    public init(id: String, userId: String, userName: String, userAvatar: String?, text: String, verseReference: String?, groupId: String?, timestamp: Date, likes: [String], comments: [Comment], isLikedByUser: Bool) {
        self.id = id
        self.userId = userId
        self.userName = userName
        self.userAvatar = userAvatar
        self.text = text
        self.verseReference = verseReference
        self.groupId = groupId
        self.timestamp = timestamp
        self.likes = likes
        self.comments = comments
        self.isLikedByUser = isLikedByUser
    }
}

public struct Comment: Identifiable, Sendable {
    public let id: String
    public let userId: String
    public let userName: String
    public let text: String
    public let timestamp: Date
    
    public init(id: String, userId: String, userName: String, text: String, timestamp: Date) {
        self.id = id
        self.userId = userId
        self.userName = userName
        self.text = text
        self.timestamp = timestamp
    }
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
    public let color: String // Changed from Color to String for Firestore compatibility
    
    public init(id: String, name: String, description: String, memberCount: Int, memberIds: [String], isJoined: Bool, lastActivity: Date, icon: String, color: String) {
        self.id = id
        self.name = name
        self.description = description
        self.memberCount = memberCount
        self.memberIds = memberIds
        self.isJoined = isJoined
        self.lastActivity = lastActivity
        self.icon = icon
        self.color = color
    }
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
    public let color: String // Changed from Color to String for Firestore compatibility
    
    public init(id: String, title: String, description: String, duration: String, participantCount: Int, participantIds: [String], progress: Double, isJoined: Bool, startDate: Date, endDate: Date, icon: String, color: String) {
        self.id = id
        self.title = title
        self.description = description
        self.duration = duration
        self.participantCount = participantCount
        self.participantIds = participantIds
        self.progress = progress
        self.isJoined = isJoined
        self.startDate = startDate
        self.endDate = endDate
        self.icon = icon
        self.color = color
    }
}

/// Real Firebase-based community service
public actor FirebaseCommunityService: CommunityServiceProtocol, @unchecked Sendable {
    
    // MARK: - Properties
    
    #if canImport(FirebaseCore)
    private let db: Firestore
    private let auth: Auth
    #endif
    
    private var isInitialized = false
    private let logger = Logger.shared
    
    // MARK: - Initialization
    
    public init() {
        #if canImport(FirebaseCore)
        self.db = Firestore.firestore()
        self.auth = Auth.auth()
        #endif
    }
    
    public func initialize() async throws {
        #if canImport(FirebaseCore)
        // Firebase should be configured in the app delegate
        guard FirebaseApp.app() != nil else {
            throw ServiceError.notInitialized
        }
        
        isInitialized = true
        logger.info("Firebase Community Service initialized", category: .network)
        #else
        throw ServiceError.notInitialized
        #endif
    }
    
    // MARK: - CommunityServiceProtocol Implementation
    
    public func getPosts(limit: Int = 20, offset: Int = 0) async throws -> [CommunityPost] {
        guard isInitialized else { throw ServiceError.notInitialized }
        
        #if canImport(FirebaseCore)
        let snapshot = try await db.collection("posts")
            .order(by: "timestamp", descending: true)
            .limit(to: limit)
            .getDocuments()
        
        return snapshot.documents.compactMap { document in
            try? document.data(as: CommunityPost.self)
        }
        #else
        return []
        #endif
    }
    
    public func createPost(_ post: CommunityPost) async throws {
        guard isInitialized else { throw ServiceError.notInitialized }
        
        #if canImport(FirebaseCore)
        try await db.collection("posts").document(post.id).setData(from: post)
        logger.info("Created post: \(post.id)", category: .network)
        #endif
    }
    
    public func likePost(_ postId: String, userId: String) async throws {
        guard isInitialized else { throw ServiceError.notInitialized }
        
        #if canImport(FirebaseCore)
        let postRef = db.collection("posts").document(postId)
        
        try await db.runTransaction { transaction, errorPointer in
            let postSnapshot: DocumentSnapshot
            do {
                postSnapshot = try transaction.getDocument(postRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            guard var post = try? postSnapshot.data(as: CommunityPost.self) else {
                let error = NSError(domain: "FirebaseError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Post not found"])
                errorPointer?.pointee = error
                return nil
            }
            
            if post.likes.contains(userId) {
                post.likes.removeAll { $0 == userId }
            } else {
                post.likes.append(userId)
            }
            
            try transaction.setData(from: post, forDocument: postRef)
            return nil
        }
        #endif
    }
    
    public func addComment(to postId: String, comment: Comment) async throws {
        guard isInitialized else { throw ServiceError.notInitialized }
        
        #if canImport(FirebaseCore)
        let postRef = db.collection("posts").document(postId)
        
        try await db.runTransaction { transaction, errorPointer in
            let postSnapshot: DocumentSnapshot
            do {
                postSnapshot = try transaction.getDocument(postRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            guard var post = try? postSnapshot.data(as: CommunityPost.self) else {
                let error = NSError(domain: "FirebaseError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Post not found"])
                errorPointer?.pointee = error
                return nil
            }
            
            post.comments.append(comment)
            
            try transaction.setData(from: post, forDocument: postRef)
            return nil
        }
        #endif
    }
    
    public func getGroups() async throws -> [StudyGroup] {
        guard isInitialized else { throw ServiceError.notInitialized }
        
        #if canImport(FirebaseCore)
        let snapshot = try await db.collection("groups")
            .order(by: "lastActivity", descending: true)
            .getDocuments()
        
        return snapshot.documents.compactMap { document in
            try? document.data(as: StudyGroup.self)
        }
        #else
        return []
        #endif
    }
    
    public func createGroup(_ group: StudyGroup) async throws {
        guard isInitialized else { throw ServiceError.notInitialized }
        
        #if canImport(FirebaseCore)
        try await db.collection("groups").document(group.id).setData(from: group)
        logger.info("Created group: \(group.id)", category: .network)
        #endif
    }
    
    public func joinGroup(_ groupId: String, userId: String) async throws {
        guard isInitialized else { throw ServiceError.notInitialized }
        
        #if canImport(FirebaseCore)
        let groupRef = db.collection("groups").document(groupId)
        
        try await db.runTransaction { transaction, errorPointer in
            let groupSnapshot: DocumentSnapshot
            do {
                groupSnapshot = try transaction.getDocument(groupRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            guard var group = try? groupSnapshot.data(as: StudyGroup.self) else {
                let error = NSError(domain: "FirebaseError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Group not found"])
                errorPointer?.pointee = error
                return nil
            }
            
            if !group.memberIds.contains(userId) {
                group.memberIds.append(userId)
                group.memberCount = group.memberIds.count
            }
            
            try transaction.setData(from: group, forDocument: groupRef)
            return nil
        }
        #endif
    }
    
    public func getChallenges() async throws -> [Challenge] {
        guard isInitialized else { throw ServiceError.notInitialized }
        
        #if canImport(FirebaseCore)
        let snapshot = try await db.collection("challenges")
            .order(by: "startDate", descending: true)
            .getDocuments()
        
        return snapshot.documents.compactMap { document in
            try? document.data(as: Challenge.self)
        }
        #else
        return []
        #endif
    }
    
    public func joinChallenge(_ challengeId: String, userId: String) async throws {
        guard isInitialized else { throw ServiceError.notInitialized }
        
        #if canImport(FirebaseCore)
        let challengeRef = db.collection("challenges").document(challengeId)
        
        try await db.runTransaction { transaction, errorPointer in
            let challengeSnapshot: DocumentSnapshot
            do {
                challengeSnapshot = try transaction.getDocument(challengeRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            guard var challenge = try? challengeSnapshot.data(as: Challenge.self) else {
                let error = NSError(domain: "FirebaseError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Challenge not found"])
                errorPointer?.pointee = error
                return nil
            }
            
            if !challenge.participantIds.contains(userId) {
                challenge.participantIds.append(userId)
                challenge.participantCount = challenge.participantIds.count
            }
            
            try transaction.setData(from: challenge, forDocument: challengeRef)
            return nil
        }
        #endif
    }
}

// MARK: - Firestore Extensions

#if canImport(FirebaseCore)
extension CommunityPost: Codable {
    enum CodingKeys: String, CodingKey {
        case id, userId, userName, userAvatar, text, verseReference, groupId, timestamp, likes, comments, isLikedByUser
    }
}

extension StudyGroup: Codable {
    enum CodingKeys: String, CodingKey {
        case id, name, description, memberCount, memberIds, isJoined, lastActivity, icon, color
    }
}

extension Challenge: Codable {
    enum CodingKeys: String, CodingKey {
        case id, title, description, duration, participantCount, participantIds, progress, isJoined, startDate, endDate, icon, color
    }
}

extension Comment: Codable {
    enum CodingKeys: String, CodingKey {
        case id, userId, userName, text, timestamp
    }
}
#endif 