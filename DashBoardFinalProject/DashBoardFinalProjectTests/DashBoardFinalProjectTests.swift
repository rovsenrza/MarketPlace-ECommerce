import XCTest
@testable import DashBoardFinalProject

@MainActor
final class DashBoardFinalProjectTests: XCTestCase {
    func testMessagesLabelFallsBackFromDisplayNameToEmailToUserId() async {
        let chatRepository = ChatRepositoryMock()
        let userProfilesRepository = UserProfilesRepositoryMock(
            profiles: [
                "display-name-user": UserProfile(displayName: "Alice", email: "alice@example.com"),
                "email-user": UserProfile(displayName: "", email: "mail-only@example.com"),
                "id-user": UserProfile(displayName: "", email: "")
            ]
        )
        let viewModel = MessagesViewModel(
            chatRepository: chatRepository,
            userProfilesRepository: userProfilesRepository
        )

        await viewModel.loadProfiles()

        XCTAssertEqual(viewModel.label(for: "display-name-user"), "Alice")
        XCTAssertEqual(viewModel.label(for: "email-user"), "mail-only@example.com")
        XCTAssertEqual(viewModel.label(for: "id-user"), "id-user")
        XCTAssertEqual(viewModel.label(for: "missing-user"), "missing-user")
    }

    func testCatalogToggleCategoryAddsThenRemovesCategoryId() {
        let viewModel = CatalogViewModel(repository: CatalogRepositoryMock())

        viewModel.toggleCategory(id: "cat-1")
        XCTAssertEqual(viewModel.selectedCategoryIds, Set(["cat-1"]))

        viewModel.toggleCategory(id: "cat-1")
        XCTAssertTrue(viewModel.selectedCategoryIds.isEmpty)
    }
}

private struct CatalogRepositoryMock: CatalogRepository {
    func fetchCategories() async throws -> [DashBoardFinalProject.Category] { [] }
    func fetchProducts() async throws -> [DashBoardFinalProject.Product] { [] }
    func addCategory(_ category: DashBoardFinalProject.Category) async throws {}
    func addProduct(_ product: DashBoardFinalProject.Product) async throws {}
}

private final class ChatRepositoryMock: ChatRepository {
    func observeChatUsers(_ onChange: @escaping ([ChatConversation]) -> Void) -> ChatListener {
        ChatListener(cancel: {})
    }

    func observeMessages(userId: String, _ onChange: @escaping ([ChatMessage]) -> Void) -> ChatListener {
        ChatListener(cancel: {})
    }

    func sendAdminMessage(text: String, to userId: String) async throws {}
}

private struct UserProfilesRepositoryMock: UserProfilesRepository {
    let profiles: [String: UserProfile]

    func fetchUserProfiles() async throws -> [String: UserProfile] {
        profiles
    }
}
