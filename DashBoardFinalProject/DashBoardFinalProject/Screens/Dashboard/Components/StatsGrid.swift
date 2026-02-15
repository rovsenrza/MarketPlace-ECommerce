import SwiftUI

struct StatsGrid: View {
    let categories: [Category]
    let products: [Product]
    let orders: [Order]

    private let columns = [
        GridItem(.adaptive(minimum: 200), spacing: 16)
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            NavigationLink {
                CategoryListView(categories: categories)
            } label: {
                StatCard(title: "Categories", value: "\(categories.count)", icon: "folder", gradient: [DashboardTheme.primary, DashboardTheme.primaryAlt])
            }
            .buttonStyle(.plain)

            NavigationLink {
                ProductListView(products: products, categories: categories)
            } label: {
                StatCard(title: "Products", value: "\(products.count)", icon: "shippingbox.fill", gradient: [DashboardTheme.success, DashboardTheme.successAlt])
            }
            .buttonStyle(.plain)

            StatCard(title: "Revenue", value: "$0", icon: "chart.line.uptrend.xyaxis", gradient: [DashboardTheme.warning, DashboardTheme.warningAlt])

            NavigationLink {
                OrdersListView(orders: orders)
            } label: {
                StatCard(title: "Orders", value: "\(orders.count)", icon: "cart.fill", gradient: [DashboardTheme.accent, DashboardTheme.accentAlt])
            }
            .buttonStyle(.plain)
        }
    }
}
