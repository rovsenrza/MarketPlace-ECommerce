import Foundation

struct ToastMessage: Identifiable {
    enum Style {
        case success
        case error
    }

    let id = UUID()
    let text: String
    let style: Style

    static func success(_ text: String) -> ToastMessage {
        ToastMessage(text: text, style: .success)
    }

    static func error(_ text: String) -> ToastMessage {
        ToastMessage(text: text, style: .error)
    }
}
