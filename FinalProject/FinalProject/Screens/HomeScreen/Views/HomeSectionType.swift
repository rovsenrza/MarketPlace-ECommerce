import Foundation

enum HomeSectionType: Int, CaseIterable {
    case featured = 0
    case categories = 1
    case products = 2

    var title: String {
        switch self {
        case .featured:
            return ""
        case .categories:
            return "Categories"
        case .products:
            return "New Arrivals"
        }
    }

    var showSeeAll: Bool {
        switch self {
        case .featured, .products:
            return false
        case .categories:
            return true
        }
    }
}
