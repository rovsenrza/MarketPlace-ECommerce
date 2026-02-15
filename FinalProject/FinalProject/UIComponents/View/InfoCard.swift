import UIKit

final class InfoCard: UIView {
    init(cornerRadius: CGFloat = 16, borderWidth: CGFloat = 1) {
        super.init(frame: .zero)
        setupCard(cornerRadius: cornerRadius, borderWidth: borderWidth)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCard(cornerRadius: CGFloat, borderWidth: CGFloat) {
        backgroundColor = UIColor(named: "Surface") ?? .systemBackground
        layer.cornerRadius = cornerRadius
        layer.borderWidth = borderWidth
        layer.borderColor = (UIColor(named: "Divider") ?? UIColor.systemGray5).cgColor
    }
}
