import Combine
import UIKit

final class MainTabBarController: UITabBarController {
    private let customTabBar = CartButton()
    private let cartVM: CartVM
    private let homeRootViewController: UIViewController
    private let browseRootViewController: UIViewController
    private let cartRootViewController: UIViewController
    private let wishlistRootViewController: UIViewController
    private let profileRootViewController: UIViewController
    private var cancellables = Set<AnyCancellable>()

    init(
        cartVM: CartVM,
        homeRootViewController: UIViewController,
        browseRootViewController: UIViewController,
        cartRootViewController: UIViewController,
        wishlistRootViewController: UIViewController,
        profileRootViewController: UIViewController
    ) {
        self.cartVM = cartVM
        self.homeRootViewController = homeRootViewController
        self.browseRootViewController = browseRootViewController
        self.cartRootViewController = cartRootViewController
        self.wishlistRootViewController = wishlistRootViewController
        self.profileRootViewController = profileRootViewController
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(named: "Background") ?? .systemBackground
        setValue(customTabBar, forKey: "tabBar")

        setupTabs()

        bindCartBadge()
        cartVM.fetchCartItems()
    }

    private func setupTabs() {
        viewControllers = [
            makeVC(vc: homeRootViewController, title: "Home", image: "house.fill"),
            makeVC(vc: browseRootViewController, title: "Browse", image: "safari"),
            makeVC(vc: cartRootViewController, title: "Cart", image: "cart"),
            makeVC(vc: wishlistRootViewController, title: "Wishlist", image: "heart"),
            makeVC(vc: profileRootViewController, title: "Profile", image: "person")
        ]

        tabBar.items?[2].isEnabled = false

        customTabBar.onCenterTap { [weak self] in
            self?.selectedIndex = 2
        }
    }

    private func bindCartBadge() {
        cartVM.$cartItems
            .receive(on: DispatchQueue.main)
            .sink { [weak self] items in
                let count = items.count
                self?.customTabBar.setBadge(count: count)
            }
            .store(in: &cancellables)
    }

    private func makeVC(vc: UIViewController, title: String, image: String) -> UINavigationController {
        vc.view.backgroundColor = .systemBackground
        vc.tabBarItem = UITabBarItem(
            title: title,
            image: UIImage(systemName: image),
            selectedImage: UIImage(systemName: image)
        )
        return UINavigationController(rootViewController: vc)
    }
}
