import Foundation

struct CategoryDetailBuilder {
    static func build(
        services: AppServices = ServiceContainer.shared,
        mode: CategoryFilterMode,
        wishlistVM: WishlistVM,
        onRoute: ((CategoryDetailRoute) -> Void)? = nil
    ) -> CategoryDetailVC {
        let vm = CategoryDetailVM(
            mode: mode,
            catalogService: services.catalogService,
            filterService: services.filterService
        )
        return CategoryDetailVC(vm: vm, wishlistVM: wishlistVM, onRoute: onRoute)
    }
}
