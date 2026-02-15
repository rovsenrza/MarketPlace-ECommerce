import SwiftUI
import Combine

struct ReviewSection: View {
    @ObservedObject var viewModel: CatalogViewModel

    var body: some View {
        SectionBox(title: "Product Reviews", subtitle: "(optional)", icon: "bubble.left") {
            HStack(spacing: 8) {
                TextField("User name", text: $viewModel.reviewUser)
                    .textFieldStyle(.plain)
                    .padding(10)
                    .background(DashboardTheme.card)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(DashboardTheme.border, lineWidth: 1)
                    )

                TextField("Stars (1-5)", text: $viewModel.reviewStars)
                    .textFieldStyle(.plain)
                    .padding(10)
                    .background(DashboardTheme.card)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(DashboardTheme.border, lineWidth: 1)
                    )
                    .frame(width: 90)
            }

            HStack(spacing: 8) {
                TextField("Review message...", text: $viewModel.reviewMessage, axis: .vertical)
                    .lineLimit(2, reservesSpace: true)
                    .textFieldStyle(.plain)
                    .padding(10)
                    .background(DashboardTheme.card)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(DashboardTheme.border, lineWidth: 1)
                    )

                SmallButton(icon: "plus", color: DashboardTheme.warning) {
                    viewModel.addReview()
                }
                .frame(width: 40)
            }

            if viewModel.reviews.isEmpty {
                Text("No reviews yet.")
                    .font(.app(12, weight: .medium))
                    .foregroundStyle(DashboardTheme.textMuted)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 12)
            } else {
                VStack(spacing: 8) {
                    ForEach(viewModel.reviews) { review in
                        ReviewRow(review: review) {
                            viewModel.removeReview(id: review.id)
                        }
                    }
                }
            }
        }
    }
}
