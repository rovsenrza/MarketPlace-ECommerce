import Foundation

final class ServiceContainer {
    static let shared = ServiceContainer()

    let catalogRepository: CatalogRepository
    let ordersRepository: OrdersRepository
    let chatRepository: ChatRepository
    let userProfilesRepository: UserProfilesRepository

    private init() {
        self.catalogRepository = FirestoreCatalogRepository()
        self.ordersRepository = FirestoreOrdersRepository()
        self.chatRepository = RealtimeChatRepository()
        self.userProfilesRepository = FirestoreUserProfilesRepository()
    }
}
