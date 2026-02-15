import SnapKit
import UIKit

final class PaymentMethodCell: UITableViewCell {
    static let reuseIdentifier = "PaymentMethodCell"

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
        view.layer.cornerRadius = 8
        view.layer.borderWidth = 1
        view.layer.borderColor = (UIColor(named: "Border") ?? UIColor.systemGray5).cgColor
        view.backgroundColor = UIColor(named: "Background") ?? .systemBackground
        return view
    }()

    private let iconView: UIImageView = {
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)
        let image = UIImage(systemName: "creditcard", withConfiguration: config)
        let iv = UIImageView(image: image)
        iv.tintColor = UIColor(named: "TextPrimary") ?? .label
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let numberLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = UIColor(named: "TextPrimary") ?? .label
        return label
    }()

    private let expiryLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = UIColor(named: "TextSecondary") ?? .secondaryLabel
        return label
    }()

    private let radioOuter: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 10
        view.layer.borderWidth = 2
        view.layer.borderColor = (UIColor(named: "Divider") ?? UIColor.systemGray4).cgColor
        return view
    }()

    private let radioInner: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 6
        view.backgroundColor = UIColor(named: "PrimaryColorSet") ?? .systemBlue
        view.isHidden = true
        return view
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
        [iconContainer, numberLabel, expiryLabel, radioOuter].forEach { containerView.addSubview($0) }
        iconContainer.addSubview(iconView)
        radioOuter.addSubview(radioInner)
    }

    func setupConstraints() {
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 6, left: 16, bottom: 6, right: 16))
        }

        iconContainer.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.equalTo(48)
            make.height.equalTo(32)
        }

        iconView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(20)
        }

        numberLabel.snp.makeConstraints { make in
            make.leading.equalTo(iconContainer.snp.trailing).offset(12)
            make.top.equalToSuperview().offset(12)
            make.trailing.equalTo(radioOuter.snp.leading).offset(-12)
        }

        expiryLabel.snp.makeConstraints { make in
            make.leading.equalTo(numberLabel)
            make.top.equalTo(numberLabel.snp.bottom).offset(4)
            make.bottom.equalToSuperview().offset(-12)
            make.trailing.equalTo(numberLabel)
        }

        radioOuter.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(20)
        }

        radioInner.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(12)
        }
    }

    func configure(with payment: PaymentMethod) {
        numberLabel.text = maskNumber(payment.cardNumber)
        expiryLabel.text = "Expires \(payment.expiryDate)"
        let isDefault = payment.isDefault
        radioInner.isHidden = !isDefault
        radioOuter.layer.borderColor = (isDefault ? (UIColor(named: "PrimaryColorSet") ?? .systemBlue) : (UIColor(named: "Divider") ?? UIColor.systemGray4)).cgColor
    }

    private func maskNumber(_ number: String) -> String {
        let digits = number.filter { $0.isNumber }
        let trimmed = String(digits.prefix(16))
        guard !trimmed.isEmpty else { return "•••• •••• •••• ••••" }

        let first = String(trimmed.prefix(4))
        let last = trimmed.count > 4 ? String(trimmed.suffix(4)) : ""
        if last.isEmpty {
            return "\(first) •••• •••• ••••"
        }
        return "\(first) •••• •••• \(last)"
    }
}
