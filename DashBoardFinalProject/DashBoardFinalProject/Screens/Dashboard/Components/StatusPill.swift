import SwiftUI

struct StatusPill: View {
    let status: OrderStatus

    var body: some View {
        Text(status.label)
            .font(.app(10, weight: .semibold))
            .foregroundStyle(status == .delivered ? DashboardTheme.statusDeliveredText : DashboardTheme.statusInTransitText)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(
                Capsule().fill(status == .delivered ? DashboardTheme.statusDeliveredBackground : DashboardTheme.statusInTransitBackground)
            )
    }
}
