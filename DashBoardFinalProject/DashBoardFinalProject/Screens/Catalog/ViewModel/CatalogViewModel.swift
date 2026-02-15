import Foundation
import SwiftUI
import Combine
@MainActor
final class CatalogViewModel: ObservableObject {
    @Published private(set) var categories: [Category] = []
    @Published private(set) var products: [Product] = []
    @Published private(set) var productsCount: Int = 0
    @Published var selectedCategoryIds: Set<String> = []

    @Published var categoryTitle: String = "" {
        didSet { generateSlug() }
    }
    @Published var categorySlug: String = ""
    @Published var categoryIcon: String = ""

    @Published var productTitle: String = ""
    @Published var productDescription: String = ""
    @Published var productBasePrice: String = ""
    @Published var productDiscountPrice: String = ""
    @Published var productQuantity: String = ""

    @Published var variantName: String = ""
    @Published var variantValues: String = ""
    @Published private(set) var variants: [Variant] = []

    @Published var reviewUser: String = ""
    @Published var reviewStars: String = ""
    @Published var reviewMessage: String = ""
    @Published private(set) var reviews: [Review] = []

    @Published var toast: ToastMessage?

    private let repository: CatalogRepository
    private var toastDismissTask: Task<Void, Never>?

    init(repository: CatalogRepository) {
        self.repository = repository
        Task { await loadData() }
    }

    deinit {
        toastDismissTask?.cancel()
    }

    var categoryCount: Int { categories.count }

    func loadData() async {
        do {
            categories = try await repository.fetchCategories()
            products = try await repository.fetchProducts()
            productsCount = products.count
        } catch {
            showToast(.error("Failed to load catalog data"))
        }
    }

    func addCategory() async {
        let trimmedTitle = categoryTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedSlug = categorySlug.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty, !trimmedSlug.isEmpty else {
            showToast(.error("Please fill in the title"))
            return
        }

        let newCategory = Category(
            id: UUID().uuidString,
            title: trimmedTitle,
            slug: trimmedSlug,
            icon: categoryIcon.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : categoryIcon
        )
        do {
            try await repository.addCategory(newCategory)
            await loadData()
            clearCategoryForm()
            showToast(.success("Category added successfully"))
        } catch {
            showToast(.error("Failed to add category"))
        }
    }

    func toggleCategory(id: String) {
        if selectedCategoryIds.contains(id) {
            selectedCategoryIds.remove(id)
        } else {
            selectedCategoryIds.insert(id)
        }
    }

    func addVariant() {
        let name = variantName.trimmingCharacters(in: .whitespacesAndNewlines)
        let values = variantValues
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        guard !name.isEmpty, !values.isEmpty else {
            showToast(.error("Please fill in variant name and values"))
            return
        }

        variants.append(Variant(id: UUID().uuidString, name: name, values: values))
        variantName = ""
        variantValues = ""
    }

    func removeVariant(id: String) {
        variants.removeAll { $0.id == id }
    }

    func addReview() {
        let user = reviewUser.trimmingCharacters(in: .whitespacesAndNewlines)
        let stars = Int(reviewStars) ?? 0
        let message = reviewMessage.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !user.isEmpty, stars > 0 else {
            showToast(.error("Please fill in user name and stars"))
            return
        }
        guard (1...5).contains(stars) else {
            showToast(.error("Stars must be between 1 and 5"))
            return
        }

        reviews.append(Review(id: UUID().uuidString, userName: user, stars: stars, message: message.isEmpty ? nil : message))
        reviewUser = ""
        reviewStars = ""
        reviewMessage = ""
    }

    func removeReview(id: String) {
        reviews.removeAll { $0.id == id }
    }

    func addProduct() async {
        let title = productTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        let description = productDescription.trimmingCharacters(in: .whitespacesAndNewlines)
        let basePrice = Double(productBasePrice) ?? -1
        let discountPrice = Double(productDiscountPrice)
        let quantity = Int(productQuantity) ?? -1

        guard !title.isEmpty, basePrice >= 0, quantity >= 0, !selectedCategoryIds.isEmpty else {
            showToast(.error("Please fill in title, price, quantity, and select at least one category"))
            return
        }

        let newProduct = Product(
            id: UUID().uuidString,
            title: title,
            description: description,
            categoryIds: Array(selectedCategoryIds),
            basePrice: basePrice,
            discountPrice: discountPrice,
            quantity: quantity,
            variants: variants,
            reviews: reviews
        )

        do {
            try await repository.addProduct(newProduct)
            await loadData()
            clearProductForm()
            showToast(.success("Product added successfully"))
        } catch {
            showToast(.error("Failed to add product"))
        }
    }

    private func generateSlug() {
        let slug = categoryTitle
            .lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "&", with: "and")
            .replacingOccurrences(of: "[^a-z0-9]+", with: "-", options: .regularExpression)
            .replacingOccurrences(of: "^-+|-+$", with: "", options: .regularExpression)
        categorySlug = slug
    }

    private func clearCategoryForm() {
        categoryTitle = ""
        categorySlug = ""
        categoryIcon = ""
    }

    private func clearProductForm() {
        productTitle = ""
        productDescription = ""
        productBasePrice = ""
        productDiscountPrice = ""
        productQuantity = ""
        selectedCategoryIds = []
        variants = []
        reviews = []
    }

    private func showToast(_ message: ToastMessage) {
        toastDismissTask?.cancel()
        toast = message
        toastDismissTask = Task { [weak self] in
            do {
                try await Task.sleep(nanoseconds: 2_500_000_000)
            } catch {
                return
            }

            guard let self, self.toast?.id == message.id else { return }
            self.toast = nil
        }
    }
}
