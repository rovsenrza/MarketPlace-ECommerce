import Kingfisher
import SnapKit
import UIKit

final class OrderCell: UITableViewCell {
    static let reuseIdentifier = "OrderCell"

    private let containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 14
        view.layer.borderWidth = 1
        view.layer.borderColor = (UIColor(named: "Divider") ?? UIColor.systemGray5).cgColor
        view.backgroundColor = UIColor(named: "Surface") ?? .systemBackground
        return view
    }()

    private let statusBadge: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10, weight: .bold)
        label.textAlignment = .center
        label.layer.cornerRadius = 10
        label.clipsToBounds = true
        return label
    }()

    private let orderLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textColor = UIColor(named: "TextPrimary") ?? .label
        return label
    }()

    private let chevronView: UIImageView = {
        let config = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        let iv = UIImageView(image: UIImage(systemName: "chevron.right", withConfiguration: config))
        iv.tintColor = UIColor(named: "TextMuted") ?? .tertiaryLabel
        return iv
    }()

    private let thumbnailView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 10
        iv.backgroundColor = UIColor(named: "SurfaceElevated") ?? .systemGray6
        return iv
    }()

    private let metaLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = UIColor(named: "TextMuted") ?? .secondaryLabel
        return label
    }()

    private let totalLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textColor = UIColor(named: "TextPrimary") ?? .label
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

        addSubviews()
        setupConstraints()
    }

    func addSubviews() {
        contentView.addSubview(containerView)
        [statusBadge, orderLabel, chevronView, thumbnailView, metaLabel, totalLabel].forEach { containerView.addSubview($0) }
    }

    func setupConstraints() {
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 6, left: 16, bottom: 6, right: 16))
        }

        statusBadge.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.leading.equalToSuperview().offset(12)
            make.height.equalTo(20)
            make.width.greaterThanOrEqualTo(80)
        }

        orderLabel.snp.makeConstraints { make in
            make.top.equalTo(statusBadge.snp.bottom)
            make.leading.equalTo(statusBadge)
        }

        chevronView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-12)
            make.centerY.equalTo(orderLabel)
        }

        thumbnailView.snp.makeConstraints { make in
            make.top.equalTo(orderLabel.snp.bottom).offset(12)
            make.leading.equalToSuperview().offset(12)
            make.width.height.equalTo(72)
            make.bottom.equalToSuperview().offset(-12)
        }

        metaLabel.snp.makeConstraints { make in
            make.leading.equalTo(thumbnailView.snp.trailing).offset(12)
            make.top.equalTo(thumbnailView)
            make.trailing.equalToSuperview().offset(-12)
        }

        totalLabel.snp.makeConstraints { make in
            make.leading.equalTo(metaLabel)
            make.top.equalTo(metaLabel.snp.bottom).offset(6)
        }
    }

    func configure(with order: Order) {
        orderLabel.text = "Order #\(order.orderNumber)"
        metaLabel.text = "\(formattedDate(order.createdAt)) • \(order.totalItems) Items"
        totalLabel.text = String(format: "$%.2f", order.total)

        if let imageUrl = order.items.first?.productImageUrl, let url = URL(string: imageUrl) {
            thumbnailView.kf.setImage(with: url)
        } else {
            thumbnailView.image = nil
        }

        if order.status == "delivered" {
            statusBadge.text = "DELIVERED"
            statusBadge.textColor = UIColor.systemGreen
            statusBadge.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.1)
        } else {
            statusBadge.text = "ON DELIVERY"
            statusBadge.textColor = UIColor.systemOrange
            statusBadge.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.1)
        }
    }

    private func formattedDate(_ date: Date?) -> String {
        guard let date = date else { return "" }

        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}
