import Foundation

nonisolated enum HelpCenterSectionItem: Hashable {
    case category(HelpCenterCategory)
    case orderStatus(HelpCenterCategory)
    case question(HelpCenterQuestion)
}

nonisolated struct HelpCenterCategory: Hashable {
    let id: UUID
    let title: String
    let subtitle: String
    let iconName: String
    let detailTitle: String
    let detailBody: String

    init(title: String, subtitle: String, iconName: String, detailTitle: String, detailBody: String) {
        self.id = UUID()
        self.title = title
        self.subtitle = subtitle
        self.iconName = iconName
        self.detailTitle = detailTitle
        self.detailBody = detailBody
    }
}

struct HelpCenterQuestion: Hashable {
    let id: UUID
    let title: String
    let detailTitle: String
    let detailBody: String

    init(title: String, detailTitle: String, detailBody: String) {
        self.id = UUID()
        self.title = title
        self.detailTitle = detailTitle
        self.detailBody = detailBody
    }
}
