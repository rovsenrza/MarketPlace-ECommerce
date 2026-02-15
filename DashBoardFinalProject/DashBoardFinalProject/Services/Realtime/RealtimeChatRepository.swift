import Foundation
import FirebaseDatabase
import FirebaseCore

final class RealtimeChatRepository: ChatRepository {
    private let rtdb: DatabaseReference
    private static let fallbackDatabaseURL = "https://finalproject-6d2f4-default-rtdb.europe-west1.firebasedatabase.app"

    init(rtdb: DatabaseReference = RealtimeChatRepository.makeReference()) {
        self.rtdb = rtdb
    }

    func observeChatUsers(_ onChange: @escaping ([ChatConversation]) -> Void) -> ChatListener {
        let ref = rtdb.child("messages")
        let handle = ref.observe(.value) { snapshot in
            var conversations: [ChatConversation] = []
            for case let userSnapshot as DataSnapshot in snapshot.children {
                let userId = userSnapshot.key
                var lastText = "No messages yet"
                var lastTime = Date(timeIntervalSince1970: 0)

                for case let messageSnapshot as DataSnapshot in userSnapshot.children {
                    let data = messageSnapshot.value as? [String: Any] ?? [:]
                    let text = data["text"] as? String ?? ""
                    let time = Self.timestamp(from: data["createdAt"]) ?? 0
                    if time >= lastTime.timeIntervalSince1970 {
                        lastTime = Date(timeIntervalSince1970: time)
                        if !text.isEmpty {
                            lastText = text
                        }
                    }
                }

                conversations.append(ChatConversation(userId: userId, lastText: lastText, lastTime: lastTime))
            }
            conversations.sort { $0.lastTime > $1.lastTime }
            onChange(conversations)
        }

        return ChatListener {
            ref.removeObserver(withHandle: handle)
        }
    }

    func observeMessages(userId: String, _ onChange: @escaping ([ChatMessage]) -> Void) -> ChatListener {
        let ref = rtdb.child("messages").child(userId)
        let handle = ref.observe(.value) { snapshot in
            var messages: [ChatMessage] = []
            for case let child as DataSnapshot in snapshot.children {
                let data = child.value as? [String: Any] ?? [:]
                let text = data["text"] as? String ?? ""
                let senderId = data["senderId"] as? String ?? ""
                let senderName = data["senderName"] as? String ?? ""
                let isFromAdmin = data["isFromAdmin"] as? Bool ?? false
                let time = Self.timestamp(from: data["createdAt"]) ?? 0
                let message = ChatMessage(
                    id: child.key,
                    text: text,
                    senderId: senderId,
                    senderName: senderName,
                    isFromAdmin: isFromAdmin,
                    createdAt: Date(timeIntervalSince1970: time)
                )
                messages.append(message)
            }
            messages.sort { $0.createdAt < $1.createdAt }
            onChange(messages)
        }

        return ChatListener {
            ref.removeObserver(withHandle: handle)
        }
    }

    func sendAdminMessage(text: String, to userId: String) async throws {
        let payload: [String: Any] = [
            "text": text,
            "senderId": "admin",
            "senderName": "Admin",
            "isFromAdmin": true,
            "createdAt": ServerValue.timestamp()
        ]
        let ref = rtdb.child("messages").child(userId).childByAutoId()
        try await ref.setValueAsync(payload)
    }

    private static func timestamp(from value: Any?) -> TimeInterval? {
        if let doubleValue = value as? Double { return doubleValue / 1000.0 }
        if let intValue = value as? Int { return TimeInterval(intValue) / 1000.0 }
        if let number = value as? NSNumber { return number.doubleValue / 1000.0 }
        if let stringValue = value as? String, let number = Double(stringValue) {
            return number / 1000.0
        }
        return nil
    }

    private static func makeReference() -> DatabaseReference {
        if
            let configuredURL = FirebaseApp.app()?.options.databaseURL?.trimmingCharacters(in: .whitespacesAndNewlines),
            !configuredURL.isEmpty
        {
            return Database.database(url: configuredURL).reference()
        }

        return Database.database(url: fallbackDatabaseURL).reference()
    }
}

private extension DatabaseReference {
    func setValueAsync(_ value: Any) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            setValue(value) { error, _ in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: ())
                }
            }
        }
    }
}
