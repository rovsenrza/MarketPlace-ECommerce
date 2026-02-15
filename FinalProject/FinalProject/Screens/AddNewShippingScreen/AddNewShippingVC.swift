import SnapKit
import UIKit

final class AddNewShippingVC: UIViewController {
    private let vm: AddNewShippingVM
    private let existingAddress: ShippingAddress?
    private let onSaved: (() -> Void)?
    
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        return sv
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        return view
    }()
    
    private let formStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        return stack
    }()
    
    private let fullNameStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 6
        return stack
    }()
    
    private let fullNameLabel: UILabel = {
        let label = UILabel()
        label.text = "Full Name"
        label.font = AppTypography.label()
        label.textColor = UIColor(named: "TextPrimary") ?? .label
        label.adjustsFontForContentSizeCategory = true
        return label
    }()
    
    private let fullNameField: InsetTextField = {
        let tf = InsetTextField(0, 16, 0, 16)
        tf.placeholder = "Enter your full name"
        tf.textContentType = .name
        tf.autocapitalizationType = .words
        tf.returnKeyType = .next
        return tf
    }()
    
    private let phoneStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 6
        return stack
    }()
    
    private let phoneLabel: UILabel = {
        let label = UILabel()
        label.text = "Phone Number"
        label.font = AppTypography.label()
        label.textColor = UIColor(named: "TextPrimary") ?? .label
        label.adjustsFontForContentSizeCategory = true
        return label
    }()
    
    private let phoneField: InsetTextField = {
        let tf = InsetTextField(0, 16, 0, 16)
        tf.placeholder = "+1 (555) 000-0000"
        tf.textContentType = .telephoneNumber
        tf.keyboardType = .phonePad
        tf.returnKeyType = .next
        return tf
    }()
    
    private let streetStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 6
        return stack
    }()
    
    private let streetLabel: UILabel = {
        let label = UILabel()
        label.text = "Street Address"
        label.font = AppTypography.label()
        label.textColor = UIColor(named: "TextPrimary") ?? .label
        label.adjustsFontForContentSizeCategory = true
        return label
    }()
    
    private let streetField: InsetTextField = {
        let tf = InsetTextField(0, 16, 0, 16)
        tf.placeholder = "Enter street name and house number"
        tf.textContentType = .fullStreetAddress
        tf.autocapitalizationType = .words
        tf.returnKeyType = .next
        return tf
    }()
    
    private let cityStateRow: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 12
        stack.distribution = .fillEqually
        return stack
    }()
    
    private let cityStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 6
        return stack
    }()
    
    private let cityLabel: UILabel = {
        let label = UILabel()
        label.text = "City"
        label.font = AppTypography.label()
        label.textColor = UIColor(named: "TextPrimary") ?? .label
        label.adjustsFontForContentSizeCategory = true
        return label
    }()
    
    private let cityField: InsetTextField = {
        let tf = InsetTextField(0, 16, 0, 16)
        tf.placeholder = "City"
        tf.textContentType = .addressCity
        tf.autocapitalizationType = .words
        tf.returnKeyType = .next
        return tf
    }()
    
    private let stateStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 6
        return stack
    }()
    
    private let stateLabel: UILabel = {
        let label = UILabel()
        label.text = "State/Province"
        label.font = AppTypography.label()
        label.textColor = UIColor(named: "TextPrimary") ?? .label
        label.adjustsFontForContentSizeCategory = true
        return label
    }()
    
    private let stateField: InsetTextField = {
        let tf = InsetTextField(0, 16, 0, 16)
        tf.placeholder = "State"
        tf.textContentType = .addressState
        tf.autocapitalizationType = .words
        tf.returnKeyType = .next
        return tf
    }()
    
    private let zipStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 6
        return stack
    }()
    
    private let zipLabel: UILabel = {
        let label = UILabel()
        label.text = "Zip/Postal Code"
        label.font = AppTypography.label()
        label.textColor = UIColor(named: "TextPrimary") ?? .label
        label.adjustsFontForContentSizeCategory = true
        return label
    }()
    
    private let zipField: InsetTextField = {
        let tf = InsetTextField(0, 16, 0, 16)
        tf.placeholder = "12345"
        tf.textContentType = .postalCode
        tf.keyboardType = .numbersAndPunctuation
        tf.returnKeyType = .done
        return tf
    }()
    
    private let defaultDivider: DividerView = {
        let view = DividerView(color: UIColor(named: "Border") ?? .separator, height: 1)
        return view
    }()
    
    private let defaultRow: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 12
        stack.alignment = .center
        return stack
    }()
    
    private let defaultTextStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 4
        return stack
    }()
    
    private let defaultTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Set as Default Address"
        label.font = AppTypography.button()
        label.textColor = UIColor(named: "TextPrimary") ?? .label
        label.adjustsFontForContentSizeCategory = true
        return label
    }()
    
    private let defaultSubtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Use this as your primary delivery address"
        label.font = AppTypography.label()
        label.textColor = UIColor(named: "TextMuted") ?? .secondaryLabel
        label.numberOfLines = 0
        label.adjustsFontForContentSizeCategory = true
        return label
    }()
    
    private let defaultSwitch: UISwitch = {
        let toggle = UISwitch()
        toggle.onTintColor = UIColor(named: "PrimaryColorSet") ?? .systemBlue
        toggle.isOn = true
        return toggle
    }()
    
    private let bottomContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "Background")?.withAlphaComponent(0.95) ?? .systemBackground
        return view
    }()
    
    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Save Address", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = AppTypography.button()
        button.backgroundColor = UIColor(named: "PrimaryColorSet") ?? .systemBlue
        button.layer.cornerRadius = 16
        button.layer.shadowColor = (UIColor(named: "PrimaryColorSet") ?? .systemBlue).withAlphaComponent(0.2).cgColor
        button.layer.shadowOpacity = 1
        button.layer.shadowRadius = 10
        button.layer.shadowOffset = CGSize(width: 0, height: 6)
        return button
    }()
    
    init(vm: AddNewShippingVM, existingAddress: ShippingAddress? = nil, onSaved: (() -> Void)? = nil) {
        self.vm = vm
        self.existingAddress = existingAddress
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
    
    func setupUI() {
        view.backgroundColor = UIColor(named: "Background") ?? .systemBackground
        title = existingAddress == nil ? "Add New Address" : "Edit Address"
        navigationController?.navigationBar.prefersLargeTitles = false
        addSubviews()
        setupConstraints()
        setupKeyboardDismiss()
        setupActions()
        applyExistingAddress()

        defaultSwitch.setContentHuggingPriority(.required, for: .horizontal)
        defaultSwitch.setContentCompressionResistancePriority(.required, for: .horizontal)
    }

    func addSubviews() {
        view.addSubview(scrollView)
        view.addSubview(bottomContainer)
        scrollView.addSubview(contentView)
        contentView.addSubview(formStack)
        
        fullNameStack.addArrangedSubview(fullNameLabel)
        fullNameStack.addArrangedSubview(fullNameField)
        
        phoneStack.addArrangedSubview(phoneLabel)
        phoneStack.addArrangedSubview(phoneField)
        
        streetStack.addArrangedSubview(streetLabel)
        streetStack.addArrangedSubview(streetField)
        
        cityStack.addArrangedSubview(cityLabel)
        cityStack.addArrangedSubview(cityField)
        
        stateStack.addArrangedSubview(stateLabel)
        stateStack.addArrangedSubview(stateField)
        
        cityStateRow.addArrangedSubview(cityStack)
        cityStateRow.addArrangedSubview(stateStack)
        
        zipStack.addArrangedSubview(zipLabel)
        zipStack.addArrangedSubview(zipField)
        
        defaultTextStack.addArrangedSubview(defaultTitleLabel)
        defaultTextStack.addArrangedSubview(defaultSubtitleLabel)
        
        defaultRow.addArrangedSubview(defaultTextStack)
        defaultRow.addArrangedSubview(defaultSwitch)
        
        formStack.addArrangedSubview(fullNameStack)
        formStack.addArrangedSubview(phoneStack)
        formStack.addArrangedSubview(streetStack)
        formStack.addArrangedSubview(cityStateRow)
        formStack.addArrangedSubview(zipStack)
        formStack.addArrangedSubview(defaultDivider)
        formStack.addArrangedSubview(defaultRow)
        
        bottomContainer.addSubview(saveButton)
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
        
        formStack.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-16)
        }
        
        bottomContainer.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        saveButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-12)
            make.height.equalTo(56)
        }
    }
    
    private func setupKeyboardDismiss() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }

    private func setupActions() {
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
    }

    private func applyExistingAddress() {
        guard let address = existingAddress else { return }

        fullNameField.text = address.name
        phoneField.text = address.phoneNumber
        streetField.text = address.streetAddress
        cityField.text = address.city
        stateField.text = address.state
        zipField.text = address.zipCode
        defaultSwitch.isOn = address.isDefault
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc private func saveTapped() {
        let name = (fullNameField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let phone = (phoneField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let street = (streetField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let city = (cityField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let state = (stateField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let zip = (zipField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let isDefault = defaultSwitch.isOn

        guard !name.isEmpty else {
            showAlert(title: "Missing Name", message: "Please enter a full name.")
            return
        }
        guard !phone.isEmpty else {
            showAlert(title: "Missing Phone", message: "Please enter a phone number.")
            return
        }
        guard !street.isEmpty else {
            showAlert(title: "Missing Address", message: "Please enter a street address.")
            return
        }
        guard !city.isEmpty else {
            showAlert(title: "Missing City", message: "Please enter a city.")
            return
        }
        guard !state.isEmpty else {
            showAlert(title: "Missing State", message: "Please enter a state or province.")
            return
        }
        guard !zip.isEmpty else {
            showAlert(title: "Missing Zip", message: "Please enter a zip or postal code.")
            return
        }

        saveButton.isEnabled = false
        Task { @MainActor in
            do {
                try await vm.saveAddress(
                    existingId: existingAddress?.id,
                    name: name,
                    phoneNumber: phone,
                    streetAddress: street,
                    city: city,
                    state: state,
                    zipCode: zip,
                    isDefault: isDefault
                )
                onSaved?()
            } catch {
                showAlert(title: "Error", message: error.localizedDescription)
                saveButton.isEnabled = true
            }
        }
    }
}
