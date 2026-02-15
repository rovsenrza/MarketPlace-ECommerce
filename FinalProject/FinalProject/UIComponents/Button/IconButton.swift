import UIKit

final class IconButton: UIButton {
    init(
        systemName: String,
        pointSize: CGFloat = 20,
        weight: UIImage.SymbolWeight = .medium,
        tintColor: UIColor? = nil,
        backgroundColor: UIColor? = nil,
        cornerRadius: CGFloat = 0
    ) {
        super.init(frame: .zero)
        setupButton(
            systemName: systemName,
            pointSize: pointSize,
            weight: weight,
            tintColor: tintColor,
            backgroundColor: backgroundColor,
            cornerRadius: cornerRadius
        )
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupButton(
        systemName: String,
        pointSize: CGFloat,
        weight: UIImage.SymbolWeight,
        tintColor: UIColor?,
        backgroundColor: UIColor?,
        cornerRadius: CGFloat
    ) {
        let config = UIImage.SymbolConfiguration(pointSize: pointSize, weight: weight)
        setImage(UIImage(systemName: systemName, withConfiguration: config), for: .normal)
        
        if let tintColor = tintColor {
            self.tintColor = tintColor
        }
        
        if let backgroundColor = backgroundColor {
            self.backgroundColor = backgroundColor
        }
        
        if cornerRadius > 0 {
            layer.cornerRadius = cornerRadius
            clipsToBounds = true
        }
    }
}
