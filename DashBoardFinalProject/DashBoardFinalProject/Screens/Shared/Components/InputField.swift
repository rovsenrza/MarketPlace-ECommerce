import SwiftUI

struct InputField: View {
    let title: String
    @Binding var text: String
    var placeholder: String
    var disabled: Bool = false
    var subtitle: String? = nil
    var icon: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                if let icon {
                    Image(systemName: icon)
                        .foregroundStyle(DashboardTheme.textMuted)
                }
                Text(title)
                    .font(.app(12, weight: .semibold))
                    .foregroundStyle(DashboardTheme.text)
                if let subtitle {
                    Text(subtitle)
                        .font(.app(11, weight: .medium))
                        .foregroundStyle(DashboardTheme.textMuted)
                }
            }

            TextField(placeholder, text: $text)
                .textFieldStyle(.plain)
                .padding(12)
                .background(disabled ? DashboardTheme.background : DashboardTheme.card)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(DashboardTheme.border, lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .disabled(disabled)
        }
    }
}
