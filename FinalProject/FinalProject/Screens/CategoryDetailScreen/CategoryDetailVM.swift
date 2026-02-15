import Combine
import Foundation

@MainActor
final class CategoryDetailVM: ObservableObject {
    @Published var allProducts: [Product] = []
    @Published var filteredProducts: [Product] = []
    @Published var categories: [Category] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var searchText: String = ""
    @Published var filterQuery: FilterQuery = .init()
    
    let mode: CategoryFilterMode
    
    private let catalogService: CatalogServiceProtocol
    private let filterService: FilterServiceProtocol
    
    init(
        mode: CategoryFilterMode,
        catalogService: CatalogServiceProtocol,
        filterService: FilterServiceProtocol
    ) {
        self.mode = mode
        self.catalogService = catalogService
        self.filterService = filterService
        if case .category(let category) = mode {
            filterQuery.categoryId = category.id
        }
    }
    
    var title: String {
        switch mode {
        case .category(let category):
            return category.title
        case .trending:
            return "Trending Now"
        case .flashSales:
            return "Flash Sales"
        case .megaDeals:
            return "Mega Deals"
        }
    }
    
    func fetchProducts() {
        isLoading = true
        errorMessage = nil
        
        Task { @MainActor in
            do {
                let products = try await catalogService.fetchProductsWithReviews()
                allProducts = products.deduplicatedByProductId()
                applyFiltersAndSearch()
                isLoading = false
            } catch {
                errorMessage = error.localizedDescription
                isLoading = false
            }
        }
    }
    
    func fetchCategories() {
        Task { @MainActor in
            do {
                categories = try await catalogService.fetchCategories()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
    
    func updateSearchText(_ text: String) {
        searchText = text
        applyFiltersAndSearch()
    }

    func applyFilterQuery(_ query: FilterQuery) {
        filterQuery = query
        applyFiltersAndSearch()
    }
    
    private func applyFiltersAndSearch() {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let base = baseProducts(allProducts)
        let fallbackCategoryId = defaultCategoryId()
        let filtered = filterService.applyFilters(
            products: base,
            query: filterQuery,
            fallbackCategoryId: fallbackCategoryId
        )
        
        if query.isEmpty {
            filteredProducts = filtered.deduplicatedByProductId()
            return
        }
        
        filteredProducts = filtered.filter { product in
            let title = product.title.lowercased()
            let brand = product.brand?.lowercased() ?? ""
            return title.contains(query) || brand.contains(query)
        }.deduplicatedByProductId()
    }
    
    private func baseProducts(_ products: [Product]) -> [Product] {
        switch mode {
        case .category(let category):
            return products
        case .trending:
            return products.filter { $0.averageRating > 4.5 }
        case .flashSales:
            return products.filter { ($0.discountPercentage ?? 0) > 30 }
        case .megaDeals:
            return products.filter { ($0.discountPercentage ?? 0) > 40 }
        }
    }
    
    private func defaultCategoryId() -> String? {
        switch mode {
        case .category(let category):
            return category.id
        case .trending, .flashSales, .megaDeals:
            return nil
        }
    }
}

enum CategoryFilterMode {
    case category(Category)
    case trending
    case flashSales
    case megaDeals
}
