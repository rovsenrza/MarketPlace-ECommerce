import Combine
import Foundation

@MainActor
final class NotificationsVM: ObservableObject {
    @Published var notifications: [AppNotification] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let notificationsService: NotificationsServiceProtocol
    private let authService: AuthenticationServiceProtocol

    init(notificationsService: NotificationsServiceProtocol, authService: AuthenticationServiceProtocol) {
        self.notificationsService = notificationsService
        self.authService = authService
    }

    func fetchNotifications() {
        guard let userId = authService.currentUser?.uid else {
            notifications = []
            return
        }

        Task {
            isLoading = true
            errorMessage = nil

            do {
                notifications = try await notificationsService.fetchNotifications(userId: userId)
            } catch {
                errorMessage = error.localizedDescription
            }

            isLoading = false
        }
    }

    func markRead(_ notification: AppNotification) {
        guard let userId = authService.currentUser?.uid,
              let notificationId = notification.id,
              notification.isRead == false else { return }

        Task {
            do {
                try await notificationsService.markNotificationRead(userId: userId, notificationId: notificationId)
                notifications = notifications.map { item in
                    guard item.id == notificationId else { return item }

                    return AppNotification(
                        id: item.id,
                        title: item.title,
                        message: item.message,
                        type: item.type,
                        orderId: item.orderId,
                        isRead: true,
                        createdAt: item.createdAt
                    )
                }
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}
