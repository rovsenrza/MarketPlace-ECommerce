import SwiftUI

struct CategoryCard: View {
    @ObservedObject var viewModel: CatalogViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            CardHeader(title: "Add Category", subtitle: "Create a new product category", icon: "plus.square.fill", gradient: DashboardTheme.headerGradient)

            VStack(alignment: .leading, spacing: 12) {
                InputField(title: "Category Title", text: $viewModel.categoryTitle, placeholder: "e.g., Electronics, Clothing")
                InputField(title: "Slug", text: $viewModel.categorySlug, placeholder: "category-slug", disabled: true, subtitle: "(auto-generated)")
                InputField(title: "SF Symbol Icon", text: $viewModel.categoryIcon, placeholder: "e.g., iphone, car, tshirt", subtitle: "(optional)")
            }

            PrimaryButton(title: "Add Category", icon: "sparkles") {
                Task { await viewModel.addCategory() }
            }
        }
        .dashboardCard()
    }
}
