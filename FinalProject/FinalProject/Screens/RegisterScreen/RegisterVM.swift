import AuthenticationServices
import Combine
import Foundation
import UIKit

@MainActor
final class RegisterVM {
    @Published var fullName: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var isAuthenticated: Bool = false
    
    private let authService: AuthenticationServiceProtocol
    private let userService: UserServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Validation
    
    var isFullNameValid: Bool {
        return fullName.trimmingCharacters(in: .whitespaces).count >= 2
    }
    
    var isEmailValid: Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    var isPasswordValid: Bool {
        return password.count >= 6
    }
    
    var passwordStrength: PasswordStrength {
        if password.isEmpty {
            return .none
        } else if password.count < 6 {
            return .weak
        } else if password.count >= 6 && password.count < 10 {
            return .medium
        } else {
            let hasUppercase = password.contains(where: { $0.isUppercase })
            let hasLowercase = password.contains(where: { $0.isLowercase })
            let hasNumber = password.contains(where: { $0.isNumber })
            
            if hasUppercase && hasLowercase && hasNumber {
                return .strong
            } else {
                return .medium
            }
        }
    }
    
    var isFormValid: Bool {
        return isFullNameValid && isEmailValid && isPasswordValid
    }
    
    // MARK: - Initialization
    
    init(
        authService: AuthenticationServiceProtocol,
        userService: UserServiceProtocol
    ) {
        self.authService = authService
        self.userService = userService
        setupBindings()
    }
    
    // MARK: - Setup
    
    private func setupBindings() {
        Publishers.CombineLatest3($fullName, $email, $password)
            .sink { [weak self] _, _, _ in
                self?.errorMessage = nil
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Actions
    
    @MainActor
    func signUp() async {
        guard isFormValid else {
            if !isFullNameValid {
                errorMessage = "Full name must be at least 2 characters"
            } else if !isEmailValid {
                errorMessage = "Please enter a valid email address"
            } else if !isPasswordValid {
                errorMessage = "Password must be at least 6 characters"
            }
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let result = try await authService.signUp(
                email: email,
                password: password,
                fullName: fullName.trimmingCharacters(in: .whitespaces)
            )
            try await userService.createUserDocument(result.user)
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

// MARK: - Password Strength Enum

enum PasswordStrength {
    case none
    case weak
    case medium
    case strong
    
    var description: String {
        switch self {
        case .none:
            return ""
        case .weak:
            return "Weak"
        case .medium:
            return "Medium"
        case .strong:
            return "Strong"
        }
    }
    
    var color: UIColor {
        switch self {
        case .none:
            return .systemGray
        case .weak:
            return .systemRed
        case .medium:
            return .systemOrange
        case .strong:
            return .systemGreen
        }
    }
}
