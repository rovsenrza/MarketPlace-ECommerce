import Combine
import Foundation

@MainActor
final class OrderDetailVM: ObservableObject {
    let order: Order
    private let firestoreService: FirestoreServiceProtocol

    init(order: Order, firestoreService: FirestoreServiceProtocol) {
        self.order = order
        self.firestoreService = firestoreService
    }

    func fetchProduct(productId: String) async throws -> Product {
        return try await firestoreService.getDocument(collection: "products", documentId: productId)
    }
}
