import SwiftUI

struct DashboardHeader: View {
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(DashboardTheme.headerGradient)
                    .frame(width: 56, height: 56)
                    .shadow(color: DashboardTheme.shadow(), radius: 8, x: 0, y: 4)

                Image(systemName: "tray.full.fill")
                    .font(.app(24, weight: .semibold))
                    .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Firebase Admin")
                    .font(.app(24, weight: .bold))
                    .foregroundStyle(DashboardTheme.text)

                Text("Manage your products and categories")
                    .font(.app(13, weight: .medium))
                    .foregroundStyle(DashboardTheme.textMuted)
            }

            Spacer()
        }
    }
}
