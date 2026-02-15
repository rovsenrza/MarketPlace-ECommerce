import Foundation

extension Array where Element == Product {
    func deduplicatedByProductId() -> [Product] {
        var seenProductIds = Set<String>()
        var seenAnonymousProducts = Set<Product>()
        var uniqueProducts: [Product] = []
        uniqueProducts.reserveCapacity(count)

        for product in self {
            if let productId = product.id, !productId.isEmpty {
                if seenProductIds.insert(productId).inserted {
                    uniqueProducts.append(product)
                }
                continue
            }

            if seenAnonymousProducts.insert(product).inserted {
                uniqueProducts.append(product)
            }
        }

        return uniqueProducts
    }
}
