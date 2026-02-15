import Combine
import Foundation

@MainActor
final class CheckoutVM: ObservableObject {
    struct DeliveryOption: Hashable {
        let title: String
        let subtitle: String
        let fee: Double
    }

    @Published var shippingAddress: ShippingAddress?
    @Published var paymentMethod: PaymentMethod?
    @Published var selectedDelivery: DeliveryOption
    @Published var subtotal: Double = 0
    @Published var shippingFee: Double = 0
    @Published var tax: Double = 0
    @Published var total: Double = 0
    @Published var totalItems: Int = 0
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let cartService: CartServiceProtocol
    private let paymentsService: PaymentsServiceProtocol
    private let shippingService: ShippingAddressServiceProtocol
    private let ordersService: OrdersServiceProtocol
    private let notificationsService: NotificationsServiceProtocol
    private let authService: AuthenticationServiceProtocol
    private let pricingCalculator: PricingCalculatorProtocol

    let deliveryOptions: [DeliveryOption] = [
        DeliveryOption(title: "Standard", subtitle: "Standard ($5.00)", fee: 5.0),
        DeliveryOption(title: "Express", subtitle: "Express ($15.00)", fee: 15.0),
        DeliveryOption(title: "Overnight", subtitle: "Overnight ($25.00)", fee: 25.0)
    ]

    init(
        cartService: CartServiceProtocol,
        paymentsService: PaymentsServiceProtocol,
        shippingService: ShippingAddressServiceProtocol,
        ordersService: OrdersServiceProtocol,
        notificationsService: NotificationsServiceProtocol,
        authService: AuthenticationServiceProtocol,
        pricingCalculator: PricingCalculatorProtocol
    ) {
        self.cartService = cartService
        self.paymentsService = paymentsService
        self.shippingService = shippingService
        self.ordersService = ordersService
        self.notificationsService = notificationsService
        self.authService = authService
        self.pricingCalculator = pricingCalculator
        self.selectedDelivery = deliveryOptions[0]
        self.shippingFee = deliveryOptions[0].fee
    }

    func refreshDefaults() {
        guard let userId = authService.currentUser?.uid else { return }

        Task {
            isLoading = true
            errorMessage = nil

            do {
                let addresses = try await shippingService.fetchAddresses(userId: userId)
                shippingAddress = addresses.first(where: { $0.isDefault }) ?? addresses.first

                let payments = try await paymentsService.fetchPayments(userId: userId)
                paymentMethod = payments.first(where: { $0.isDefault }) ?? payments.first
            } catch {
                errorMessage = error.localizedDescription
            }

            isLoading = false
        }
    }

    func updateTotals(cartItems: [CartItem]) {
        let summary = pricingCalculator.makeSummary(
            cartItems: cartItems,
            deliveryFee: selectedDelivery.fee,
            applyFreeShippingThreshold: false
        )
        subtotal = summary.subtotal
        totalItems = summary.totalItems
        shippingFee = summary.shippingFee
        tax = summary.tax
        total = summary.total
    }

    func setDelivery(_ option: DeliveryOption, cartItems: [CartItem]) {
        selectedDelivery = option
        updateTotals(cartItems: cartItems)
    }

    func placeOrder(cartItems: [CartItem]) async throws -> Order {
        guard let userId = authService.currentUser?.uid else {
            throw NSError(domain: "Checkout", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
        }
        guard let shippingAddress = shippingAddress else {
            throw NSError(domain: "Checkout", code: -2, userInfo: [NSLocalizedDescriptionKey: "Shipping address required"])
        }
        guard let paymentMethod = paymentMethod else {
            throw NSError(domain: "Checkout", code: -3, userInfo: [NSLocalizedDescriptionKey: "Payment method required"])
        }

        let orderNumber = try await ordersService.nextOrderNumber()

        let items: [OrderItem] = cartItems.compactMap { item in
            guard let product = item.product else { return nil }

            let price = product.discountPrice ?? product.basePrice
            return OrderItem(
                productId: item.productId,
                productName: product.title,
                productImageUrl: product.imageUrl ?? product.variantImages?.first,
                unitPrice: price,
                quantity: item.quantity,
                selectedVariants: item.selectedVariants
            )
        }

        let order = Order(
            id: nil,
            orderNumber: orderNumber,
            userId: userId,
            status: "on_delivery",
            deliveryMethod: selectedDelivery.title,
            subtotal: subtotal,
            shippingFee: shippingFee,
            tax: tax,
            total: total,
            totalItems: totalItems,
            shippingAddress: shippingAddress,
            paymentMethod: paymentMethod,
            items: items,
            createdAt: Date()
        )

        let orderId = try await ordersService.createOrder(userId: userId, order: order)
        try await cartService.checkoutCart(userId: userId)

        let notification = AppNotification(
            id: nil,
            title: "Order Accepted",
            message: "Your order #\(orderNumber) has been confirmed and is being prepared.",
            type: "order_accepted",
            orderId: orderId,
            isRead: false,
            createdAt: Date()
        )
        try? await notificationsService.addNotification(userId: userId, notification: notification)

        return order
    }
}
