@preconcurrency import FirebaseFirestore
import Foundation

nonisolated struct WishlistItem: Identifiable, Codable, Hashable, Sendable {
    @DocumentID var id: String?
    let productId: String
    var product: Product?
    let addedAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case productId
        case addedAt
    }
}
