import SnapKit
import UIKit

final class SectionHeaderView: UICollectionReusableView {
    static let reuseIdentifier = "SectionHeaderView"
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = UIColor(named: "TextPrimary")
        return label
    }()
    
    private let seeAllButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("See All", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        btn.setTitleColor(UIColor(named: "PrimaryColorSet"), for: .normal)
        return btn
    }()
    
    private let filterButton: UIButton = {
        let btn = UIButton(type: .system)
        let image = UIImage(systemName: "line.3.horizontal.decrease.circle")
        btn.setImage(image, for: .normal)
        btn.tintColor = UIColor(named: "TextPrimary")
        return btn
    }()
    
    private let trailingStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 12
        return stack
    }()
    
    var onSeeAllTapped: (() -> Void)?
    var onFilterTapped: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        onSeeAllTapped = nil
        onFilterTapped = nil
    }
    
    func setupUI() {
        addSubviews()
        setupConstraints()
        seeAllButton.addTarget(self, action: #selector(seeAllTapped), for: .touchUpInside)
        filterButton.addTarget(self, action: #selector(filterTapped), for: .touchUpInside)
    }

    func addSubviews() {
        addSubview(titleLabel)
        addSubview(trailingStack)
        [seeAllButton, filterButton].forEach { trailingStack.addArrangedSubview($0) }
    }

    func setupConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
        }

        trailingStack.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
        }
    }
    
    func configure(title: String, showSeeAll: Bool, showFilter: Bool = false) {
        titleLabel.text = title
        seeAllButton.isHidden = !showSeeAll
        filterButton.isHidden = !showFilter
    }
    
    @objc private func seeAllTapped() {
        onSeeAllTapped?()
    }
    
    @objc private func filterTapped() {
        onFilterTapped?()
    }
}
