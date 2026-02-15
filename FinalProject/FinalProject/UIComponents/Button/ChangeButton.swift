import UIKit

final class ChangeButton: UIButton {
    init(title: String = "Change") {
        super.init(frame: .zero)
        setupButton(title: title)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupButton(title: String) {
        setTitle(title, for: .normal)
        titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        setTitleColor(UIColor(named: "PrimaryColorSet") ?? .systemBlue, for: .normal)
    }
}
