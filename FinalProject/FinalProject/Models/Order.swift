@preconcurrency import FirebaseFirestore
import Foundation

nonisolated struct Order: Identifiable, Codable, Hashable, Sendable {
    @DocumentID var id: String?
    let orderNumber: String
    let userId: String
    let status: String
    let deliveryMethod: String
    let subtotal: Double
    let shippingFee: Double
    let tax: Double
    let total: Double
    let totalItems: Int
    let shippingAddress: ShippingAddress
    let paymentMethod: PaymentMethod
    let items: [OrderItem]
    let createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case orderNumber
        case userId
        case status
        case deliveryMethod
        case subtotal
        case shippingFee
        case tax
        case total
        case totalItems
        case shippingAddress
        case paymentMethod
        case items
        case createdAt
    }
}
