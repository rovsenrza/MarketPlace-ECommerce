import FirebaseFirestore
import Foundation

protocol FilterServiceProtocol {
    func applyFilters(
        products: [Product],
        query: FilterQuery,
        fallbackCategoryId: String?
    ) -> [Product]
}

final class FilterService: FilterServiceProtocol {
    func applyFilters(
        products: [Product],
        query: FilterQuery,
        fallbackCategoryId: String?
    ) -> [Product] {
        var result = products
        let categoryId = query.categoryId ?? fallbackCategoryId
        
        if let categoryId, !categoryId.isEmpty {
            result = result.filter { $0.categoryIds?.contains(categoryId) ?? false }
        }
        
        if let minPrice = query.minPrice {
            result = result.filter { $0.displayPrice >= minPrice }
        }
        
        if let maxPrice = query.maxPrice {
            result = result.filter { $0.displayPrice <= maxPrice }
        }
        
        return sortProducts(result, by: query.sort)
    }
    
    private func sortProducts(_ products: [Product], by option: FilterQuery.SortOption) -> [Product] {
        switch option {
        case .aToZ:
            return products.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }

        case .mostPopular:
            return products.sorted { $0.averageRating > $1.averageRating }

        case .newest:
            return products.sorted {
                ($0.createdAt?.dateValue() ?? .distantPast) > ($1.createdAt?.dateValue() ?? .distantPast)
            }

        case .lowestPrice:
            return products.sorted { $0.displayPrice < $1.displayPrice }

        case .highestPrice:
            return products.sorted { $0.displayPrice > $1.displayPrice }

        case .mostSuitable:
            return products.sorted {
                if $0.averageRating == $1.averageRating {
                    return $0.reviewCount > $1.reviewCount
                }
                return $0.averageRating > $1.averageRating
            }
        }
    }
}
