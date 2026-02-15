import FirebaseDatabase
import Foundation

protocol ChatServiceProtocol {
    func messagesStream(userId: String) -> AsyncThrowingStream<ChatMessage, Error>
    func sendMessage(
        userId: String,
        text: String,
        senderId: String,
        senderName: String?,
        isFromAdmin: Bool
    ) async throws
}

final class ChatService: ChatServiceProtocol {
    private let db: DatabaseReference
    private static let realtimeDatabaseURL = "https://finalproject-6d2f4-default-rtdb.europe-west1.firebasedatabase.app"

    init(db: DatabaseReference? = nil) {
        if let db {
            self.db = db
        } else {
            self.db = Database.database(url: Self.realtimeDatabaseURL).reference()
        }
    }

    private func messagesRef(for userId: String) -> DatabaseReference {
        db.child("messages").child(userId)
    }

    func messagesStream(userId: String) -> AsyncThrowingStream<ChatMessage, Error> {
        let query = messagesRef(for: userId).queryOrdered(byChild: "createdAt")
        return AsyncThrowingStream { continuation in
            let handle = query.observe(
                .childAdded,
                with: { snapshot in
                    guard let data = snapshot.value as? [String: Any],
                          let message = ChatMessage(id: snapshot.key, data: data) else { return }

                    continuation.yield(message)
                },
                withCancel: { error in
                    continuation.finish(throwing: error)
                }
            )

            continuation.onTermination = { _ in
                query.removeObserver(withHandle: handle)
            }
        }
    }

    func sendMessage(
        userId: String,
        text: String,
        senderId: String,
        senderName: String?,
        isFromAdmin: Bool
    ) async throws {
        let ref = messagesRef(for: userId).childByAutoId()
        let payload: [String: Any] = [
            "text": text,
            "senderId": senderId,
            "senderName": senderName as Any,
            "isFromAdmin": isFromAdmin,
            "createdAt": ServerValue.timestamp()
        ]

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            ref.setValue(payload) { error, _ in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: ())
                }
            }
        }
    }
}
