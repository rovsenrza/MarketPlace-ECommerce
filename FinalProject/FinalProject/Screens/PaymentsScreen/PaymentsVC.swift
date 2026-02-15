import Combine
import SnapKit
import UIKit

final class PaymentsVC: UIViewController {
    private let vm: PaymentsVM
    private let onRoute: ((PaymentsRoute) -> Void)?
    private var cancellables = Set<AnyCancellable>()

    // MARK: - UI

    private let savedMethodsLabel: UILabel = {
        let label = UILabel()
        label.text = "Saved Methods"
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
        tableView.register(PaymentMethodCell.self, forCellReuseIdentifier: PaymentMethodCell.reuseIdentifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    private let loadingView: LoadingView = {
        let view = LoadingView(message: "Loading payment methods...")
        view.isHidden = true
        return view
    }()

    private let emptyContainer: UIView = {
        let view = UIView()
        return view
    }()

    private let iconContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "SurfaceElevated") ?? .secondarySystemBackground
        view.layer.cornerRadius = 48
        view.layer.borderWidth = 1
        view.layer.borderColor = (UIColor(named: "Divider") ?? UIColor.systemGray5).cgColor
        view.layer.shadowColor = UIColor.black.withAlphaComponent(0.05).cgColor
        view.layer.shadowOpacity = 1
        view.layer.shadowRadius = 6
        view.layer.shadowOffset = CGSize(width: 0, height: 3)
        return view
    }()

    private let iconWrapper: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()

    private let cardIcon: UIImageView = {
        let config = UIImage.SymbolConfiguration(pointSize: 52, weight: .light)
        let image = UIImage(systemName: "creditcard", withConfiguration: config)
        let iv = UIImageView(image: image)
        iv.tintColor = UIColor(named: "TextMuted") ?? .systemGray3
        return iv
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "No Payment Methods"
        label.font = AppTypography.title()
        label.textColor = UIColor(named: "TextPrimary") ?? .label
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Save a card for faster checkout next time."
        label.font = AppTypography.body()
        label.textColor = UIColor(named: "TextMuted") ?? .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private let securityStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 6
        return stack
    }()

    private let lockIcon: UIImageView = {
        let config = UIImage.SymbolConfiguration(pointSize: 12, weight: .semibold)
        let image = UIImage(systemName: "lock", withConfiguration: config)
        let iv = UIImageView(image: image)
        iv.tintColor = UIColor(named: "TextMuted") ?? .tertiaryLabel
        return iv
    }()

    private let securityLabel: UILabel = {
        let label = UILabel()
        label.text = "SECURELY ENCRYPTED"
        label.font = .systemFont(ofSize: 10, weight: .semibold)
        label.textColor = UIColor(named: "TextMuted") ?? .tertiaryLabel
        return label
    }()

    private let bottomContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "Background")?.withAlphaComponent(0.98) ?? .systemBackground
        return view
    }()

    private let addButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Add New Card", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        button.backgroundColor = UIColor(named: "PrimaryColorSet") ?? .systemBlue
        button.layer.cornerRadius = 14
        button.layer.shadowColor = (UIColor(named: "PrimaryColorSet") ?? .systemBlue).withAlphaComponent(0.2).cgColor
        button.layer.shadowOpacity = 1
        button.layer.shadowRadius = 10
        button.layer.shadowOffset = CGSize(width: 0, height: 6)
        return button
    }()

    // MARK: - Init

    init(vm: PaymentsVM, onRoute: ((PaymentsRoute) -> Void)? = nil) {
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
        vm.fetchPayments()
    }

    func setupUI() {
        view.backgroundColor = UIColor(named: "Background") ?? .systemBackground
        title = "Payments"
        navigationController?.navigationBar.prefersLargeTitles = false

        let addBarButton = UIBarButtonItem(
            image: UIImage(systemName: "plus"),
            style: .plain,
            target: self,
            action: #selector(addPaymentTapped)
        )
        navigationItem.rightBarButtonItem = addBarButton

        addSubviews()
        setupConstraints()
        setupActions()
        bindViewModel()
    }

    func addSubviews() {
        securityStack.addArrangedSubview(lockIcon)
        securityStack.addArrangedSubview(securityLabel)
        [savedMethodsLabel, tableView, emptyContainer, bottomContainer, loadingView].forEach { view.addSubview($0) }
        bottomContainer.addSubview(addButton)

        emptyContainer.addSubview(iconContainer)
        emptyContainer.addSubview(titleLabel)
        emptyContainer.addSubview(subtitleLabel)
        emptyContainer.addSubview(securityStack)
        iconContainer.addSubview(iconWrapper)
        iconWrapper.addSubview(cardIcon)
    }

    func setupConstraints() {
        savedMethodsLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(12)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        tableView.snp.makeConstraints { make in
            make.top.equalTo(savedMethodsLabel.snp.bottom).offset(12)
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
            make.height.equalTo(52)
        }

        emptyContainer.snp.makeConstraints { make in
            make.centerY.equalToSuperview().offset(-40)
            make.leading.trailing.equalToSuperview().inset(24)
        }

        iconContainer.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.height.equalTo(120)
        }

        iconWrapper.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(96)
        }

        cardIcon.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(80)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(iconContainer.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        securityStack.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        loadingView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func setupActions() {
        addButton.addTarget(self, action: #selector(addPaymentTapped), for: .touchUpInside)
    }

    private func bindViewModel() {
        vm.$payments
            .receive(on: DispatchQueue.main)
            .sink { [weak self] payments in
                guard let self = self else { return }

                let isEmpty = payments.isEmpty
                self.emptyContainer.isHidden = !isEmpty
                self.tableView.isHidden = isEmpty
                self.savedMethodsLabel.isHidden = isEmpty
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

    @objc private func addPaymentTapped() {
        onRoute?(.addNewPayment)
    }
}

extension PaymentsVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vm.payments.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PaymentMethodCell.reuseIdentifier, for: indexPath) as? PaymentMethodCell else {
            return UITableViewCell()
        }

        let payment = vm.payments[indexPath.row]
        cell.configure(with: payment)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let payment = vm.payments[indexPath.row]
        if !payment.isDefault {
            vm.setDefault(payment)
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 86
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let payment = vm.payments[indexPath.row]
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completion in
            self?.vm.deletePayment(payment)
            completion(true)
        }
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}
