import UIKit

final class CardView: UIView {
    private let cardBackgroundColor: UIColor
    private let cardCornerRadius: CGFloat
    private let cardShadowOpacity: Float
    private let cardShadowOffset: CGSize
    private let cardShadowRadius: CGFloat

    init(
        backgroundColor: UIColor = .systemBackground,
        cornerRadius: CGFloat = 12,
        shadowOpacity: Float = 0.05,
        shadowOffset: CGSize = CGSize(width: 0, height: 2),
        shadowRadius: CGFloat = 8
    ) {
        self.cardBackgroundColor = backgroundColor
        self.cardCornerRadius = cornerRadius
        self.cardShadowOpacity = shadowOpacity
        self.cardShadowOffset = shadowOffset
        self.cardShadowRadius = shadowRadius
        super.init(frame: .zero)
        setupUI()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupUI() {
        backgroundColor = cardBackgroundColor
        layer.cornerRadius = cardCornerRadius
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = cardShadowOpacity
        layer.shadowOffset = cardShadowOffset
        layer.shadowRadius = cardShadowRadius
        addSubviews()
        setupConstraints()
    }

    func addSubviews() {}

    func setupConstraints() {}
}
