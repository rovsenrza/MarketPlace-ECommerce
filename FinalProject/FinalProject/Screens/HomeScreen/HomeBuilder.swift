import Foundation

struct HomeBuilder {
    static func build(
        services: AppServices = ServiceContainer.shared,
        wishlistVM: WishlistVM,
        onRoute: ((HomeRoute) -> Void)? = nil
    ) -> HomeVC {
        let vm = HomeVM(
            catalogService: services.catalogService,
            notificationsService: services.notificationsService,
            authService: services.authService,
            filterService: services.filterService
        )
        return HomeVC(vm: vm, wishlistVM: wishlistVM, onRoute: onRoute)
    }
}
