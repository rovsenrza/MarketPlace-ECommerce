import Foundation

protocol OrdersServiceProtocol {
    func createOrder(userId: String, order: Order) async throws -> String
    func fetchOrders(userId: String) async throws -> [Order]
    func nextOrderNumber() async throws -> String
}

final class OrdersService: OrdersServiceProtocol {
    private let firestoreService: FirestoreServiceProtocol

    init(firestoreService: FirestoreServiceProtocol) {
        self.firestoreService = firestoreService
    }

    func createOrder(userId: String, order: Order) async throws -> String {
        let orderId = UUID().uuidString

        try await firestoreService.setDocument(
            collection: "orders",
            documentId: orderId,
            data: order,
            merge: true
        )

        try await firestoreService.setDocument(
            collection: "users/\(userId)/orders",
            documentId: orderId,
            data: order,
            merge: true
        )

        return orderId
    }

    func fetchOrders(userId: String) async throws -> [Order] {
        let allOrders: [Order] = try await firestoreService.getDocuments(
            collection: "orders"
        )

        let orders = allOrders.filter { $0.userId == userId }
        return orders.sorted { ($0.createdAt ?? Date.distantPast) > ($1.createdAt ?? Date.distantPast) }
    }

    func nextOrderNumber() async throws -> String {
        let counterCollection = "metadata"
        let counterDocument = "orderCounter"

        struct OrderCounter: Codable {
            let nextValue: Int
        }

        let current: Int
        if let counter: OrderCounter = try? await firestoreService.getDocument(collection: counterCollection, documentId: counterDocument) {
            current = counter.nextValue
        } else {
            current = 1
        }

        let nextValue = current + 1
        try await firestoreService.setData(
            collection: counterCollection,
            documentId: counterDocument,
            data: ["nextValue": nextValue],
            merge: true
        )

        return String(format: "%05d", current)
    }
}
