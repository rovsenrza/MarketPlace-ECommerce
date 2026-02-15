import Combine
import FirebaseFirestore
import Foundation

protocol FirestoreServiceProtocol {
    func getDocument<T: Decodable>(collection: String, documentId: String) async throws -> T
    func getDocuments<T: Decodable>(collection: String) async throws -> [T]
    func setDocument<T: Encodable>(collection: String, documentId: String, data: T, merge: Bool) async throws
    func setData(collection: String, documentId: String, data: [String: Any], merge: Bool) async throws
    func addDocument<T: Encodable>(collection: String, data: T) async throws -> String
    func updateDocument(collection: String, documentId: String, data: [String: Any]) async throws
    func deleteDocument(collection: String, documentId: String) async throws
    func listenToCollection<T: Decodable>(collection: String) -> AnyPublisher<[T], Error>
    func listenToDocument<T: Decodable>(collection: String, documentId: String) -> AnyPublisher<T?, Error>
}

final class FirestoreService: FirestoreServiceProtocol {
    private let db: Firestore
    
    init(db: Firestore = Firestore.firestore()) {
        self.db = db
    }
    
    func getDocument<T: Decodable>(collection: String, documentId: String) async throws -> T {
        let document = try await db.collection(collection).document(documentId).getDocument()
        
        guard document.exists else {
            throw FirestoreError.documentNotFound
        }
        
        return try document.data(as: T.self)
    }
    
    func getDocuments<T: Decodable>(collection: String) async throws -> [T] {
        let snapshot = try await db.collection(collection).getDocuments()
        
        return snapshot.documents.compactMap { document in
            try? document.data(as: T.self)
        }
    }
    
    func setDocument<T: Encodable>(collection: String, documentId: String, data: T, merge: Bool = true) async throws {
        try db.collection(collection).document(documentId).setData(from: data, merge: merge)
    }

    func setData(collection: String, documentId: String, data: [String: Any], merge: Bool = true) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            db.collection(collection).document(documentId).setData(data, merge: merge) { error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: ())
                }
            }
        }
    }
    
    func addDocument<T: Encodable>(collection: String, data: T) async throws -> String {
        let docRef = try db.collection(collection).addDocument(from: data)
        return docRef.documentID
    }
    
    func updateDocument(collection: String, documentId: String, data: [String: Any]) async throws {
        try await db.collection(collection).document(documentId).updateData(data)
    }
    
    func deleteDocument(collection: String, documentId: String) async throws {
        try await db.collection(collection).document(documentId).delete()
    }
    
    func listenToCollection<T: Decodable>(collection: String) -> AnyPublisher<[T], Error> {
        let subject = PassthroughSubject<[T], Error>()
        
        let listener = db.collection(collection).addSnapshotListener { snapshot, error in
            if let error = error {
                subject.send(completion: .failure(error))
                return
            }
            
            guard let documents = snapshot?.documents else {
                subject.send([])
                return
            }
            
            let items = documents.compactMap { try? $0.data(as: T.self) }
            subject.send(items)
        }
        
        return subject
            .handleEvents(receiveCancel: {
                listener.remove()
            })
            .eraseToAnyPublisher()
    }
    
    func listenToDocument<T: Decodable>(collection: String, documentId: String) -> AnyPublisher<T?, Error> {
        let subject = PassthroughSubject<T?, Error>()
        
        let listener = db.collection(collection).document(documentId).addSnapshotListener { snapshot, error in
            if let error = error {
                subject.send(completion: .failure(error))
                return
            }
            
            guard let snapshot = snapshot, snapshot.exists else {
                subject.send(nil)
                return
            }
            
            if let item = try? snapshot.data(as: T.self) {
                subject.send(item)
            } else {
                subject.send(nil)
            }
        }
        
        return subject
            .handleEvents(receiveCancel: {
                listener.remove()
            })
            .eraseToAnyPublisher()
    }
}

enum FirestoreError: LocalizedError {
    case documentNotFound
    case decodingFailed
    case encodingFailed
    
    var errorDescription: String? {
        switch self {
        case .documentNotFound:
            return "Document not found"
        case .decodingFailed:
            return "Failed to decode document"
        case .encodingFailed:
            return "Failed to encode document"
        }
    }
}
