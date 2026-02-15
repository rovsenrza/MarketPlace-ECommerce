import SwiftUI

struct OrderRow: View {
    let order: Order
    let onStatusChange: (OrderStatus) -> Void
    @State private var selectedStatus: OrderStatus

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Order #\(order.orderNumber)")
                    .font(.app(14, weight: .semibold))
                    .foregroundStyle(DashboardTheme.text)

                Spacer()

                StatusPill(status: order.status)
            }

            Text(order.customerName)
                .font(.app(12, weight: .medium))
                .foregroundStyle(DashboardTheme.textMuted)

            HStack {
                Text(String(format: "$%.2f", order.total))
                    .font(.app(12, weight: .semibold))
                    .foregroundStyle(DashboardTheme.text)

                Spacer()

                Picker("Status", selection: $selectedStatus) {
                    ForEach(OrderStatus.allCases) { status in
                        Text(status.label).tag(status)
                    }
                }
                .pickerStyle(.menu)
                .font(.app(12, weight: .semibold))
                .foregroundStyle(DashboardTheme.primary)
                .onChange(of: selectedStatus) { newValue in
                    guard newValue != order.status else { return }
                    onStatusChange(newValue)
                }
            }
        }
        .padding(12)
        .background(DashboardTheme.card)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(DashboardTheme.border, lineWidth: 1)
        )
        .onAppear {
            selectedStatus = order.status
        }
        .onChange(of: order.status) { newValue in
            selectedStatus = newValue
        }
    }

    init(order: Order, onStatusChange: @escaping (OrderStatus) -> Void) {
        self.order = order
        self.onStatusChange = onStatusChange
        _selectedStatus = State(initialValue: order.status)
    }
}
