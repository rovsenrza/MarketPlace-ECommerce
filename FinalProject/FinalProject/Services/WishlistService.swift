import Combine
import Foundation

protocol WishlistServiceProtocol {
    func fetchWishlistItems(userId: String) async throws -> [WishlistItem]
    func addToWishlist(userId: String, wishlistItem: WishlistItem) async throws -> String
    func removeFromWishlist(userId: String, wishlistItemId: String) async throws
    func isInWishlist(userId: String, productId: String) async throws -> Bool
    func listenToWishlist(userId: String) -> AnyPublisher<[WishlistItem], Error>
}

final class WishlistService: WishlistServiceProtocol {
    private let firestoreService: FirestoreServiceProtocol
    
    init(firestoreService: FirestoreServiceProtocol) {
        self.firestoreService = firestoreService
    }
    
    func fetchWishlistItems(userId: String) async throws -> [WishlistItem] {
        let wishlistItems: [WishlistItem] = try await firestoreService.getDocuments(
            collection: "users/\(userId)/wishlist"
        )
        
        var itemsWithProducts: [WishlistItem] = []
        var firstError: Error?
        
        for var wishlistItem in wishlistItems {
            do {
                let product: Product = try await firestoreService.getDocument(
                    collection: "products",
                    documentId: wishlistItem.productId
                )
                var enrichedProduct = product
                if let reviews: [Review] = try? await firestoreService.getDocuments(
                    collection: "products/\(wishlistItem.productId)/reviews"
                ) {
                    enrichedProduct.reviews = reviews
                }
                wishlistItem.product = enrichedProduct
                itemsWithProducts.append(wishlistItem)
            } catch {
                if firstError == nil {
                    firstError = error
                }
            }
        }
        
        if let error = firstError {
            throw error
        }
        let sortedItems = itemsWithProducts.sorted { ($0.addedAt ?? Date()) > ($1.addedAt ?? Date()) }
        return deduplicatedByProductId(sortedItems)
    }
    
    func addToWishlist(userId: String, wishlistItem: WishlistItem) async throws -> String {
        let documentId = wishlistItem.productId
        try await firestoreService.setDocument(
            collection: "users/\(userId)/wishlist",
            documentId: documentId,
            data: wishlistItem,
            merge: true
        )
        return documentId
    }
    
    func removeFromWishlist(userId: String, wishlistItemId: String) async throws {
        try await firestoreService.deleteDocument(
            collection: "users/\(userId)/wishlist",
            documentId: wishlistItemId
        )
    }
    
    func isInWishlist(userId: String, productId: String) async throws -> Bool {
        let wishlistItems: [WishlistItem] = try await firestoreService.getDocuments(
            collection: "users/\(userId)/wishlist"
        )
        
        return wishlistItems.contains { $0.productId == productId }
    }
    
    func listenToWishlist(userId: String) -> AnyPublisher<[WishlistItem], Error> {
        return firestoreService.listenToCollection(collection: "users/\(userId)/wishlist")
            .flatMap { (wishlistItems: [WishlistItem]) -> AnyPublisher<[WishlistItem], Error> in
                if wishlistItems.isEmpty {
                    return Just([])
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                }
                
                let publishers = wishlistItems.map { wishlistItem -> AnyPublisher<WishlistItem, Error> in
                    Future<WishlistItem, Error> { promise in
                        Task {
                            do {
                                let product: Product = try await self.firestoreService.getDocument(
                                    collection: "products",
                                    documentId: wishlistItem.productId
                                )
                                var enrichedProduct = product
                                let reviews: [Review] = try await self.firestoreService.getDocuments(
                                    collection: "products/\(wishlistItem.productId)/reviews"
                                )
                                enrichedProduct.reviews = reviews
                                var updatedItem = wishlistItem
                                updatedItem.product = enrichedProduct
                                promise(.success(updatedItem))
                            } catch {
                                promise(.failure(error))
                            }
                        }
                    }
                    .eraseToAnyPublisher()
                }
                
                return Publishers.MergeMany(publishers)
                    .collect()
                    .map { items in
                        let sortedItems = items.sorted { ($0.addedAt ?? Date()) > ($1.addedAt ?? Date()) }
                        return self.deduplicatedByProductId(sortedItems)
                    }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    private func deduplicatedByProductId(_ items: [WishlistItem]) -> [WishlistItem] {
        var seenProductIds = Set<String>()
        var uniqueItems: [WishlistItem] = []
        uniqueItems.reserveCapacity(items.count)

        for item in items {
            if seenProductIds.insert(item.productId).inserted {
                uniqueItems.append(item)
            }
        }

        return uniqueItems
    }
}
