import Foundation

protocol CatalogRepository {
    func fetchCategories() async throws -> [Category]
    func fetchProducts() async throws -> [Product]
    func addCategory(_ category: Category) async throws
    func addProduct(_ product: Product) async throws
}
