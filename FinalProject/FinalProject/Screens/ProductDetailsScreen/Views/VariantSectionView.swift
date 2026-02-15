import SnapKit
import UIKit

final class VariantSectionView: UIView {
    private let variantKey: String
    private let options: [String]
    private var onSelectionChanged: ((String) -> Void)?
    
    private let headerLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 12, weight: .bold)
        lbl.textColor = .secondaryLabel
        return lbl
    }()
    
    private let optionsScrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsHorizontalScrollIndicator = false
        return sv
    }()
    
    private let optionsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 12
        stack.distribution = .equalSpacing
        return stack
    }()
    
    init(variantKey: String, options: [String], selectedValue: String?, onSelectionChanged: @escaping (String) -> Void) {
        self.variantKey = variantKey
        self.options = options
        self.onSelectionChanged = onSelectionChanged
        super.init(frame: .zero)
        
        setupUI()
        setupOptions(selectedValue: selectedValue)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        headerLabel.text = "SELECT \(variantKey.uppercased())"
        addSubviews()
        setupConstraints()
    }

    func addSubviews() {
        [headerLabel, optionsScrollView].forEach { addSubview($0) }
        optionsScrollView.addSubview(optionsStack)
    }

    func setupConstraints() {
        headerLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }

        optionsScrollView.snp.makeConstraints { make in
            make.top.equalTo(headerLabel.snp.bottom).offset(16)
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(48)
        }

        optionsStack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalToSuperview()
        }
    }
    
    private func setupOptions(selectedValue: String?) {
        optionsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        let isColorVariant = variantKey.lowercased() == "color"
        
        for (index, option) in options.enumerated() {
            if isColorVariant {
                let button = createColorButton(value: option, isSelected: option == selectedValue)
                button.tag = index
                optionsStack.addArrangedSubview(button)
            } else {
                let button = createTextButton(value: option, isSelected: option == selectedValue)
                button.tag = index
                optionsStack.addArrangedSubview(button)
            }
        }
    }
    
    private func createColorButton(value: String, isSelected: Bool) -> UIButton {
        let button = UIButton(type: .custom)
        button.backgroundColor = UIColor(named: "Background")
        button.layer.cornerRadius = 24
        button.addTarget(self, action: #selector(optionTapped(_:)), for: .touchUpInside)
        
        let innerView = UIView()
        innerView.backgroundColor = UIColor(hex: value) ?? .gray
        innerView.layer.cornerRadius = 16
        innerView.isUserInteractionEnabled = false
        
        button.addSubview(innerView)
        innerView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(32)
        }
        
        button.snp.makeConstraints { make in
            make.size.equalTo(48)
        }
        
        if isSelected {
            button.layer.borderWidth = 2
            button.layer.borderColor = UIColor(named: "PrimaryColorSet")?.cgColor
        } else {
            button.layer.borderWidth = 0
        }
        
        return button
    }
    
    private func createTextButton(value: String, isSelected: Bool) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(value, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .bold)
        button.layer.cornerRadius = 16
        button.layer.borderWidth = 2
        button.addTarget(self, action: #selector(optionTapped(_:)), for: .touchUpInside)
        
        if isSelected {
            button.backgroundColor = UIColor(named: "PrimaryColorSet")
            button.setTitleColor(.white, for: .normal)
            button.layer.borderColor = UIColor(named: "PrimaryColorSet")?.cgColor
        } else {
            button.backgroundColor = .systemBackground
            button.setTitleColor(.secondaryLabel, for: .normal)
            button.layer.borderColor = UIColor.separator.cgColor
        }
        
        button.snp.makeConstraints { make in
            make.width.greaterThanOrEqualTo(80)
            make.height.equalTo(48)
        }
        
        return button
    }
    
    @objc private func optionTapped(_ sender: UIButton) {
        let selectedOption = options[sender.tag]
        onSelectionChanged?(selectedOption)
        updateSelection(selectedValue: selectedOption)
    }
    
    func updateSelection(selectedValue: String?) {
        for (index, view) in optionsStack.arrangedSubviews.enumerated() {
            guard let button = view as? UIButton else { continue }

            let isSelected = options[index] == selectedValue
            
            if variantKey.lowercased() == "color" {
                if isSelected {
                    button.layer.borderWidth = 2
                    button.layer.borderColor = UIColor(named: "PrimaryColorSet")?.cgColor
                } else {
                    button.layer.borderWidth = 0
                }
            } else {
                if isSelected {
                    button.backgroundColor = UIColor(named: "PrimaryColorSet")
                    button.setTitleColor(.white, for: .normal)
                    button.layer.borderColor = UIColor(named: "PrimaryColorSet")?.cgColor
                } else {
                    button.backgroundColor = .systemBackground
                    button.setTitleColor(.secondaryLabel, for: .normal)
                    button.layer.borderColor = UIColor.separator.cgColor
                }
            }
        }
    }
}
