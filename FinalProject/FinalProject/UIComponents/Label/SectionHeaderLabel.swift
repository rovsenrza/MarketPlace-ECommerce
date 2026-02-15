import UIKit

final class SectionHeaderLabel: UILabel {
    init(text: String) {
        super.init(frame: .zero)
        setupLabel(text: text)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLabel(text: String) {
        self.text = text
        font = .preferredFont(forTextStyle: .caption1)
        adjustsFontForContentSizeCategory = true
        textColor = .secondaryLabel
    }
}
