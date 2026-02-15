import SwiftUI

struct ProductListView: View {
    let products: [Product]
    let categories: [Category]

    var body: some View {
        List {
            if products.isEmpty {
                Text("No products yet.")
                    .foregroundStyle(DashboardTheme.textMuted)
            } else {
                ForEach(products) { product in
                    VStack(alignment: .leading, spacing: 6) {
                        Text(product.title)
                            .font(.app(14, weight: .semibold))
                        HStack {
                            Text(String(format: "$%.2f", product.basePrice))
                                .font(.app(12, weight: .semibold))
                            Spacer()
                            Text("Qty \(product.quantity)")
                                .font(.app(12, weight: .medium))
                                .foregroundStyle(DashboardTheme.textMuted)
                        }
                        Text(categoryNames(for: product.categoryIds))
                            .font(.app(11, weight: .medium))
                            .foregroundStyle(DashboardTheme.textMuted)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle("Products")
    }

    private func categoryNames(for ids: [String]) -> String {
        let lookup = Dictionary(uniqueKeysWithValues: categories.map { ($0.id, $0.title) })
        let names = ids.compactMap { lookup[$0] }
        return names.isEmpty ? "No categories" : names.joined(separator: ", ")
    }
}
