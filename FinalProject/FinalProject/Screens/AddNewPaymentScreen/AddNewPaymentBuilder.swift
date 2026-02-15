import Foundation

struct AddNewPaymentBuilder {
    static func build(
        services: AppServices = ServiceContainer.shared,
        onSaved: (() -> Void)? = nil
    ) -> AddNewPaymentVC {
        let vm = AddNewPaymentVM(
            paymentsService: services.paymentsService,
            authService: services.authService
        )
        return AddNewPaymentVC(vm: vm, onSaved: onSaved)
    }
}
