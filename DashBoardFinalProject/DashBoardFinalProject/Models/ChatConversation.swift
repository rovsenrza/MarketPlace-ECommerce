import Foundation

struct ChatConversation: Identifiable, Hashable {
    let id: String
    let userId: String
    let lastText: String
    let lastTime: Date

    init(userId: String, lastText: String, lastTime: Date) {
        self.id = userId
        self.userId = userId
        self.lastText = lastText
        self.lastTime = lastTime
    }
}
