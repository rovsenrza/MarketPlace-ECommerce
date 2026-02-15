import SwiftUI

struct PriceGrid: View {
    @Binding var basePrice: String
    @Binding var discountPrice: String

    var body: some View {
        HStack(spacing: 12) {
            InputField(title: "Base Price", text: $basePrice, placeholder: "0.00", icon: "dollarsign.circle")
            InputField(title: "Discount Price", text: $discountPrice, placeholder: "Optional", icon: "dollarsign.circle.fill")
        }
    }
}
