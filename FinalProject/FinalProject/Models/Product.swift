@preconcurrency import FirebaseFirestore
import Foundation

nonisolated struct Product: Identifiable, Codable, Hashable, Sendable {
    static func == (lhs: Product, rhs: Product) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    @DocumentID
    var id: String?

    let title: String
    let description: String?
    let brand: String?
    let categoryIds: [String]?

    let basePrice: Double
    let discountPrice: Double?
    var stockQuantity: Int?
    
    let imageUrl: String?
    
    let variants: [String: [String]]?
    
    var reviews: [Review]?

    let createdAt: Timestamp?
    
    var variantImages: [String]? {
        return variants?["images"]
    }

    var color: [String]? {
        return variants?["color"]
    }

    var size: [String]? {
        return variants?["size"]
    }

    var images: [String]? {
        return variants?["images"]
    }
    
    var averageRating: Double {
        guard let reviews = reviews, !reviews.isEmpty else { return 0.0 }

        let sum = reviews.reduce(0) { $0 + $1.stars }
        return Double(sum) / Double(reviews.count)
    }
    
    var reviewCount: Int {
        return reviews?.count ?? 0
    }
    
    var discountPercentage: Int? {
        guard let discountPrice = discountPrice else { return nil }

        let discount = ((basePrice - discountPrice) / basePrice) * 100
        return Int(discount)
    }
    
    var displayPrice: Double {
        return discountPrice ?? basePrice
    }
}
