import SwiftUI

struct CardHeader: View {
    let title: String
    let subtitle: String
    let icon: String
    let gradient: LinearGradient

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(gradient)
                    .frame(width: 40, height: 40)

                Image(systemName: icon)
                    .font(.app(18, weight: .semibold))
                    .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.app(16, weight: .semibold))
                    .foregroundStyle(DashboardTheme.text)

                Text(subtitle)
                    .font(.app(12, weight: .medium))
                    .foregroundStyle(DashboardTheme.textMuted)
            }

            Spacer()
        }
    }
}
