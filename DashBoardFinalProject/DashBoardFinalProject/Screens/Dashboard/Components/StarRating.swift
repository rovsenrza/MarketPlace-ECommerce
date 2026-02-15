import SwiftUI

struct StarRating: View {
    let stars: Int

    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<5, id: \.self) { index in
                Image(systemName: index < stars ? "star.fill" : "star")
                    .font(.app(10))
                    .foregroundStyle(DashboardTheme.warning)
            }
        }
    }
}
