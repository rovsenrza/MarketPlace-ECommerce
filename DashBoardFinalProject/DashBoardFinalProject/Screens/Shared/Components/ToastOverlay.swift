import SwiftUI

struct ToastOverlay: View {
    var message: ToastMessage?

    var body: some View {
        Group {
            if let message {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Text(message.text)
                            .font(.app(12, weight: .semibold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(message.style == .success ? DashboardTheme.success : Color.red)
                            )
                    }
                }
                .padding(20)
                .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.25), value: message?.id)
    }
}
