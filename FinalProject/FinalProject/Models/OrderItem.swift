import Foundation

struct OrderItem: Codable, Hashable, Sendable {
    let productId: String
    let productName: String
    let productImageUrl: String?
    let unitPrice: Double
    let quantity: Int
    let selectedVariants: [String: String]?

    var totalPrice: Double {
        unitPrice * Double(quantity)
    }
}
