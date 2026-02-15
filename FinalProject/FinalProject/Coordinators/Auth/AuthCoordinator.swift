import UIKit

final class AuthCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var onAuthenticated: (() -> Void)?

    private let router: NavigationRouter

    init(router: NavigationRouter = NavigationRouter()) {
        self.router = router
    }

    var rootViewController: UIViewController {
        router.rootViewController
    }

    func start() {
        showLogin()
    }

    private func showLogin() {
        let loginVC = LoginBuilder.build(
            onAuthenticated: { [weak self] in
                self?.onAuthenticated?()
            },
            onRegisterRequested: { [weak self] in
                self?.showRegister()
            }
        )
        router.setRootModule(loginVC, hideBar: false)
    }

    private func showRegister() {
        let registerVC = RegisterBuilder.build(
            onAuthenticated: { [weak self] in
                self?.onAuthenticated?()
            },
            onLoginRequested: { [weak self] in
                self?.router.pop(animated: true)
            }
        )
        router.push(registerVC, animated: true)
    }
}
