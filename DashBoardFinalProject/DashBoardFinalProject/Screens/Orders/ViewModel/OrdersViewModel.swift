import Foundation
import Combine

@MainActor
final class OrdersViewModel: ObservableObject {
    @Published private(set) var orders: [Order] = []
    @Published var toast: ToastMessage?

    private let repository: OrdersRepository
    private var toastDismissTask: Task<Void, Never>?
    private var statusUpdatesInFlight: Set<String> = []
    private var pendingStatusByOrderId: [String: OrderStatus] = [:]

    init(repository: OrdersRepository) {
        self.repository = repository
        Task { await loadOrders() }
    }

    deinit {
        toastDismissTask?.cancel()
    }

    var orderCount: Int { orders.count }

    func loadOrders() async {
        do {
            orders = try await repository.fetchOrders()
        } catch {
            showToast(.error("Failed to load orders"))
        }
    }

    func updateStatus(orderId: String, status: OrderStatus) {
        setLocalStatus(orderId: orderId, status: status)
        pendingStatusByOrderId[orderId] = status

        guard !statusUpdatesInFlight.contains(orderId) else { return }
        statusUpdatesInFlight.insert(orderId)

        Task { await processPendingStatusUpdates(for: orderId) }
    }

    private func processPendingStatusUpdates(for orderId: String) async {
        defer { statusUpdatesInFlight.remove(orderId) }

        while true {
            while let nextStatus = pendingStatusByOrderId[orderId] {
                pendingStatusByOrderId[orderId] = nil

                do {
                    try await repository.updateOrderStatus(orderId: orderId, status: nextStatus)
                } catch {
                    await loadOrders()
                    showToast(.error("Failed to update order"))
                    return
                }
            }

            await loadOrders()
            guard pendingStatusByOrderId[orderId] == nil else { continue }
            showToast(.success("Order status updated"))
            return
        }
    }

    private func setLocalStatus(orderId: String, status: OrderStatus) {
        guard let index = orders.firstIndex(where: { $0.id == orderId }) else { return }
        orders[index].status = status
    }

    private func showToast(_ message: ToastMessage) {
        toastDismissTask?.cancel()
        toast = message
        toastDismissTask = Task { [weak self] in
            do {
                try await Task.sleep(nanoseconds: 2_500_000_000)
            } catch {
                return
            }

            guard let self, self.toast?.id == message.id else { return }
            self.toast = nil
        }
    }
}
