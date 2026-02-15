import SwiftUI
import Combine
struct ProductCard: View {
    @ObservedObject var viewModel: CatalogViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            CardHeader(title: "Add Product", subtitle: "Create a new product with variants and reviews", icon: "shippingbox.fill", gradient: LinearGradient(colors: [DashboardTheme.success, DashboardTheme.successAlt], startPoint: .topLeading, endPoint: .bottomTrailing))

            VStack(alignment: .leading, spacing: 12) {
                InputField(title: "Product Title", text: $viewModel.productTitle, placeholder: "Enter product name")
                TextAreaField(title: "Description", text: $viewModel.productDescription, placeholder: "Describe your product...")

                CategorySelector(categories: viewModel.categories, selected: viewModel.selectedCategoryIds) { id in
                    viewModel.toggleCategory(id: id)
                }

                PriceGrid(
                    basePrice: $viewModel.productBasePrice,
                    discountPrice: $viewModel.productDiscountPrice
                )

                InputField(title: "Base Quantity", text: $viewModel.productQuantity, placeholder: "e.g., 25", icon: "line.3.horizontal")
            }

            VariantSection(viewModel: viewModel)

            ReviewSection(viewModel: viewModel)

            SuccessButton(title: "Save Product", icon: "tray.and.arrow.down.fill") {
                Task { await viewModel.addProduct() }
            }
        }
        .dashboardCard()
    }
}
