import SwiftUI

struct SectionBox<Content: View>: View {
    let title: String
    let subtitle: String
    let icon: String
    @ViewBuilder let content: Content

    init(title: String, subtitle: String, icon: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundStyle(DashboardTheme.accent)
                Text(title)
                    .font(.app(13, weight: .semibold))
                    .foregroundStyle(DashboardTheme.text)
                Text(subtitle)
                    .font(.app(11, weight: .medium))
                    .foregroundStyle(DashboardTheme.textMuted)
            }

            content
        }
        .padding(12)
        .background(DashboardTheme.surface)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(DashboardTheme.border, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
