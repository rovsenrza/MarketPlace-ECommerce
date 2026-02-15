import Foundation

final class ChatListener {
    private let cancelBlock: () -> Void
    private var isActive = true

    init(cancel: @escaping () -> Void) {
        self.cancelBlock = cancel
    }

    func stop() {
        guard isActive else { return }
        isActive = false
        cancelBlock()
    }
}

protocol ChatRepository {
    func observeChatUsers(_ onChange: @escaping ([ChatConversation]) -> Void) -> ChatListener
    func observeMessages(userId: String, _ onChange: @escaping ([ChatMessage]) -> Void) -> ChatListener
    func sendAdminMessage(text: String, to userId: String) async throws
}
