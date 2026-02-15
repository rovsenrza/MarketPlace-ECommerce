import SwiftUI

struct SmallButton: View {
    let icon: String
    var color: Color = DashboardTheme.primary
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.app(12, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 32, height: 32)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(color)
                )
        }
        .buttonStyle(.plain)
    }
}
