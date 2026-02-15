import SnapKit
import UIKit

final class HelpCenterQuestionCell: UICollectionViewCell {
    static let reuseIdentifier = "HelpCenterQuestionCell"

    private let containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 14
        view.layer.borderWidth = 1
        view.layer.borderColor = (UIColor(named: "Border") ?? UIColor.systemGray5).cgColor
        view.backgroundColor = UIColor(named: "Surface") ?? .systemBackground
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = UIColor(named: "TextPrimary") ?? .label
        label.numberOfLines = 2
        return label
    }()

    private let chevronView: UIImageView = {
        let iv = UIImageView()
        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)
        iv.image = UIImage(systemName: "chevron.right", withConfiguration: config)
        iv.tintColor = UIColor(named: "TextMuted") ?? .tertiaryLabel
        return iv
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
        addSubviews()
        setupConstraints()
        let selectedView = UIView()
        selectedView.backgroundColor = (UIColor(named: "PrimaryColorSet") ?? .systemBlue).withAlphaComponent(0.08)
        selectedBackgroundView = selectedView
    }

    func addSubviews() {
        contentView.addSubview(containerView)
        [titleLabel, chevronView].forEach { containerView.addSubview($0) }
    }

    func setupConstraints() {
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        chevronView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
        }

        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalTo(chevronView.snp.leading).offset(-12)
            make.top.equalToSuperview().offset(16)
            make.bottom.equalToSuperview().offset(-16)
        }
    }

    func configure(with question: HelpCenterQuestion) {
        titleLabel.text = question.title
    }
}
