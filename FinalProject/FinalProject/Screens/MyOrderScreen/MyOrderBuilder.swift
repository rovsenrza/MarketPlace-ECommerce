import Foundation

struct MyOrderBuilder {
    static func build(
        services: AppServices = ServiceContainer.shared,
        onRoute: ((MyOrderRoute) -> Void)? = nil
    ) -> MyOrderVC {
        let vm = MyOrderVM(
            ordersService: services.ordersService,
            notificationsService: services.notificationsService,
            authService: services.authService
        )
        return MyOrderVC(vm: vm, onRoute: onRoute)
    }
}
