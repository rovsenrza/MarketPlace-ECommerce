import UIKit

enum AppTypography {
    static func titleLarge() -> UIFont {
        scaledFont(textStyle: .largeTitle, weight: .heavy)
    }
    
    static func title() -> UIFont {
        scaledFont(textStyle: .title2, weight: .bold)
    }
    
    static func body() -> UIFont {
        scaledFont(textStyle: .body, weight: .regular)
    }
    
    static func label() -> UIFont {
        scaledFont(textStyle: .footnote, weight: .semibold)
    }
    
    static func button() -> UIFont {
        scaledFont(textStyle: .headline, weight: .semibold)
    }
    
    private static func scaledFont(textStyle: UIFont.TextStyle, weight: UIFont.Weight) -> UIFont {
        let baseSize = UIFont.preferredFont(forTextStyle: textStyle).pointSize
        let font = UIFont.systemFont(ofSize: baseSize, weight: weight)
        return UIFontMetrics(forTextStyle: textStyle).scaledFont(for: font)
    }
}
