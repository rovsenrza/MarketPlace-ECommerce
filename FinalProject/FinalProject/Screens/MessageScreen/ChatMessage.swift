import Foundation

struct ChatMessage: Hashable {
    let id: String
    let text: String
    let senderId: String
    let senderName: String?
    let isFromAdmin: Bool
    let createdAt: Date

    init(
        id: String,
        text: String,
        senderId: String,
        senderName: String?,
        isFromAdmin: Bool,
        createdAt: Date
    ) {
        self.id = id
        self.text = text
        self.senderId = senderId
        self.senderName = senderName
        self.isFromAdmin = isFromAdmin
        self.createdAt = createdAt
    }

    init?(id: String, data: [String: Any]) {
        guard let text = data["text"] as? String,
              let senderId = data["senderId"] as? String
        else {
            return nil
        }

        let senderName = data["senderName"] as? String
        let isFromAdmin = data["isFromAdmin"] as? Bool ?? false

        let createdAt: Date
        if let timestamp = data["createdAt"] as? TimeInterval {
            createdAt = Date(timeIntervalSince1970: timestamp / 1000)
        } else if let timestamp = data["createdAt"] as? Int {
            createdAt = Date(timeIntervalSince1970: TimeInterval(timestamp) / 1000)
        } else {
            createdAt = Date()
        }

        self.init(
            id: id,
            text: text,
            senderId: senderId,
            senderName: senderName,
            isFromAdmin: isFromAdmin,
            createdAt: createdAt
        )
    }
}
