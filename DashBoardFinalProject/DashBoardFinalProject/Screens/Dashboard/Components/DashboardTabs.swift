import SwiftUI

struct DashboardTabs: View {
    @Binding var activeTab: DashboardTab

    var body: some View {
        HStack(spacing: 8) {
            ForEach(DashboardTab.allCases) { tab in
                let isActive = activeTab == tab
                Button {
                    activeTab = tab
                } label: {
                    Text(tab.title)
                        .font(.app(14, weight: .semibold))
                        .foregroundStyle(isActive ? .white : DashboardTheme.textMuted)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            Capsule()
                                .fill(
                                    isActive
                                    ? AnyShapeStyle(DashboardTheme.headerGradient)
                                    : AnyShapeStyle(Color.clear)
                                )
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(8)
        .background(DashboardTheme.card)
        .overlay(
            Capsule().stroke(DashboardTheme.border, lineWidth: 1)
        )
        .shadow(color: DashboardTheme.shadow(), radius: 6, x: 0, y: 3)
    }
}
