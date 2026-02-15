import Combine
import SnapKit
import UIKit

final class ShippingAddressVC: UIViewController {
    private let vm: ShippingAddressVM
    private let onRoute: ((ShippingAddressRoute) -> Void)?
    private var cancellables = Set<AnyCancellable>()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Saved Addresses"
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = UIColor(named: "TextPrimary") ?? .label
        return label
    }()

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.showsVerticalScrollIndicator = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ShippingAddressCell.self, forCellReuseIdentifier: ShippingAddressCell.reuseIdentifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    private let loadingView: LoadingView = {
        let view = LoadingView(message: "Loading addresses...")
        view.isHidden = true
        return view
    }()

    private let emptyContainer = UIView()
    private let emptyIcon: UIImageView = {
        let config = UIImage.SymbolConfiguration(pointSize: 36, weight: .semibold)
        let image = UIImage(systemName: "location.fill", withConfiguration: config)
        let iv = UIImageView(image: image)
        iv.tintColor = UIColor(named: "PrimaryColorSet") ?? .systemBlue
        return iv
    }()

    private let emptyTitle: UILabel = {
        let label = UILabel()
        label.text = "No Addresses Found"
        label.font = AppTypography.title()
        label.textColor = UIColor(named: "TextPrimary") ?? .label
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private let emptySubtitle: UILabel = {
        let label = UILabel()
        label.text = "Add a shipping address to make checkout faster."
        label.font = AppTypography.body()
        label.textColor = UIColor(named: "TextMuted") ?? .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private let bottomContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "Background")?.withAlphaComponent(0.98) ?? .systemBackground
        return view
    }()

    private let addButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Add New Address", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = AppTypography.button()
        button.backgroundColor = UIColor(named: "PrimaryColorSet") ?? .systemBlue
        button.layer.cornerRadius = 16
        button.layer.shadowColor = (UIColor(named: "PrimaryColorSet") ?? .systemBlue).withAlphaComponent(0.25).cgColor
        button.layer.shadowOpacity = 1
        button.layer.shadowRadius = 10
        button.layer.shadowOffset = CGSize(width: 0, height: 6)
        return button
    }()

    init(vm: ShippingAddressVM, onRoute: ((ShippingAddressRoute) -> Void)? = nil) {
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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        vm.fetchAddresses()
    }

    func setupUI() {
        view.backgroundColor = UIColor(named: "Background") ?? .systemBackground
        title = "Shipping Address"
        navigationController?.navigationBar.prefersLargeTitles = false

        let addBarButton = UIBarButtonItem(
            image: UIImage(systemName: "plus"),
            style: .plain,
            target: self,
            action: #selector(addAddressTapped)
        )
        navigationItem.rightBarButtonItem = addBarButton

        addSubviews()
        setupConstraints()
        setupActions()
        bindViewModel()
    }

    func addSubviews() {
        [titleLabel, tableView, emptyContainer, bottomContainer, loadingView].forEach { view.addSubview($0) }
        bottomContainer.addSubview(addButton)
        [emptyIcon, emptyTitle, emptySubtitle].forEach { emptyContainer.addSubview($0) }
    }

    func setupConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(12)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        tableView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(bottomContainer.snp.top)
        }

        bottomContainer.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
        }

        addButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-12)
            make.height.equalTo(56)
        }

        emptyContainer.snp.makeConstraints { make in
            make.centerY.equalToSuperview().offset(-40)
            make.leading.trailing.equalToSuperview().inset(32)
        }

        emptyIcon.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.height.equalTo(48)
        }

        emptyTitle.snp.makeConstraints { make in
            make.top.equalTo(emptyIcon.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview()
        }

        emptySubtitle.snp.makeConstraints { make in
            make.top.equalTo(emptyTitle.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(8)
            make.bottom.equalToSuperview()
        }

        loadingView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func setupActions() {
        addButton.addTarget(self, action: #selector(addAddressTapped), for: .touchUpInside)
    }

    private func bindViewModel() {
        vm.$addresses
            .receive(on: DispatchQueue.main)
            .sink { [weak self] addresses in
                guard let self = self else { return }

                let isEmpty = addresses.isEmpty
                self.emptyContainer.isHidden = !isEmpty
                self.tableView.isHidden = isEmpty
                self.titleLabel.isHidden = isEmpty
                self.tableView.reloadData()
            }
            .store(in: &cancellables)

        vm.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                self?.loadingView.isHidden = !isLoading
            }
            .store(in: &cancellables)

        vm.$errorMessage
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] message in
                self?.showAlert(title: "Error", message: message)
            }
            .store(in: &cancellables)
    }

    @objc private func addAddressTapped() {
        onRoute?(.addOrEditAddress(nil))
    }
}

extension ShippingAddressVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vm.addresses.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ShippingAddressCell.reuseIdentifier, for: indexPath) as? ShippingAddressCell else {
            return UITableViewCell()
        }

        let address = vm.addresses[indexPath.row]
        cell.configure(with: address)
        cell.onEditTapped = { [weak self] in
            self?.onRoute?(.addOrEditAddress(address))
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let address = vm.addresses[indexPath.row]
        if !address.isDefault {
            vm.setDefault(address)
        }
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let address = vm.addresses[indexPath.row]
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completion in
            self?.vm.deleteAddress(address)
            completion(true)
        }
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
}
