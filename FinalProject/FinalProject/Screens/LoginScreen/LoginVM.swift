import AuthenticationServices
import Combine
import Foundation
import UIKit

@MainActor
final class LoginVM {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var isAuthenticated: Bool = false
    
    private let authService: AuthenticationServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    var isEmailValid: Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    var isPasswordValid: Bool {
        return password.count >= 6
    }
    
    var isFormValid: Bool {
        return !email.isEmpty && !password.isEmpty && isEmailValid && isPasswordValid
    }
    
    // MARK: - Initialization
    
    init(authService: AuthenticationServiceProtocol) {
        self.authService = authService
        setupBindings()
    }
    
    // MARK: - Setup
    
    private func setupBindings() {
        Publishers.CombineLatest($email, $password)
            .sink { [weak self] _, _ in
                self?.errorMessage = nil
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Actions
    
    @MainActor
    func login() async {
        guard isFormValid else {
            errorMessage = "Please enter valid email and password"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            _ = try await authService.signIn(email: email, password: password)
            isAuthenticated = true
            
        } catch let error as AuthError {
            errorMessage = error.localizedDescription
            isAuthenticated = false
        } catch {
            errorMessage = "An unexpected error occurred"
            isAuthenticated = false
        }
        
        isLoading = false
    }
    
    @MainActor
    func forgotPassword() async {
        guard !email.isEmpty, isEmailValid else {
            errorMessage = "Please enter a valid email address"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            try await authService.resetPassword(email: email)
            errorMessage = "Password reset email sent successfully"
        } catch let error as AuthError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = "Failed to send password reset email"
        }
        
        isLoading = false
    }
    
    func clearError() {
        errorMessage = nil
    }
    
    // MARK: - Social Sign-In
    
    @MainActor
    func signInWithGoogle(presentingViewController: UIViewController) async {
        isLoading = true
        errorMessage = nil
        
        do {
            _ = try await authService.signInWithGoogle(presentingViewController: presentingViewController)
            isAuthenticated = true
        } catch let error as AuthError {
            errorMessage = error.localizedDescription
            isAuthenticated = false
        } catch {
            errorMessage = "Google Sign-In failed: \(error.localizedDescription)"
            isAuthenticated = false
        }
        
        isLoading = false
    }
    
    @MainActor
    func signInWithApple() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let helper = AppleSignInHelper()
            let (nonce, credential) = try await helper.signIn()
            
            guard let idTokenData = credential.identityToken,
                  let idTokenString = String(data: idTokenData, encoding: .utf8)
            else {
                errorMessage = "Failed to get Apple ID token"
                isLoading = false
                return
            }
            
            _ = try await authService.signInWithApple(
                nonce: nonce,
                idTokenString: idTokenString,
                fullName: credential.fullName
            )
            
            isAuthenticated = true
        } catch let error as AuthError {
            errorMessage = error.localizedDescription
            isAuthenticated = false
        } catch {
            errorMessage = "Apple Sign-In failed: \(error.localizedDescription)"
            isAuthenticated = false
        }
        
        isLoading = false
    }
}
