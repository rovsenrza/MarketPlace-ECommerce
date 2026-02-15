import UIKit

struct AddNewShippingBuilder {
    static func build(
        services: AppServices = ServiceContainer.shared,
        address: ShippingAddress? = nil,
        onSaved: (() -> Void)? = nil
    ) -> UIViewController {
        let vm = AddNewShippingVM(
            shippingService: services.shippingAddressService,
            authService: services.authService
        )
        return AddNewShippingVC(vm: vm, existingAddress: address, onSaved: onSaved)
    }
}
