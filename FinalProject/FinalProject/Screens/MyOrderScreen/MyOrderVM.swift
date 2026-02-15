import Combine
import Foundation

@MainActor
final class MyOrderVM: ObservableObject {
    @Published var orders: [Order] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let ordersService: OrdersServiceProtocol
    private let notificationsService: NotificationsServiceProtocol
    private let authService: AuthenticationServiceProtocol

    init(ordersService: OrdersServiceProtocol, notificationsService: NotificationsServiceProtocol, authService: AuthenticationServiceProtocol) {
        self.ordersService = ordersService
        self.notificationsService = notificationsService
        self.authService = authService
    }

    func fetchOrders() {
        guard let userId = authService.currentUser?.uid else {
            orders = []
            return
        }

        Task {
            isLoading = true
            errorMessage = nil

            do {
                orders = try await ordersService.fetchOrders(userId: userId)
                await notificationsService.syncOrderStatusNotifications(userId: userId, orders: orders)
            } catch {
                errorMessage = error.localizedDescription
            }

            isLoading = false
        }
    }
}
