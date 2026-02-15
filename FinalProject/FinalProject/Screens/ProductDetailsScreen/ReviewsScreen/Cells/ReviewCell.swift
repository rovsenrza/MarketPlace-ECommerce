import SnapKit
import UIKit

final class ReviewCell: UITableViewCell {
    static let reuseIdentifier = "ReviewCell"
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "Background")
        view.layer.cornerRadius = 16
        return view
    }()
    
    private let nameLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 16, weight: .bold)
        lbl.textColor = .label
        return lbl
    }()
    
    private let starsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 4
        stack.distribution = .fillEqually
        return stack
    }()
    
    private let messageLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 15, weight: .regular)
        lbl.textColor = .secondaryLabel
        lbl.numberOfLines = 0
        return lbl
    }()
    
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
        addSubviews()
        setupConstraints()
        setupStars()
    }

    func addSubviews() {
        contentView.addSubview(containerView)
        [nameLabel, starsStack, messageLabel].forEach { containerView.addSubview($0) }
    }

    func setupConstraints() {
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 6, left: 16, bottom: 6, right: 16))
        }

        nameLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(16)
        }

        starsStack.snp.makeConstraints { make in
            make.leading.equalTo(nameLabel.snp.trailing).offset(12)
            make.centerY.equalTo(nameLabel)
            make.height.equalTo(16)
            make.width.equalTo(90)
        }

        messageLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-16)
        }
    }

    private func setupStars() {
        for _ in 0 ..< 5 {
            let starImageView = UIImageView()
            let config = UIImage.SymbolConfiguration(pointSize: 14, weight: .medium)
            starImageView.image = UIImage(systemName: "star.fill", withConfiguration: config)
            starImageView.tintColor = UIColor(named: "Rating")
            starImageView.contentMode = .scaleAspectFit
            starsStack.addArrangedSubview(starImageView)
        }
    }
    
    func configure(with review: Review) {
        nameLabel.text = review.userName
        messageLabel.text = review.message
        
        for (index, view) in starsStack.arrangedSubviews.enumerated() {
            if let starImageView = view as? UIImageView {
                starImageView.tintColor = index < review.stars ? UIColor(named: "Rating") : UIColor.separator
            }
        }
    }
}
