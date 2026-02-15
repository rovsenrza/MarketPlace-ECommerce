import SwiftUI
import Combine
struct VariantSection: View {
    @ObservedObject var viewModel: CatalogViewModel

    var body: some View {
        SectionBox(title: "Product Variants", subtitle: "(optional)", icon: "square.grid.2x2") {
            HStack(spacing: 8) {
                TextField("Variant name (e.g., Color)", text: $viewModel.variantName)
                    .textFieldStyle(.plain)
                    .padding(10)
                    .background(DashboardTheme.card)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(DashboardTheme.border, lineWidth: 1)
                    )

                TextField("Values (comma separated)", text: $viewModel.variantValues)
                    .textFieldStyle(.plain)
                    .padding(10)
                    .background(DashboardTheme.card)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(DashboardTheme.border, lineWidth: 1)
                    )

                SmallButton(icon: "plus") {
                    viewModel.addVariant()
                }
            }

            if viewModel.variants.isEmpty {
                Text("No variants yet.")
                    .font(.app(12, weight: .medium))
                    .foregroundStyle(DashboardTheme.textMuted)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 12)
            } else {
                VStack(spacing: 8) {
                    ForEach(viewModel.variants) { variant in
                        PreviewRow(title: variant.name, subtitle: variant.values.joined(separator: ", ")) {
                            viewModel.removeVariant(id: variant.id)
                        }
                    }
                }
            }
        }
    }
}
