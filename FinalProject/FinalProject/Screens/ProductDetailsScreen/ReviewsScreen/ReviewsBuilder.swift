import Foundation

struct ReviewsBuilder {
    static func build(
        services: AppServices = ServiceContainer.shared,
        product: Product
    ) -> ReviewsVC {
        let vm = ReviewsVM(
            product: product,
            reviewService: services.reviewService,
            authService: services.authService
        )
        let vc = ReviewsVC(vm: vm)
        return vc
    }
}
