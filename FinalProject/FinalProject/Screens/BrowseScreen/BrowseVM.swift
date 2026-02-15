import Combine
import Foundation

@MainActor
final class BrowseVM: ObservableObject {
    @Published var categories: [Category] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let catalogService: CatalogServiceProtocol
    
    init(catalogService: CatalogServiceProtocol) {
        self.catalogService = catalogService
    }
    
    func fetchCategories() {
        isLoading = true
        errorMessage = nil
        
        Task { @MainActor in
            do {
                categories = try await catalogService.fetchCategories()
                isLoading = false
            } catch {
                errorMessage = error.localizedDescription
                isLoading = false
            }
        }
    }
}
