import SnapKit
import UIKit

final class ShippingAddressCell: UITableViewCell {
    static let reuseIdentifier = "ShippingAddressCell"

    private let containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 14
        view.layer.borderWidth = 1
        view.layer.borderColor = (UIColor(named: "Border") ?? UIColor.systemGray5).cgColor
        view.backgroundColor = UIColor(named: "Surface") ?? .systemBackground
        return view
    }()

    private let iconContainer: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.backgroundColor = (UIColor(named: "PrimaryColorSet") ?? .systemBlue).withAlphaComponent(0.1)
        return view
    }()

    private let iconView: UIImageView = {
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        let image = UIImage(systemName: "location.fill", withConfiguration: config)
        let iv = UIImageView(image: image)
        iv.tintColor = UIColor(named: "PrimaryColorSet") ?? .systemBlue
        return iv
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = UIColor(named: "TextPrimary") ?? .label
        return label
    }()

    private let defaultBadge: UILabel = {
        let label = UILabel()
        label.text = "Default"
        label.font = .systemFont(ofSize: 10, weight: .bold)
        label.textColor = UIColor(named: "PrimaryColorSet") ?? .systemBlue
        label.backgroundColor = (UIColor(named: "PrimaryColorSet") ?? .systemBlue).withAlphaComponent(0.1)
        label.layer.cornerRadius = 8
        label.clipsToBounds = true
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()

    private let phoneLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = UIColor(named: "TextMuted") ?? .secondaryLabel
        return label
    }()

    private let addressLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = UIColor(named: "TextSecondary") ?? .secondaryLabel
        label.numberOfLines = 2
        return label
    }()

    private let editButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Edit", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 12, weight: .semibold)
        button.setTitleColor(UIColor(named: "PrimaryColorSet") ?? .systemBlue, for: .normal)
        button.backgroundColor = UIColor(named: "SurfaceElevated") ?? UIColor.systemGray6
        button.layer.cornerRadius = 10
        return button
    }()

    var onEditTapped: (() -> Void)?

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

        editButton.addTarget(self, action: #selector(editTapped), for: .touchUpInside)
    }

    func addSubviews() {
        contentView.addSubview(containerView)
        [iconContainer, nameLabel, defaultBadge, phoneLabel, addressLabel, editButton].forEach { containerView.addSubview($0) }
        iconContainer.addSubview(iconView)
    }

    func setupConstraints() {
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 6, left: 16, bottom: 6, right: 16))
        }

        iconContainer.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(16)
            make.width.height.equalTo(48)
        }

        iconView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(20)
        }

        editButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.top.equalToSuperview().offset(16)
            make.height.equalTo(28)
            make.width.equalTo(64)
        }

        nameLabel.snp.makeConstraints { make in
            make.leading.equalTo(iconContainer.snp.trailing).offset(12)
            make.trailing.lessThanOrEqualTo(editButton.snp.leading).offset(-12)
            make.top.equalToSuperview().offset(16)
        }

        defaultBadge.snp.makeConstraints { make in
            make.leading.equalTo(nameLabel)
            make.top.equalTo(nameLabel.snp.bottom).offset(6)
            make.height.equalTo(16)
            make.width.greaterThanOrEqualTo(56)
        }

        phoneLabel.snp.makeConstraints { make in
            make.leading.equalTo(nameLabel)
            make.top.equalTo(defaultBadge.snp.bottom).offset(6)
            make.trailing.equalToSuperview().offset(-16)
        }

        addressLabel.snp.makeConstraints { make in
            make.leading.equalTo(nameLabel)
            make.top.equalTo(phoneLabel.snp.bottom).offset(6)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-16)
        }
    }

    func configure(with address: ShippingAddress) {
        nameLabel.text = address.name
        phoneLabel.text = address.phoneNumber
        addressLabel.text = "\(address.streetAddress), \(address.city), \(address.state) \(address.zipCode)"
        defaultBadge.isHidden = !address.isDefault
    }

    @objc private func editTapped() {
        onEditTapped?()
    }
}
