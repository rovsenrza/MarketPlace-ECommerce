import Combine
import Foundation

@MainActor
final class SearchResultVM: ObservableObject {
    @Published var searchText: String = ""
    @Published var products: [Product] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let catalogService: CatalogServiceProtocol
    private var searchTask: Task<Void, Never>?
    
    init(catalogService: CatalogServiceProtocol) {
        self.catalogService = catalogService
    }
    
    func search(_ query: String) {
        searchTask?.cancel()
        
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        searchText = trimmedQuery
        
        guard !trimmedQuery.isEmpty else {
            products = []
            return
        }
        
        isLoading = true
        
        searchTask = Task {
            do {
                try await Task.sleep(nanoseconds: 300_000_000)
                
                guard !Task.isCancelled else { return }
                
                let allProducts = try await catalogService.fetchProductsWithReviews()
                
                guard !Task.isCancelled else { return }
                
                let query = trimmedQuery.lowercased()
                let filtered = allProducts.filter { product in
                    let titleMatch = product.title.lowercased().contains(query)
                    let brandMatch = product.brand?.lowercased().contains(query) ?? false
                    let descMatch = product.description?.lowercased().contains(query) ?? false
                    return titleMatch || brandMatch || descMatch
                }
                
                products = filtered
                isLoading = false
            } catch {
                if !Task.isCancelled {
                    errorMessage = error.localizedDescription
                    isLoading = false
                }
            }
        }
    }
    
    func clearSearch() {
        searchTask?.cancel()
        searchText = ""
        products = []
        isLoading = false
    }
}
