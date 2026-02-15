import Foundation

struct WishlistBuilder {
    static func build(
        wishlistVM: WishlistVM,
        onRoute: ((WishlistRoute) -> Void)? = nil
    ) -> WishlistVC {
        WishlistVC(vm: wishlistVM, onRoute: onRoute)
    }
}
