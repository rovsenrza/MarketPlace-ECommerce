import SwiftUI

struct TextAreaField: View {
    let title: String
    @Binding var text: String
    var placeholder: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.app(12, weight: .semibold))
                .foregroundStyle(DashboardTheme.text)

            ZStack(alignment: .topLeading) {
                TextEditor(text: $text)
                    .frame(minHeight: 100)
                    .padding(8)
                    .background(DashboardTheme.card)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(DashboardTheme.border, lineWidth: 1)
                    )

                if text.isEmpty {
                    Text(placeholder)
                        .font(.app(13, weight: .regular))
                        .foregroundStyle(DashboardTheme.textMuted)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 14)
                }
            }
        }
    }
}
