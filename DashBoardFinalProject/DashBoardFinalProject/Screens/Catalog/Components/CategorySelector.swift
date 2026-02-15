import SwiftUI

struct CategorySelector: View {
    let categories: [Category]
    let selected: Set<String>
    let onToggle: (String) -> Void

    private let columns = [
        GridItem(.adaptive(minimum: 90), spacing: 8)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Categories")
                .font(.app(12, weight: .semibold))
                .foregroundStyle(DashboardTheme.text)

            if categories.isEmpty {
                Text("No categories available. Add one first.")
                    .font(.app(12, weight: .medium))
                    .foregroundStyle(DashboardTheme.textMuted)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 16)
                    .background(DashboardTheme.background)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(DashboardTheme.border, lineWidth: 1)
                    )
            } else {
                LazyVGrid(columns: columns, alignment: .leading, spacing: 8) {
                    ForEach(categories) { category in
                        CategoryBadge(title: category.title, isSelected: selected.contains(category.id))
                            .onTapGesture {
                                onToggle(category.id)
                            }
                    }
                }
                .padding(12)
                .background(DashboardTheme.background)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(DashboardTheme.border, lineWidth: 1)
                )
            }
        }
    }
}
