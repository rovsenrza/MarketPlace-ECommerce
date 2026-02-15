import Foundation

struct OrderSuccessBuilder {
    static func build(orderNumber: String) -> OrderSuccessVC {
        let vm = OrderSuccessVM(orderNumber: orderNumber)
        return OrderSuccessVC(vm: vm)
    }
}
