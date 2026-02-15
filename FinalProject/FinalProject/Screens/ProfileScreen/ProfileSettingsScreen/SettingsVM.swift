import Combine
import Foundation

@MainActor
final class SettingsVM: ObservableObject {
    // MARK: - Published Properties
    
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var successMessage: String?
    @Published var currentUser: User?
    
    // MARK: - Private Properties
    
    private let userService: UserServiceProtocol
    private let authService: AuthenticationServiceProtocol
    
    // MARK: - Initialization
    
    init(
        userService: UserServiceProtocol,
        authService: AuthenticationServiceProtocol
    ) {
        self.userService = userService
        self.authService = authService
        fetchCurrentUser()
    }
    
    // MARK: - Public Methods
    
    func fetchCurrentUser() {
        Task { @MainActor in
            do {
                let user = try await userService.fetchUserData()
                self.currentUser = user
            } catch {
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    func updateName(_ name: String) async throws {
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Name cannot be empty"])
        }
         guard name.count >= 2 else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Name must be at least 2 characters"])
        }
        
        isLoading = true
        defer { isLoading = false }

        try await userService.updateUserProfile(displayName: name, photoURL: nil)
        currentUser = try await userService.fetchUserData()
    }
    
    func updatePassword(_ newPassword: String) async throws {
        guard !newPassword.isEmpty else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Password cannot be empty"])
        }
         guard newPassword.count >= 6 else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Password must be at least 6 characters"])
        }
        
        isLoading = true
        defer { isLoading = false }

        do {
            try await authService.updatePassword(newPassword)
        } catch let error as AuthError {
            if case .requiresRecentLogin = error {
                throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: error.localizedDescription])
            }
            throw error
        } catch {
            throw error
        }
    }
    
    func logout() throws {
        try authService.signOut()
    }
}
