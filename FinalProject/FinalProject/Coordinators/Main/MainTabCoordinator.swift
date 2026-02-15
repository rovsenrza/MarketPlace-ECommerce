import UIKit

enum HomeRoute {
    case notifications
    case browse
    case productDetail(Product)
    case search
    case filter(
        categories: [Category],
        currentQuery: FilterQuery,
        hideCategoryFilter: Bool,
        onApply: (FilterQuery) -> Void
    )
}

enum BrowseRoute {
    case categoryDetail(CategoryFilterMode)
}

enum CategoryDetailRoute {
    case productDetail(Product)
    case filter(
        categories: [Category],
        currentQuery: FilterQuery,
        hideCategoryFilter: Bool,
        onApply: (FilterQuery) -> Void
    )
}

enum SearchResultRoute {
    case productDetail(Product)
    case close
}

enum CartRoute {
    case checkout
    case goToHome
}

enum CheckoutRoute {
    case addShipping(address: ShippingAddress?)
    case addPayment
    case selectShipping
    case selectPayment
    case orderSuccess(orderNumber: String)
}

enum PaymentsRoute {
    case addNewPayment
}

enum ShippingAddressRoute {
    case addOrEditAddress(ShippingAddress?)
}

enum MyOrderRoute {
    case orderDetail(Order)
    case goToHome
}

enum OrderDetailRoute {
    case productDetail(Product)
}

enum ProductDetailRoute {
    case back
    case reviews(Product)
}

enum NotificationsRoute {
    case detail(AppNotification)
}

enum WishlistRoute {
    case productDetail(Product)
    case goToHome
}

enum HelpCenterRoute {
    case detail(title: String, subtitle: String, body: String)
    case chat
}

enum ProfileRoute {
    case settings
    case orders
    case wishlist
    case payments
    case notifications
    case shippingAddress
    case helpCenter
}

final class MainTabCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var onLogout: (() -> Void)?

    private(set) var rootViewController: UIViewController = .init()
    private let services: AppServices
    private lazy var sharedWishlistVM: WishlistVM = .init(
        wishlistService: services.wishlistService,
        firestoreService: services.firestoreService,
        authService: services.authService
    )

    private lazy var sharedCartVM: CartVM = .init(
        cartService: services.cartService,
        authService: services.authService
    )

    private weak var tabBarController: MainTabBarController?
    private var homeRouter: NavigationRouter?
    private var browseRouter: NavigationRouter?
    private var cartRouter: NavigationRouter?
    private var wishlistRouter: NavigationRouter?
    private var profileRouter: NavigationRouter?

    init(services: AppServices = ServiceContainer.shared) {
        self.services = services
    }

    func start() {
        let homeVC = HomeBuilder.build(services: services, wishlistVM: sharedWishlistVM, onRoute: { [weak self] route in
            self?.handle(route: route, router: self?.homeRouter)
        })
        let browseVC = BrowseBuilder.build(onRoute: { [weak self] route in
            self?.handle(route: route, router: self?.browseRouter)
        })
        let cartVC = CartBuilder.build(services: services, cartVM: sharedCartVM, onRoute: { [weak self] route in
            self?.handle(route: route, router: self?.cartRouter)
        })
        let wishlistVC = WishlistBuilder.build(wishlistVM: sharedWishlistVM, onRoute: { [weak self] route in
            self?.handle(route: route, router: self?.wishlistRouter)
        })
        let profileVC = ProfileBuilder.build(
            onRoute: { [weak self] route in
                self?.handle(route: route)
            },
            onLogout: { [weak self] in
                self?.onLogout?()
            }
        )

        let tabBarController = MainTabBarController(
            cartVM: sharedCartVM,
            homeRootViewController: homeVC,
            browseRootViewController: browseVC,
            cartRootViewController: cartVC,
            wishlistRootViewController: wishlistVC,
            profileRootViewController: profileVC
        )
        self.tabBarController = tabBarController
        rootViewController = tabBarController

        if let homeNav = tabBarController.viewControllers?[safe: 0] as? UINavigationController {
            homeRouter = NavigationRouter(navigationController: homeNav)
        }
        if let browseNav = tabBarController.viewControllers?[safe: 1] as? UINavigationController {
            browseRouter = NavigationRouter(navigationController: browseNav)
        }
        if let cartNav = tabBarController.viewControllers?[safe: 2] as? UINavigationController {
            cartRouter = NavigationRouter(navigationController: cartNav)
        }
        if let wishlistNav = tabBarController.viewControllers?[safe: 3] as? UINavigationController {
            wishlistRouter = NavigationRouter(navigationController: wishlistNav)
        }
        if let profileNav = tabBarController.viewControllers?[safe: 4] as? UINavigationController {
            profileRouter = NavigationRouter(navigationController: profileNav)
        }
    }

    private func handle(route: HomeRoute, router: NavigationRouter?) {
        guard let router else { return }

        switch route {
        case .notifications:
            router.push(NotificationsBuilder.build(onRoute: makeNotificationsHandler(router: router)), animated: true)

        case .browse:
            router.push(BrowseBuilder.build(onRoute: makeBrowseHandler(router: router)), animated: true)

        case .productDetail(let product):
            router.push(makeProductDetailScreen(product: product, router: router), animated: true)

        case .search:
            router.push(
                SearchResultBuilder.build(
                    services: services,
                    wishlistVM: sharedWishlistVM,
                    onRoute: makeSearchResultHandler(router: router)
                ),
                animated: true
            )

        case .filter(let categories, let currentQuery, let hideCategoryFilter, let onApply):
            presentFilter(
                categories: categories,
                currentQuery: currentQuery,
                hideCategoryFilter: hideCategoryFilter,
                onApply: onApply,
                router: router
            )
        }
    }

    private func handle(route: BrowseRoute, router: NavigationRouter?) {
        guard let router else { return }

        switch route {
        case .categoryDetail(let mode):
            router.push(
                CategoryDetailBuilder.build(
                    services: services,
                    mode: mode,
                    wishlistVM: sharedWishlistVM,
                    onRoute: makeCategoryDetailHandler(router: router)
                ),
                animated: true
            )
        }
    }

    private func handle(route: CategoryDetailRoute, router: NavigationRouter?) {
        guard let router else { return }

        switch route {
        case .productDetail(let product):
            router.push(makeProductDetailScreen(product: product, router: router), animated: true)
        case .filter(let categories, let currentQuery, let hideCategoryFilter, let onApply):
            presentFilter(
                categories: categories,
                currentQuery: currentQuery,
                hideCategoryFilter: hideCategoryFilter,
                onApply: onApply,
                router: router
            )
        }
    }

    private func handle(route: SearchResultRoute, router: NavigationRouter?) {
        guard let router else { return }

        switch route {
        case .productDetail(let product):
            router.push(makeProductDetailScreen(product: product, router: router), animated: true)
        case .close:
            router.pop(animated: true)
        }
    }

    private func handle(route: CartRoute, router: NavigationRouter?) {
        guard let router else { return }

        switch route {
        case .checkout:
            router.push(
                CheckoutBuilder.build(
                    services: services,
                    cartVM: sharedCartVM,
                    onRoute: makeCheckoutHandler(router: router)
                ),
                animated: true
            )
        case .goToHome:
            tabBarController?.selectedIndex = 0
        }
    }

    private func handle(route: CheckoutRoute, router: NavigationRouter?) {
        guard let router else { return }

        switch route {
        case .addShipping(let address):
            router.push(
                AddNewShippingBuilder.build(
                    address: address,
                    onSaved: { [weak router] in
                        router?.pop(animated: true)
                    }
                ),
                animated: true
            )

        case .addPayment:
            router.push(
                AddNewPaymentBuilder.build(
                    onSaved: { [weak router] in
                        router?.pop(animated: true)
                    }
                ),
                animated: true
            )

        case .selectShipping:
            router.push(ShippingAddressBuilder.build(onRoute: makeShippingAddressHandler(router: router)), animated: true)

        case .selectPayment:
            router.push(PaymentsBuilder.build(onRoute: makePaymentsHandler(router: router)), animated: true)

        case .orderSuccess(let orderNumber):
            let successVC = OrderSuccessBuilder.build(orderNumber: orderNumber)
            successVC.onDismiss = { [weak self] in
                self?.tabBarController?.selectedIndex = 0
            }
            successVC.modalPresentationStyle = .fullScreen
            router.present(successVC, animated: true)
        }
    }

    private func handle(route: PaymentsRoute, router: NavigationRouter?) {
        guard let router else { return }

        switch route {
        case .addNewPayment:
            router.push(
                AddNewPaymentBuilder.build(
                    onSaved: { [weak router] in
                        router?.pop(animated: true)
                    }
                ),
                animated: true
            )
        }
    }

    private func handle(route: ShippingAddressRoute, router: NavigationRouter?) {
        guard let router else { return }

        switch route {
        case .addOrEditAddress(let address):
            router.push(
                AddNewShippingBuilder.build(
                    address: address,
                    onSaved: { [weak router] in
                        router?.pop(animated: true)
                    }
                ),
                animated: true
            )
        }
    }

    private func handle(route: MyOrderRoute, router: NavigationRouter?) {
        guard let router else { return }

        switch route {
        case .orderDetail(let order):
            router.push(OrderDetailBuilder.build(order: order, onRoute: makeOrderDetailHandler(router: router)), animated: true)
        case .goToHome:
            tabBarController?.selectedIndex = 0
        }
    }

    private func handle(route: OrderDetailRoute, router: NavigationRouter?) {
        guard let router else { return }

        switch route {
        case .productDetail(let product):
            router.push(makeProductDetailScreen(product: product, router: router), animated: true)
        }
    }

    private func handle(route: ProductDetailRoute, router: NavigationRouter?) {
        guard let router else { return }

        switch route {
        case .back:
            router.pop(animated: true)
        case .reviews(let product):
            let reviewsVC = ReviewsBuilder.build(product: product)
            reviewsVC.modalPresentationStyle = .pageSheet
            if let sheet = reviewsVC.sheetPresentationController {
                sheet.detents = [.large()]
                sheet.prefersGrabberVisible = true
            }
            router.present(reviewsVC, animated: true)
        }
    }

    private func handle(route: NotificationsRoute, router: NavigationRouter?) {
        guard let router else { return }

        switch route {
        case .detail(let notification):
            router.push(NotificationDetailBuilder.build(notification: notification), animated: true)
        }
    }

    private func handle(route: WishlistRoute, router: NavigationRouter?) {
        guard let router else { return }

        switch route {
        case .productDetail(let product):
            router.push(makeProductDetailScreen(product: product, router: router), animated: true)
        case .goToHome:
            tabBarController?.selectedIndex = 0
        }
    }

    private func handle(route: HelpCenterRoute, router: NavigationRouter?) {
        guard let router else { return }

        switch route {
        case .detail(let title, let subtitle, let body):
            let detailVC = HelpCenterDetailBuilder.build(
                title: title,
                subtitle: subtitle,
                body: body,
                onChatRequested: { [weak self] in
                    self?.presentSupportChat(router: router)
                }
            )
            router.push(detailVC, animated: true)

        case .chat:
            presentSupportChat(router: router)
        }
    }

    private func handle(route: ProfileRoute) {
        guard let profileRouter else { return }

        switch route {
        case .settings:
            let settingsVC = SettingsBuilder.build(onLogout: { [weak self] in
                self?.onLogout?()
            })
            let navController = UINavigationController(rootViewController: settingsVC)
            profileRouter.present(navController, animated: true)

        case .orders:
            profileRouter.push(MyOrderBuilder.build(onRoute: makeMyOrderHandler(router: profileRouter)), animated: true)

        case .wishlist:
            profileRouter.push(
                WishlistBuilder.build(
                    wishlistVM: sharedWishlistVM,
                    onRoute: makeWishlistHandler(router: profileRouter)
                ),
                animated: true
            )

        case .payments:
            profileRouter.push(PaymentsBuilder.build(onRoute: makePaymentsHandler(router: profileRouter)), animated: true)

        case .notifications:
            profileRouter.push(NotificationsBuilder.build(onRoute: makeNotificationsHandler(router: profileRouter)), animated: true)

        case .shippingAddress:
            profileRouter.push(ShippingAddressBuilder.build(onRoute: makeShippingAddressHandler(router: profileRouter)), animated: true)

        case .helpCenter:
            profileRouter.push(HelpCenterBuilder.build(onRoute: makeHelpCenterHandler(router: profileRouter)), animated: true)
        }
    }

    private func makeBrowseHandler(router: NavigationRouter) -> (BrowseRoute) -> Void {
        { [weak self] route in
            self?.handle(route: route, router: router)
        }
    }

    private func makeCategoryDetailHandler(router: NavigationRouter) -> (CategoryDetailRoute) -> Void {
        { [weak self] route in
            self?.handle(route: route, router: router)
        }
    }

    private func makeSearchResultHandler(router: NavigationRouter) -> (SearchResultRoute) -> Void {
        { [weak self] route in
            self?.handle(route: route, router: router)
        }
    }

    private func makeCheckoutHandler(router: NavigationRouter) -> (CheckoutRoute) -> Void {
        { [weak self] route in
            self?.handle(route: route, router: router)
        }
    }

    private func makePaymentsHandler(router: NavigationRouter) -> (PaymentsRoute) -> Void {
        { [weak self] route in
            self?.handle(route: route, router: router)
        }
    }

    private func makeShippingAddressHandler(router: NavigationRouter) -> (ShippingAddressRoute) -> Void {
        { [weak self] route in
            self?.handle(route: route, router: router)
        }
    }

    private func makeMyOrderHandler(router: NavigationRouter) -> (MyOrderRoute) -> Void {
        { [weak self] route in
            self?.handle(route: route, router: router)
        }
    }

    private func makeOrderDetailHandler(router: NavigationRouter) -> (OrderDetailRoute) -> Void {
        { [weak self] route in
            self?.handle(route: route, router: router)
        }
    }

    private func makeProductDetailHandler(router: NavigationRouter) -> (ProductDetailRoute) -> Void {
        { [weak self] route in
            self?.handle(route: route, router: router)
        }
    }

    private func makeNotificationsHandler(router: NavigationRouter) -> (NotificationsRoute) -> Void {
        { [weak self] route in
            self?.handle(route: route, router: router)
        }
    }

    private func makeWishlistHandler(router: NavigationRouter) -> (WishlistRoute) -> Void {
        { [weak self] route in
            self?.handle(route: route, router: router)
        }
    }

    private func makeHelpCenterHandler(router: NavigationRouter) -> (HelpCenterRoute) -> Void {
        { [weak self] route in
            self?.handle(route: route, router: router)
        }
    }

    private func presentFilter(
        categories: [Category],
        currentQuery: FilterQuery,
        hideCategoryFilter: Bool,
        onApply: @escaping (FilterQuery) -> Void,
        router: NavigationRouter
    ) {
        if let presented = router.navigationController.presentedViewController {
            presented.dismiss(animated: true) { [weak self] in
                self?.presentFilter(
                    categories: categories,
                    currentQuery: currentQuery,
                    hideCategoryFilter: hideCategoryFilter,
                    onApply: onApply,
                    router: router
                )
            }
            return
        }

        let filterVC = FilterBuilder.build(
            categories: categories,
            currentQuery: currentQuery,
            hideCategoryFilter: hideCategoryFilter,
            onApply: onApply
        )
        router.present(filterVC, animated: true)
    }

    private func presentSupportChat(router: NavigationRouter) {
        let messageVC = MessageBuilder.build()
        let nav = UINavigationController(rootViewController: messageVC)
        nav.modalPresentationStyle = .fullScreen
        router.present(nav, animated: true)
    }

    private func makeProductDetailScreen(product: Product, router: NavigationRouter) -> UIViewController {
        let detailVC = ProductDetailBuilder.build(
            services: services,
            product: product,
            wishlistVM: sharedWishlistVM,
            cartVM: sharedCartVM,
            onRoute: makeProductDetailHandler(router: router)
        )
        detailVC.hidesBottomBarWhenPushed = true
        return detailVC
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        guard indices.contains(index) else { return nil }

        return self[index]
    }
}
