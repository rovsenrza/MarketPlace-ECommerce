@preconcurrency import FirebaseFirestore
import Foundation

nonisolated struct PaymentMethod: Identifiable, Codable, Hashable, Sendable {
    @DocumentID var id: String?
    let cardholderName: String
    let cardNumber: String
    let expiryDate: String
    let cvv: String
    let isDefault: Bool
    let createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case cardholderName
        case cardNumber
        case expiryDate
        case cvv
        case isDefault
        case createdAt
    }
}
