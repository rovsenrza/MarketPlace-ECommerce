import Kingfisher
import SnapKit
import UIKit

final class OrderDetailItemCell: UITableViewCell {
    static let reuseIdentifier = "OrderDetailItemCell"

    private let containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.layer.borderWidth = 1
        view.layer.borderColor = (UIColor(named: "Divider") ?? UIColor.systemGray5).cgColor
        view.backgroundColor = UIColor(named: "Surface") ?? .systemBackground
        return view
    }()

    private let thumbnailView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 10
        iv.backgroundColor = UIColor(named: "SurfaceElevated") ?? .systemGray6
        return iv
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = UIColor(named: "TextPrimary") ?? .label
        label.numberOfLines = 2
        return label
    }()

    private let variantsLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = UIColor(named: "TextMuted") ?? .secondaryLabel
        label.numberOfLines = 2
        return label
    }()

    private let colorDot: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 6
        view.layer.borderWidth = 1
        view.layer.borderColor = (UIColor(named: "Divider") ?? UIColor.systemGray5).cgColor
        view.isHidden = true
        return view
    }()

    private let quantityLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = UIColor(named: "PrimaryColorSet") ?? .systemBlue
        return label
    }()

    private let priceLabel: UILabel = {
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
        [thumbnailView, nameLabel, variantsLabel, colorDot, quantityLabel, priceLabel].forEach { containerView.addSubview($0) }
    }

    func setupConstraints() {
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 6, left: 16, bottom: 6, right: 16))
        }

        thumbnailView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(72)
        }

        nameLabel.snp.makeConstraints { make in
            make.leading.equalTo(thumbnailView.snp.trailing).offset(12)
            make.top.equalToSuperview().offset(12)
            make.trailing.equalToSuperview().offset(-12)
        }

        variantsLabel.snp.makeConstraints { make in
            make.leading.equalTo(nameLabel)
            make.top.equalTo(nameLabel.snp.bottom).offset(4)
            make.trailing.equalToSuperview().offset(-12)
        }

        colorDot.snp.makeConstraints { make in
            make.leading.equalTo(nameLabel)
            make.top.equalTo(variantsLabel.snp.bottom).offset(8)
            make.width.height.equalTo(12)
        }

        quantityLabel.snp.makeConstraints { make in
            make.leading.equalTo(colorDot.snp.trailing).offset(8)
            make.centerY.equalTo(colorDot)
            make.bottom.equalToSuperview().offset(-12)
        }

        priceLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-12)
            make.centerY.equalTo(quantityLabel)
        }
    }

    func configure(with item: OrderItem) {
        nameLabel.text = item.productName
        quantityLabel.text = "Quantity: \(item.quantity)"
        priceLabel.text = String(format: "$%.2f", item.totalPrice)

        if let variants = item.selectedVariants, !variants.isEmpty {
            let filtered = variants.filter { $0.key.lowercased() != "color" }
            let variantText = filtered.map { "\($0.key.capitalized): \($0.value)" }.joined(separator: " | ")
            variantsLabel.text = variantText.isEmpty ? "Standard" : variantText
        } else {
            variantsLabel.text = "Standard"
        }

        let colorValue = item.selectedVariants?.first { $0.key.lowercased() == "color" }?.value
        if let colorValue, let color = UIColor(hex: colorValue) {
            colorDot.isHidden = false
            colorDot.backgroundColor = color
        } else {
            colorDot.isHidden = true
            colorDot.backgroundColor = .clear
        }

        if let imageUrl = item.productImageUrl, let url = URL(string: imageUrl) {
            thumbnailView.kf.setImage(with: url)
        } else {
            thumbnailView.image = nil
        }
    }
}
