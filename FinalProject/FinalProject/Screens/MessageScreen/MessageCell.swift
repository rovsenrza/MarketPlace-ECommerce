import SnapKit
import UIKit

final class MessageCell: UITableViewCell {
    static let reuseIdentifier = "MessageCell"

    private let bubbleView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 18
        view.layer.masksToBounds = true
        return view
    }()

    private let messageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.numberOfLines = 0
        return label
    }()

    private var leadingConstraint: Constraint?
    private var trailingConstraint: Constraint?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        addSubviews()
        setupConstraints()
    }

    func addSubviews() {
        contentView.addSubview(bubbleView)
        bubbleView.addSubview(messageLabel)
    }

    func setupConstraints() {
        bubbleView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(6)
            make.width.lessThanOrEqualToSuperview().multipliedBy(0.75)
            leadingConstraint = make.leading.equalToSuperview().offset(16).constraint
            trailingConstraint = make.trailing.equalToSuperview().offset(-16).constraint
        }

        messageLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(12)
        }
    }

    func configure(with message: ChatMessage, isIncoming: Bool) {
        messageLabel.text = message.text

        if isIncoming {
            bubbleView.backgroundColor = UIColor(named: "Surface") ?? UIColor.systemGray5
            messageLabel.textColor = UIColor(named: "TextPrimary") ?? .label
            leadingConstraint?.activate()
            trailingConstraint?.deactivate()
        } else {
            bubbleView.backgroundColor = UIColor(named: "PrimaryColorSet") ?? .systemBlue
            messageLabel.textColor = .white
            trailingConstraint?.activate()
            leadingConstraint?.deactivate()
        }
    }
}
