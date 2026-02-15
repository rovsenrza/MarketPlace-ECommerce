import SwiftUI

struct DashboardBuilder {
    static func build() -> ContentView {
        let container = ServiceContainer.shared
        return ContentView(
            catalogRepository: container.catalogRepository,
            ordersRepository: container.ordersRepository,
            chatRepository: container.chatRepository,
            userProfilesRepository: container.userProfilesRepository
        )
    }
}
