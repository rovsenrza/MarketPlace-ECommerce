import UIKit

final class IconContainer: UIView {
    init(backgroundColor: UIColor? = nil, cornerRadius: CGFloat = 8) {
        super.init(frame: .zero)
        setupContainer(backgroundColor: backgroundColor, cornerRadius: cornerRadius)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupContainer(backgroundColor: UIColor?, cornerRadius: CGFloat) {
        self.backgroundColor = backgroundColor ?? (UIColor(named: "SurfaceElevated") ?? .secondarySystemBackground)
        layer.cornerRadius = cornerRadius
    }
}
