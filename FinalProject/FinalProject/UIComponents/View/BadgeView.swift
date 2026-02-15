import UIKit

final class BadgeView: UIView {
    private let label = UILabel()
    private let badgeText: String
    private let badgeBackgroundColor: UIColor
    private let badgeTextColor: UIColor
    private let badgeFont: UIFont
    private let badgeCornerRadius: CGFloat
    
    init(
        text: String,
        backgroundColor: UIColor,
        textColor: UIColor = .white,
        font: UIFont = .systemFont(ofSize: 10, weight: .bold),
        cornerRadius: CGFloat = 4
    ) {
        self.badgeText = text
        self.badgeBackgroundColor = backgroundColor
        self.badgeTextColor = textColor
        self.badgeFont = font
        self.badgeCornerRadius = cornerRadius
        super.init(frame: .zero)
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        backgroundColor = badgeBackgroundColor
        layer.cornerRadius = badgeCornerRadius
        clipsToBounds = true
        
        label.text = badgeText
        label.font = badgeFont
        label.textColor = badgeTextColor
        label.textAlignment = .center
        
        addSubviews()
        setupConstraints()
    }

    func addSubviews() {
        addSubview(label)
    }

    func setupConstraints() {
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4),
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8)
        ])
    }
    
    func updateText(_ text: String) {
        label.text = text
    }
}
