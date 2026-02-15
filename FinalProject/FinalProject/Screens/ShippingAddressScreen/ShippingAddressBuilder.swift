import Foundation

struct ShippingAddressBuilder {
    static func build(
        services: AppServices = ServiceContainer.shared,
        onRoute: ((ShippingAddressRoute) -> Void)? = nil
    ) -> ShippingAddressVC {
        let vm = ShippingAddressVM(
            shippingService: services.shippingAddressService,
            authService: services.authService
        )
        return ShippingAddressVC(vm: vm, onRoute: onRoute)
    }
}
