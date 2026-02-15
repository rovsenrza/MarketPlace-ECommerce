import Foundation

struct FilterQuery: Equatable {
    enum SortOption: String, CaseIterable {
        case aToZ
        case mostPopular
        case newest
        case lowestPrice
        case highestPrice
        case mostSuitable
        
        var title: String {
            switch self {
            case .aToZ:
                return "A-Z"
            case .mostPopular:
                return "Most Popular"
            case .newest:
                return "Newest"
            case .lowestPrice:
                return "Lowest Price"
            case .highestPrice:
                return "Highest Price"
            case .mostSuitable:
                return "Most Suitable"
            }
        }
    }
    
    var sort: SortOption
    var categoryId: String?
    var minPrice: Double?
    var maxPrice: Double?
    
    init(
        sort: SortOption = .mostPopular,
        categoryId: String? = nil,
        minPrice: Double? = nil,
        maxPrice: Double? = nil
    ) {
        self.sort = sort
        self.categoryId = categoryId
        self.minPrice = minPrice
        self.maxPrice = maxPrice
    }
}
