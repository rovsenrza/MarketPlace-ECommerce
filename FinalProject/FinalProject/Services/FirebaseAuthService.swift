import AuthenticationServices
import CryptoKit
import FirebaseAuth
import FirebaseCore
import Foundation
import GoogleSignIn

// MARK: - Authentication Protocol

protocol AuthenticationServiceProtocol {
    var currentUser: User? { get }
    var isAuthenticated: Bool { get }
    
    func signUp(email: String, password: String, fullName: String?) async throws -> AuthResult
    func signIn(email: String, password: String) async throws -> AuthResult
    func signInWithGoogle(presentingViewController: UIViewController) async throws -> AuthResult
    func signInWithApple(nonce: String, idTokenString: String, fullName: PersonNameComponents?) async throws -> AuthResult
    func signOut() throws
    func resetPassword(email: String) async throws
    func updateDisplayName(_ displayName: String) async throws
    func updatePassword(_ newPassword: String) async throws
    func deleteAccount() async throws
}

final class FirebaseAuthService: AuthenticationServiceProtocol {
    private let auth: Auth
    
    var currentUser: User? {
        guard let firebaseUser = auth.currentUser else { return nil }

        return mapUser(firebaseUser)
    }
    
    var isAuthenticated: Bool {
        return auth.currentUser != nil
    }
    
    init(auth: Auth = Auth.auth()) {
        self.auth = auth
    }
    
    func signUp(email: String, password: String, fullName: String?) async throws -> AuthResult {
        do {
            let authResult = try await auth.createUser(withEmail: email, password: password)
            
            if let fullName = fullName {
                let changeRequest = authResult.user.createProfileChangeRequest()
                changeRequest.displayName = fullName
                try await changeRequest.commitChanges()
            }
            
            return AuthResult(user: mapUser(authResult.user))
        } catch {
            throw mapFirebaseError(error)
        }
    }
    
    func signIn(email: String, password: String) async throws -> AuthResult {
        do {
            let authResult = try await auth.signIn(withEmail: email, password: password)
            return AuthResult(user: mapUser(authResult.user))
        } catch {
            throw mapFirebaseError(error)
        }
    }
    
    func signOut() throws {
        do {
            try auth.signOut()
        } catch {
            throw AuthError.unknown("Failed to sign out: \(error.localizedDescription)")
        }
    }
    
    func resetPassword(email: String) async throws {
        do {
            try await auth.sendPasswordReset(withEmail: email)
        } catch {
            throw mapFirebaseError(error)
        }
    }
    
    func updateDisplayName(_ displayName: String) async throws {
        guard let user = auth.currentUser else {
            throw AuthError.userNotFound
        }
        
        do {
            let changeRequest = user.createProfileChangeRequest()
            changeRequest.displayName = displayName
            try await changeRequest.commitChanges()
        } catch {
            throw AuthError.unknown("Failed to update display name: \(error.localizedDescription)")
        }
    }
    
    func updatePassword(_ newPassword: String) async throws {
        guard let user = auth.currentUser else {
            throw AuthError.userNotFound
        }
        
        do {
            try await user.updatePassword(to: newPassword)
        } catch {
            throw error
        }
    }
    
    func deleteAccount() async throws {
        guard let user = auth.currentUser else {
            throw AuthError.userNotFound
        }
        
        do {
            try await user.delete()
        } catch {
            throw mapFirebaseError(error)
        }
    }
    
    // MARK: - Google Sign-In
    
    func signInWithGoogle(presentingViewController: UIViewController) async throws -> AuthResult {
        guard let clientID = auth.app?.options.clientID else {
            throw AuthError.unknown("Missing Google Client ID")
        }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        do {
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController)
            let user = result.user
            
            guard let idToken = user.idToken?.tokenString else {
                throw AuthError.unknown("Failed to get ID token from Google")
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
            let authResult = try await auth.signIn(with: credential)
            
            return AuthResult(user: mapUser(authResult.user))
        } catch {
            throw AuthError.unknown("Google Sign-In failed: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Apple Sign-In
    
    func signInWithApple(nonce: String, idTokenString: String, fullName: PersonNameComponents?) async throws -> AuthResult {
        let credential = OAuthProvider.appleCredential(
            withIDToken: idTokenString,
            rawNonce: nonce,
            fullName: fullName
        )
        
        do {
            let authResult = try await auth.signIn(with: credential)
            
            if let fullName = fullName,
               authResult.user.displayName == nil
            {
                let changeRequest = authResult.user.createProfileChangeRequest()
                let displayName = [fullName.givenName, fullName.familyName]
                    .compactMap { $0 }
                    .joined(separator: " ")
                if !displayName.isEmpty {
                    changeRequest.displayName = displayName
                    try await changeRequest.commitChanges()
                }
            }
            
            return AuthResult(user: mapUser(authResult.user))
        } catch {
            throw mapFirebaseError(error)
        }
    }
    
    // MARK: - Helper Methods
    
    private func mapFirebaseError(_ error: Error) -> AuthError {
        guard let errorCode = AuthErrorCode(rawValue: (error as NSError).code) else {
            return .unknown(error.localizedDescription)
        }
        
        switch errorCode {
        case .invalidEmail:
            return .invalidEmail
        case .wrongPassword:
            return .wrongPassword
        case .userNotFound:
            return .userNotFound
        case .emailAlreadyInUse:
            return .emailAlreadyInUse
        case .weakPassword:
            return .weakPassword
        case .networkError:
            return .networkError
        case .requiresRecentLogin:
            return .requiresRecentLogin
        default:
            return .unknown(error.localizedDescription)
        }
    }

    private func mapUser(_ firebaseUser: FirebaseAuth.User) -> User {
        User(
            uid: firebaseUser.uid,
            email: firebaseUser.email ?? "",
            displayName: firebaseUser.displayName,
            createdAt: firebaseUser.metadata.creationDate ?? Date(),
            photoURL: firebaseUser.photoURL?.absoluteString
        )
    }
}
