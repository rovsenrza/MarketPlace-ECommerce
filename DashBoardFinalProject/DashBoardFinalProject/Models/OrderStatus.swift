import Foundation

enum OrderStatus: String, CaseIterable, Identifiable {
    case onDelivery = "on_delivery"
    case delivered = "delivered"

    var id: String { rawValue }

    var label: String {
        switch self {
        case .onDelivery: return "On delivery"
        case .delivered: return "Delivered"
        }
    }
}
