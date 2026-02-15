import Foundation

enum DashboardTab: String, CaseIterable, Identifiable {
    case catalog
    case orders
    case messages

    var id: String { rawValue }

    var title: String {
        switch self {
        case .catalog: return "Catalog"
        case .orders: return "Orders Status"
        case .messages: return "Messages"
        }
    }
}
