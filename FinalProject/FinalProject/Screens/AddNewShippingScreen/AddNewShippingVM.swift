import Combine
import Foundation

@MainActor
final class AddNewShippingVM {
    @Published var isSaving: Bool = false
    @Published var errorMessage: String?

    private let shippingService: ShippingAddressServiceProtocol
    private let authService: AuthenticationServiceProtocol

    init(shippingService: ShippingAddressServiceProtocol, authService: AuthenticationServiceProtocol) {
        self.shippingService = shippingService
        self.authService = authService
    }

    func saveAddress(
        existingId: String?,
        name: String,
        phoneNumber: String,
        streetAddress: String,
        city: String,
        state: String,
        zipCode: String,
        isDefault: Bool
    ) async throws {
        guard let userId = authService.currentUser?.uid else {
            throw NSError(domain: "AddNewShipping", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
        }

        isSaving = true
        errorMessage = nil

        do {
            if let existingId = existingId {
                if isDefault {
                    try await shippingService.setDefaultAddress(userId: userId, addressId: existingId)
                }

                var data: [String: Any] = [
                    "name": name,
                    "phoneNumber": phoneNumber,
                    "streetAddress": streetAddress,
                    "city": city,
                    "state": state,
                    "zipCode": zipCode,
                    "isDefault": isDefault
                ]
                data["updatedAt"] = Date()

                try await shippingService.updateAddress(userId: userId, addressId: existingId, data: data)
            } else {
                let address = ShippingAddress(
                    id: nil,
                    name: name,
                    phoneNumber: phoneNumber,
                    streetAddress: streetAddress,
                    city: city,
                    state: state,
                    zipCode: zipCode,
                    isDefault: isDefault,
                    createdAt: Date()
                )

                _ = try await shippingService.addAddress(userId: userId, address: address)
            }

            isSaving = false
        } catch {
            isSaving = false
            errorMessage = error.localizedDescription
            throw error
        }
    }
}
