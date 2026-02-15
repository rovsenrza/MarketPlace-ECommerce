import UIKit

final class LoadingView: UIView {
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private let messageLabel = UILabel()
    private let stackView = UIStackView()
    private let initialMessage: String
    
    init(message: String = "Loading...") {
        self.initialMessage = message
        super.init(frame: .zero)
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        backgroundColor = .systemBackground.withAlphaComponent(0.95)
        
        activityIndicator.color = UIColor(named: "PrimaryColorSet") ?? .systemBlue
        activityIndicator.startAnimating()
        
        messageLabel.text = initialMessage
        messageLabel.font = .systemFont(ofSize: 16, weight: .medium)
        messageLabel.textColor = .secondaryLabel
        messageLabel.textAlignment = .center
        
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .center
        [activityIndicator, messageLabel].forEach { stackView.addArrangedSubview($0) }
        
        addSubviews()
        setupConstraints()
    }

    func addSubviews() {
        addSubview(stackView)
    }

    func setupConstraints() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    func updateMessage(_ message: String) {
        messageLabel.text = message
    }
}
