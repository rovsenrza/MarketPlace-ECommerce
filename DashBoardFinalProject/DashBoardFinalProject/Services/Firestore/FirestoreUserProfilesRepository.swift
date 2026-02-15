import Foundation
import FirebaseFirestore

final class FirestoreUserProfilesRepository: UserProfilesRepository {
    private let firestore: Firestore

    init(firestore: Firestore = Firestore.firestore()) {
        self.firestore = firestore
    }

    func fetchUserProfiles() async throws -> [String: UserProfile] {
        let snapshot = try await firestore.collection("users").getDocuments()
        var profiles: [String: UserProfile] = [:]
        for doc in snapshot.documents {
            let data = doc.data()
            let displayName = data["displayName"] as? String ?? ""
            let email = data["email"] as? String ?? ""
            profiles[doc.documentID] = UserProfile(displayName: displayName, email: email)
        }
        return profiles
    }
}
