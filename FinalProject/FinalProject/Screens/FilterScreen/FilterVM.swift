import Combine
import Foundation

@MainActor
final class FilterVM: ObservableObject {
    @Published var selectedSort: FilterQuery.SortOption
    @Published var selectedCategoryId: String?
    @Published var minPriceText: String
    @Published var maxPriceText: String
    @Published var showsAllCategories: Bool = false
    
    let categories: [Category]
    let hideCategoryFilter: Bool
    
    init(categories: [Category], currentQuery: FilterQuery, hideCategoryFilter: Bool = false) {
        self.categories = categories
        self.hideCategoryFilter = hideCategoryFilter
        self.selectedSort = currentQuery.sort
        self.selectedCategoryId = currentQuery.categoryId
        self.minPriceText = currentQuery.minPrice.map { String(Int($0)) } ?? ""
        self.maxPriceText = currentQuery.maxPrice.map { String(Int($0)) } ?? ""
    }
    
    var visibleCategories: [Category] {
        if showsAllCategories { return categories }
        return Array(categories.prefix(6))
    }
    
    func makeQuery() -> FilterQuery {
        let min = parsePrice(minPriceText)
        let max = parsePrice(maxPriceText)
        
        if let min, let max, min > max {
            return FilterQuery(
                sort: selectedSort,
                categoryId: selectedCategoryId,
                minPrice: max,
                maxPrice: min
            )
        }
        
        return FilterQuery(
            sort: selectedSort,
            categoryId: selectedCategoryId,
            minPrice: min,
            maxPrice: max
        )
    }
    
    private func parsePrice(_ text: String) -> Double? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        let normalized = trimmed.replacingOccurrences(of: ",", with: "")
        return Double(normalized)
    }
}
