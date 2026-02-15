import Combine
import FirebaseFirestore
import Foundation

protocol ReviewServiceProtocol {
    func listenToReviews(productId: String) -> AnyPublisher<[Review], Error>
    func submitReview(productId: String, review: Review) async throws
}

final class ReviewService: ReviewServiceProtocol {
    private let db: Firestore

    init(db: Firestore = Firestore.firestore()) {
        self.db = db
    }

    func listenToReviews(productId: String) -> AnyPublisher<[Review], Error> {
        let subject = PassthroughSubject<[Review], Error>()

        let listener = db.collection("products")
            .document(productId)
            .collection("reviews")
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    subject.send(completion: .failure(error))
                    return
                }

                let reviews = snapshot?.documents.compactMap { doc in
                    try? doc.data(as: Review.self)
                } ?? []

                subject.send(reviews)
            }

        return subject
            .handleEvents(receiveCancel: {
                listener.remove()
            })
            .eraseToAnyPublisher()
    }

    func submitReview(productId: String, review: Review) async throws {
        let data: [String: Any] = [
            "userName": review.userName,
            "stars": review.stars,
            "message": review.message,
            "createdAt": FieldValue.serverTimestamp()
        ]

        try await db.collection("products")
            .document(productId)
            .collection("reviews")
            .addDocument(data: data)
    }
}
