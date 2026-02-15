import SnapKit
import UIKit

final class OrderSuccessVC: UIViewController {
    private let vm: OrderSuccessVM
    var onDismiss: (() -> Void)?

    private let headerView = UIView()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Order Confirmed"
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = UIColor(named: "TextPrimary") ?? .label
        label.textAlignment = .center
        return label
    }()

    private let closeButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        button.setImage(UIImage(systemName: "xmark", withConfiguration: config), for: .normal)
        button.tintColor = UIColor(named: "TextPrimary") ?? .label
        return button
    }()

    private let illustrationContainer = UIView()
    private let glowView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.2)
        view.layer.cornerRadius = 80
        return view
    }()

    private let checkCircle: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemOrange
        view.layer.cornerRadius = 64
        return view
    }()

    private let checkIcon: UIImageView = {
        let config = UIImage.SymbolConfiguration(pointSize: 64, weight: .bold)
        let image = UIImage(systemName: "checkmark", withConfiguration: config)
        let iv = UIImageView(image: image)
        iv.tintColor = .white
        return iv
    }()

    private let headlineLabel: UILabel = {
        let label = UILabel()
        label.text = "Order Placed Successfully!"
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textColor = UIColor(named: "TextPrimary") ?? .label
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = UIColor(named: "TextSecondary") ?? .secondaryLabel
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()

    private let bottomContainer = UIView()
    private let backHomeButton = PrimaryButton(title: "Back to Home", style: .outlined)

    init(vm: OrderSuccessVM) {
        self.vm = vm
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    func setupUI() {
        view.backgroundColor = UIColor(named: "Background") ?? .systemBackground

        subtitleLabel.text = "Your order #\(vm.orderNumber) has been confirmed and is being processed."

        addSubviews()
        setupConstraints()
        setupActions()
    }

    func addSubviews() {
        [headerView, illustrationContainer, headlineLabel, subtitleLabel, bottomContainer].forEach { view.addSubview($0) }
        headerView.addSubview(titleLabel)
        headerView.addSubview(closeButton)
        illustrationContainer.addSubview(glowView)
        illustrationContainer.addSubview(checkCircle)
        checkCircle.addSubview(checkIcon)
        bottomContainer.addSubview(backHomeButton)
    }

    func setupConstraints() {
        headerView.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(48)
        }

        titleLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        closeButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(32)
        }

        illustrationContainer.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom).offset(24)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(160)
        }

        glowView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(140)
        }

        checkCircle.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(120)
        }

        checkIcon.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        headlineLabel.snp.makeConstraints { make in
            make.top.equalTo(illustrationContainer.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(24)
        }

        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(headlineLabel.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(24)
        }

        bottomContainer.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
        }

        backHomeButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.leading.trailing.equalToSuperview().inset(24)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-12)
            make.height.equalTo(52)
        }
    }

    private func setupActions() {
        closeButton.addTarget(self, action: #selector(dismissToHome), for: .touchUpInside)
        backHomeButton.addTarget(self, action: #selector(dismissToHome), for: .touchUpInside)
    }

    @objc private func dismissToHome() {
        presentingViewController?.dismiss(animated: true) { [weak self] in
            self?.onDismiss?()
        }
    }
}
