import Foundation

struct ChatMessage: Identifiable, Hashable {
    let id: String
    let text: String
    let senderId: String
    let senderName: String
    let isFromAdmin: Bool
    let createdAt: Date
}
