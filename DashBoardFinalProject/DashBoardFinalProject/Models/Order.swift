import Foundation

struct Order: Identifiable, Hashable {
    let id: String
    var orderNumber: String
    var customerName: String
    var total: Double
    var status: OrderStatus
}
