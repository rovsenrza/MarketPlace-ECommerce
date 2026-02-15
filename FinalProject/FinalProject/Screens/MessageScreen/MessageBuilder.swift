import UIKit

struct MessageBuilder {
    static func build(services: AppServices = ServiceContainer.shared) -> MessageVC {
        let vm = MessageVM(
            chatService: services.chatService,
            authService: services.authService
        )
        return MessageVC(vm: vm)
    }
}
