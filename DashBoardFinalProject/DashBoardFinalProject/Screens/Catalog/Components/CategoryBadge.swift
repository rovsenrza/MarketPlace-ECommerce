import SwiftUI

struct CategoryBadge: View {
    let title: String
    let isSelected: Bool

    var body: some View {
        Text(title)
            .font(.app(12, weight: .semibold))
            .foregroundStyle(isSelected ? .white : DashboardTheme.text)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(
                        isSelected
                        ? AnyShapeStyle(DashboardTheme.headerGradient)
                        : AnyShapeStyle(DashboardTheme.card)
                    )
            )
            .overlay(
                Capsule()
                    .stroke(isSelected ? Color.clear : DashboardTheme.border, lineWidth: 1)
            )
    }
}
