import Foundation

enum HelpCenterSectionType: Int, CaseIterable {
    case categories = 0
    case orderStatus = 1
    case trending = 2

    var title: String {
        switch self {
        case .categories:
            return "Categories"
        case .orderStatus:
            return ""
        case .trending:
            return "Trending Questions"
        }
    }

    var showsHeader: Bool {
        switch self {
        case .orderStatus:
            return false
        case .categories, .trending:
            return true
        }
    }
}
