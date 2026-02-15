import Foundation

struct CartBuilder {
    static func build(
        services: AppServices = ServiceContainer.shared,
        cartVM: CartVM,
        onRoute: ((CartRoute) -> Void)? = nil
    ) -> CartVC {
        CartVC(
            vm: cartVM,
            pricingCalculator: services.pricingCalculator,
            onRoute: onRoute
        )
    }
}
