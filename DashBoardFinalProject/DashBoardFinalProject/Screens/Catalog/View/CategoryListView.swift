import SwiftUI

struct CategoryListView: View {
    let categories: [Category]

    var body: some View {
        List {
            if categories.isEmpty {
                Text("No categories available.")
                    .foregroundStyle(DashboardTheme.textMuted)
            } else {
                ForEach(categories) { category in
                    HStack(spacing: 12) {
                        Image(systemName: category.icon ?? "tag")
                            .foregroundStyle(DashboardTheme.primary)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(category.title)
                                .font(.app(14, weight: .semibold))
                            Text(category.slug)
                                .font(.app(12, weight: .medium))
                                .foregroundStyle(DashboardTheme.textMuted)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle("Categories")
    }
}
