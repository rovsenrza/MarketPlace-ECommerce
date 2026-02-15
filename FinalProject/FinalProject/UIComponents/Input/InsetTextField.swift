import UIKit

final class InsetTextField: UITextField {
    private let contentInsets: UIEdgeInsets

    init(_ top: CGFloat, _ left: CGFloat, _ bottom: CGFloat, _ right: CGFloat) {
        self.contentInsets = UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
        super.init(frame: .zero)
        commonInit()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }

    private func commonInit() {
        backgroundColor = UIColor(named: "Surface") ?? .secondarySystemBackground
        layer.cornerRadius = 12
        layer.borderWidth = 1
        layer.borderColor = (UIColor(named: "Border") ?? UIColor.systemGray4).cgColor
        font = .preferredFont(forTextStyle: .body)
        adjustsFontForContentSizeCategory = true
        heightAnchor.constraint(equalToConstant: 52).isActive = true
    }

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: contentInsets)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: contentInsets)
    }

    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: contentInsets)
    }
}
