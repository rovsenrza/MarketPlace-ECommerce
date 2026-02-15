import SwiftUI

struct PreviewRow: View {
    let title: String
    let subtitle: String
    let onRemove: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.app(13, weight: .semibold))
                    .foregroundStyle(DashboardTheme.text)
                Text(subtitle)
                    .font(.app(12, weight: .medium))
                    .foregroundStyle(DashboardTheme.textMuted)
            }

            Spacer()

            Button(action: onRemove) {
                Image(systemName: "xmark")
                    .font(.app(12, weight: .bold))
                    .foregroundStyle(DashboardTheme.textMuted)
                    .padding(6)
            }
            .buttonStyle(.plain)
        }
        .padding(10)
        .background(DashboardTheme.card)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(DashboardTheme.border, lineWidth: 1)
        )
    }
}
