import Foundation

struct ProfileBuilder {
    static func build(
        services: AppServices = ServiceContainer.shared,
        onRoute: ((ProfileRoute) -> Void)? = nil,
        onLogout: (() -> Void)? = nil
    ) -> ProfileVC {
        let vm = ProfileVM(
            userService: services.userService,
            authService: services.authService
        )
        return ProfileVC(vm: vm, onRoute: onRoute, onLogout: onLogout)
    }
}
