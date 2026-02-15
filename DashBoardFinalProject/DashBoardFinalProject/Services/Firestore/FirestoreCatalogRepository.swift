import Foundation
import FirebaseFirestore

final class FirestoreCatalogRepository: CatalogRepository {
    private let db = Firestore.firestore()

    func fetchCategories() async throws -> [Category] {
        let snapshot = try await db.collection("categories").getDocuments()
        return snapshot.documents.map { doc in
            let data = doc.data()
            return Category(
                id: doc.documentID,
                title: data["title"] as? String ?? "",
                slug: data["slug"] as? String ?? "",
                icon: data["icon"] as? String
            )
        }
        .sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
    }

    func fetchProducts() async throws -> [Product] {
        let snapshot = try await db.collection("products").getDocuments()
        return snapshot.documents.map { doc in
            let data = doc.data()
            return Product(
                id: doc.documentID,
                title: data["title"] as? String ?? "",
                description: data["description"] as? String ?? "",
                categoryIds: data["categoryIds"] as? [String] ?? [],
                basePrice: Self.doubleValue(from: data["basePrice"]) ?? 0,
                discountPrice: Self.doubleValue(from: data["discountPrice"]),
                quantity: Self.intValue(from: data["quantity"]) ?? 0,
                variants: [],
                reviews: []
            )
        }
    }

    func addCategory(_ category: Category) async throws {
        var payload: [String: Any] = [
            "title": category.title,
            "slug": category.slug,
            "createdAt": FieldValue.serverTimestamp()
        ]
        if let icon = category.icon, !icon.isEmpty {
            payload["icon"] = icon
        }
        _ = try await db.collection("categories").addDocument(data: payload)
    }

    func addProduct(_ product: Product) async throws {
        var payload: [String: Any] = [
            "title": product.title,
            "description": product.description,
            "categoryIds": product.categoryIds,
            "basePrice": product.basePrice,
            "quantity": product.quantity,
            "createdAt": FieldValue.serverTimestamp()
        ]
        if let discount = product.discountPrice {
            payload["discountPrice"] = discount
        }
        if !product.variants.isEmpty {
            payload["variants"] = product.variants.reduce(into: [String: [String]]()) { result, variant in
                result[variant.name] = variant.values
            }
        }

        let ref = try await db.collection("products").addDocument(data: payload)
        if !product.reviews.isEmpty {
            for review in product.reviews {
                var reviewPayload: [String: Any] = [
                    "userName": review.userName,
                    "stars": review.stars,
                    "createdAt": FieldValue.serverTimestamp()
                ]
                if let message = review.message, !message.isEmpty {
                    reviewPayload["message"] = message
                }
                _ = try await ref.collection("reviews").addDocument(data: reviewPayload)
            }
        }
    }

    private static func doubleValue(from value: Any?) -> Double? {
        if let doubleValue = value as? Double { return doubleValue }
        if let intValue = value as? Int { return Double(intValue) }
        if let number = value as? NSNumber { return number.doubleValue }
        return nil
    }

    private static func intValue(from value: Any?) -> Int? {
        if let intValue = value as? Int { return intValue }
        if let doubleValue = value as? Double { return Int(doubleValue) }
        if let number = value as? NSNumber { return number.intValue }
        return nil
    }
}
