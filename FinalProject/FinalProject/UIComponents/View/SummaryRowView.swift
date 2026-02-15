import SnapKit
import UIKit

final class SummaryRowView: UIView {
    let titleLabel = UILabel()
    let valueLabel = UILabel()
    
    init(title: String, isBold: Bool = false) {
        super.init(frame: .zero)
        configureTitleLabel(title: title, isBold: isBold)
        configureValueLabel(isBold: isBold)
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureTitleLabel(title: String, isBold: Bool) {
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: isBold ? 18 : 14, weight: isBold ? .bold : .regular)
        titleLabel.textColor = isBold ? (UIColor(named: "TextPrimary") ?? .label) : (UIColor(named: "TextSecondary") ?? .secondaryLabel)
    }
    
    private func configureValueLabel(isBold: Bool) {
        valueLabel.font = .systemFont(ofSize: isBold ? 18 : 14, weight: isBold ? .bold : .medium)
        valueLabel.textColor = isBold ? (UIColor(named: "TextPrimary") ?? .label) : (UIColor(named: "TextPrimary") ?? .label)
        valueLabel.textAlignment = .right
    }

    func setupUI() {
        addSubviews()
        setupConstraints()
    }
    
    func addSubviews() {
        addSubview(titleLabel)
        addSubview(valueLabel)
    }
    
    func setupConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
        }
        
        valueLabel.snp.makeConstraints { make in
            make.trailing.top.bottom.equalToSuperview()
            make.leading.greaterThanOrEqualTo(titleLabel.snp.trailing).offset(8)
        }
    }
    
    func setValue(_ value: String) {
        valueLabel.text = value
    }
}
