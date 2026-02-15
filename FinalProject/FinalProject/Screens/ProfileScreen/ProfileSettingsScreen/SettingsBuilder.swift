import Foundation

struct SettingsBuilder {
    static func build(
        services: AppServices = ServiceContainer.shared,
        onLogout: (() -> Void)? = nil
    ) -> SettingsVC {
        let vm = SettingsVM(
            userService: services.userService,
            authService: services.authService
        )
        return SettingsVC(vm: vm, onLogout: onLogout)
    }
}
