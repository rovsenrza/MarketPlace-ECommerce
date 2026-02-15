import SwiftUI

struct OrdersListView: View {
    let orders: [Order]

    var body: some View {
        List {
            if orders.isEmpty {
                Text("No orders yet.")
                    .foregroundStyle(DashboardTheme.textMuted)
            } else {
                ForEach(orders) { order in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text("Order #\(order.orderNumber)")
                                .font(.app(14, weight: .semibold))
                            Spacer()
                            StatusPill(status: order.status)
                        }
                        Text(order.customerName)
                            .font(.app(12, weight: .medium))
                            .foregroundStyle(DashboardTheme.textMuted)
                        Text(String(format: "$%.2f", order.total))
                            .font(.app(12, weight: .semibold))
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle("Orders")
    }
}
