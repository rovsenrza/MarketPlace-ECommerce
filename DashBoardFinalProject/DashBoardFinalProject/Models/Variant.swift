import Foundation

struct Variant: Identifiable, Hashable {
    let id: String
    var name: String
    var values: [String]
}
