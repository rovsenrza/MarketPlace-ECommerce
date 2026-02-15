import Foundation

enum AuthError: LocalizedError {
    case invalidEmail
    case wrongPassword
    case userNotFound
    case emailAlreadyInUse
    case weakPassword
    case networkError
    case requiresRecentLogin
    case unknown(String)

    var errorDescription: String? {
        switch self {
        case .invalidEmail:
            return "Invalid email address format."
        case .wrongPassword:
            return "Incorrect password."
        case .userNotFound:
            return "No account found with this email."
        case .emailAlreadyInUse:
            return "This email is already registered."
        case .weakPassword:
            return "Password must be at least 6 characters."
        case .networkError:
            return "Network connection error. Please try again."
        case .requiresRecentLogin:
            return "Please log out and log in again to update your password."
        case .unknown(let message):
            return message
        }
    }
}

nonisolated struct User: Codable, Equatable, Sendable {
    let uid: String
    let email: String
    var displayName: String?
    let createdAt: Date
    var photoURL: String?

    init(
        uid: String,
        email: String,
        displayName: String? = nil,
        createdAt: Date = Date(),
        photoURL: String? = nil
    ) {
        self.uid = uid
        self.email = email
        self.displayName = displayName
        self.createdAt = createdAt
        self.photoURL = photoURL
    }
}

struct AuthResult {
    let user: User

    init(user: User) {
        self.user = user
    }
}
