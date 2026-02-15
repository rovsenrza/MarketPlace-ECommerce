import FirebaseFirestore
import Foundation

protocol CatalogServiceProtocol {
    func fetchCategories() async throws -> [Category]
    func fetchProductsWithReviews() async throws -> [Product]
}

final class CatalogService: CatalogServiceProtocol {
    private let db: Firestore

    init(db: Firestore = Firestore.firestore()) {
        self.db = db
    }

    func fetchCategories() async throws -> [Category] {
        let snapshot = try await db.collection("categories").getDocuments()
        return try snapshot.documents.map { document in
            try document.data(as: Category.self)
        }
    }

    func fetchProductsWithReviews() async throws -> [Product] {
        let snapshot = try await db.collection("products").getDocuments()
        var products: [Product] = []

        for document in snapshot.documents {
            var product = try document.data(as: Product.self)

            if let productId = product.id {
                do {
                    let reviewSnapshot = try await db.collection("products")
                        .document(productId)
                        .collection("reviews")
                        .getDocuments()

                    let reviews = try reviewSnapshot.documents.map { reviewDoc in
                        try reviewDoc.data(as: Review.self)
                    }

                    product.reviews = reviews
                } catch {
                    throw error
                }
            }

            products.append(product)
        }

        return products
    }
}
