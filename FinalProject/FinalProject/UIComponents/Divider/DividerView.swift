import UIKit

final class DividerView: UIView {
    private let dividerColor: UIColor
    private let dividerHeight: CGFloat

    init(color: UIColor = .separator, height: CGFloat = 0.5) {
        self.dividerColor = color
        self.dividerHeight = height
        super.init(frame: .zero)
        setupUI()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupUI() {
        backgroundColor = dividerColor
        translatesAutoresizingMaskIntoConstraints = false
        addSubviews()
        setupConstraints()
    }

    func addSubviews() {}

    func setupConstraints() {
        heightAnchor.constraint(equalToConstant: dividerHeight).isActive = true
    }
}
