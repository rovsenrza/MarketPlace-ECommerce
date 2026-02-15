@preconcurrency import FirebaseFirestore
import Foundation

nonisolated struct ShippingAddress: Identifiable, Codable, Hashable, Sendable {
    @DocumentID var id: String?
    let name: String
    let phoneNumber: String
    let streetAddress: String
    let city: String
    let state: String
    let zipCode: String
    let isDefault: Bool
    let createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case phoneNumber
        case streetAddress
        case city
        case state
        case zipCode
        case isDefault
        case createdAt
    }
}
