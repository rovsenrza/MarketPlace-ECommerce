import UIKit

final class CartButton: UITabBar {
    private let centerButton = UIButton(type: .system)

    private let badgeLabel: UILabel = {
        let badgeLabel = UILabel()
        badgeLabel.backgroundColor = .rating
        badgeLabel.textColor = UIColor.systemBlue
        badgeLabel.font = .systemFont(ofSize: 10, weight: .heavy)
        badgeLabel.textAlignment = .center
        badgeLabel.layer.cornerRadius = 10
        badgeLabel.clipsToBounds = true
        badgeLabel.isHidden = true
        badgeLabel.textColor = .textPrimary
        return badgeLabel
    }()

    private let buttonSize: CGFloat = 56

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        layoutCenterButton()
    }

    func setupUI() {
        clipsToBounds = false
        layer.masksToBounds = false

        setupCenterButton()
        addSubviews()
        setupConstraints()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            centerButton.layer.borderColor = UIColor.systemBackground.cgColor
        }
    }

    private func setupCenterButton() {
        centerButton.backgroundColor = .primaryColorSet
        centerButton.layer.cornerRadius = buttonSize / 2
        centerButton.layer.borderWidth = 4
        centerButton.layer.borderColor = UIColor.systemBackground.cgColor
        centerButton.layer.shadowColor = UIColor.gray.cgColor
        centerButton.layer.shadowOpacity = 0.3
        centerButton.layer.shadowOffset = CGSize(width: 0, height: 10)
        centerButton.layer.shadowRadius = 20

        let image = UIImage(systemName: "cart.fill")
        centerButton.setImage(image, for: .normal)
        centerButton.tintColor = .white
    }

    func addSubviews() {
        [centerButton, badgeLabel].forEach { addSubview($0) }
    }

    func setupConstraints() {}

    private func layoutCenterButton() {
        centerButton.frame = CGRect(
            x: (bounds.width - buttonSize) / 2,
            y: 0,
            width: buttonSize,
            height: buttonSize
        )

        badgeLabel.frame = CGRect(
            x: centerButton.frame.maxX - 20,
            y: centerButton.frame.minY - 2,
            width: 20,
            height: 20
        )
        bringSubviewToFront(badgeLabel)
    }

    func setBadge(count: Int) {
        badgeLabel.isHidden = count <= 0
        badgeLabel.text = "\(count)"
    }

    func onCenterTap(_ action: @escaping () -> Void) {
        centerButton.addAction(UIAction { _ in action() }, for: .touchUpInside)
    }
}
