import UIKit

final class PrimaryButton: UIButton {
    private let style: Style
    
    enum Style {
        case filled
        case outlined
        case text
    }
    
    init(title: String, style: Style = .filled) {
        self.style = style
        super.init(frame: .zero)
        setupButton(title: title)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupButton(title: String) {
        setTitle(title, for: .normal)
        titleLabel?.font = .preferredFont(forTextStyle: .headline)
        titleLabel?.adjustsFontForContentSizeCategory = true
        layer.cornerRadius = 12
        
        switch style {
        case .filled:
            backgroundColor = UIColor(named: "PrimaryColorSet") ?? .systemBlue
            setTitleColor(.white, for: .normal)
            
        case .outlined:
            backgroundColor = .clear
            layer.borderWidth = 2
            layer.borderColor = (UIColor(named: "PrimaryColorSet") ?? .systemBlue).cgColor
            setTitleColor(UIColor(named: "PrimaryColorSet") ?? .systemBlue, for: .normal)
            
        case .text:
            backgroundColor = .clear
            setTitleColor(UIColor(named: "PrimaryColorSet") ?? .systemBlue, for: .normal)
        }
    }
    
    func setLoading(_ isLoading: Bool) {
        isEnabled = !isLoading
        if isLoading {
            let activityIndicator = UIActivityIndicatorView(style: .medium)
            activityIndicator.color = .white
            activityIndicator.startAnimating()
            activityIndicator.tag = 999
            addSubview(activityIndicator)
            activityIndicator.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
                activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor)
            ])
            titleLabel?.alpha = 0
        } else {
            viewWithTag(999)?.removeFromSuperview()
            titleLabel?.alpha = 1
        }
    }
}
