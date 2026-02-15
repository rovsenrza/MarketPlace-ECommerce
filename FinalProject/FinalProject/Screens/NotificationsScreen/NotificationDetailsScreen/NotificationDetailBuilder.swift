import Foundation

struct NotificationDetailBuilder {
    static func build(notification: AppNotification) -> NotificationDetailVC {
        let vm = NotificationDetailVM(notification: notification)
        return NotificationDetailVC(vm: vm)
    }
}
