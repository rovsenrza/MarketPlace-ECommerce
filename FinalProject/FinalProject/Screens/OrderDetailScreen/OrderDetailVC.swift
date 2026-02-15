import SnapKit
import UIKit

final class OrderDetailVC: UIViewController {
    private let vm: OrderDetailVM
    private let onRoute: ((OrderDetailRoute) -> Void)?

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(OrderDetailItemCell.self, forCellReuseIdentifier: OrderDetailItemCell.reuseIdentifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    init(vm: OrderDetailVM, onRoute: ((OrderDetailRoute) -> Void)? = nil) {
        self.vm = vm
        self.onRoute = onRoute
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    func setupUI() {
        view.backgroundColor = UIColor(named: "Background") ?? .systemBackground
        title = "Order #\(vm.order.orderNumber)"
        navigationController?.navigationBar.prefersLargeTitles = false

        addSubviews()
        setupConstraints()
    }

    func addSubviews() {
        view.addSubview(tableView)
    }

    func setupConstraints() {
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension OrderDetailVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vm.order.items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: OrderDetailItemCell.reuseIdentifier, for: indexPath) as? OrderDetailItemCell else {
            return UITableViewCell()
        }

        let item = vm.order.items[indexPath.row]
        cell.configure(with: item)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = vm.order.items[indexPath.row]
        Task { @MainActor in
            do {
                let product = try await vm.fetchProduct(productId: item.productId)
                onRoute?(.productDetail(product))
            } catch {
                showAlert(title: "Error", message: error.localizedDescription)
            }
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
}
