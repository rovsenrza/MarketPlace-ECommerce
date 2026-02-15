import UIKit

final class SocialLoginButton: UIButton {
    enum Provider {
        case google
        case apple
        
        var icon: UIImage? {
            switch self {
            case .google:
                return UIImage(named: "google_logo")
            case .apple:
                return UIImage(systemName: "apple.logo")
            }
        }
        
        var title: String {
            switch self {
            case .google:
                return "Continue with Google"
            case .apple:
                return "Continue with Apple"
            }
        }
    }
    
    private let provider: Provider
    private let iconImageView = UIImageView()
    private let titleTextLabel = UILabel()
    private let stackView = UIStackView()
    
    init(provider: Provider) {
        self.provider = provider
        super.init(frame: .zero)
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        backgroundColor = .systemBackground
        layer.cornerRadius = 12
        layer.borderWidth = 1
        layer.borderColor = UIColor.separator.cgColor
        
        iconImageView.image = provider.icon
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = .label
        
        titleTextLabel.text = provider.title
        titleTextLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        titleTextLabel.textColor = .label

        stackView.axis = .horizontal
        stackView.spacing = 12
        stackView.alignment = .center
        stackView.isUserInteractionEnabled = false
        
        addSubviews()
        setupConstraints()
    }

    func addSubviews() {
        addSubview(stackView)
        [iconImageView, titleTextLabel].forEach { stackView.addArrangedSubview($0) }
    }

    func setupConstraints() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24),
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}
