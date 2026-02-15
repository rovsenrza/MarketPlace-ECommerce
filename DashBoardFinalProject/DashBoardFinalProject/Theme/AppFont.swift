import SwiftUI

enum AppFontWeight {
    case regular
    case medium
    case semibold
    case bold

    var name: String {
        switch self {
        case .regular: return "Montserrat-Regular"
        case .medium: return "Montserrat-Medium"
        case .semibold: return "Montserrat-SemiBold"
        case .bold: return "Montserrat-Bold"
        }
    }
}

extension Font {
    static func app(_ size: CGFloat, weight: AppFontWeight = .regular) -> Font {
        .custom(weight.name, size: size)
    }
}
