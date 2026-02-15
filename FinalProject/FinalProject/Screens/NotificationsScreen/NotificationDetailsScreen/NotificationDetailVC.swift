import SnapKit
import UIKit

final class NotificationDetailVC: UIViewController {
    private let vm: NotificationDetailVM

    private let iconContainer: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 32
        view.backgroundColor = (UIColor(named: "PrimaryColorSet") ?? .systemBlue).withAlphaComponent(0.1)
        return view
    }()

    private let iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.tintColor = UIColor(named: "PrimaryColorSet") ?? .systemBlue
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = UIColor(named: "TextPrimary") ?? .label
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()

    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = UIColor(named: "TextMuted") ?? .secondaryLabel
        label.textAlignment = .center
        return label
    }()

    private let messageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textColor = UIColor(named: "TextSecondary") ?? .secondaryLabel
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()

    init(vm: NotificationDetailVM) {
        self.vm = vm
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
        title = "Notification"
        navigationController?.navigationBar.prefersLargeTitles = false

        addSubviews()
        setupConstraints()
        configure()
    }

    func addSubviews() {
        [iconContainer, titleLabel, timeLabel, messageLabel].forEach { view.addSubview($0) }
        iconContainer.addSubview(iconImageView)
    }

    func setupConstraints() {
        iconContainer.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(40)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(64)
        }

        iconImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(28)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(iconContainer.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(24)
        }

        timeLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(24)
        }

        messageLabel.snp.makeConstraints { make in
            make.top.equalTo(timeLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(32)
        }
    }

    private func configure() {
        let notification = vm.notification
        titleLabel.text = notification.title
        messageLabel.text = notification.message
        timeLabel.text = formattedDate(notification.createdAt)

        let iconName: String
        switch notification.type {
        case "order_accepted":
            iconName = "local_shipping"
        case "order_delivered":
            iconName = "check_circle"
        case "order_shipped":
            iconName = "shippingbox"
        default:
            iconName = "notifications"
        }

        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .regular)
        iconImageView.image = UIImage(systemName: iconName, withConfiguration: config)
    }

    private func formattedDate(_ date: Date?) -> String {
        guard let date = date else { return "" }

        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
