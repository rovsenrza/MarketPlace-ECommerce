import Combine
import Foundation

protocol CartServiceProtocol {
    func fetchCartItems(userId: String) async throws -> [CartItem]
    func addToCart(userId: String, cartItem: CartItem) async throws -> String
    func updateCartItemQuantity(userId: String, cartItemId: String, quantity: Int) async throws
    func removeFromCart(userId: String, cartItemId: String) async throws
    func clearCart(userId: String) async throws
    func listenToCart(userId: String) -> AnyPublisher<[CartItem], Error>
    func checkoutCart(userId: String) async throws
}

final class CartService: CartServiceProtocol {
    private let firestoreService: FirestoreServiceProtocol
    
    init(firestoreService: FirestoreServiceProtocol) {
        self.firestoreService = firestoreService
    }
    
    func fetchCartItems(userId: String) async throws -> [CartItem] {
        let cartItems: [CartItem] = try await firestoreService.getDocuments(
            collection: "users/\(userId)/cart"
        )
        
        var itemsWithProducts: [CartItem] = []
        var firstError: Error?
        
        for var cartItem in cartItems {
            do {
                let product: Product = try await firestoreService.getDocument(
                    collection: "products",
                    documentId: cartItem.productId
                )
                cartItem.product = product
                itemsWithProducts.append(cartItem)
            } catch {
                if firstError == nil {
                    firstError = error
                }
            }
        }
        
        if let error = firstError {
            throw error
        }
        return itemsWithProducts.sorted { ($0.addedAt ?? Date()) > ($1.addedAt ?? Date()) }
    }
    
    func addToCart(userId: String, cartItem: CartItem) async throws -> String {
        guard cartItem.product != nil else {
            throw NSError(domain: "CartService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Product data is required"])
        }
        
        let latestProduct: Product = try await firestoreService.getDocument(
            collection: "products",
            documentId: cartItem.productId
        )
        
        let existingItems = try await fetchCartItems(userId: userId)
        
        if let existingItem = existingItems.first(where: {
            $0.productId == cartItem.productId && $0.matchesVariants(cartItem.selectedVariants)
        }) {
            let newQuantity = existingItem.quantity + cartItem.quantity
            
            if let availableStock = latestProduct.stockQuantity, newQuantity > availableStock {
                throw NSError(domain: "CartService", code: -2, userInfo: [NSLocalizedDescriptionKey: "Only \(availableStock) items available in stock"])
            }
            
            guard let existingId = existingItem.id else {
                throw NSError(domain: "CartService", code: -3, userInfo: [NSLocalizedDescriptionKey: "Cart item ID not found"])
            }
            
            try await updateCartItemQuantity(userId: userId, cartItemId: existingId, quantity: newQuantity)
            return existingId
        } else {
            if let availableStock = latestProduct.stockQuantity, cartItem.quantity > availableStock {
                throw NSError(domain: "CartService", code: -2, userInfo: [NSLocalizedDescriptionKey: "Only \(availableStock) items available in stock"])
            }
            
            let documentId = try await firestoreService.addDocument(
                collection: "users/\(userId)/cart",
                data: cartItem
            )
            return documentId
        }
    }
    
    func updateCartItemQuantity(userId: String, cartItemId: String, quantity: Int) async throws {
        try await firestoreService.updateDocument(
            collection: "users/\(userId)/cart",
            documentId: cartItemId,
            data: ["quantity": quantity]
        )
    }
    
    func removeFromCart(userId: String, cartItemId: String) async throws {
        try await firestoreService.deleteDocument(
            collection: "users/\(userId)/cart",
            documentId: cartItemId
        )
    }
    
    func clearCart(userId: String) async throws {
        let cartItems: [CartItem] = try await firestoreService.getDocuments(
            collection: "users/\(userId)/cart"
        )
        
        for item in cartItems {
            if let itemId = item.id {
                try await firestoreService.deleteDocument(
                    collection: "users/\(userId)/cart",
                    documentId: itemId
                )
            }
        }
    }
    
    func listenToCart(userId: String) -> AnyPublisher<[CartItem], Error> {
        return firestoreService.listenToCollection(collection: "users/\(userId)/cart")
            .flatMap { (cartItems: [CartItem]) -> AnyPublisher<[CartItem], Error> in
                if cartItems.isEmpty {
                    return Just([])
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                }
                
                let publishers = cartItems.map { cartItem -> AnyPublisher<CartItem, Error> in
                    Future<CartItem, Error> { promise in
                        Task {
                            do {
                                let product: Product = try await self.firestoreService.getDocument(
                                    collection: "products",
                                    documentId: cartItem.productId
                                )
                                var updatedItem = cartItem
                                updatedItem.product = product
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
                        items.sorted { ($0.addedAt ?? Date()) > ($1.addedAt ?? Date()) }
                    }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    func checkoutCart(userId: String) async throws {
        try await clearCart(userId: userId)
    }
}
