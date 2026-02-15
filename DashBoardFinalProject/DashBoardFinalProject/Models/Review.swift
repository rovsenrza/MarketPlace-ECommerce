import Foundation

struct Review: Identifiable, Hashable {
    let id: String
    var userName: String
    var stars: Int
    var message: String?
}
