import Foundation

protocol PaymentsServiceProtocol {
    func fetchPayments(userId: String) async throws -> [PaymentMethod]
    func addPayment(userId: String, payment: PaymentMethod) async throws -> String
    func deletePayment(userId: String, paymentId: String) async throws
    func setDefaultPayment(userId: String, paymentId: String) async throws
}

final class PaymentsService: PaymentsServiceProtocol {
    private let firestoreService: FirestoreServiceProtocol

    init(firestoreService: FirestoreServiceProtocol) {
        self.firestoreService = firestoreService
    }

    func fetchPayments(userId: String) async throws -> [PaymentMethod] {
        let payments: [PaymentMethod] = try await firestoreService.getDocuments(
            collection: "users/\(userId)/payments"
        )

        return payments.sorted {
            if $0.isDefault != $1.isDefault {
                return $0.isDefault && !$1.isDefault
            }
            return ($0.createdAt ?? Date.distantPast) > ($1.createdAt ?? Date.distantPast)
        }
    }

    func addPayment(userId: String, payment: PaymentMethod) async throws -> String {
        if payment.isDefault {
            try await clearDefaultPayments(userId: userId)
        }

        let documentId = try await firestoreService.addDocument(
            collection: "users/\(userId)/payments",
            data: payment
        )
        return documentId
    }

    func deletePayment(userId: String, paymentId: String) async throws {
        try await firestoreService.deleteDocument(
            collection: "users/\(userId)/payments",
            documentId: paymentId
        )
    }

    func setDefaultPayment(userId: String, paymentId: String) async throws {
        try await clearDefaultPayments(userId: userId)
        try await firestoreService.updateDocument(
            collection: "users/\(userId)/payments",
            documentId: paymentId,
            data: ["isDefault": true]
        )
    }

    private func clearDefaultPayments(userId: String) async throws {
        let payments: [PaymentMethod] = try await firestoreService.getDocuments(
            collection: "users/\(userId)/payments"
        )

        for payment in payments where payment.isDefault {
            if let paymentId = payment.id {
                try await firestoreService.updateDocument(
                    collection: "users/\(userId)/payments",
                    documentId: paymentId,
                    data: ["isDefault": false]
                )
            }
        }
    }
}
