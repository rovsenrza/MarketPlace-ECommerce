import SnapKit
import UIKit

final class AddNewPaymentVC: UIViewController {
    private let vm: AddNewPaymentVM
    private let onSaved: (() -> Void)?
    
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        return sv
    }()
    
    private let contentView = UIView()
    
    private let cardPreview: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        view.backgroundColor = .primaryColorSet
        return view
    }()
    
    private let cardGradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [
            UIColor(red: 0.07, green: 0.36, blue: 0.93, alpha: 1.0).cgColor,
            UIColor(red: 0.04, green: 0.18, blue: 0.48, alpha: 1.0).cgColor
        ]
        layer.startPoint = CGPoint(x: 0, y: 0)
        layer.endPoint = CGPoint(x: 1, y: 1)
        return layer
    }()
    
    private let cardOverlay: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        return view
    }()
    
    private let chipView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemYellow.withAlphaComponent(0.8)
        view.layer.cornerRadius = 6
        return view
    }()
    
    private let contactlessIcon: UIImageView = {
        let config = UIImage.SymbolConfiguration(pointSize: 32, weight: .regular)
        let image = UIImage(systemName: "wave.3.right", withConfiguration: config)
        let iv = UIImageView(image: image)
        iv.tintColor = UIColor.white.withAlphaComponent(0.9)
        return iv
    }()
    
    private let cardNumberTitle: UILabel = {
        let label = UILabel()
        label.text = "Card Number"
        label.font = .systemFont(ofSize: 10, weight: .bold)
        label.textColor = UIColor.white.withAlphaComponent(0.7)
        label.textAlignment = .left
        return label
    }()
    
    private let cardNumberLabel: UILabel = {
        let label = UILabel()
        label.text = "•••• •••• •••• 1234"
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .white
        label.textAlignment = .left
        return label
    }()
    
    private let cardholderTitle: UILabel = {
        let label = UILabel()
        label.text = "Cardholder Name"
        label.font = .systemFont(ofSize: 10, weight: .bold)
        label.textColor = UIColor.white.withAlphaComponent(0.7)
        label.textAlignment = .left
        return label
    }()
    
    private let cardholderName: UILabel = {
        let label = UILabel()
        label.text = "JOHN DOE"
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .white
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    private let expiryTitle: UILabel = {
        let label = UILabel()
        label.text = "Expires"
        label.font = .systemFont(ofSize: 10, weight: .bold)
        label.textColor = UIColor.white.withAlphaComponent(0.7)
        label.textAlignment = .right
        return label
    }()
    
    private let expiryValue: UILabel = {
        let label = UILabel()
        label.text = "09/27"
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .white
        label.textAlignment = .right
        return label
    }()
    
    private let formStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        return stack
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Cardholder Name"
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = UIColor(named: "TextPrimary") ?? .label
        return label
    }()
    
    private let nameField: InsetTextField = {
        let tf = InsetTextField(0, 16, 0, 16)
        tf.placeholder = "e.g. John Doe"
        tf.autocapitalizationType = .words
        return tf
    }()
    
    private let numberLabel: UILabel = {
        let label = UILabel()
        label.text = "Card Number"
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = UIColor(named: "TextPrimary") ?? .label
        return label
    }()
    
    private let numberField: InsetTextField = {
        let tf = InsetTextField(0, 16, 0, 44)
        tf.placeholder = "0000 0000 0000 0000"
        tf.keyboardType = .numberPad
        return tf
    }()
    
    private let cardIcon: UIImageView = {
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .regular)
        let image = UIImage(systemName: "creditcard", withConfiguration: config)
        let iv = UIImageView(image: image)
        iv.tintColor = UIColor(named: "TextMuted") ?? .secondaryLabel
        return iv
    }()
    
    private let expiryLabel: UILabel = {
        let label = UILabel()
        label.text = "Expiry Date"
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = UIColor(named: "TextPrimary") ?? .label
        return label
    }()
    
    private let expiryField: InsetTextField = {
        let tf = InsetTextField(0, 16, 0, 16)
        tf.placeholder = "MM/YY"
        tf.keyboardType = .numbersAndPunctuation
        return tf
    }()
    
    private let cvvLabel: UILabel = {
        let label = UILabel()
        label.text = "CVV"
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = UIColor(named: "TextPrimary") ?? .label
        return label
    }()
    
    private let cvvField: InsetTextField = {
        let tf = InsetTextField(0, 16, 0, 16)
        tf.placeholder = "123"
        tf.keyboardType = .numberPad
        tf.isSecureTextEntry = true
        return tf
    }()
    
    private let saveDefaultContainer: UIView = {
        let view = UIView()
        view.layer.borderWidth = 1
        view.layer.borderColor = (UIColor(named: "Divider") ?? UIColor.systemGray5).cgColor
        view.layer.cornerRadius = 12
        return view
    }()
    
    private let saveTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Save as default"
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = UIColor(named: "TextPrimary") ?? .label
        return label
    }()
    
    private let saveSubtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "This card will be used for future payments"
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = UIColor(named: "TextMuted") ?? .secondaryLabel
        label.numberOfLines = 2
        return label
    }()
    
    private let defaultSwitch = UISwitch()
    
    private let bottomContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "Background")?.withAlphaComponent(0.95) ?? .systemBackground
        return view
    }()
    
    private let addButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Add Card", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(red: 0.07, green: 0.36, blue: 0.93, alpha: 1.0)
        button.layer.cornerRadius = 12
        return button
    }()
    
    init(vm: AddNewPaymentVM, onSaved: (() -> Void)? = nil) {
        self.vm = vm
        self.onSaved = onSaved
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        cardGradientLayer.frame = cardPreview.bounds
        cardOverlay.frame = cardPreview.bounds
    }
    
    func setupUI() {
        view.backgroundColor = UIColor(named: "Background") ?? .systemBackground
        title = "Add New Payment"
        
        addSubviews()
        setupConstraints()
        setupKeyboardDismiss()
        setupActions()
        updateCardPreview()
    }

    func addSubviews() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        view.addSubview(bottomContainer)
        bottomContainer.addSubview(addButton)
        
        contentView.addSubview(cardPreview)
        cardPreview.layer.insertSublayer(cardGradientLayer, at: 0)
        cardPreview.addSubview(cardOverlay)
        cardPreview.addSubview(chipView)
        cardPreview.addSubview(contactlessIcon)
        cardPreview.addSubview(cardNumberTitle)
        cardPreview.addSubview(cardNumberLabel)
        cardPreview.addSubview(cardholderTitle)
        cardPreview.addSubview(cardholderName)
        cardPreview.addSubview(expiryTitle)
        cardPreview.addSubview(expiryValue)
        
        contentView.addSubview(formStack)
        
        saveDefaultContainer.addSubview(saveTitleLabel)
        saveDefaultContainer.addSubview(saveSubtitleLabel)
        saveDefaultContainer.addSubview(defaultSwitch)
        
        numberField.addSubview(cardIcon)

        if formStack.arrangedSubviews.isEmpty {
            let nameStack = makeFieldStack(title: nameLabel, field: nameField)
            let numberStack = makeFieldStack(title: numberLabel, field: numberField, trailingView: cardIcon)
            let expiryStack = makeFieldStack(title: expiryLabel, field: expiryField)
            let cvvStack = makeFieldStack(title: cvvLabel, field: cvvField)

            let rowStack: UIStackView = {
                let stack = UIStackView(arrangedSubviews: [expiryStack, cvvStack])
                stack.axis = .horizontal
                stack.spacing = 12
                stack.distribution = .fillEqually
                return stack
            }()

            [nameStack, numberStack, rowStack, saveDefaultContainer].forEach { formStack.addArrangedSubview($0) }
        }
    }
    
    func setupConstraints() {
        scrollView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(bottomContainer.snp.top)
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        bottomContainer.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        addButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-12)
            make.height.equalTo(52)
        }
        
        cardPreview.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(cardPreview.snp.width).multipliedBy(0.63)
        }
        
        chipView.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(16)
            make.width.equalTo(48)
            make.height.equalTo(36)
        }
        
        contactlessIcon.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.width.height.equalTo(32)
        }
        
        cardNumberTitle.snp.makeConstraints { make in
            make.top.equalTo(chipView.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(16)
        }
        
        cardNumberLabel.snp.makeConstraints { make in
            make.top.equalTo(cardNumberTitle.snp.bottom).offset(6)
            make.leading.equalToSuperview().offset(16)
        }
        
        cardholderTitle.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.bottom.equalToSuperview().offset(-36)
        }
        
        cardholderName.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalTo(cardholderTitle.snp.bottom).offset(4)
            make.trailing.equalTo(expiryTitle.snp.leading).offset(-12)
        }
        
        expiryTitle.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-36)
        }
        
        expiryValue.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.top.equalTo(expiryTitle.snp.bottom).offset(4)
        }
        
        formStack.snp.makeConstraints { make in
            make.top.equalTo(cardPreview.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-24)
        }
        
        saveDefaultContainer.snp.makeConstraints { make in
            make.height.equalTo(76)
        }
        
        saveTitleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(12)
            make.top.equalToSuperview().offset(12)
            make.trailing.lessThanOrEqualTo(defaultSwitch.snp.leading).offset(-12)
        }
        
        saveSubtitleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(12)
            make.top.equalTo(saveTitleLabel.snp.bottom).offset(4)
            make.trailing.lessThanOrEqualTo(defaultSwitch.snp.leading).offset(-12)
        }
        
        defaultSwitch.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-12)
        }
        
        cardIcon.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-14)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(18)
        }
    }

    private func setupActions() {
        nameField.addTarget(self, action: #selector(nameChanged), for: .editingChanged)
        numberField.addTarget(self, action: #selector(numberChanged), for: .editingChanged)
        expiryField.addTarget(self, action: #selector(expiryChanged), for: .editingChanged)
        addButton.addTarget(self, action: #selector(addCardTapped), for: .touchUpInside)
    }

    @objc private func nameChanged() {
        updateCardPreview()
    }

    @objc private func numberChanged() {
        let digits = digitsOnly(numberField.text)
        numberField.text = formatCardNumberInput(digits)
        updateCardPreview()
    }

    @objc private func expiryChanged() {
        let digits = digitsOnly(expiryField.text)
        expiryField.text = formatExpiryInput(digits)
        updateCardPreview()
    }

    @objc private func addCardTapped() {
        let name = (nameField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let cardDigits = digitsOnly(numberField.text)
        let expiry = (expiryField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let cvv = (cvvField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let isDefault = defaultSwitch.isOn

        guard !name.isEmpty else {
            showAlert(title: "Missing Name", message: "Please enter the cardholder name.")
            return
        }
        guard cardDigits.count >= 8 else {
            showAlert(title: "Invalid Card", message: "Please enter a valid card number.")
            return
        }
        guard expiry.count >= 4 else {
            showAlert(title: "Invalid Expiry", message: "Please enter the expiry date.")
            return
        }
        guard cvv.count >= 3 else {
            showAlert(title: "Invalid CVV", message: "Please enter the CVV.")
            return
        }

        addButton.isEnabled = false
        Task { @MainActor in
            do {
                try await vm.savePayment(
                    cardholderName: name,
                    cardNumber: cardDigits,
                    expiryDate: expiry,
                    cvv: cvv,
                    isDefault: isDefault
                )
                onSaved?()
            } catch {
                showAlert(title: "Error", message: error.localizedDescription)
                addButton.isEnabled = true
            }
        }
    }

    private func updateCardPreview() {
        let nameText = (nameField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        cardholderName.text = nameText.isEmpty ? "CARDHOLDER" : nameText.uppercased()

        let digits = digitsOnly(numberField.text)
        cardNumberLabel.text = maskedCardNumber(digits)

        let expiryText = (expiryField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        expiryValue.text = expiryText.isEmpty ? "MM/YY" : expiryText
    }

    private func digitsOnly(_ text: String?) -> String {
        return (text ?? "").filter { $0.isNumber }
    }

    private func formatCardNumberInput(_ digits: String) -> String {
        let trimmed = String(digits.prefix(16))
        var result = ""
        for (index, char) in trimmed.enumerated() {
            if index > 0 && index % 4 == 0 {
                result.append(" ")
            }
            result.append(char)
        }
        return result
    }

    private func maskedCardNumber(_ digits: String) -> String {
        let trimmed = String(digits.prefix(16))
        guard !trimmed.isEmpty else {
            return "•••• •••• •••• ••••"
        }
        
        let count = trimmed.count
        let first = String(trimmed.prefix(4))
        if count <= 4 {
            return first
        }
        
        let middleCount = min(max(count - 4, 0), 8)
        let middleBullets = String(repeating: "•", count: middleCount)
        let middleGroups = stride(from: 0, to: middleBullets.count, by: 4).map { start -> String in
            let startIndex = middleBullets.index(middleBullets.startIndex, offsetBy: start)
            let endIndex = middleBullets.index(startIndex, offsetBy: min(4, middleBullets.count - start))
            return String(middleBullets[startIndex ..< endIndex])
        }
        
        var parts: [String] = [first]
        parts.append(contentsOf: middleGroups.filter { !$0.isEmpty })
        
        if count > 12 {
            let lastCount = count - 12
            let lastDigits = String(trimmed.suffix(lastCount))
            parts.append(lastDigits)
        } else {
            parts.append("••••")
        }
        
        return parts.joined(separator: " ")
    }

    private func formatExpiryInput(_ digits: String) -> String {
        let trimmed = String(digits.prefix(4))
        if trimmed.count <= 2 {
            return trimmed
        }
        let prefix = String(trimmed.prefix(2))
        let suffix = String(trimmed.suffix(trimmed.count - 2))
        return "\(prefix)/\(suffix)"
    }
    
    private func makeFieldStack(title: UILabel, field: UIView, trailingView: UIView? = nil) -> UIView {
        let container = UIView()
        let labelContainer = UIView()
        let fieldContainer = UIView()
        
        labelContainer.addSubview(title)
        fieldContainer.addSubview(field)
        
        container.addSubview(labelContainer)
        container.addSubview(fieldContainer)
        
        labelContainer.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(22)
        }
        
        title.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(4)
            make.centerY.equalToSuperview()
        }
        
        fieldContainer.snp.makeConstraints { make in
            make.top.equalTo(labelContainer.snp.bottom).offset(6)
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(56)
        }
        
        field.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        if let trailingView = trailingView {
            fieldContainer.addSubview(trailingView)
            trailingView.snp.makeConstraints { make in
                make.trailing.equalToSuperview().offset(-14)
                make.centerY.equalToSuperview()
                make.width.height.equalTo(18)
            }
        }
        
        return container
    }
    
    private func setupKeyboardDismiss() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}
