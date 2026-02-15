import UIKit

final class AppCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []

    private let window: UIWindow
    private let authService: AuthenticationServiceProtocol

    init(window: UIWindow, authService: AuthenticationServiceProtocol = ServiceContainer.shared.authService) {
        self.window = window
        self.authService = authService
    }

    func start() {
        if authService.isAuthenticated {
            showMainFlow()
        } else {
            showAuthFlow()
        }
    }

    private func showAuthFlow() {
        let coordinator = AuthCoordinator()
        coordinator.onAuthenticated = { [weak self, weak coordinator] in
            guard let self, let coordinator else { return }

            self.removeChild(coordinator)
            self.showMainFlow()
        }

        addChild(coordinator)
        coordinator.start()

        window.rootViewController = coordinator.rootViewController
        window.makeKeyAndVisible()
    }

    private func showMainFlow() {
        let coordinator = MainTabCoordinator()
        coordinator.onLogout = { [weak self, weak coordinator] in
            guard let self, let coordinator else { return }

            self.removeChild(coordinator)
            self.showAuthFlow()
        }

        addChild(coordinator)
        coordinator.start()

        window.rootViewController = coordinator.rootViewController
        window.makeKeyAndVisible()
    }
}
