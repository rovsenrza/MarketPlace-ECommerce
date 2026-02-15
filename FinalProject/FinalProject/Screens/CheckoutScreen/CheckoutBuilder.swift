import Foundation

struct CheckoutBuilder {
    static func build(
        services: AppServices = ServiceContainer.shared,
        cartVM: CartVM,
        onRoute: ((CheckoutRoute) -> Void)? = nil
    ) -> CheckoutVC {
        let vm = CheckoutVM(
            cartService: services.cartService,
            paymentsService: services.paymentsService,
            shippingService: services.shippingAddressService,
            ordersService: services.ordersService,
            notificationsService: services.notificationsService,
            authService: services.authService,
            pricingCalculator: services.pricingCalculator
        )
        return CheckoutVC(vm: vm, cartVM: cartVM, onRoute: onRoute)
    }
}
