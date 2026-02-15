import FirebaseStorage
import Foundation
import UIKit

protocol StorageServiceProtocol {
    func uploadImage(_ image: UIImage, path: String, compressionQuality: CGFloat) async throws -> String
    func deleteFile(at path: String) async throws
    func getDownloadURL(for path: String) async throws -> URL
}

final class StorageService: StorageServiceProtocol {
    private let storage: Storage
    
    init(storage: Storage = Storage.storage()) {
        self.storage = storage
    }
    
    func uploadImage(_ image: UIImage, path: String, compressionQuality: CGFloat = 0.7) async throws -> String {
        guard let imageData = image.jpegData(compressionQuality: compressionQuality) else {
            throw StorageError.invalidImage
        }
        
        let storageRef = storage.reference().child(path)
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        _ = try await storageRef.putDataAsync(imageData, metadata: metadata)
        let downloadURL = try await storageRef.downloadURL()
        
        return downloadURL.absoluteString
    }
    
    func deleteFile(at path: String) async throws {
        let storageRef = storage.reference().child(path)
        try await storageRef.delete()
    }
    
    func getDownloadURL(for path: String) async throws -> URL {
        let storageRef = storage.reference().child(path)
        return try await storageRef.downloadURL()
    }
}

enum StorageError: LocalizedError {
    case invalidImage
    case uploadFailed
    case deleteFailed
    case downloadURLFailed
    
    var errorDescription: String? {
        switch self {
        case .invalidImage:
            return "Invalid image data"
        case .uploadFailed:
            return "Failed to upload file"
        case .deleteFailed:
            return "Failed to delete file"
        case .downloadURLFailed:
            return "Failed to get download URL"
        }
    }
}
