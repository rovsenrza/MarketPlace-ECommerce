@preconcurrency import FirebaseFirestore
import Foundation

nonisolated struct Review: Identifiable, Codable, Sendable {
    @DocumentID
    var id: String?

    let userName: String
    let stars: Int
    let message: String
    let createdAt: Timestamp?
}
