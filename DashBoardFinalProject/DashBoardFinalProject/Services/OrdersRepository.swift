import Foundation

protocol OrdersRepository {
    func fetchOrders() async throws -> [Order]
    func updateOrderStatus(orderId: String, status: OrderStatus) async throws
}
