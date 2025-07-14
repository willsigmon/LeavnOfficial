import Foundation

import Alamofire

// MARK: - Auth API Client
final class AuthAPIClient: BaseAPIClient {
    
    // MARK: - Authentication Endpoints
    func signIn(email: String, password: String) async throws -> AuthResponseDTO {
        let endpoint = Endpoint(
            path: "/auth/signin",
            method: .post,
            parameters: [
                "email": email,
                "password": password
            ],
            encoding: JSONEncoding.default
        )
        
        return try await networkService.request(endpoint)
    }
    
    func signUp(email: String, password: String, displayName: String) async throws -> AuthResponseDTO {
        let endpoint = Endpoint(
            path: "/auth/signup",
            method: .post,
            parameters: [
                "email": email,
                "password": password,
                "displayName": displayName
            ],
            encoding: JSONEncoding.default
        )
        
        return try await networkService.request(endpoint)
    }
    
    func signInWithApple(
        identityToken: String,
        nonce: String,
        fullName: String? = nil,
        email: String? = nil
    ) async throws -> AuthResponseDTO {
        var parameters: [String: Any] = [
            "identityToken": identityToken,
            "nonce": nonce
        ]
        
        if let fullName = fullName {
            parameters["fullName"] = fullName
        }
        
        if let email = email {
            parameters["email"] = email
        }
        
        let endpoint = Endpoint(
            path: "/auth/apple",
            method: .post,
            parameters: parameters,
            encoding: JSONEncoding.default
        )
        
        return try await networkService.request(endpoint)
    }
    
    func signInWithGoogle(idToken: String) async throws -> AuthResponseDTO {
        let endpoint = Endpoint(
            path: "/auth/google",
            method: .post,
            parameters: [
                "idToken": idToken
            ],
            encoding: JSONEncoding.default
        )
        
        return try await networkService.request(endpoint)
    }
    
    func signOut() async throws {
        let endpoint = Endpoint(
            path: "/auth/signout",
            method: .post
        )
        
        _ = try await networkService.request(endpoint)
    }
    
    // MARK: - Session Management
    func refreshToken(refreshToken: String) async throws -> AuthSessionDTO {
        let endpoint = Endpoint(
            path: "/auth/refresh",
            method: .post,
            parameters: [
                "refreshToken": refreshToken
            ],
            encoding: JSONEncoding.default
        )
        
        return try await networkService.request(endpoint)
    }
    
    // MARK: - Password Management
    func resetPassword(email: String) async throws {
        let endpoint = Endpoint(
            path: "/auth/reset-password",
            method: .post,
            parameters: [
                "email": email
            ],
            encoding: JSONEncoding.default
        )
        
        _ = try await networkService.request(endpoint)
    }
    
    func updatePassword(currentPassword: String, newPassword: String) async throws {
        let endpoint = Endpoint(
            path: "/auth/password",
            method: .patch,
            parameters: [
                "currentPassword": currentPassword,
                "newPassword": newPassword
            ],
            encoding: JSONEncoding.default
        )
        
        _ = try await networkService.request(endpoint)
    }
    
    func verifyPassword(password: String) async throws -> Bool {
        let endpoint = Endpoint(
            path: "/auth/verify-password",
            method: .post,
            parameters: [
                "password": password
            ],
            encoding: JSONEncoding.default
        )
        
        let response: VerifyPasswordResponseDTO = try await networkService.request(endpoint)
        return response.isValid
    }
    
    // MARK: - Profile Management
    func updateProfile(displayName: String?, photoURL: URL?) async throws -> AuthUserDTO {
        var parameters: [String: Any] = [:]
        
        if let displayName = displayName {
            parameters["displayName"] = displayName
        }
        
        if let photoURL = photoURL {
            parameters["photoURL"] = photoURL.absoluteString
        }
        
        let endpoint = Endpoint(
            path: "/auth/profile",
            method: .patch,
            parameters: parameters,
            encoding: JSONEncoding.default
        )
        
        return try await networkService.request(endpoint)
    }
    
    func uploadProfilePhoto(imageData: Data) async throws -> URL {
        let endpoint = Endpoint(
            path: "/auth/profile/photo",
            method: .post
        )
        
        let response: UploadPhotoResponseDTO = try await networkService.upload(endpoint, data: imageData)
        guard let url = URL(string: response.photoURL) else {
            throw LeavnError.decodingError(underlying: NSError(domain: "Invalid URL", code: -1))
        }
        
        return url
    }
    
    func deleteAccount() async throws {
        let endpoint = Endpoint(
            path: "/auth/account",
            method: .delete
        )
        
        _ = try await networkService.request(endpoint)
    }
    
    // MARK: - Email Verification
    func sendEmailVerification() async throws {
        let endpoint = Endpoint(
            path: "/auth/email/verification",
            method: .post
        )
        
        _ = try await networkService.request(endpoint)
    }
    
    func verifyEmail(code: String) async throws {
        let endpoint = Endpoint(
            path: "/auth/email/verify",
            method: .post,
            parameters: [
                "code": code
            ],
            encoding: JSONEncoding.default
        )
        
        _ = try await networkService.request(endpoint)
    }
    
    func resendEmailVerification() async throws {
        let endpoint = Endpoint(
            path: "/auth/email/verification/resend",
            method: .post
        )
        
        _ = try await networkService.request(endpoint)
    }
    
    // MARK: - Account Recovery
    func sendPasswordResetEmail(email: String) async throws {
        let endpoint = Endpoint(
            path: "/auth/password/reset",
            method: .post,
            parameters: [
                "email": email
            ],
            encoding: JSONEncoding.default
        )
        
        _ = try await networkService.request(endpoint)
    }
    
    func verifyPasswordResetCode(email: String, code: String) async throws -> String {
        let endpoint = Endpoint(
            path: "/auth/password/reset/verify",
            method: .post,
            parameters: [
                "email": email,
                "code": code
            ],
            encoding: JSONEncoding.default
        )
        
        let response: PasswordResetVerifyResponseDTO = try await networkService.request(endpoint)
        return response.resetToken
    }
    
    func confirmPasswordReset(email: String, code: String, newPassword: String) async throws {
        let endpoint = Endpoint(
            path: "/auth/password/reset/confirm",
            method: .post,
            parameters: [
                "email": email,
                "code": code,
                "newPassword": newPassword
            ],
            encoding: JSONEncoding.default
        )
        
        _ = try await networkService.request(endpoint)
    }
    
    // MARK: - Account Linking
    func linkAppleAccount(identityToken: String, nonce: String) async throws {
        let endpoint = Endpoint(
            path: "/auth/link/apple",
            method: .post,
            parameters: [
                "identityToken": identityToken,
                "nonce": nonce
            ],
            encoding: JSONEncoding.default
        )
        
        _ = try await networkService.request(endpoint)
    }
    
    func linkGoogleAccount(idToken: String) async throws {
        let endpoint = Endpoint(
            path: "/auth/link/google",
            method: .post,
            parameters: [
                "idToken": idToken
            ],
            encoding: JSONEncoding.default
        )
        
        _ = try await networkService.request(endpoint)
    }
    
    func unlinkProvider(provider: String) async throws {
        let endpoint = Endpoint(
            path: "/auth/unlink/\\(provider)",
            method: .delete
        )
        
        _ = try await networkService.request(endpoint)
    }
    
    // MARK: - Security
    func getSignInMethods(email: String) async throws -> [String] {
        let endpoint = Endpoint(
            path: "/auth/signin-methods",
            parameters: [
                "email": email
            ]
        )
        
        let response: SignInMethodsResponseDTO = try await networkService.request(endpoint)
        return response.methods
    }
    
    func enableTwoFactorAuth() async throws {
        let endpoint = Endpoint(
            path: "/auth/2fa/enable",
            method: .post
        )
        
        _ = try await networkService.request(endpoint)
    }
    
    func disableTwoFactorAuth() async throws {
        let endpoint = Endpoint(
            path: "/auth/2fa/disable",
            method: .post
        )
        
        _ = try await networkService.request(endpoint)
    }
    
    func verifyTwoFactorCode(code: String) async throws {
        let endpoint = Endpoint(
            path: "/auth/2fa/verify",
            method: .post,
            parameters: [
                "code": code
            ],
            encoding: JSONEncoding.default
        )
        
        _ = try await networkService.request(endpoint)
    }
}

// MARK: - Data Transfer Objects
struct AuthResponseDTO: Codable {
    let user: AuthUserDTO
    let session: AuthSessionDTO
}

struct AuthUserDTO: Codable {
    let id: String
    let email: String
    let displayName: String
    let photoURL: URL?
    let isEmailVerified: Bool
    let authProvider: String
    let createdAt: Date
    let lastSignInAt: Date?
}

struct AuthSessionDTO: Codable {
    let accessToken: String
    let refreshToken: String
    let expiresAt: Date
}

struct VerifyPasswordResponseDTO: Codable {
    let isValid: Bool
}

struct UploadPhotoResponseDTO: Codable {
    let photoURL: String
}

struct PasswordResetVerifyResponseDTO: Codable {
    let resetToken: String
}

struct SignInMethodsResponseDTO: Codable {
    let methods: [String]
}