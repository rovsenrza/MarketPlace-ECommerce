import Foundation

struct OrderDetailBuilder {
    static func build(
        services: AppServices = ServiceContainer.shared,
        order: Order,
        onRoute: ((OrderDetailRoute) -> Void)? = nil
    ) -> OrderDetailVC {
        let vm = OrderDetailVM(order: order, firestoreService: services.firestoreService)
        return OrderDetailVC(vm: vm, onRoute: onRoute)
    }
}
