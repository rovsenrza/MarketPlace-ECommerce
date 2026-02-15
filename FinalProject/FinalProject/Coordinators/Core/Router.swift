import UIKit

protocol Router: AnyObject {
    var rootViewController: UIViewController { get }
    func setRootModule(_ module: UIViewController, hideBar: Bool)
    func push(_ module: UIViewController, animated: Bool)
    func pop(animated: Bool)
    func present(_ module: UIViewController, animated: Bool)
    func dismiss(animated: Bool)
}

final class NavigationRouter: Router {
    let navigationController: UINavigationController

    init(navigationController: UINavigationController = UINavigationController()) {
        self.navigationController = navigationController
    }

    var rootViewController: UIViewController {
        navigationController
    }

    func setRootModule(_ module: UIViewController, hideBar: Bool = false) {
        navigationController.setViewControllers([module], animated: false)
        navigationController.setNavigationBarHidden(hideBar, animated: false)
    }

    func push(_ module: UIViewController, animated: Bool = true) {
        navigationController.pushViewController(module, animated: animated)
    }

    func pop(animated: Bool = true) {
        navigationController.popViewController(animated: animated)
    }

    func present(_ module: UIViewController, animated: Bool = true) {
        navigationController.present(module, animated: animated)
    }

    func dismiss(animated: Bool = true) {
        navigationController.dismiss(animated: animated)
    }
}
