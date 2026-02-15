import UIKit

final class EmptyStateView: UIView {
    private let iconImageView = UIImageView()
    private let titleLabel = UILabel()
    private let messageLabel = UILabel()
    private let actionButton = PrimaryButton(title: "", style: .filled)
    private let stackView = UIStackView()
    private let iconImage: UIImage?
    private let titleText: String
    private let messageText: String
    private let buttonTitle: String?
    private let buttonAction: (() -> Void)?
    
    init(
        icon: UIImage?,
        title: String,
        message: String,
        buttonTitle: String? = nil,
        buttonAction: (() -> Void)? = nil
    ) {
        self.iconImage = icon
        self.titleText = title
        self.messageText = message
        self.buttonTitle = buttonTitle
        self.buttonAction = buttonAction
        super.init(frame: .zero)
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        iconImageView.image = iconImage
        iconImageView.tintColor = UIColor(named: "PrimaryColorSet") ?? .systemBlue
        iconImageView.contentMode = .scaleAspectFit
        
        titleLabel.text = titleText
        titleLabel.font = .systemFont(ofSize: 24, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.textColor = .label
        
        messageLabel.text = messageText
        messageLabel.font = .systemFont(ofSize: 16, weight: .regular)
        messageLabel.textAlignment = .center
        messageLabel.textColor = .secondaryLabel
        messageLabel.numberOfLines = 0
        
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .center
        [iconImageView, titleLabel, messageLabel].forEach { stackView.addArrangedSubview($0) }
        
        addSubviews()
        setupConstraints()
        
        if let buttonTitle = buttonTitle, let buttonAction = buttonAction {
            actionButton.setTitle(buttonTitle, for: .normal)
            actionButton.addAction(UIAction { _ in buttonAction() }, for: .touchUpInside)
            
            stackView.addArrangedSubview(actionButton)
            actionButton.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                actionButton.heightAnchor.constraint(equalToConstant: 54),
                actionButton.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
                actionButton.trailingAnchor.constraint(equalTo: stackView.trailingAnchor)
            ])
        }
    }
    
    func addSubviews() {
        addSubview(stackView)
    }
    
    func setupConstraints() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            iconImageView.widthAnchor.constraint(equalToConstant: 96),
            iconImageView.heightAnchor.constraint(equalToConstant: 96),
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 32),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32)
        ])
    }
}
