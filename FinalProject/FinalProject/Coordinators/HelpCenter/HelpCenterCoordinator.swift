import UIKit

final class HelpCenterCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []

    private let router: Router

    init(router: Router) {
        self.router = router
    }

    func start() {
        let helpCenterVC = HelpCenterBuilder.build(
            onRoute: { [weak self] route in
                self?.handle(route: route)
            }
        )
        router.push(helpCenterVC, animated: true)
    }

    private func handle(route: HelpCenterRoute) {
        switch route {
        case .detail(let title, let subtitle, let body):
            let detailVC = HelpCenterDetailBuilder.build(
                title: title,
                subtitle: subtitle,
                body: body,
                onChatRequested: { [weak self] in
                    self?.presentSupportChat()
                }
            )
            router.push(detailVC, animated: true)

        case .chat:
            presentSupportChat()
        }
    }

    private func presentSupportChat() {
        let messageVC = MessageBuilder.build()
        let nav = UINavigationController(rootViewController: messageVC)
        nav.modalPresentationStyle = .fullScreen
        router.present(nav, animated: true)
    }
}
