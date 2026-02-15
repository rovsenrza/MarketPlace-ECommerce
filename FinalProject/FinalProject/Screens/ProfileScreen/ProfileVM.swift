import Combine
import Foundation
import UIKit

@MainActor
final class ProfileVM: ObservableObject {
    @Published var user: User?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let userService: UserServiceProtocol
    private let authService: AuthenticationServiceProtocol
    
    init(
        userService: UserServiceProtocol,
        authService: AuthenticationServiceProtocol
    ) {
        self.userService = userService
        self.authService = authService
    }
    
    func fetchUserData() {
        Task {
            isLoading = true
            errorMessage = nil
            
            do {
                user = try await userService.fetchUserData()
                
                if user == nil, let currentUser = authService.currentUser {
                    user = currentUser
                    try await userService.createUserDocument(currentUser)
                }
            } catch {
                errorMessage = error.localizedDescription
            }
            
            isLoading = false
        }
    }
    
    func updateProfileImage(_ image: UIImage) async throws -> String {
        guard let userId = authService.currentUser?.uid else {
            throw UserServiceError.notAuthenticated
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let urlString = try await userService.updateProfileImage(image, userId: userId)
            
            fetchUserData()
            
            isLoading = false
            return urlString
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
            throw error
        }
    }

    func removeProfileImage() async throws {
        guard let userId = authService.currentUser?.uid else {
            throw UserServiceError.notAuthenticated
        }

        isLoading = true
        errorMessage = nil

        do {
            try await userService.removeProfileImage(userId: userId)
            fetchUserData()
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
            throw error
        }
    }

    func signOut() throws {
        try authService.signOut()
    }
}
