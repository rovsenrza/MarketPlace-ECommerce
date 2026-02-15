import UIKit

struct FilterBuilder {
    static func build(
        categories: [Category],
        currentQuery: FilterQuery,
        hideCategoryFilter: Bool = false,
        onApply: @escaping (FilterQuery) -> Void
    ) -> UIViewController {
        let vm = FilterVM(categories: categories, currentQuery: currentQuery, hideCategoryFilter: hideCategoryFilter)
        let vc = FilterVC(vm: vm)
        vc.onApply = onApply
        return vc
    }
}
