import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import FirebaseStorage
import Foundation

protocol FirebaseConfigurationServiceProtocol {
    func configure()
}

protocol AppServices {
    var authService: AuthenticationServiceProtocol { get }
    var firestoreService: FirestoreServiceProtocol { get }
    var userService: UserServiceProtocol { get }
    var catalogService: CatalogServiceProtocol { get }
    var categoryService: CategoryServiceProtocol { get }
    var reviewService: ReviewServiceProtocol { get }
    var cartService: CartServiceProtocol { get }
    var wishlistService: WishlistServiceProtocol { get }
    var paymentsService: PaymentsServiceProtocol { get }
    var shippingAddressService: ShippingAddressServiceProtocol { get }
    var ordersService: OrdersServiceProtocol { get }
    var notificationsService: NotificationsServiceProtocol { get }
    var chatService: ChatServiceProtocol { get }
    var filterService: FilterServiceProtocol { get }
    var pricingCalculator: PricingCalculatorProtocol { get }
}

final class FirebaseConfigurationService: FirebaseConfigurationServiceProtocol {
    func configure() {
        FirebaseConfiguration.shared.setLoggerLevel(.error)
        FirebaseApp.configure()
    }
}

struct CartPricingSummary {
    let subtotal: Double
    let shippingFee: Double
    let tax: Double
    let total: Double
    let totalItems: Int
}

protocol PricingCalculatorProtocol {
    var taxRate: Double { get }
    var freeShippingThreshold: Double { get }
    var standardDeliveryFee: Double { get }
    func makeSummary(
        cartItems: [CartItem],
        deliveryFee: Double,
        applyFreeShippingThreshold: Bool
    ) -> CartPricingSummary
    func makeFreeShippingProgress(subtotal: Double) -> (remaining: Double, progress: Double)
}

final class PricingCalculator: PricingCalculatorProtocol {
    let taxRate: Double = 0.08
    let freeShippingThreshold: Double = 50.0
    let standardDeliveryFee: Double = 5.0

    func makeSummary(
        cartItems: [CartItem],
        deliveryFee: Double,
        applyFreeShippingThreshold: Bool
    ) -> CartPricingSummary {
        let subtotal = cartItems.reduce(0.0) { total, item in
            guard let product = item.product else { return total }

            let price = product.discountPrice ?? product.basePrice
            return total + (price * Double(item.quantity))
        }
        let totalItems = cartItems.reduce(0) { $0 + $1.quantity }
        let shippingFee = applyFreeShippingThreshold && subtotal >= freeShippingThreshold
            ? 0.0
            : deliveryFee
        let tax = subtotal * taxRate
        let total = subtotal + shippingFee + tax

        return CartPricingSummary(
            subtotal: subtotal,
            shippingFee: shippingFee,
            tax: tax,
            total: total,
            totalItems: totalItems
        )
    }

    func makeFreeShippingProgress(subtotal: Double) -> (remaining: Double, progress: Double) {
        let remaining = max(0.0, freeShippingThreshold - subtotal)
        let progress = min(1.0, subtotal / freeShippingThreshold)
        return (remaining, progress)
    }
}

final class ServiceContainer {
    // MARK: - Singleton

    static let shared = ServiceContainer()

    // MARK: - Services

    lazy var authService: AuthenticationServiceProtocol = FirebaseAuthService()

    lazy var firebaseConfigurationService: FirebaseConfigurationServiceProtocol = FirebaseConfigurationService()

    lazy var firestoreService: FirestoreServiceProtocol = FirestoreService()

    lazy var storageService: StorageServiceProtocol = StorageService()

    lazy var userService: UserServiceProtocol = UserService(
        firestoreService: firestoreService,
        storageService: storageService,
        authService: authService
    )

    lazy var catalogService: CatalogServiceProtocol = CatalogService()

    lazy var categoryService: CategoryServiceProtocol = CategoryService()

    lazy var reviewService: ReviewServiceProtocol = ReviewService()

    lazy var cartService: CartServiceProtocol = CartService(firestoreService: firestoreService)

    lazy var wishlistService: WishlistServiceProtocol = WishlistService(firestoreService: firestoreService)

    lazy var paymentsService: PaymentsServiceProtocol = PaymentsService(firestoreService: firestoreService)

    lazy var shippingAddressService: ShippingAddressServiceProtocol = ShippingAddressService(firestoreService: firestoreService)

    lazy var ordersService: OrdersServiceProtocol = OrdersService(firestoreService: firestoreService)

    lazy var notificationsService: NotificationsServiceProtocol = NotificationsService(firestoreService: firestoreService)

    lazy var filterService: FilterServiceProtocol = FilterService()

    lazy var chatService: ChatServiceProtocol = ChatService()

    lazy var pricingCalculator: PricingCalculatorProtocol = PricingCalculator()

    // MARK: - Initialization

    private init() {}
}

extension ServiceContainer: AppServices {}
