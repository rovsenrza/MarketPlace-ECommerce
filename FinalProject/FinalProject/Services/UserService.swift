import FirebaseAuth
import FirebaseFirestore
import Foundation
import UIKit

protocol UserServiceProtocol {
    func fetchUserData() async throws -> User
    func updateUserProfile(displayName: String?, photoURL: String?) async throws
    func updateProfileImage(_ image: UIImage, userId: String) async throws -> String
    func removeProfileImage(userId: String) async throws
    func createUserDocument(_ user: User) async throws
}

final class UserService: UserServiceProtocol {
    private let firestoreService: FirestoreServiceProtocol
    private let storageService: StorageServiceProtocol
    private let authService: AuthenticationServiceProtocol
    
    init(
        firestoreService: FirestoreServiceProtocol,
        storageService: StorageServiceProtocol,
        authService: AuthenticationServiceProtocol
    ) {
        self.firestoreService = firestoreService
        self.storageService = storageService
        self.authService = authService
    }
    
    func fetchUserData() async throws -> User {
        guard let currentUser = authService.currentUser else {
            throw UserServiceError.notAuthenticated
        }
        
        do {
            let user: User = try await firestoreService.getDocument(
                collection: "users",
                documentId: currentUser.uid
            )
            return user
        } catch {
            return currentUser
        }
    }
    
    func updateUserProfile(displayName: String?, photoURL: String?) async throws {
        guard let userId = authService.currentUser?.uid else {
            throw UserServiceError.notAuthenticated
        }
        
        var updateData: [String: Any] = [:]
        
        if let displayName = displayName {
            updateData["displayName"] = displayName
            try await authService.updateDisplayName(displayName)
        }
        
        if let photoURL = photoURL {
            updateData["photoURL"] = photoURL
        }
        
        if !updateData.isEmpty {
            try await firestoreService.updateDocument(
                collection: "users",
                documentId: userId,
                data: updateData
            )
        }
    }
    
    func updateProfileImage(_ image: UIImage, userId: String) async throws -> String {
        let path = "profile_images/\(userId).jpg"
        let downloadURL = try await storageService.uploadImage(image, path: path, compressionQuality: 0.7)
        
        try await firestoreService.setData(
            collection: "users",
            documentId: userId,
            data: ["photoURL": downloadURL],
            merge: true
        )
        
        if let url = URL(string: downloadURL) {
            let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
            changeRequest?.photoURL = url
            try await changeRequest?.commitChanges()
        }
        
        return downloadURL
    }

    func removeProfileImage(userId: String) async throws {
        let path = "profile_images/\(userId).jpg"

        do {
            try await storageService.deleteFile(at: path)
        } catch {}

        try await firestoreService.updateDocument(
            collection: "users",
            documentId: userId,
            data: ["photoURL": FieldValue.delete()]
        )

        if let firebaseUser = Auth.auth().currentUser, firebaseUser.uid == userId {
            let changeRequest = firebaseUser.createProfileChangeRequest()
            changeRequest.photoURL = nil
            try await changeRequest.commitChanges()
        }
    }
    
    func createUserDocument(_ user: User) async throws {
        let userData: [String: Any] = [
            "uid": user.uid,
            "email": user.email,
            "displayName": user.displayName ?? "",
            "photoURL": user.photoURL ?? "",
            "createdAt": user.createdAt
        ]
        
        try await firestoreService.setData(
            collection: "users",
            documentId: user.uid,
            data: userData,
            merge: true
        )
    }
}

enum UserServiceError: LocalizedError {
    case notAuthenticated
    case updateFailed
    
    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "User not authenticated"
        case .updateFailed:
            return "Failed to update user profile"
        }
    }
}
