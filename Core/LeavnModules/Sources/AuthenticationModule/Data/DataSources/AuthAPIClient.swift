import Foundation

// MARK: - Auth API Client
final class AuthAPIClient {
    private let baseURL = "https://api.leavn.com"
    private let session = URLSession.shared
    
    // MARK: - Helper Methods
    private func performRequest<T: Codable>(_ endpoint: String, method: String = "GET", parameters: [String: Any]? = nil, responseType: T.Type) async throws -> T {
        let url = URL(string: "\(baseURL)\(endpoint)")!
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let parameters = parameters {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
        }
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw LeavnError.networkError(message: "Network request failed")
        }
        
        return try JSONDecoder().decode(T.self, from: data)
    }
    
    private func performVoidRequest(_ endpoint: String, method: String = "GET", parameters: [String: Any]? = nil) async throws {
        let url = URL(string: "\(baseURL)\(endpoint)")!
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let parameters = parameters {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
        }
        
        let (_, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw LeavnError.networkError(message: "Network request failed")
        }
    }
    
    // MARK: - Authentication Endpoints
    func signIn(email: String, password: String) async throws -> AuthResponseDTO {
        return try await performRequest("/auth/signin", method: "POST", parameters: [
            "email": email,
            "password": password
        ], responseType: AuthResponseDTO.self)
    }
    
    func signUp(email: String, password: String, displayName: String) async throws -> AuthResponseDTO {
        return try await performRequest("/auth/signup", method: "POST", parameters: [
            "email": email,
            "password": password,
            "displayName": displayName
        ], responseType: AuthResponseDTO.self)
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
        
        return try await performRequest("/auth/apple", method: "POST", parameters: parameters, responseType: AuthResponseDTO.self)
    }
    
    func signInWithGoogle(idToken: String) async throws -> AuthResponseDTO {
        return try await performRequest("/auth/google", method: "POST", parameters: [
            "idToken": idToken
        ], responseType: AuthResponseDTO.self)
    }
    
    func signOut() async throws {
        try await performVoidRequest("/auth/signout", method: "POST")
    }
    
    // MARK: - Session Management
    func refreshToken(refreshToken: String) async throws -> AuthSessionDTO {
        return try await performRequest("/auth/refresh", method: "POST", parameters: [
            "refreshToken": refreshToken
        ], responseType: AuthSessionDTO.self)
    }
    
    // MARK: - Password Management
    func resetPassword(email: String) async throws {
        try await performVoidRequest("/auth/reset-password", method: "POST", parameters: [
            "email": email
        ])
    }
    
    func updatePassword(currentPassword: String, newPassword: String) async throws {
        try await performVoidRequest("/auth/password", method: "PATCH", parameters: [
            "currentPassword": currentPassword,
            "newPassword": newPassword
        ])
    }
    
    func verifyPassword(password: String) async throws -> Bool {
        let response: VerifyPasswordResponseDTO = try await performRequest("/auth/verify-password", method: "POST", parameters: [
            "password": password
        ], responseType: VerifyPasswordResponseDTO.self)
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
        
        return try await performRequest("/auth/profile", method: "PATCH", parameters: parameters, responseType: AuthUserDTO.self)
    }
    
    func uploadProfilePhoto(imageData: Data) async throws -> URL {
        // For file uploads, we need a different approach
        let url = URL(string: "\(baseURL)/auth/profile/photo")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"photo\"; filename=\"photo.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw LeavnError.networkError(message: "Upload failed")
        }
        
        let uploadResponse = try JSONDecoder().decode(UploadPhotoResponseDTO.self, from: data)
        guard let url = URL(string: uploadResponse.photoURL) else {
            throw LeavnError.decodingError(underlying: NSError(domain: "Invalid URL", code: -1))
        }
        
        return url
    }
    
    func deleteAccount() async throws {
        try await performVoidRequest("/auth/account", method: "DELETE")
    }
    
    // MARK: - Email Verification
    func sendEmailVerification() async throws {
        try await performVoidRequest("/auth/email/verification", method: "POST")
    }
    
    func verifyEmail(code: String) async throws {
        try await performVoidRequest("/auth/email/verify", method: "POST", parameters: [
            "code": code
        ])
    }
    
    func resendEmailVerification() async throws {
        try await performVoidRequest("/auth/email/verification/resend", method: "POST")
    }
    
    // MARK: - Account Recovery
    func sendPasswordResetEmail(email: String) async throws {
        try await performVoidRequest("/auth/password/reset", method: "POST", parameters: [
            "email": email
        ])
    }
    
    func verifyPasswordResetCode(email: String, code: String) async throws -> String {
        let response: PasswordResetVerifyResponseDTO = try await performRequest("/auth/password/reset/verify", method: "POST", parameters: [
            "email": email,
            "code": code
        ], responseType: PasswordResetVerifyResponseDTO.self)
        return response.resetToken
    }
    
    func confirmPasswordReset(email: String, code: String, newPassword: String) async throws {
        try await performVoidRequest("/auth/password/reset/confirm", method: "POST", parameters: [
            "email": email,
            "code": code,
            "newPassword": newPassword
        ])
    }
    
    // MARK: - Account Linking
    func linkAppleAccount(identityToken: String, nonce: String) async throws {
        try await performVoidRequest("/auth/link/apple", method: "POST", parameters: [
            "identityToken": identityToken,
            "nonce": nonce
        ])
    }
    
    func linkGoogleAccount(idToken: String) async throws {
        try await performVoidRequest("/auth/link/google", method: "POST", parameters: [
            "idToken": idToken
        ])
    }
    
    func unlinkProvider(provider: String) async throws {
        try await performVoidRequest("/auth/unlink/\(provider)", method: "DELETE")
    }
    
    // MARK: - Security
    func getSignInMethods(email: String) async throws -> [String] {
        let response: SignInMethodsResponseDTO = try await performRequest("/auth/signin-methods", parameters: [
            "email": email
        ], responseType: SignInMethodsResponseDTO.self)
        return response.methods
    }
    
    func enableTwoFactorAuth() async throws {
        try await performVoidRequest("/auth/2fa/enable", method: "POST")
    }
    
    func disableTwoFactorAuth() async throws {
        try await performVoidRequest("/auth/2fa/disable", method: "POST")
    }
    
    func verifyTwoFactorCode(code: String) async throws {
        try await performVoidRequest("/auth/2fa/verify", method: "POST", parameters: [
            "code": code
        ])
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