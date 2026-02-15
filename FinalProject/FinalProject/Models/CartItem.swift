@preconcurrency import FirebaseFirestore
import Foundation

nonisolated struct CartItem: Identifiable, Codable, Hashable, Sendable {
    @DocumentID var id: String?
    let productId: String
    var product: Product?
    var quantity: Int
    var selectedVariants: [String: String]?
    let addedAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case productId
        case quantity
        case selectedVariants
        case addedAt
    }

    func matchesVariants(_ other: [String: String]?) -> Bool {
        guard let selfVariants = selectedVariants, let otherVariants = other else {
            return selectedVariants == nil && other == nil
        }

        return selfVariants == otherVariants
    }
}
