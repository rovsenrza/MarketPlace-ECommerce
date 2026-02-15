import Combine
import Foundation

@MainActor
final class WishlistVM: ObservableObject {
    @Published var wishlistItems: [WishlistItem] = []
    @Published var categories: [Category] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let wishlistService: WishlistServiceProtocol
    private let firestoreService: FirestoreServiceProtocol
    private let authService: AuthenticationServiceProtocol
    private var wishlistListenerCancellable: AnyCancellable?
    private var fetchTask: Task<Void, Never>?
    private var listeningUserId: String?
    private var hasLoadedInitialState = false

    init(
        wishlistService: WishlistServiceProtocol,
        firestoreService: FirestoreServiceProtocol,
        authService: AuthenticationServiceProtocol
    ) {
        self.wishlistService = wishlistService
        self.firestoreService = firestoreService
        self.authService = authService
    }

    func fetchWishlistItems(forceRefresh: Bool = false) {
        guard let userId = authService.currentUser?.uid else {
            clearStateForSignedOutUser()
            return
        }

        if !forceRefresh,
           hasLoadedInitialState,
           listeningUserId == userId,
           wishlistListenerCancellable != nil
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
                if self.categories.isEmpty {
                    await self.fetchCategories()
                }
                self.wishlistItems = try await self.wishlistService.fetchWishlistItems(userId: userId)
                self.setupWishlistListener(userId: userId)
                self.hasLoadedInitialState = true
            } catch is CancellationError {
            } catch {
                self.errorMessage = error.localizedDescription
            }
        }
    }

    func addToWishlist(product: Product) {
        Task { @MainActor in
            await addToWishlistAsync(product: product)
        }
    }

    func addToWishlistAsync(product: Product) async {
        guard let userId = authService.currentUser?.uid,
              let productId = product.id else { return }

        if isInWishlist(productId: productId) { return }

        let wishlistItem = WishlistItem(
            id: nil,
            productId: productId,
            product: product,
            addedAt: Date()
        )

        errorMessage = nil

        let insertedIndex = 0
        wishlistItems.insert(wishlistItem, at: insertedIndex)

        do {
            let newId = try await wishlistService.addToWishlist(userId: userId, wishlistItem: wishlistItem)
            if let idx = wishlistItems.firstIndex(where: { $0.productId == productId && $0.id == nil }) {
                var updated = wishlistItems[idx]
                updated.id = newId
                wishlistItems[idx] = updated
            }
        } catch {
            if wishlistItems.indices.contains(insertedIndex), wishlistItems[insertedIndex].productId == productId {
                wishlistItems.remove(at: insertedIndex)
            } else if let idx = wishlistItems.firstIndex(where: { $0.productId == productId }) {
                wishlistItems.remove(at: idx)
            }
            errorMessage = error.localizedDescription
        }
    }

    func removeFromWishlist(product: Product) {
        Task { @MainActor in
            await removeFromWishlistAsync(product: product)
        }
    }

    func removeFromWishlistAsync(product: Product) async {
        guard let userId = authService.currentUser?.uid,
              let productId = product.id else { return }
        guard let idx = wishlistItems.firstIndex(where: { $0.productId == productId }) else { return }

        errorMessage = nil

        let removedItem = wishlistItems.remove(at: idx)
        guard let itemId = removedItem.id else {
            wishlistItems.insert(removedItem, at: idx)
            return
        }

        do {
            try await wishlistService.removeFromWishlist(userId: userId, wishlistItemId: itemId)
        } catch {
            wishlistItems.insert(removedItem, at: idx)
            errorMessage = error.localizedDescription
        }
    }

    func toggleWishlist(product: Product) {
        Task { @MainActor in
            await toggleWishlistAsync(product: product)
        }
    }

    func toggleWishlistAsync(product: Product) async {
        if isInWishlist(productId: product.id ?? "") {
            await removeFromWishlistAsync(product: product)
        } else {
            await addToWishlistAsync(product: product)
        }
    }

    func isInWishlist(productId: String) -> Bool {
        return wishlistItems.contains { $0.productId == productId }
    }

    private func setupWishlistListener(userId: String) {
        if listeningUserId == userId, wishlistListenerCancellable != nil {
            return
        }

        wishlistListenerCancellable?.cancel()
        listeningUserId = userId
        wishlistListenerCancellable = wishlistService.listenToWishlist(userId: userId)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] items in
                    self?.wishlistItems = items
                }
            )
    }

    private func fetchCategories() async {
        do {
            let fetchedCategories: [Category] = try await firestoreService.getDocuments(collection: "categories")
            categories = fetchedCategories
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func clearStateForSignedOutUser() {
        fetchTask?.cancel()
        fetchTask = nil
        wishlistListenerCancellable?.cancel()
        wishlistListenerCancellable = nil
        listeningUserId = nil
        hasLoadedInitialState = false
        wishlistItems = []
        categories = []
        isLoading = false
        errorMessage = nil
    }
}
