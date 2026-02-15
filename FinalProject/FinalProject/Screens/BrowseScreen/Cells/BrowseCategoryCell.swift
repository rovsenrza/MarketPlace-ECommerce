import SnapKit
import UIKit

final class BrowseCategoryCell: UITableViewCell {
    static let reuseIdentifier = "BrowseCategoryCell"
    
    private let iconContainer: UIView = {
        let view = UIView()
        view.backgroundColor = (UIColor(named: "PrimaryColorSet") ?? .systemBlue).withAlphaComponent(0.1)
        view.layer.cornerRadius = 10
        return view
    }()
    
    private let iconView: UIImageView = {
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .regular)
        let iv = UIImageView()
        iv.preferredSymbolConfiguration = config
        iv.tintColor = UIColor(named: "PrimaryColorSet") ?? .systemBlue
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = AppTypography.body()
        label.textColor = UIColor(named: "TextPrimary") ?? .label
        return label
    }()
    
    private let chevronView: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "chevron.right"))
        iv.tintColor = UIColor(named: "TextMuted") ?? .tertiaryLabel
        return iv
    }()
    
    private let separator = UIView()
    
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
        backgroundColor = UIColor(named: "Background") ?? .systemBackground
        contentView.backgroundColor = .clear
        
        separator.backgroundColor = (UIColor(named: "Divider") ?? .separator).withAlphaComponent(0.6)
        addSubviews()
        setupConstraints()
    }

    func addSubviews() {
        [iconContainer, titleLabel, chevronView, separator].forEach { contentView.addSubview($0) }
        iconContainer.addSubview(iconView)
    }

    func setupConstraints() {
        iconContainer.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(40)
        }

        iconView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(20)
        }

        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(iconContainer.snp.trailing).offset(12)
            make.centerY.equalToSuperview()
        }

        chevronView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
        }

        separator.snp.makeConstraints { make in
            make.leading.equalTo(iconContainer)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview()
            make.height.equalTo(0.5)
        }
    }
    
    func configure(with category: Category, isLast: Bool) {
        titleLabel.text = category.title
        iconView.image = UIImage(systemName: category.icon)
        separator.isHidden = isLast
    }
}
