import Foundation
import LeavnCore

#if canImport(FirebaseCore)
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
#endif

// Community models are now imported from LeavnCore.SharedTypes

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
            throw ServiceError.system(.notInitialized)
        }
        
        isInitialized = true
        logger.info("Firebase Community Service initialized", category: .network)
        #else
        throw ServiceError.system(.notInitialized)
        #endif
    }
    
    // MARK: - CommunityServiceProtocol Implementation
    
    public func getPosts(limit: Int = 20, offset: Int = 0) async throws -> [CommunityPost] {
        guard isInitialized else {
            throw ServiceError.system(.notInitialized)
        }
        
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
        guard isInitialized else {
            throw ServiceError.system(.notInitialized)
        }
        
        #if canImport(FirebaseCore)
        try await db.collection("posts").document(post.id).setData(from: post)
        logger.info("Created post: \(post.id)", category: .network)
        #endif
    }
    
    public func likePost(_ postId: String, userId: String) async throws {
        guard isInitialized else {
            throw ServiceError.system(.notInitialized)
        }
        
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
        guard isInitialized else {
            throw ServiceError.system(.notInitialized)
        }
        
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
        guard isInitialized else {
            throw ServiceError.system(.notInitialized)
        }
        
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
        guard isInitialized else {
            throw ServiceError.system(.notInitialized)
        }
        
        #if canImport(FirebaseCore)
        try await db.collection("groups").document(group.id).setData(from: group)
        logger.info("Created group: \(group.id)", category: .network)
        #endif
    }
    
    public func joinGroup(_ groupId: String, userId: String) async throws {
        guard isInitialized else {
            throw ServiceError.system(.notInitialized)
        }
        
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
        guard isInitialized else {
            throw ServiceError.system(.notInitialized)
        }
        
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
        guard isInitialized else {
            throw ServiceError.system(.notInitialized)
        }
        
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