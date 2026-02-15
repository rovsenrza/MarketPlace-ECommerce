import UIKit

struct HelpCenterDetailBuilder {
    static func build(
        title: String,
        subtitle: String,
        body: String,
        onChatRequested: (() -> Void)? = nil
    ) -> HelpCenterDetailVC {
        let vm = HelpCenterDetailVM(title: title, subtitle: subtitle, body: body)
        return HelpCenterDetailVC(vm: vm, onChatRequested: onChatRequested)
    }
}
