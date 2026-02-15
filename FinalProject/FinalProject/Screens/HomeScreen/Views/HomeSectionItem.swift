import Foundation

nonisolated enum HomeSectionItem: Hashable, Sendable {
    case featured(Product)
    case category(Category)
    case allCategory
    case product(Product)

    func hash(into hasher: inout Hasher) {
        switch self {
        case .featured(let product):
            hasher.combine("featured")
            hasher.combine(product.id)

        case .category(let category):
            hasher.combine("category")
            hasher.combine(category.id)

        case .allCategory:
            hasher.combine("allCategory")

        case .product(let product):
            hasher.combine("product")
            hasher.combine(product.id)
        }
    }

    static func == (lhs: HomeSectionItem, rhs: HomeSectionItem) -> Bool {
        switch (lhs, rhs) {
        case (.featured(let lProduct), .featured(let rProduct)):
            return lProduct.id == rProduct.id
        case (.category(let lCategory), .category(let rCategory)):
            return lCategory.id == rCategory.id
        case (.allCategory, .allCategory):
            return true
        case (.product(let lProduct), .product(let rProduct)):
            return lProduct.id == rProduct.id
        default:
            return false
        }
    }
}
