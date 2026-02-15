import Foundation

struct ProductDetailBuilder {
    static func build(
        services: AppServices = ServiceContainer.shared,
        product: Product,
        wishlistVM: WishlistVM,
        cartVM: CartVM,
        onRoute: ((ProductDetailRoute) -> Void)? = nil
    ) -> ProductDetailVC {
        let vm = ProductDetailVM(
            product: product,
            wishlistStore: wishlistVM,
            cartHandler: cartVM,
            categoryService: services.categoryService,
            reviewService: services.reviewService
        )
        return ProductDetailVC(vm: vm, onRoute: onRoute)
    }
}
