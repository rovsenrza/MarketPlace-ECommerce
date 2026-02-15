import Foundation


struct Product: Identifiable, Hashable {
    let id: String
    var title: String
    var description: String
    var categoryIds: [String]
    var basePrice: Double
    var discountPrice: Double?
    var quantity: Int
    var variants: [Variant]
    var reviews: [Review]
}
