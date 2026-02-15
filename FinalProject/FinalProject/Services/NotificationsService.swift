import Foundation

protocol NotificationsServiceProtocol {
    func addNotification(userId: String, notification: AppNotification) async throws -> String
    func fetchNotifications(userId: String) async throws -> [AppNotification]
    func markNotificationRead(userId: String, notificationId: String) async throws
    func syncOrderStatusNotifications(userId: String, orders: [Order]) async
}

final class NotificationsService: NotificationsServiceProtocol {
    private let firestoreService: FirestoreServiceProtocol

    init(firestoreService: FirestoreServiceProtocol) {
        self.firestoreService = firestoreService
    }

    func addNotification(userId: String, notification: AppNotification) async throws -> String {
        try await firestoreService.addDocument(
            collection: "users/\(userId)/notifications",
            data: notification
        )
    }

    func fetchNotifications(userId: String) async throws -> [AppNotification] {
        let notifications: [AppNotification] = try await firestoreService.getDocuments(
            collection: "users/\(userId)/notifications"
        )

        return notifications.sorted { ($0.createdAt ?? Date.distantPast) > ($1.createdAt ?? Date.distantPast) }
    }

    func markNotificationRead(userId: String, notificationId: String) async throws {
        try await firestoreService.updateDocument(
            collection: "users/\(userId)/notifications",
            documentId: notificationId,
            data: ["isRead": true]
        )
    }

    func syncOrderStatusNotifications(userId: String, orders: [Order]) async {
        let cacheKey = "orderStatusCache_\(userId)"
        var cached = UserDefaults.standard.dictionary(forKey: cacheKey) as? [String: String] ?? [:]
        var needsSave = false

        for order in orders {
            let orderKey = order.id ?? order.orderNumber
            let currentStatus = order.status
            let normalizedStatus = currentStatus.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            let previousStatus = cached[orderKey]
            let normalizedPreviousStatus = previousStatus?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

            let isDelivered = normalizedStatus == "delivered"
            let wasDelivered = normalizedPreviousStatus == "delivered"

            if isDelivered, wasDelivered == false {
                let notification = AppNotification(
                    id: nil,
                    title: "Order Delivered",
                    message: "Your order #\(order.orderNumber) has been delivered.",
                    type: "order_delivered",
                    orderId: order.id,
                    isRead: false,
                    createdAt: Date()
                )
                try? await addNotification(userId: userId, notification: notification)
            }

            if let previousStatus = previousStatus {
                if normalizedPreviousStatus != normalizedStatus {
                    cached[orderKey] = normalizedStatus
                    needsSave = true
                }
            } else {
                cached[orderKey] = normalizedStatus
                needsSave = true
            }
        }

        if needsSave {
            UserDefaults.standard.set(cached, forKey: cacheKey)
        }
    }
}
