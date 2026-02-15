import UIKit

final class SectionLoadingView: UIView {
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = UIColor(named: "PrimaryColorSet") ?? .systemBlue
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.text = "Loading..."
        label.font = AppTypography.label()
        label.textColor = UIColor(named: "TextMuted") ?? .secondaryLabel
        label.textAlignment = .center
        label.adjustsFontForContentSizeCategory = true
        return label
    }()
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 8
        return stack
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        backgroundColor = .clear
        addSubviews()
        setupConstraints()
    }

    func addSubviews() {
        addSubview(stackView)
        [activityIndicator, messageLabel].forEach { stackView.addArrangedSubview($0) }
    }

    func setupConstraints() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    func setLoading(_ isLoading: Bool) {
        if isLoading {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
        isHidden = !isLoading
    }
}
