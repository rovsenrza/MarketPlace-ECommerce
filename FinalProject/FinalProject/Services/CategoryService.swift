import FirebaseFirestore
import Foundation

protocol CategoryServiceProtocol {
    func fetchCategory(id: String) async throws -> Category
}

final class CategoryService: CategoryServiceProtocol {
    private let db: Firestore

    init(db: Firestore = Firestore.firestore()) {
        self.db = db
    }

    func fetchCategory(id: String) async throws -> Category {
        try await db.collection("categories").document(id).getDocument(as: Category.self)
    }
}
