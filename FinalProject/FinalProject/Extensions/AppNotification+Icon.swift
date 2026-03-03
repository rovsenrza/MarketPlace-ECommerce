import Foundation

extension AppNotification {
    var iconSystemName: String {
        switch type {
        case "order_accepted":
            return "checkmark.circle.fill"
        case "order_delivered":
            return "shippingbox.fill"
        case "order_shipped":
            return "truck.box.fill"
        default:
            return "bell.fill"
        }
    }
}
