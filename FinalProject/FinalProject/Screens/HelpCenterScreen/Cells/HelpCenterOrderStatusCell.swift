import SnapKit
import UIKit

final class HelpCenterOrderStatusCell: UICollectionViewCell {
    static let reuseIdentifier = "HelpCenterOrderStatusCell"

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
        view.backgroundColor = (UIColor(named: "PrimaryColorSet") ?? .systemBlue).withAlphaComponent(0.12)
        return view
    }()

    private let iconView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.tintColor = UIColor(named: "PrimaryColorSet") ?? .systemBlue
        return iv
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textColor = UIColor(named: "TextPrimary") ?? .label
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = UIColor(named: "TextMuted") ?? .secondaryLabel
        label.numberOfLines = 2
        return label
    }()

    private let chevronView: UIImageView = {
        let iv = UIImageView()
        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)
        iv.image = UIImage(systemName: "chevron.right", withConfiguration: config)
        iv.tintColor = UIColor(named: "TextMuted") ?? .tertiaryLabel
        return iv
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupUI() {
        addSubviews()
        setupConstraints()
        let selectedView = UIView()
        selectedView.backgroundColor = (UIColor(named: "PrimaryColorSet") ?? .systemBlue).withAlphaComponent(0.08)
        selectedBackgroundView = selectedView
    }

    func addSubviews() {
        contentView.addSubview(containerView)
        [iconContainer, titleLabel, subtitleLabel, chevronView].forEach { containerView.addSubview($0) }
        iconContainer.addSubview(iconView)
    }

    func setupConstraints() {
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        iconContainer.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(48)
        }

        iconView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(24)
        }

        chevronView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.width.equalTo(16)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.equalTo(iconContainer.snp.trailing).offset(12)
            make.trailing.equalTo(chevronView.snp.leading).offset(-12)
        }

        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.leading.trailing.equalTo(titleLabel)
            make.bottom.lessThanOrEqualToSuperview().offset(-16)
        }
    }

    func configure(with category: HelpCenterCategory) {
        titleLabel.text = category.title
        subtitleLabel.text = category.subtitle
        let config = UIImage.SymbolConfiguration(pointSize: 22, weight: .semibold)
        iconView.image = UIImage(systemName: category.iconName, withConfiguration: config)
    }
}
