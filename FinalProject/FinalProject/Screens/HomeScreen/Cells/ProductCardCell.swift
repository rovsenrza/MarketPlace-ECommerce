import Kingfisher
import SnapKit
import UIKit

final class ProductCardCell: UICollectionViewCell {
    static let reuseIdentifier = "ProductCardCell"
    
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = UIColor(named: "Surface")
        return iv
    }()
    
    let favoriteButton: UIButton = {
        let btn = UIButton()
        let config = UIImage.SymbolConfiguration(pointSize: 18)
        btn.setImage(UIImage(systemName: "heart.fill", withConfiguration: config), for: .normal)
        btn.tintColor = UIColor(named: "TextMuted")
        btn.backgroundColor = .white.withAlphaComponent(0.9)
        btn.layer.cornerRadius = 16
        btn.layer.shadowColor = UIColor.black.cgColor
        btn.layer.shadowOffset = CGSize(width: 0, height: 2)
        btn.layer.shadowRadius = 4
        btn.layer.shadowOpacity = 0.1
        return btn
    }()
    
    private let discountBadge: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10, weight: .bold)
        label.textColor = UIColor(named: "TextPrimary")
        label.backgroundColor = UIColor(named: "Rating")?.withAlphaComponent(0.9)
        label.textAlignment = .center
        label.layer.cornerRadius = 4
        label.clipsToBounds = true
        label.isHidden = true
        return label
    }()
    
    private let ratingIcon: UIImageView = {
        let iv = UIImageView()
        let config = UIImage.SymbolConfiguration(pointSize: 14)
        iv.image = UIImage(systemName: "star.fill", withConfiguration: config)
        iv.tintColor = UIColor(named: "Rating")
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    private let ratingLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10, weight: .bold)
        label.textColor = UIColor(named: "TextMuted")
        return label
    }()
    
    private let ratingStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 4
        stack.alignment = .center
        return stack
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = UIColor(named: "TextPrimary")
        label.numberOfLines = 1
        return label
    }()
    
    private let brandLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = UIColor(named: "TextMuted")
        label.numberOfLines = 1
        return label
    }()
    
    private let originalPriceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10, weight: .regular)
        label.textColor = UIColor(named: "TextMuted")
        label.isHidden = true
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .heavy)
        label.textColor = UIColor(named: "PrimaryColorSet")
        return label
    }()
    
    private let priceStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 6
        stack.alignment = .center
        return stack
    }()
    
    var onFavoriteTapped: ((Bool) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        favoriteButton.addTarget(self, action: #selector(favoriteTapped), for: .touchUpInside)
    }
    
    @objc private func favoriteTapped() {
        favoriteButton.isSelected.toggle()
        favoriteButton.tintColor = favoriteButton.isSelected ? UIColor(named: "Error") : UIColor(named: "TextMuted")
        onFavoriteTapped?(favoriteButton.isSelected)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.kf.cancelDownloadTask()
        imageView.image = nil
        titleLabel.text = nil
        brandLabel.text = nil
        ratingLabel.text = nil
        favoriteButton.isSelected = false
        favoriteButton.tintColor = UIColor(named: "TextMuted")
        onFavoriteTapped = nil
        
        priceStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        priceLabel.text = nil
        originalPriceLabel.text = nil
        discountBadge.text = nil
    }
    
    func setupUI() {
        contentView.backgroundColor = UIColor(named: "Surface")
        contentView.layer.cornerRadius = 16
        contentView.clipsToBounds = true
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor(named: "Border")?.cgColor
        addSubviews()
        setupConstraints()
    }

    func addSubviews() {
        for item in [imageView, favoriteButton, discountBadge, ratingStackView, titleLabel, brandLabel, priceStackView] {
            contentView.addSubview(item)
        }
        [ratingIcon, ratingLabel].forEach { ratingStackView.addArrangedSubview($0) }
        [originalPriceLabel, priceLabel].forEach { priceStackView.addArrangedSubview($0) }
    }

    func setupConstraints() {
        imageView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(imageView.snp.width)
        }

        favoriteButton.snp.makeConstraints { make in
            make.top.equalTo(imageView).offset(8)
            make.trailing.equalTo(imageView).offset(-8)
            make.width.height.equalTo(32)
        }

        discountBadge.snp.makeConstraints { make in
            make.leading.equalTo(imageView).offset(8)
            make.bottom.equalTo(imageView).offset(-8)
            make.height.equalTo(18)
            make.width.greaterThanOrEqualTo(50)
        }

        ratingStackView.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(12)
            make.leading.equalToSuperview().offset(12)
        }

        ratingIcon.snp.makeConstraints { make in
            make.width.height.equalTo(14)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(ratingStackView.snp.bottom).offset(4)
            make.leading.trailing.equalToSuperview().inset(12)
        }

        brandLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(2)
            make.leading.trailing.equalToSuperview().inset(12)
        }

        priceStackView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(12)
            make.bottom.equalToSuperview().offset(-12)
        }
    }
    
    func configure(with product: Product, categories: [Category] = []) {
        if let urlString = product.imageUrl, let url = URL(string: urlString) {
            imageView.kf.setImage(with: url, placeholder: nil)
        } else if let variantImages = product.variantImages, let firstImage = variantImages.first, let url = URL(string: firstImage) {
            imageView.kf.setImage(with: url, placeholder: nil)
        } else {
            imageView.image = nil
        }
        
        titleLabel.text = product.title
        
        if let categoryIds = product.categoryIds, let firstCategoryId = categoryIds.first {
            let categoryName = categories.first(where: { $0.id == firstCategoryId })?.title
            brandLabel.text = categoryName ?? product.brand ?? ""
        } else {
            brandLabel.text = product.brand ?? ""
        }
        
        let rating = product.averageRating
        let reviewCount = product.reviewCount
        ratingLabel.text = String(format: "%.1f (%d)", rating, reviewCount)
        
        priceStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        if let discountPrice = product.discountPrice {
            priceLabel.text = String(format: "$%.2f", discountPrice)
            priceStackView.addArrangedSubview(priceLabel)
            
            originalPriceLabel.isHidden = false
            let attributedString = NSAttributedString(
                string: String(format: "$%.2f", product.basePrice),
                attributes: [.strikethroughStyle: NSUnderlineStyle.single.rawValue]
            )
            originalPriceLabel.attributedText = attributedString
            priceStackView.addArrangedSubview(originalPriceLabel)
            
            if let percentage = product.discountPercentage {
                discountBadge.text = "SAVE \(percentage)%"
                discountBadge.isHidden = false
            }
        } else {
            priceLabel.text = String(format: "$%.2f", product.basePrice)
            priceStackView.addArrangedSubview(priceLabel)
            originalPriceLabel.isHidden = true
            discountBadge.isHidden = true
        }
    }
}
