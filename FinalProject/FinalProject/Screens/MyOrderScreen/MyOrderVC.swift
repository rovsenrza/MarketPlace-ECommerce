import Combine
import SnapKit
import UIKit

final class MyOrderVC: UIViewController {
    private let vm: MyOrderVM
    private let onRoute: ((MyOrderRoute) -> Void)?
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Empty State UI

    private let emptyContainer = UIView()
    private let illustrationContainer = UIView()

    private let outerCircle: UIView = {
        let view = UIView()
        view.backgroundColor = (UIColor(named: "PrimaryColorSet") ?? .systemRed).withAlphaComponent(0.05)
        view.layer.cornerRadius = 96
        return view
    }()

    private let glowCircle: UIView = {
        let view = UIView()
        view.backgroundColor = (UIColor(named: "PrimaryColorSet") ?? .systemRed).withAlphaComponent(0.1)
        view.layer.cornerRadius = 88
        view.alpha = 0.6
        return view
    }()

    private let packageFrame: UIView = {
        let view = UIView()
        view.layer.borderWidth = 2
        view.layer.borderColor = (UIColor(named: "PrimaryColorSet") ?? .systemRed).withAlphaComponent(0.3).cgColor
        view.layer.cornerRadius = 18
        return view
    }()

    private let iconBadge: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "Background") ?? .systemBackground
        view.layer.cornerRadius = 10
        return view
    }()

    private let iconView: UIImageView = {
        let config = UIImage.SymbolConfiguration(pointSize: 34, weight: .regular)
        let image = UIImage(systemName: "shippingbox", withConfiguration: config)
        let iv = UIImageView(image: image)
        iv.tintColor = UIColor(named: "PrimaryColorSet") ?? .systemRed
        return iv
    }()

    private let lineTop: UIView = {
        let view = UIView()
        view.backgroundColor = (UIColor(named: "PrimaryColorSet") ?? .systemRed).withAlphaComponent(0.2)
        view.layer.cornerRadius = 2
        return view
    }()

    private let lineBottom: UIView = {
        let view = UIView()
        view.backgroundColor = (UIColor(named: "PrimaryColorSet") ?? .systemRed).withAlphaComponent(0.2)
        view.layer.cornerRadius = 2
        return view
    }()

    private let dotTop: UIView = {
        let view = UIView()
        view.backgroundColor = (UIColor(named: "PrimaryColorSet") ?? .systemRed).withAlphaComponent(0.4)
        view.layer.cornerRadius = 6
        return view
    }()

    private let dotBottom: UIView = {
        let view = UIView()
        view.backgroundColor = (UIColor(named: "PrimaryColorSet") ?? .systemRed).withAlphaComponent(0.2)
        view.layer.cornerRadius = 4
        return view
    }()

    private let emptyTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "No Orders Yet"
        label.font = AppTypography.title()
        label.textColor = UIColor(named: "TextPrimary") ?? .label
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private let emptySubtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "When you place an order, it will appear here for you to track and manage."
        label.font = AppTypography.body()
        label.textColor = UIColor(named: "TextMuted") ?? .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private let primaryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Go to Store", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = AppTypography.button()
        button.backgroundColor = UIColor(named: "PrimaryColorSet") ?? .systemRed
        button.layer.cornerRadius = 28
        button.layer.shadowColor = (UIColor(named: "PrimaryColorSet") ?? .systemRed).withAlphaComponent(0.2).cgColor
        button.layer.shadowOpacity = 1
        button.layer.shadowRadius = 12
        button.layer.shadowOffset = CGSize(width: 0, height: 6)
        return button
    }()

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(OrderCell.self, forCellReuseIdentifier: OrderCell.reuseIdentifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    private let loadingView: LoadingView = {
        let view = LoadingView(message: "Loading orders...")
        view.isHidden = true
        return view
    }()

    // MARK: - Init

    init(vm: MyOrderVM, onRoute: ((MyOrderRoute) -> Void)? = nil) {
        self.vm = vm
        self.onRoute = onRoute
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        vm.fetchOrders()
    }

    func setupUI() {
        view.backgroundColor = UIColor(named: "Background") ?? .systemBackground
        title = "My Orders"
        navigationController?.navigationBar.prefersLargeTitles = false

        addSubviews()
        setupConstraints()
        setupActions()
        bindViewModel()
    }

    func addSubviews() {
        [tableView, emptyContainer, loadingView].forEach { view.addSubview($0) }
        emptyContainer.addSubview(illustrationContainer)
        [outerCircle, glowCircle, packageFrame, dotTop, dotBottom].forEach { illustrationContainer.addSubview($0) }
        [lineTop, lineBottom, iconBadge].forEach { packageFrame.addSubview($0) }
        iconBadge.addSubview(iconView)
        [emptyTitleLabel, emptySubtitleLabel, primaryButton].forEach { emptyContainer.addSubview($0) }
    }

    func setupConstraints() {
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        emptyContainer.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(24)
        }

        illustrationContainer.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.height.equalTo(192)
        }

        outerCircle.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        glowCircle.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(176)
        }

        packageFrame.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(112)
        }

        iconBadge.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(packageFrame.snp.top).offset(-12)
            make.width.height.equalTo(28)
        }

        iconView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(24)
        }

        lineTop.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(32)
            make.width.equalTo(48)
            make.height.equalTo(4)
        }

        lineBottom.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-20)
            make.width.equalTo(32)
            make.height.equalTo(4)
        }

        dotTop.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().offset(-24)
            make.width.height.equalTo(12)
        }

        dotBottom.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-18)
            make.leading.equalToSuperview().offset(28)
            make.width.height.equalTo(8)
        }

        emptyTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(illustrationContainer.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        emptySubtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(emptyTitleLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        primaryButton.snp.makeConstraints { make in
            make.top.equalTo(emptySubtitleLabel.snp.bottom).offset(32)
            make.leading.trailing.equalToSuperview().inset(12)
            make.height.equalTo(56)
            make.bottom.equalToSuperview()
        }

        loadingView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func setupActions() {
        primaryButton.addTarget(self, action: #selector(goToStoreTapped), for: .touchUpInside)
    }

    private func bindViewModel() {
        vm.$orders
            .receive(on: DispatchQueue.main)
            .sink { [weak self] orders in
                guard let self = self else { return }

                let isEmpty = orders.isEmpty
                self.emptyContainer.isHidden = !isEmpty
                self.tableView.isHidden = isEmpty
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

    @objc private func goToStoreTapped() {
        onRoute?(.goToHome)
    }
}

extension MyOrderVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vm.orders.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: OrderCell.reuseIdentifier, for: indexPath) as? OrderCell else {
            return UITableViewCell()
        }

        let order = vm.orders[indexPath.row]
        cell.configure(with: order)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let order = vm.orders[indexPath.row]
        onRoute?(.orderDetail(order))
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 156
    }
}
