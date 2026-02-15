@preconcurrency import FirebaseFirestore
import Foundation

nonisolated struct Category: Identifiable, Codable, Hashable, Sendable {
    static func == (lhs: Category, rhs: Category) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    @DocumentID
    var id: String?

    let title: String
    let slug: String

    let icon: String

    let createdAt: Timestamp?
}
