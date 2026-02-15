import Combine
import SnapKit
import UIKit

final class NotificationsVC: UIViewController {
    private let vm: NotificationsVM
    private let onRoute: ((NotificationsRoute) -> Void)?
    private var cancellables = Set<AnyCancellable>()

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.showsVerticalScrollIndicator = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 96
        tableView.register(NotificationCell.self, forCellReuseIdentifier: NotificationCell.reuseIdentifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    private let loadingView: LoadingView = {
        let view = LoadingView(message: "Loading notifications...")
        view.isHidden = true
        return view
    }()

    private let emptyContainer: UIView = {
        let view = UIView()
        return view
    }()

    private let emptyIconContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "SurfaceElevated") ?? .secondarySystemBackground
        view.layer.cornerRadius = 40
        view.layer.borderWidth = 1
        view.layer.borderColor = (UIColor(named: "Divider") ?? UIColor.systemGray5).cgColor
        return view
    }()

    private let emptyIconView: UIImageView = {
        let config = UIImage.SymbolConfiguration(pointSize: 48, weight: .light)
        let image = UIImage(systemName: "bell", withConfiguration: config)
        let iv = UIImageView(image: image)
        iv.tintColor = UIColor(named: "TextMuted") ?? .systemGray3
        return iv
    }()

    private let emptyTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "No Notifications"
        label.font = AppTypography.title()
        label.textColor = UIColor(named: "TextPrimary") ?? .label
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private let emptySubtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "You're all caught up. We'll notify you when something new arrives."
        label.font = AppTypography.body()
        label.textColor = UIColor(named: "TextMuted") ?? .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    init(vm: NotificationsVM, onRoute: ((NotificationsRoute) -> Void)? = nil) {
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
        vm.fetchNotifications()
    }

    func setupUI() {
        view.backgroundColor = UIColor(named: "Background") ?? .systemBackground
        title = "Notifications"
        navigationController?.navigationBar.prefersLargeTitles = false

        addSubviews()
        setupConstraints()
        bindViewModel()
    }

    func addSubviews() {
        [tableView, emptyContainer, loadingView].forEach { view.addSubview($0) }
        [emptyIconContainer, emptyTitleLabel, emptySubtitleLabel].forEach { emptyContainer.addSubview($0) }
        emptyIconContainer.addSubview(emptyIconView)
    }

    func setupConstraints() {
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        loadingView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        emptyContainer.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(24)
        }

        emptyIconContainer.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.height.equalTo(80)
        }

        emptyIconView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        emptyTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(emptyIconContainer.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview()
        }

        emptySubtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(emptyTitleLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }

    private func bindViewModel() {
        vm.$notifications
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
                self?.updateEmptyState()
            }
            .store(in: &cancellables)

        vm.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                self?.loadingView.isHidden = !isLoading
                self?.updateEmptyState()
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

    private func updateEmptyState() {
        let isEmpty = vm.notifications.isEmpty && vm.isLoading == false
        emptyContainer.isHidden = !isEmpty
        tableView.isHidden = isEmpty
    }
}

extension NotificationsVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        vm.notifications.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NotificationCell.reuseIdentifier, for: indexPath) as? NotificationCell else {
            return UITableViewCell()
        }

        cell.configure(with: vm.notifications[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let notification = vm.notifications[indexPath.row]
        vm.markRead(notification)
        onRoute?(.detail(notification))
    }
}
