import UIKit

struct SearchResultBuilder {
    static func build(
        services: AppServices = ServiceContainer.shared,
        wishlistVM: WishlistVM,
        onRoute: ((SearchResultRoute) -> Void)? = nil
    ) -> UIViewController {
        let vm = SearchResultVM(catalogService: services.catalogService)
        return SearchResultVC(vm: vm, wishlistVM: wishlistVM, onRoute: onRoute)
    }
}
