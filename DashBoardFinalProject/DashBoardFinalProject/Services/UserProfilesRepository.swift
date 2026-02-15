import Foundation

protocol UserProfilesRepository {
    func fetchUserProfiles() async throws -> [String: UserProfile]
}
