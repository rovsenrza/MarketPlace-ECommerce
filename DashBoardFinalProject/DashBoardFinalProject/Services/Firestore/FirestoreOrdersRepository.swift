import Foundation
import FirebaseFirestore

final class FirestoreOrdersRepository: OrdersRepository {
    private let db = Firestore.firestore()

    func fetchOrders() async throws -> [Order] {
        let snapshot = try await db.collection("orders").getDocuments()
        return snapshot.documents.map { doc in
            let data = doc.data()
            let shipping = data["shippingAddress"] as? [String: Any]
            let statusRaw = data["status"] as? String ?? OrderStatus.onDelivery.rawValue
            return Order(
                id: doc.documentID,
                orderNumber: Self.stringValue(from: data["orderNumber"]) ?? "—",
                customerName: shipping?["name"] as? String ?? "—",
                total: Self.doubleValue(from: data["total"]) ?? 0,
                status: OrderStatus(rawValue: statusRaw) ?? .onDelivery
            )
        }
    }

    func updateOrderStatus(orderId: String, status: OrderStatus) async throws {
        try await db.collection("orders").document(orderId).updateData([
            "status": status.rawValue
        ])
    }

    private static func doubleValue(from value: Any?) -> Double? {
        if let doubleValue = value as? Double { return doubleValue }
        if let intValue = value as? Int { return Double(intValue) }
        if let number = value as? NSNumber { return number.doubleValue }
        return nil
    }

    private static func stringValue(from value: Any?) -> String? {
        if let stringValue = value as? String { return stringValue }
        if let intValue = value as? Int { return String(intValue) }
        if let doubleValue = value as? Double { return String(Int(doubleValue)) }
        if let number = value as? NSNumber { return number.stringValue }
        return nil
    }
}
