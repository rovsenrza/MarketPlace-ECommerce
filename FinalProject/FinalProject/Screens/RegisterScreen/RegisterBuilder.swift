import Foundation

struct RegisterBuilder {
    static func build(
        services: AppServices = ServiceContainer.shared,
        onAuthenticated: (() -> Void)? = nil,
        onLoginRequested: (() -> Void)? = nil
    ) -> RegisterVC {
        let vm = RegisterVM(
            authService: services.authService,
            userService: services.userService
        )
        return RegisterVC(
            vm: vm,
            onAuthenticated: onAuthenticated,
            onLoginRequested: onLoginRequested
        )
    }
}
