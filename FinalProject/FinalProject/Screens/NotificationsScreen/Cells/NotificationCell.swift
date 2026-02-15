import SnapKit
import UIKit

final class NotificationCell: UITableViewCell {
    static let reuseIdentifier = "NotificationCell"

    private let containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.layer.borderWidth = 1
        return view
    }()

    private let iconContainer: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.backgroundColor = (UIColor(named: "PrimaryColorSet") ?? .systemBlue).withAlphaComponent(0.1)
        return view
    }()

    private let iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.tintColor = UIColor(named: "PrimaryColorSet") ?? .systemBlue
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let unreadDot: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "PrimaryColorSet") ?? .systemBlue
        view.layer.cornerRadius = 5
        view.layer.borderWidth = 2
        view.layer.borderColor = (UIColor(named: "Background") ?? .systemBackground).cgColor
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = UIColor(named: "TextPrimary") ?? .label
        return label
    }()

    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = UIColor(named: "TextMuted") ?? .secondaryLabel
        label.textAlignment = .right
        return label
    }()

    private let messageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = UIColor(named: "TextSecondary") ?? .secondaryLabel
        label.numberOfLines = 0
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        addSubviews()
        setupConstraints()
    }

    func addSubviews() {
        contentView.addSubview(containerView)
        [iconContainer, titleLabel, timeLabel, messageLabel].forEach { containerView.addSubview($0) }
        iconContainer.addSubview(iconImageView)
        containerView.addSubview(unreadDot)
    }

    func setupConstraints() {
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }

        iconContainer.snp.makeConstraints { make in
            make.leading.top.equalToSuperview().inset(16)
            make.width.height.equalTo(48)
        }

        iconImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(22)
        }

        unreadDot.snp.makeConstraints { make in
            make.top.equalTo(iconContainer.snp.top).offset(-4)
            make.trailing.equalTo(iconContainer.snp.trailing).offset(4)
            make.width.height.equalTo(10)
        }

        timeLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(16)
            make.trailing.equalToSuperview().inset(16)
        }

        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(iconContainer.snp.trailing).offset(12)
            make.top.equalToSuperview().inset(16)
            make.trailing.lessThanOrEqualTo(timeLabel.snp.leading).offset(-8)
        }

        messageLabel.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(6)
            make.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(16)
        }
    }

    func configure(with notification: AppNotification) {
        titleLabel.text = notification.title
        messageLabel.text = notification.message
        timeLabel.text = relativeTime(from: notification.createdAt)
        unreadDot.isHidden = notification.isRead

        let iconName = iconNameForType(notification.type)
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular)
        iconImageView.image = UIImage(systemName: "shippingbox", withConfiguration: config)

        if notification.isRead {
            containerView.backgroundColor = UIColor(named: "Background") ?? .systemBackground
            containerView.layer.borderColor = (UIColor(named: "Divider") ?? UIColor.systemGray5).cgColor
        } else {
            containerView.backgroundColor = (UIColor(named: "SurfaceElevated") ?? .secondarySystemBackground)
            containerView.layer.borderColor = (UIColor(named: "Divider") ?? UIColor.systemGray5).cgColor
        }
    }

    private func iconNameForType(_ type: String) -> String {
        switch type {
        case "order_accepted":
            return "local_shipping"
        case "order_delivered":
            return "check_circle"
        case "order_shipped":
            return "shippingbox"
        default:
            return "notifications"
        }
    }

    private func relativeTime(from date: Date?) -> String {
        guard let date = date else { return "" }

        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}
