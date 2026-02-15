import Foundation

protocol ShippingAddressServiceProtocol {
    func fetchAddresses(userId: String) async throws -> [ShippingAddress]
    func addAddress(userId: String, address: ShippingAddress) async throws -> String
    func updateAddress(userId: String, addressId: String, data: [String: Any]) async throws
    func deleteAddress(userId: String, addressId: String) async throws
    func setDefaultAddress(userId: String, addressId: String) async throws
}

final class ShippingAddressService: ShippingAddressServiceProtocol {
    private let firestoreService: FirestoreServiceProtocol

    init(firestoreService: FirestoreServiceProtocol) {
        self.firestoreService = firestoreService
    }

    func fetchAddresses(userId: String) async throws -> [ShippingAddress] {
        let addresses: [ShippingAddress] = try await firestoreService.getDocuments(
            collection: "users/\(userId)/shippingAddresses"
        )

        return addresses.sorted {
            if $0.isDefault != $1.isDefault {
                return $0.isDefault && !$1.isDefault
            }
            return ($0.createdAt ?? Date.distantPast) > ($1.createdAt ?? Date.distantPast)
        }
    }

    func addAddress(userId: String, address: ShippingAddress) async throws -> String {
        if address.isDefault {
            try await clearDefaultAddresses(userId: userId)
        }

        let documentId = try await firestoreService.addDocument(
            collection: "users/\(userId)/shippingAddresses",
            data: address
        )
        return documentId
    }

    func updateAddress(userId: String, addressId: String, data: [String: Any]) async throws {
        try await firestoreService.updateDocument(
            collection: "users/\(userId)/shippingAddresses",
            documentId: addressId,
            data: data
        )
    }

    func deleteAddress(userId: String, addressId: String) async throws {
        try await firestoreService.deleteDocument(
            collection: "users/\(userId)/shippingAddresses",
            documentId: addressId
        )
    }

    func setDefaultAddress(userId: String, addressId: String) async throws {
        try await clearDefaultAddresses(userId: userId)
        try await firestoreService.updateDocument(
            collection: "users/\(userId)/shippingAddresses",
            documentId: addressId,
            data: ["isDefault": true]
        )
    }

    private func clearDefaultAddresses(userId: String) async throws {
        let addresses: [ShippingAddress] = try await firestoreService.getDocuments(
            collection: "users/\(userId)/shippingAddresses"
        )

        for address in addresses where address.isDefault {
            if let addressId = address.id {
                try await firestoreService.updateDocument(
                    collection: "users/\(userId)/shippingAddresses",
                    documentId: addressId,
                    data: ["isDefault": false]
                )
            }
        }
    }
}
