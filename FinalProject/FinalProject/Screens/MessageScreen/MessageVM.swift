import Combine
import Foundation

@MainActor
final class MessageVM: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var inputText: String = ""
    @Published var errorMessage: String?

    let supportName: String
    let isSupportOnline: Bool

    private let chatService: ChatServiceProtocol
    private let authService: AuthenticationServiceProtocol
    private var streamTask: Task<Void, Never>?
    private var messageIds = Set<String>()

    init(
        chatService: ChatServiceProtocol,
        authService: AuthenticationServiceProtocol,
        supportName: String = "Admin",
        isSupportOnline: Bool = true
    ) {
        self.chatService = chatService
        self.authService = authService
        self.supportName = supportName
        self.isSupportOnline = isSupportOnline
    }

    func start() {
        guard let userId = authService.currentUser?.uid else {
            errorMessage = "Please sign in to start a chat."
            return
        }

        streamTask?.cancel()
        messages.removeAll()
        messageIds.removeAll()

        streamTask = Task { [weak self] in
            guard let self else { return }

            do {
                for try await message in chatService.messagesStream(userId: userId) {
                    if Task.isCancelled { break }
                    guard !messageIds.contains(message.id) else { continue }

                    messageIds.insert(message.id)
                    messages.append(message)
                    messages.sort { $0.createdAt < $1.createdAt }
                }
            } catch {
                if !Task.isCancelled {
                    errorMessage = error.localizedDescription
                }
            }
        }
    }

    func stop() {
        streamTask?.cancel()
        streamTask = nil
    }

    func sendCurrentMessage() {
        let trimmed = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        guard let user = authService.currentUser else {
            errorMessage = "Please sign in to send messages."
            return
        }

        let senderName = user.displayName ?? user.email
        let userId = user.uid
        inputText = ""

        Task {
            do {
                try await chatService.sendMessage(
                    userId: userId,
                    text: trimmed,
                    senderId: userId,
                    senderName: senderName,
                    isFromAdmin: false
                )
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}
