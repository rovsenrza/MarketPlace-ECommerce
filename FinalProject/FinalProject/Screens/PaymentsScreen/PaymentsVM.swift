import Combine
import Foundation

@MainActor
final class PaymentsVM: ObservableObject {
    @Published var payments: [PaymentMethod] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let paymentsService: PaymentsServiceProtocol
    private let authService: AuthenticationServiceProtocol

    init(paymentsService: PaymentsServiceProtocol, authService: AuthenticationServiceProtocol) {
        self.paymentsService = paymentsService
        self.authService = authService
    }

    func fetchPayments() {
        guard let userId = authService.currentUser?.uid else {
            payments = []
            return
        }

        Task {
            isLoading = true
            errorMessage = nil

            do {
                payments = try await paymentsService.fetchPayments(userId: userId)
            } catch {
                errorMessage = error.localizedDescription
            }

            isLoading = false
        }
    }

    func deletePayment(_ payment: PaymentMethod) {
        guard let userId = authService.currentUser?.uid,
              let paymentId = payment.id else { return }

        Task {
            do {
                try await paymentsService.deletePayment(userId: userId, paymentId: paymentId)
                payments.removeAll { $0.id == paymentId }
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    func setDefault(_ payment: PaymentMethod) {
        guard let userId = authService.currentUser?.uid,
              let paymentId = payment.id else { return }

        Task {
            do {
                try await paymentsService.setDefaultPayment(userId: userId, paymentId: paymentId)
                payments = payments.map { item in
                    if item.id == paymentId {
                        return PaymentMethod(
                            id: item.id,
                            cardholderName: item.cardholderName,
                            cardNumber: item.cardNumber,
                            expiryDate: item.expiryDate,
                            cvv: item.cvv,
                            isDefault: true,
                            createdAt: item.createdAt
                        )
                    }
                    return PaymentMethod(
                        id: item.id,
                        cardholderName: item.cardholderName,
                        cardNumber: item.cardNumber,
                        expiryDate: item.expiryDate,
                        cvv: item.cvv,
                        isDefault: false,
                        createdAt: item.createdAt
                    )
                }
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}
