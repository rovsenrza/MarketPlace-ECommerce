@preconcurrency import FirebaseFirestore
import Foundation

nonisolated struct AppNotification: Identifiable, Codable, Hashable, Sendable {
    @DocumentID var id: String?
    let title: String
    let message: String
    let type: String
    let orderId: String?
    let isRead: Bool
    let createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case message
        case type
        case orderId
        case isRead
        case createdAt
    }
}
