import SwiftUI

struct ReviewRow: View {
    let review: Review
    let onRemove: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(review.userName)
                    .font(.app(13, weight: .semibold))
                    .foregroundStyle(DashboardTheme.text)

                StarRating(stars: review.stars)

                Spacer()

                Button(action: onRemove) {
                    Image(systemName: "xmark")
                        .font(.app(12, weight: .bold))
                        .foregroundStyle(DashboardTheme.textMuted)
                        .padding(6)
                }
                .buttonStyle(.plain)
            }

            if let message = review.message, !message.isEmpty {
                Text(message)
                    .font(.app(12, weight: .medium))
                    .foregroundStyle(DashboardTheme.textMuted)
            }
        }
        .padding(10)
        .background(DashboardTheme.card)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(DashboardTheme.border, lineWidth: 1)
        )
    }
}
