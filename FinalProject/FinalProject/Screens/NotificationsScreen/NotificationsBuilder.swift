import Foundation

struct NotificationsBuilder {
    static func build(
        services: AppServices = ServiceContainer.shared,
        onRoute: ((NotificationsRoute) -> Void)? = nil
    ) -> NotificationsVC {
        let vm = NotificationsVM(
            notificationsService: services.notificationsService,
            authService: services.authService
        )
        return NotificationsVC(vm: vm, onRoute: onRoute)
    }
}
