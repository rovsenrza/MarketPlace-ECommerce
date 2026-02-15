import Combine
import Foundation

@MainActor
protocol WishlistStateStore {
    var wishlistItemsPublisher: AnyPublisher<[WishlistItem], Never> { get }
    func isInWishlist(productId: String) -> Bool
    func toggleWishlistAsync(product: Product) async
}

extension WishlistVM: WishlistStateStore {
    var wishlistItemsPublisher: AnyPublisher<[WishlistItem], Never> {
        $wishlistItems.eraseToAnyPublisher()
    }
}

@MainActor
protocol CartActionHandler {
    var errorMessagePublisher: AnyPublisher<String?, Never> { get }
    func addToCart(product: Product, quantity: Int, selectedVariants: [String: String]?)
}

extension CartVM: CartActionHandler {
    var errorMessagePublisher: AnyPublisher<String?, Never> {
        $errorMessage.eraseToAnyPublisher()
    }
}

@MainActor
final class ProductDetailVM {
    // MARK: - Published Properties
    
    @Published var product: Product
    @Published var selectedVariants: [String: String] = [:]
    @Published var quantity: Int = 1
    @Published var isInWishlist: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var variantSelectionChanged: Bool = false
    @Published var categoryName: String = ""
    
    // MARK: - Private Properties
    
    private let wishlistStore: WishlistStateStore
    private let cartHandler: CartActionHandler
    private let categoryService: CategoryServiceProtocol
    private let reviewService: ReviewServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Computed Properties
    
    var availableVariantKeys: [String] {
        guard let variants = product.variants else { return [] }

        return variants.keys.filter { $0 != "images" }.sorted()
    }
    
    func getVariantOptions(for key: String) -> [String] {
        return product.variants?[key] ?? []
    }
    
    func getSelectedValue(for key: String) -> String? {
        return selectedVariants[key]
    }
    
    func getSelectedIndex(for key: String) -> Int {
        guard let selected = selectedVariants[key],
              let options = product.variants?[key],
              let index = options.firstIndex(of: selected)
        else {
            return 0
        }

        return index
    }
    
    var displayPrice: Double {
        return product.discountPrice ?? product.basePrice
    }
    
    var hasDiscount: Bool {
        return product.discountPrice != nil
    }
    
    var discountPercentage: Int? {
        guard let discountPrice = product.discountPrice else { return nil }

        let discount = ((product.basePrice - discountPrice) / product.basePrice) * 100
        return Int(discount)
    }
    
    var averageRating: Double {
        guard let reviews = product.reviews, !reviews.isEmpty else { return 0.0 }

        let total = reviews.reduce(0.0) { $0 + Double($1.stars) }
        return total / Double(reviews.count)
    }
    
    var reviewCount: Int {
        return product.reviews?.count ?? 0
    }
    
    var ratingDistribution: [Int: Int] {
        guard let reviews = product.reviews else { return [:] }

        var distribution: [Int: Int] = [5: 0, 4: 0, 3: 0, 2: 0, 1: 0]
        
        for review in reviews {
            let rating = Int(review.stars)
            distribution[rating, default: 0] += 1
        }
        
        return distribution
    }
    
    // MARK: - Initialization
    
    init(
        product: Product,
        wishlistStore: WishlistStateStore,
        cartHandler: CartActionHandler,
        categoryService: CategoryServiceProtocol,
        reviewService: ReviewServiceProtocol
    ) {
        self.product = product
        self.wishlistStore = wishlistStore
        self.cartHandler = cartHandler
        self.categoryService = categoryService
        self.reviewService = reviewService
        
        initializeDefaultVariants()
        
        checkWishlistStatus()
        setupWishlistListener()
        setupCartErrorListener()
        setupReviewListener()
        fetchCategoryName()
    }
    
    // MARK: - Public Methods
    
    func incrementQuantity() {
        let maxStock = product.stockQuantity ?? 99
        guard quantity < maxStock else { return }

        quantity += 1
    }
    
    func decrementQuantity() {
        guard quantity > 1 else { return }

        quantity -= 1
    }
    
    func toggleWishlist() {
        Task { @MainActor in
            await wishlistStore.toggleWishlistAsync(product: product)
            checkWishlistStatus()
        }
    }
    
    func addToCart() {
        cartHandler.addToCart(
            product: product,
            quantity: quantity,
            selectedVariants: selectedVariants.isEmpty ? nil : selectedVariants
        )
    }
    
    func selectVariant(key: String, value: String) {
        selectedVariants[key] = value
        variantSelectionChanged.toggle()
    }
    
    func initializeDefaultVariants() {
        guard let variants = product.variants else { return }

        for (key, values) in variants where key != "images" && !values.isEmpty {
            if selectedVariants[key] == nil {
                selectedVariants[key] = values[0]
            }
        }
    }

    func clearError() {
        errorMessage = nil
    }
    
    // MARK: - Private Methods
    
    private func checkWishlistStatus() {
        guard let productId = product.id else { return }

        isInWishlist = wishlistStore.isInWishlist(productId: productId)
    }
    
    private func setupWishlistListener() {
        wishlistStore.wishlistItemsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.checkWishlistStatus()
            }
            .store(in: &cancellables)
    }

    private func setupCartErrorListener() {
        cartHandler.errorMessagePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] message in
                guard let message, !message.isEmpty else { return }

                self?.errorMessage = message
            }
            .store(in: &cancellables)
    }
    
    private func fetchCategoryName() {
        guard let categoryIds = product.categoryIds,
              let firstCategoryId = categoryIds.first
        else {
            categoryName = product.brand ?? ""
            return
        }
        
        Task { @MainActor in
            do {
                let category = try await categoryService.fetchCategory(id: firstCategoryId)
                self.categoryName = category.title
            } catch {
                self.categoryName = self.product.brand ?? ""
            }
        }
    }
    
    private func setupReviewListener() {
        guard let productId = product.id else { return }
        
        reviewService.listenToReviews(productId: productId)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] reviews in
                    guard let self = self else { return }

                    var updatedProduct = self.product
                    updatedProduct.reviews = reviews
                    self.product = updatedProduct
                }
            )
            .store(in: &cancellables)
    }
}
