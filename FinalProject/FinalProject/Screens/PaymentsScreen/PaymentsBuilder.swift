import Foundation

struct PaymentsBuilder {
    static func build(
        services: AppServices = ServiceContainer.shared,
        onRoute: ((PaymentsRoute) -> Void)? = nil
    ) -> PaymentsVC {
        let vm = PaymentsVM(
            paymentsService: services.paymentsService,
            authService: services.authService
        )
        return PaymentsVC(vm: vm, onRoute: onRoute)
    }
}
