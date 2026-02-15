import Kingfisher
import SnapKit
import UIKit

final class CartItemCell: UITableViewCell {
    static let reuseIdentifier = "CartItemCell"
    
    var onQuantityChanged: ((Int) -> Void)?
    var onDeleteTapped: (() -> Void)?
    
    private let productImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 12
        iv.backgroundColor = .systemGray6
        return iv
    }()
    
    private let nameLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 16, weight: .bold)
        lbl.textColor = .label
        lbl.numberOfLines = 2
        return lbl
    }()
    
    private let detailsLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 12, weight: .medium)
        lbl.textColor = .secondaryLabel
        return lbl
    }()

    private let variantsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        return stack
    }()
    
    private let saleBadge: UILabel = {
        let lbl = UILabel()
        lbl.text = "SALE"
        lbl.font = .systemFont(ofSize: 10, weight: .bold)
        lbl.textColor = UIColor(named: "Accent") ?? .systemOrange
        lbl.backgroundColor = (UIColor(named: "Accent") ?? .systemOrange).withAlphaComponent(0.1)
        lbl.textAlignment = .center
        lbl.layer.cornerRadius = 4
        lbl.clipsToBounds = true
        lbl.isHidden = true
        return lbl
    }()
    
    private let priceLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 18, weight: .heavy)
        lbl.textColor = UIColor(named: "PrimaryColorSet") ?? .systemBlue
        return lbl
    }()
    
    private let deleteButton: UIButton = {
        let btn = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 20)
        btn.setImage(UIImage(systemName: "trash", withConfiguration: config), for: .normal)
        btn.tintColor = .systemGray3
        return btn
    }()
    
    private let quantityContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        view.layer.cornerRadius = 8
        return view
    }()
    
    private let decrementButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("-", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        btn.tintColor = UIColor(named: "PrimaryColorSet") ?? .systemBlue
        return btn
    }()
    
    private let quantityLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "1"
        lbl.font = .systemFont(ofSize: 14, weight: .bold)
        lbl.textAlignment = .center
        lbl.textColor = .label
        return lbl
    }()
    
    private let incrementButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("+", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        btn.tintColor = UIColor(named: "PrimaryColorSet") ?? .systemBlue
        return btn
    }()
    
    private var currentQuantity = 1
    
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
        
        decrementButton.addTarget(self, action: #selector(decrementTapped), for: .touchUpInside)
        incrementButton.addTarget(self, action: #selector(incrementTapped), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
    }

    func addSubviews() {
        [
            productImageView,
            nameLabel,
            saleBadge,
            detailsLabel,
            variantsStackView,
            priceLabel,
            deleteButton,
            quantityContainerView
        ].forEach { contentView.addSubview($0) }

        [decrementButton, quantityLabel, incrementButton].forEach { quantityContainerView.addSubview($0) }
    }

    func setupConstraints() {
        productImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(12)
            make.bottom.equalToSuperview().offset(-12)
            make.width.height.equalTo(90)
        }

        deleteButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.top.equalToSuperview().offset(16)
            make.width.height.equalTo(32)
        }

        nameLabel.snp.makeConstraints { make in
            make.leading.equalTo(productImageView.snp.trailing).offset(8)
            make.trailing.equalTo(deleteButton.snp.leading).offset(-8)
            make.top.equalTo(productImageView.snp.top).offset(-16)
        }

        saleBadge.snp.makeConstraints { make in
            make.leading.equalTo(nameLabel.snp.trailing)
            make.centerY.equalTo(nameLabel)
            make.height.equalTo(18)
            make.width.equalTo(40)
        }

        detailsLabel.snp.makeConstraints { make in
            make.leading.equalTo(nameLabel)
            make.top.equalTo(nameLabel.snp.bottom).offset(4)
        }

        variantsStackView.snp.makeConstraints { make in
            make.leading.equalTo(detailsLabel.snp.trailing).offset(8)
            make.trailing.lessThanOrEqualTo(nameLabel)
            make.centerY.equalTo(detailsLabel)
        }

        priceLabel.snp.makeConstraints { make in
            make.leading.equalTo(nameLabel)
            make.bottom.equalTo(productImageView.snp.bottom).offset(-2)
        }

        quantityContainerView.snp.makeConstraints { make in
            make.trailing.equalTo(deleteButton)
            make.bottom.equalTo(productImageView.snp.bottom).offset(-2)
            make.height.equalTo(32)
        }

        decrementButton.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.bottom.equalToSuperview()
            make.width.equalTo(32)
        }

        quantityLabel.snp.makeConstraints { make in
            make.leading.equalTo(decrementButton.snp.trailing)
            make.top.bottom.equalToSuperview()
            make.width.equalTo(24)
        }

        incrementButton.snp.makeConstraints { make in
            make.leading.equalTo(quantityLabel.snp.trailing)
            make.trailing.equalToSuperview()
            make.top.bottom.equalToSuperview()
            make.width.equalTo(32)
        }
    }
    
    func configure(imageUrl: String?, name: String, variants: [String: String]?, price: Double, quantity: Int, isOnSale: Bool = false) {
        if let urlString = imageUrl, let url = URL(string: urlString) {
            productImageView.kf.setImage(with: url, placeholder: UIImage(systemName: "photo"))
        } else {
            productImageView.image = UIImage(systemName: "photo")
        }
        
        nameLabel.text = name
        
        variantsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        if let variants = variants, !variants.isEmpty {
            let colorKey = variants.keys.first { $0.lowercased() == "color" }
            let colorValue = colorKey.flatMap { variants[$0] }
            
            let nonColorKeys = variants.keys
                .filter { $0.lowercased() != "color" }
                .sorted()
            
            var parts: [String] = []
            for key in nonColorKeys {
                if let value = variants[key] {
                    parts.append("\(key.capitalized): \(value)")
                }
            }
            
            if colorValue != nil {
                parts.append("Color")
            }
            
            detailsLabel.text = parts.isEmpty ? "Standard" : parts.joined(separator: " | ")
            
            if let colorValue, let color = UIColor(hex: colorValue) {
                let colorSwatch = UIView()
                colorSwatch.layer.cornerRadius = 7
                colorSwatch.layer.borderWidth = 1
                colorSwatch.layer.borderColor = UIColor.separator.cgColor
                colorSwatch.backgroundColor = color
                colorSwatch.snp.makeConstraints { make in
                    make.width.height.equalTo(14)
                }
                variantsStackView.addArrangedSubview(colorSwatch)
            }
        } else {
            detailsLabel.text = "Standard"
        }
        
        priceLabel.text = String(format: "$%.2f", price)
        currentQuantity = quantity
        quantityLabel.text = "\(quantity)"
        saleBadge.isHidden = !isOnSale
    }
    
    @objc private func decrementTapped() {
        guard currentQuantity > 1 else { return }

        currentQuantity -= 1
        quantityLabel.text = "\(currentQuantity)"
        onQuantityChanged?(currentQuantity)
    }
    
    @objc private func incrementTapped() {
        currentQuantity += 1
        quantityLabel.text = "\(currentQuantity)"
        onQuantityChanged?(currentQuantity)
    }
    
    @objc private func deleteTapped() {
        onDeleteTapped?()
    }
}
