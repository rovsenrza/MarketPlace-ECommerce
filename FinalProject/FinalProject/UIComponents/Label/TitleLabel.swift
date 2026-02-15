import UIKit

final class TitleLabel: UILabel {
    init(text: String = "", size: CGFloat = 24, weight: UIFont.Weight = .bold, color: UIColor? = nil) {
        super.init(frame: .zero)
        setupLabel(text: text, size: size, weight: weight, color: color)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLabel(text: String, size: CGFloat, weight: UIFont.Weight, color: UIColor?) {
        self.text = text
        font = .systemFont(ofSize: size, weight: weight)
        textColor = color ?? UIColor(named: "TextPrimary") ?? .label
    }
}
