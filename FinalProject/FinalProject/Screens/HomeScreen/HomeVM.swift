import Combine
import Foundation

@MainActor
final class HomeVM: ObservableObject {
    // MARK: - Published Properties
    
    @Published var featuredProducts: [Product] = []
    @Published var categories: [Category] = []
    @Published var allProducts: [Product] = []
    @Published var filteredProducts: [Product] = []
    @Published var selectedCategoryIndex: Int = 0
    @Published var selectedCategoryId: String?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var unreadNotificationsCount: Int = 0
    @Published var filterQuery: FilterQuery = .init()
    
    // MARK: - Private Properties
    
    private let catalogService: CatalogServiceProtocol
    private let notificationsService: NotificationsServiceProtocol
    private let authService: AuthenticationServiceProtocol
    private let filterService: FilterServiceProtocol

    // MARK: - Initialization

    init(
        catalogService: CatalogServiceProtocol,
        notificationsService: NotificationsServiceProtocol,
        authService: AuthenticationServiceProtocol,
        filterService: FilterServiceProtocol
    ) {
        self.catalogService = catalogService
        self.notificationsService = notificationsService
        self.authService = authService
        self.filterService = filterService
    }
    
    // MARK: - Public Methods
    
    func fetchData() {
        isLoading = true
        loadMockFeaturedProducts()
        errorMessage = nil

        Task { @MainActor in
            do {
                async let categories = catalogService.fetchCategories()
                async let products = catalogService.fetchProductsWithReviews()
                let (fetchedCategories, fetchedProducts) = try await (categories, products)

                self.categories = fetchedCategories
                self.allProducts = fetchedProducts.deduplicatedByProductId()
                self.applyFilters()
                self.isLoading = false
            } catch {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    private func loadMockFeaturedProducts() {
        featuredProducts = [
            Product(
                id: "featured1",
                title: "Nike Air Zoom",
                description: "Step into the future of comfort",
                brand: "Nike",
                categoryIds: [],
                basePrice: 299.00,
                discountPrice: nil,
                imageUrl: "https://images.unsplash.com/photo-1542291026-7eec264c27ff",
                
                variants: nil,
                reviews: nil,
                createdAt: nil
            ),
            Product(
                id: "featured2",
                title: "Series 8 Pro",
                description: "Up to 20% off this weekend",
                brand: "Apple",
                categoryIds: [],
                basePrice: 499.00,
                discountPrice: 399.00,
                imageUrl: "https://images.unsplash.com/photo-1579586337278-3befd40fd17a",
                
                variants: nil,
                reviews: nil,
                createdAt: nil
            )
        ]
    }
    
    func filterProducts(byCategoryId categoryId: String?) {
        selectedCategoryId = categoryId
        filterQuery.categoryId = nil
        applyFilters()
    }

    func applyFilterQuery(_ query: FilterQuery) {
        filterQuery = query
        if let categoryId = query.categoryId {
            selectedCategoryId = categoryId
            if let index = categories.firstIndex(where: { $0.id == categoryId }) {
                selectedCategoryIndex = index + 1
            } else {
                selectedCategoryIndex = 0
            }
        } else {
            selectedCategoryId = nil
            selectedCategoryIndex = 0
        }
        applyFilters()
    }
    
    private func applyFilters() {
        filteredProducts = filterService.applyFilters(
            products: allProducts,
            query: filterQuery,
            fallbackCategoryId: selectedCategoryId
        ).deduplicatedByProductId()
    }

    func refreshUnreadNotifications() {
        guard let userId = authService.currentUser?.uid else {
            unreadNotificationsCount = 0
            return
        }

        Task {
            let notifications = try? await notificationsService.fetchNotifications(userId: userId)
            let count = notifications?.filter { $0.isRead == false }.count ?? 0
            unreadNotificationsCount = count
        }
    }
    
    // MARK: - Private Methods
}
