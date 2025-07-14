import AuthenticationServices
import Foundation

@MainActor
public protocol PasskeyAuthenticationServiceProtocol {
    func signUpWithPasskey(username: String, userID: String) async throws
    func signInWithPasskey() async throws
    func isPasskeyAvailable() -> Bool
}

@MainActor
public final class PasskeyAuthenticationService: NSObject, PasskeyAuthenticationServiceProtocol {
    private let relyingPartyIdentifier = "leavn.app"
    private var currentAuthController: ASAuthorizationController?
    private var registrationContinuation: CheckedContinuation<Void, Error>?
    private var authenticationContinuation: CheckedContinuation<Void, Error>?
    
    public override init() {
        super.init()
    }
    
    public func isPasskeyAvailable() -> Bool {
        if #available(iOS 16.0, *) {
            return true
        } else {
            return false
        }
    }
    
    public func signUpWithPasskey(username: String, userID: String) async throws {
        guard isPasskeyAvailable() else {
            throw PasskeyError.notAvailable
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            self.registrationContinuation = continuation
            
            Task { @MainActor in
                // In production, fetch from server
                let challenge = generateMockChallenge()
                    
                    let provider = ASAuthorizationPlatformPublicKeyCredentialProvider(
                        relyingPartyIdentifier: relyingPartyIdentifier
                    )
                    
                    let registrationRequest = provider.createCredentialRegistrationRequest(
                        challenge: challenge,
                        name: username,
                        userID: Data(userID.utf8)
                    )
                    
                    // Configure request options
                    registrationRequest.displayName = username
                    registrationRequest.userVerificationPreference = .preferred
                    
                    let authController = ASAuthorizationController(
                        authorizationRequests: [registrationRequest]
                    )
                    authController.delegate = self
                    authController.presentationContextProvider = self
                    
                    self.currentAuthController = authController
                    authController.performRequests()
            }
        }
    }
    
    public func signInWithPasskey() async throws {
        guard isPasskeyAvailable() else {
            throw PasskeyError.notAvailable
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            self.authenticationContinuation = continuation
            
            Task { @MainActor in
                // In production, fetch from server
                let challenge = generateMockChallenge()
                    
                    let provider = ASAuthorizationPlatformPublicKeyCredentialProvider(
                        relyingPartyIdentifier: relyingPartyIdentifier
                    )
                    
                    let assertionRequest = provider.createCredentialAssertionRequest(
                        challenge: challenge
                    )
                    
                    // Allow sign in with passkey from anywhere
                    assertionRequest.userVerificationPreference = .preferred
                    
                    let authController = ASAuthorizationController(
                        authorizationRequests: [assertionRequest]
                    )
                    authController.delegate = self
                    authController.presentationContextProvider = self
                    
                    self.currentAuthController = authController
                    authController.performRequests()
            }
        }
    }
    
    private func generateMockChallenge() -> Data {
        // In production, this should come from your server
        let challengeString = UUID().uuidString
        return Data(challengeString.utf8)
    }
    
    private func handleRegistrationCredential(_ credential: ASAuthorizationPlatformPublicKeyCredentialRegistration) {
        // In production, send these to your server
        let credentialID = credential.credentialID
        _ = credential.rawClientDataJSON
        _ = credential.rawAttestationObject
        
        // Mock successful registration
        print("Passkey registered successfully")
        print("Credential ID: \(credentialID.base64EncodedString())")
        
        // Store credential ID for future use
        UserDefaults.standard.set(credentialID.base64EncodedString(), forKey: "passkeyCredentialID")
        
        registrationContinuation?.resume()
        registrationContinuation = nil
    }
    
    private func handleAuthenticationCredential(_ credential: ASAuthorizationPlatformPublicKeyCredentialAssertion) {
        // In production, send these to your server for verification
        let userID = credential.userID
        
        // Mock successful authentication
        print("Passkey authentication successful")
        if let userID = userID {
            print("User ID: \(String(data: userID, encoding: .utf8) ?? "Unknown")")
        }
        
        authenticationContinuation?.resume()
        authenticationContinuation = nil
    }
}

// MARK: - ASAuthorizationControllerDelegate
extension PasskeyAuthenticationService: ASAuthorizationControllerDelegate {
    public func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        switch authorization.credential {
        case let credential as ASAuthorizationPlatformPublicKeyCredentialRegistration:
            handleRegistrationCredential(credential)
            
        case let credential as ASAuthorizationPlatformPublicKeyCredentialAssertion:
            handleAuthenticationCredential(credential)
            
        default:
            let error = PasskeyError.unexpectedCredentialType
            registrationContinuation?.resume(throwing: error)
            authenticationContinuation?.resume(throwing: error)
        }
    }
    
    public func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithError error: Error
    ) {
        let passkeyError = PasskeyError.authorizationFailed(underlying: error)
        registrationContinuation?.resume(throwing: passkeyError)
        authenticationContinuation?.resume(throwing: passkeyError)
        
        registrationContinuation = nil
        authenticationContinuation = nil
    }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding
extension PasskeyAuthenticationService: ASAuthorizationControllerPresentationContextProviding {
    public func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        // Return the key window
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            fatalError("No window found")
        }
        return window
    }
}

// MARK: - PasskeyError
public enum PasskeyError: LocalizedError {
    case notAvailable
    case unexpectedCredentialType
    case authorizationFailed(underlying: Error)
    
    public var errorDescription: String? {
        switch self {
        case .notAvailable:
            return "Passkeys are not available on this device. iOS 16 or later is required."
        case .unexpectedCredentialType:
            return "Received unexpected credential type"
        case .authorizationFailed(let error):
            return "Passkey authorization failed: \(error.localizedDescription)"
        }
    }
}