import Foundation
import Combine
@MainActor
final class MessagesViewModel: ObservableObject {
    @Published private(set) var conversations: [ChatConversation] = []
    @Published private(set) var messages: [ChatMessage] = []
    @Published private(set) var profiles: [String: UserProfile] = [:]
    @Published var selectedUserId: String? = nil
    @Published var messageText: String = ""
    @Published var toast: ToastMessage?

    private let chatRepository: ChatRepository
    private let userProfilesRepository: UserProfilesRepository
    private var conversationsListener: ChatListener?
    private var messagesListener: ChatListener?
    private var toastDismissTask: Task<Void, Never>?

    init(chatRepository: ChatRepository, userProfilesRepository: UserProfilesRepository) {
        self.chatRepository = chatRepository
        self.userProfilesRepository = userProfilesRepository
        Task { await start() }
    }

    @MainActor deinit {
        toastDismissTask?.cancel()
        conversationsListener?.stop()
        messagesListener?.stop()
    }

    func start() async {
        await loadProfiles()
        listenForConversations()
    }

    func loadProfiles() async {
        do {
            profiles = try await userProfilesRepository.fetchUserProfiles()
        } catch {
            showToast(.error("Failed to load users"))
        }
    }

    func listenForConversations() {
        conversationsListener?.stop()
        conversationsListener = chatRepository.observeChatUsers { [weak self] conversations in
            guard let self else { return }
            Task { @MainActor in
                self.conversations = conversations
                if self.selectedUserId == nil, let first = conversations.first {
                    self.selectConversation(first.userId)
                } else if let selected = self.selectedUserId, !conversations.contains(where: { $0.userId == selected }) {
                    self.messagesListener?.stop()
                    self.messagesListener = nil
                    self.selectedUserId = nil
                    self.messages = []
                }
            }
        }
    }

    func selectConversation(_ userId: String) {
        selectedUserId = userId
        listenForMessages(userId: userId)
    }

    func listenForMessages(userId: String) {
        messagesListener?.stop()
        messagesListener = chatRepository.observeMessages(userId: userId) { [weak self] messages in
            guard let self else { return }
            Task { @MainActor in
                self.messages = messages
            }
        }
    }

    func sendMessage() async {
        let text = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        guard let userId = selectedUserId else {
            showToast(.error("Select a conversation first"))
            return
        }
        do {
            try await chatRepository.sendAdminMessage(text: text, to: userId)
            messageText = ""
        } catch {
            showToast(.error("Failed to send message"))
        }
    }

    func label(for userId: String) -> String {
        if let profile = profiles[userId] {
            if !profile.displayName.isEmpty { return profile.displayName }
            if !profile.email.isEmpty { return profile.email }
        }
        return userId
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
