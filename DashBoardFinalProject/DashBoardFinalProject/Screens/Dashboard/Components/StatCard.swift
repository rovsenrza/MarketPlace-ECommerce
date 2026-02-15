import SwiftUI

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let gradient: [Color]

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(LinearGradient(colors: gradient, startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 48, height: 48)

                Image(systemName: icon)
                    .font(.app(20, weight: .semibold))
                    .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.app(20, weight: .bold))
                    .foregroundStyle(DashboardTheme.text)

                Text(title)
                    .font(.app(12, weight: .medium))
                    .foregroundStyle(DashboardTheme.textMuted)
            }

            Spacer()
        }
        .dashboardCard()
    }
}
