import SnapKit
import UIKit

final class CategoryPillCell: UICollectionViewCell {
    static let reuseIdentifier = "CategoryPillCell"
    
    private let iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.tintColor = UIColor(named: "TextPrimary")
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = UIColor(named: "TextPrimary")
        label.textAlignment = .center
        return label
    }()
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        return stack
    }()
    
    override var isSelected: Bool {
        didSet {
            updateAppearance()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        contentView.layer.cornerRadius = 20
        contentView.layer.borderWidth = 1
        addSubviews()
        setupConstraints()
        updateAppearance()
    }

    func addSubviews() {
        contentView.addSubview(stackView)
        [iconImageView, titleLabel].forEach { stackView.addArrangedSubview($0) }
    }

    func setupConstraints() {
        iconImageView.snp.makeConstraints { make in
            make.width.height.equalTo(18)
        }

        stackView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.centerY.equalToSuperview()
        }
    }
    
    private func updateAppearance() {
        if isSelected {
            contentView.backgroundColor = UIColor(named: "AccentColor")
            contentView.layer.borderColor = UIColor(named: "AccentColor")?.cgColor
            titleLabel.textColor = .white
            iconImageView.tintColor = .white
            
            contentView.layer.shadowColor = UIColor(named: "AccentColor")?.cgColor
            contentView.layer.shadowOffset = CGSize(width: 0, height: 4)
            contentView.layer.shadowRadius = 8
            contentView.layer.shadowOpacity = 0.2
        } else {
            contentView.backgroundColor = UIColor(named: "Surface")
            contentView.layer.borderColor = UIColor(named: "Border")?.cgColor
            titleLabel.textColor = UIColor(named: "TextPrimary")
            iconImageView.tintColor = UIColor(named: "TextPrimary")
            
            contentView.layer.shadowOpacity = 0
        }
    }
    
    func configure(with category: Category, showIcon: Bool = true) {
        titleLabel.text = category.title
        
        if showIcon {
            iconImageView.image = UIImage(systemName: category.icon)
            iconImageView.isHidden = false
        } else {
            iconImageView.isHidden = true
        }
    }
    
    func configureAsAll() {
        titleLabel.text = "All"
        iconImageView.isHidden = true
        titleLabel.textColor = .white
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        iconImageView.isHidden = false
        isSelected = false
        updateAppearance()
    }
}
