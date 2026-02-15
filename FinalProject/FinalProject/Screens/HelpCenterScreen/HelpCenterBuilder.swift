import UIKit

struct HelpCenterBuilder {
    static func build(onRoute: ((HelpCenterRoute) -> Void)? = nil) -> HelpCenterVC {
        let vm = HelpCenterVM()
        return HelpCenterVC(vm: vm, onRoute: onRoute)
    }
}
