import UIKit

final class SubtitleLabel: UILabel {
    init(text: String = "", size: CGFloat = 14, weight: UIFont.Weight = .regular, color: UIColor? = nil, lines: Int = 0) {
        super.init(frame: .zero)
        setupLabel(text: text, size: size, weight: weight, color: color, lines: lines)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLabel(text: String, size: CGFloat, weight: UIFont.Weight, color: UIColor?, lines: Int) {
        self.text = text
        font = .systemFont(ofSize: size, weight: weight)
        textColor = color ?? UIColor(named: "TextSecondary") ?? .secondaryLabel
        numberOfLines = lines
    }
}
