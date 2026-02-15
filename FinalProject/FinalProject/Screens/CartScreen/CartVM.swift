import Combine
import Foundation

@MainActor
final class CartVM: ObservableObject {
    // MARK: - Published Properties
    
    @Published var cartItems: [CartItem] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // MARK: - Private Properties
    
    private let cartService: CartServiceProtocol
    private let authService: AuthenticationServiceProtocol
    private var cartListenerCancellable: AnyCancellable?
    private var fetchTask: Task<Void, Never>?
    private var listeningUserId: String?
    private var hasLoadedInitialState = false
    
    // MARK: - Initialization
    
    init(
        cartService: CartServiceProtocol,
        authService: AuthenticationServiceProtocol
    ) {
        self.cartService = cartService
        self.authService = authService
    }
    
    // MARK: - Public Methods
    
    func fetchCartItems(forceRefresh: Bool = false) {
        guard let userId = authService.currentUser?.uid else {
            clearStateForSignedOutUser()
            return
        }

        if !forceRefresh,
           hasLoadedInitialState,
           listeningUserId == userId,
           cartListenerCancellable != nil
        {
            return
        }

        fetchTask?.cancel()
        fetchTask = Task { @MainActor [weak self] in
            guard let self = self else { return }

            self.isLoading = true
            self.errorMessage = nil
            defer {
                self.isLoading = false
                self.fetchTask = nil
            }

            do {
                self.cartItems = try await self.cartService.fetchCartItems(userId: userId)
                self.setupCartListener(userId: userId)
                self.hasLoadedInitialState = true
            } catch is CancellationError {
            } catch {
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    func addToCart(product: Product, quantity: Int = 1, selectedVariants: [String: String]? = nil) {
        guard let userId = authService.currentUser?.uid else {
            errorMessage = "User not authenticated"
            return
        }
        guard let productId = product.id else {
            errorMessage = "Product ID not found"
            return
        }
        
        let cartItem = CartItem(
            id: nil,
            productId: productId,
            product: product,
            quantity: quantity,
            selectedVariants: selectedVariants,
            addedAt: Date()
        )
        
        Task {
            do {
                _ = try await cartService.addToCart(userId: userId, cartItem: cartItem)
                errorMessage = nil
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
    
    func updateQuantity(for item: CartItem, quantity: Int) {
        guard let userId = authService.currentUser?.uid,
              let itemId = item.id,
              quantity > 0 else { return }
        
        Task {
            do {
                try await cartService.updateCartItemQuantity(userId: userId, cartItemId: itemId, quantity: quantity)
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
    
    func removeFromCart(item: CartItem) {
        guard let userId = authService.currentUser?.uid,
              let itemId = item.id else { return }
        
        Task {
            do {
                try await cartService.removeFromCart(userId: userId, cartItemId: itemId)
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
    
    func clearCart() {
        guard let userId = authService.currentUser?.uid else { return }
        
        Task {
            do {
                try await cartService.clearCart(userId: userId)
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
    
    func calculateSubtotal() -> Double {
        return cartItems.reduce(0.0) { total, item in
            guard let product = item.product else { return total }

            let price = product.discountPrice ?? product.basePrice
            return total + (price * Double(item.quantity))
        }
    }
    
    func isInCart(productId: String) -> Bool {
        return cartItems.contains { $0.productId == productId }
    }
    
    func checkout() {
        guard let userId = authService.currentUser?.uid else { return }
        
        Task {
            isLoading = true
            do {
                try await cartService.checkoutCart(userId: userId)
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
    
    // MARK: - Private Methods
    
    private func setupCartListener(userId: String) {
        if listeningUserId == userId, cartListenerCancellable != nil {
            return
        }

        cartListenerCancellable?.cancel()
        listeningUserId = userId
        cartListenerCancellable = cartService.listenToCart(userId: userId)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] items in
                    self?.cartItems = items
                }
            )
    }

    private func clearStateForSignedOutUser() {
        fetchTask?.cancel()
        fetchTask = nil
        cartListenerCancellable?.cancel()
        cartListenerCancellable = nil
        listeningUserId = nil
        hasLoadedInitialState = false
        cartItems = []
        isLoading = false
        errorMessage = nil
    }
}
