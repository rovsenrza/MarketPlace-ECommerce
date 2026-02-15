import Combine
import Foundation

@MainActor
final class ShippingAddressVM: ObservableObject {
    @Published var addresses: [ShippingAddress] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let shippingService: ShippingAddressServiceProtocol
    private let authService: AuthenticationServiceProtocol

    init(shippingService: ShippingAddressServiceProtocol, authService: AuthenticationServiceProtocol) {
        self.shippingService = shippingService
        self.authService = authService
    }

    func fetchAddresses() {
        guard let userId = authService.currentUser?.uid else {
            addresses = []
            return
        }

        Task {
            isLoading = true
            errorMessage = nil

            do {
                addresses = try await shippingService.fetchAddresses(userId: userId)
            } catch {
                errorMessage = error.localizedDescription
            }

            isLoading = false
        }
    }

    func deleteAddress(_ address: ShippingAddress) {
        guard let userId = authService.currentUser?.uid,
              let addressId = address.id else { return }

        Task {
            do {
                try await shippingService.deleteAddress(userId: userId, addressId: addressId)
                addresses.removeAll { $0.id == addressId }
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    func setDefault(_ address: ShippingAddress) {
        guard let userId = authService.currentUser?.uid,
              let addressId = address.id else { return }

        Task {
            do {
                try await shippingService.setDefaultAddress(userId: userId, addressId: addressId)
                addresses = addresses.map { item in
                    if item.id == addressId {
                        return ShippingAddress(
                            id: item.id,
                            name: item.name,
                            phoneNumber: item.phoneNumber,
                            streetAddress: item.streetAddress,
                            city: item.city,
                            state: item.state,
                            zipCode: item.zipCode,
                            isDefault: true,
                            createdAt: item.createdAt
                        )
                    }
                    return ShippingAddress(
                        id: item.id,
                        name: item.name,
                        phoneNumber: item.phoneNumber,
                        streetAddress: item.streetAddress,
                        city: item.city,
                        state: item.state,
                        zipCode: item.zipCode,
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
