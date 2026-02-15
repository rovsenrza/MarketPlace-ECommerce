import Combine
import Foundation

@MainActor
final class AddNewPaymentVM {
    @Published var isSaving: Bool = false
    @Published var errorMessage: String?

    private let paymentsService: PaymentsServiceProtocol
    private let authService: AuthenticationServiceProtocol

    init(paymentsService: PaymentsServiceProtocol, authService: AuthenticationServiceProtocol) {
        self.paymentsService = paymentsService
        self.authService = authService
    }

    func savePayment(
        cardholderName: String,
        cardNumber: String,
        expiryDate: String,
        cvv: String,
        isDefault: Bool
    ) async throws {
        guard let userId = authService.currentUser?.uid else {
            throw NSError(domain: "AddNewPayment", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
        }

        let payment = PaymentMethod(
            id: nil,
            cardholderName: cardholderName,
            cardNumber: cardNumber,
            expiryDate: expiryDate,
            cvv: cvv,
            isDefault: isDefault,
            createdAt: Date()
        )

        isSaving = true
        errorMessage = nil

        do {
            _ = try await paymentsService.addPayment(userId: userId, payment: payment)
            isSaving = false
        } catch {
            isSaving = false
            errorMessage = error.localizedDescription
            throw error
        }
    }
}
