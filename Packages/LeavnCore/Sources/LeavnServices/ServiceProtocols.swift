import Foundation
import LeavnCore

public protocol CommunityServiceProtocol: ServiceProtocol, Sendable {
    func getPosts(limit: Int, offset: Int) async throws -> [CommunityPost]
    func createPost(_ post: CommunityPost) async throws
    func likePost(_ postId: String, userId: String) async throws
    func addComment(to postId: String, comment: Comment) async throws
    func getGroups() async throws -> [StudyGroup]
    func createGroup(_ group: StudyGroup) async throws
    func joinGroup(_ groupId: String, userId: String) async throws
    func getChallenges() async throws -> [Challenge]
    func joinChallenge(_ challengeId: String, userId: String) async throws
} 