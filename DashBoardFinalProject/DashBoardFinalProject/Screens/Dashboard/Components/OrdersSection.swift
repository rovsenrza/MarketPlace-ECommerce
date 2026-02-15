import SwiftUI

struct OrdersSection: View {
    @ObservedObject var viewModel: OrdersViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            CardHeader(title: "Orders Status", subtitle: "Set each order to delivered or on delivery", icon: "shippingbox.fill", gradient: LinearGradient(colors: [DashboardTheme.warning, DashboardTheme.warningAlt], startPoint: .topLeading, endPoint: .bottomTrailing))

            if viewModel.orders.isEmpty {
                Text("No orders yet.")
                    .font(.app(13, weight: .medium))
                    .foregroundStyle(DashboardTheme.textMuted)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 24)
            } else {
                VStack(spacing: 12) {
                    ForEach(viewModel.orders) { order in
                        OrderRow(order: order) { status in
                            viewModel.updateStatus(orderId: order.id, status: status)
                        }
                    }
                }
            }
        }
        .dashboardCard()
    }
}
