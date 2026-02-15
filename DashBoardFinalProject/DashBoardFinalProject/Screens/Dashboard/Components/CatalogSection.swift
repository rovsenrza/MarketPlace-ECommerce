import SwiftUI

struct CatalogSection: View {
    @ObservedObject var viewModel: CatalogViewModel

    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .top, spacing: 16) {
                CategoryCard(viewModel: viewModel)
                ProductCard(viewModel: viewModel)
            }

            VStack(spacing: 16) {
                CategoryCard(viewModel: viewModel)
                ProductCard(viewModel: viewModel)
            }
        }
    }
}
