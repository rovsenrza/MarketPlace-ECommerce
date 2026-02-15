import Foundation

struct LoginBuilder {
    static func build(
        services: AppServices = ServiceContainer.shared,
        onAuthenticated: (() -> Void)? = nil,
        onRegisterRequested: (() -> Void)? = nil
    ) -> LoginVC {
        let vm = LoginVM(authService: services.authService)
        return LoginVC(
            vm: vm,
            onAuthenticated: onAuthenticated,
            onRegisterRequested: onRegisterRequested
        )
    }
}
