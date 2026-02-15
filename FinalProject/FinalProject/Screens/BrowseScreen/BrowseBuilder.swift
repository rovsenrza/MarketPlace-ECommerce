import Foundation

struct BrowseBuilder {
    static func build(
        services: AppServices = ServiceContainer.shared,
        onRoute: ((BrowseRoute) -> Void)? = nil
    ) -> BrowseVC {
        let vm = BrowseVM(catalogService: services.catalogService)
        return BrowseVC(vm: vm, onRoute: onRoute)
    }
}
