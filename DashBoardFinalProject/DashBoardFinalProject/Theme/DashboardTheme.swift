import SwiftUI

enum DashboardTheme {
    static let background = Color("DashboardBackground")
    static let card = Color("DashboardCard")
    static let surface = Color("DashboardSurface")
    static let text = Color("DashboardText")
    static let textMuted = Color("DashboardTextMuted")
    static let border = Color("DashboardBorder")

    static let primary = Color("DashboardPrimary")
    static let primaryAlt = Color("DashboardPrimaryAlt")
    static let success = Color("DashboardSuccess")
    static let successAlt = Color("DashboardSuccessAlt")
    static let warning = Color("DashboardWarning")
    static let warningAlt = Color("DashboardWarningAlt")
    static let accent = Color("DashboardAccent")
    static let accentAlt = Color("DashboardAccentAlt")

    static let statusDeliveredText = Color("DashboardStatusDeliveredText")
    static let statusDeliveredBackground = Color("DashboardStatusDeliveredBackground")
    static let statusInTransitText = Color("DashboardStatusInTransitText")
    static let statusInTransitBackground = Color("DashboardStatusInTransitBackground")

    static let headerGradient = LinearGradient(
        colors: [primary, accent],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static func shadow() -> Color {
        Color.black.opacity(0.12)
    }
}

struct CardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(16)
            .background(DashboardTheme.card)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(DashboardTheme.border, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: DashboardTheme.shadow(), radius: 6, x: 0, y: 3)
    }
}

extension View {
    func dashboardCard() -> some View {
        modifier(CardModifier())
    }
}
