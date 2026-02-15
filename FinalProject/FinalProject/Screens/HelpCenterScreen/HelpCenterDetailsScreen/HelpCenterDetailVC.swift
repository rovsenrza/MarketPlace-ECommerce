import SnapKit
import UIKit

final class HelpCenterDetailVC: UIViewController {
    private let vm: HelpCenterDetailVM
    private let onChatRequested: (() -> Void)?
    private let whatsappNumber = "994507193149"

    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        return sv
    }()

    private let contentView = UIView()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textColor = UIColor(named: "TextPrimary") ?? .label
        label.numberOfLines = 0
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.textColor = UIColor(named: "PrimaryColorSet") ?? .systemBlue
        label.numberOfLines = 0
        return label
    }()

    private let bodyLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = UIColor(named: "TextSecondary") ?? .secondaryLabel
        label.numberOfLines = 0
        return label
    }()

    init(vm: HelpCenterDetailVM, onChatRequested: (() -> Void)? = nil) {
        self.vm = vm
        self.onChatRequested = onChatRequested
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
        title = "Help Center"
        navigationController?.navigationBar.prefersLargeTitles = false

        let supportButton = UIBarButtonItem(
            image: UIImage(systemName: "headset"),
            style: .plain,
            target: self,
            action: #selector(contactSupportTapped)
        )
        let chatButton = UIBarButtonItem(
            image: UIImage(systemName: "bubble.left.and.bubble.right.fill"),
            style: .plain,
            target: self,
            action: #selector(openChatTapped)
        )
        navigationItem.rightBarButtonItems = [supportButton, chatButton]

        addSubviews()
        setupConstraints()
        configureContent()
    }

    func addSubviews() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        [titleLabel, subtitleLabel, bodyLabel].forEach { contentView.addSubview($0) }
    }

    func setupConstraints() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }

        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        bodyLabel.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().offset(-24)
        }
    }

    private func configureContent() {
        titleLabel.text = vm.title
        subtitleLabel.text = vm.subtitle
        bodyLabel.text = vm.body
    }

    @objc private func contactSupportTapped() {
        let urlString = "https://wa.me/\(whatsappNumber)"
        guard let url = URL(string: urlString) else { return }

        UIApplication.shared.open(url)
    }

    @objc private func openChatTapped() {
        onChatRequested?()
    }
}
