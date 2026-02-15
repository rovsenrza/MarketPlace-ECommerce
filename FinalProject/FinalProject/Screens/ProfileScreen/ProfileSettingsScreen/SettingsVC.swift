import Combine
import SnapKit
import UIKit

final class SettingsVC: UIViewController {
    // MARK: - Properties
    
    private let vm: SettingsVM
    private let onLogout: (() -> Void)?
    private var cancellables = Set<AnyCancellable>()
    var onNameChanged: ((String) -> Void)?
    
    // MARK: - Initialization
    
    init(vm: SettingsVM, onLogout: (() -> Void)? = nil) {
        self.vm = vm
        self.onLogout = onLogout
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Components
    
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        return sv
    }()
    
    private let contentView = UIView()
    
    private let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Account Settings"
        lbl.font = .systemFont(ofSize: 28, weight: .bold)
        return lbl
    }()
    
    private let subtitleLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Update your account information"
        lbl.font = .systemFont(ofSize: 14, weight: .regular)
        lbl.textColor = .secondaryLabel
        lbl.numberOfLines = 0
        return lbl
    }()
    
    private let nameHeaderLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Full Name"
        lbl.font = .systemFont(ofSize: 14, weight: .semibold)
        return lbl
    }()
    
    private lazy var nameTextField: InsetTextField = {
        let tf = InsetTextField(0, 16, 0, 16)
        tf.placeholder = "Enter your full name"
        tf.autocapitalizationType = .words
        tf.delegate = self
        return tf
    }()
    
    private let saveNameButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Update Name", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        btn.backgroundColor = UIColor(named: "PrimaryColorSet") ?? .systemBlue
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 12
        return btn
    }()
    
    private let divider1: UIView = {
        let view = UIView()
        view.backgroundColor = .separator
        return view
    }()
    
    private let passwordHeaderLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "New Password"
        lbl.font = .systemFont(ofSize: 14, weight: .semibold)
        return lbl
    }()
    
    private let passwordContainerView = UIView()
    
    private lazy var passwordTextField: InsetTextField = {
        let tf = InsetTextField(0, 16, 0, 52)
        tf.placeholder = "Enter new password"
        tf.isSecureTextEntry = true
        tf.delegate = self
        return tf
    }()
    
    private let passwordVisibilityButton: UIButton = {
        let btn = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 20)
        btn.setImage(UIImage(systemName: "eye", withConfiguration: config), for: .normal)
        btn.tintColor = UIColor(named: "TextMuted") ?? .secondaryLabel
        btn.accessibilityLabel = "Toggle password visibility"
        btn.accessibilityHint = "Shows or hides your password"
        btn.accessibilityTraits = .button
        return btn
    }()
    
    private let confirmPasswordHeaderLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Confirm Password"
        lbl.font = .systemFont(ofSize: 14, weight: .semibold)
        return lbl
    }()
    
    private let confirmPasswordContainerView = UIView()
    
    private lazy var confirmPasswordTextField: InsetTextField = {
        let tf = InsetTextField(0, 16, 0, 52)
        tf.placeholder = "Confirm new password"
        tf.isSecureTextEntry = true
        tf.delegate = self
        return tf
    }()
    
    private let confirmPasswordVisibilityButton: UIButton = {
        let btn = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 20)
        btn.setImage(UIImage(systemName: "eye", withConfiguration: config), for: .normal)
        btn.tintColor = UIColor(named: "TextMuted") ?? .secondaryLabel
        btn.accessibilityLabel = "Toggle confirm password visibility"
        btn.accessibilityHint = "Shows or hides the confirmation password"
        btn.accessibilityTraits = .button
        return btn
    }()
    
    private let passwordErrorLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 12, weight: .medium)
        lbl.textColor = .systemRed
        lbl.numberOfLines = 0
        lbl.isHidden = true
        return lbl
    }()
    
    private let savePasswordButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Update Password", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        btn.backgroundColor = UIColor(named: "PrimaryColorSet") ?? .systemBlue
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 12
        return btn
    }()
    
    private let divider2: UIView = {
        let view = UIView()
        view.backgroundColor = .separator
        return view
    }()
    
    private let logoutHeaderLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Account Actions"
        lbl.font = .systemFont(ofSize: 14, weight: .semibold)
        return lbl
    }()
    
    private let logoutButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Logout", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        btn.backgroundColor = .systemRed
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 12
        return btn
    }()

    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.isHidden = true
        return indicator
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Setup
    
    func setupUI() {
        view.backgroundColor = UIColor(named: "Background") ?? .systemBackground
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(closeTapped)
        )
        
        addSubviews()
        setupConstraints()
        setupActions()
        setupKeyboardObservers()
        bindViewModel()
        loadCurrentUserData()
    }
    
    func addSubviews() {
        view.addSubview(scrollView)
        view.addSubview(loadingIndicator)
        scrollView.addSubview(contentView)
        
        [
            titleLabel,
            subtitleLabel,
            nameHeaderLabel,
            nameTextField,
            saveNameButton,
            divider1,
            passwordHeaderLabel,
            passwordContainerView,
            confirmPasswordHeaderLabel,
            confirmPasswordContainerView,
            passwordErrorLabel,
            savePasswordButton,
            divider2,
            logoutHeaderLabel,
            logoutButton
        ].forEach { contentView.addSubview($0) }
        
        passwordContainerView.addSubview(passwordTextField)
        passwordContainerView.addSubview(passwordVisibilityButton)
        
        confirmPasswordContainerView.addSubview(confirmPasswordTextField)
        confirmPasswordContainerView.addSubview(confirmPasswordVisibilityButton)
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
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        nameHeaderLabel.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(32)
            make.leading.equalToSuperview().offset(20)
        }
        
        nameTextField.snp.makeConstraints { make in
            make.top.equalTo(nameHeaderLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(52)
        }
        
        saveNameButton.snp.makeConstraints { make in
            make.top.equalTo(nameTextField.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(50)
        }
        
        divider1.snp.makeConstraints { make in
            make.top.equalTo(saveNameButton.snp.bottom).offset(32)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(1)
        }
        
        passwordHeaderLabel.snp.makeConstraints { make in
            make.top.equalTo(divider1.snp.bottom).offset(32)
            make.leading.equalToSuperview().offset(20)
        }
        
        passwordContainerView.snp.makeConstraints { make in
            make.top.equalTo(passwordHeaderLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(52)
        }
        
        passwordTextField.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        passwordVisibilityButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-4)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(44)
        }
        
        confirmPasswordHeaderLabel.snp.makeConstraints { make in
            make.top.equalTo(passwordContainerView.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(20)
        }
        
        confirmPasswordContainerView.snp.makeConstraints { make in
            make.top.equalTo(confirmPasswordHeaderLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(52)
        }
        
        confirmPasswordTextField.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        confirmPasswordVisibilityButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-4)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(44)
        }
        
        passwordErrorLabel.snp.makeConstraints { make in
            make.top.equalTo(confirmPasswordContainerView.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        savePasswordButton.snp.makeConstraints { make in
            make.top.equalTo(passwordErrorLabel.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(50)
        }
        
        divider2.snp.makeConstraints { make in
            make.top.equalTo(savePasswordButton.snp.bottom).offset(32)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(1)
        }
        
        logoutHeaderLabel.snp.makeConstraints { make in
            make.top.equalTo(divider2.snp.bottom).offset(24)
            make.leading.equalToSuperview().offset(20)
        }
        
        logoutButton.snp.makeConstraints { make in
            make.top.equalTo(logoutHeaderLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(50)
            make.bottom.equalToSuperview().offset(-32)
        }

        loadingIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    private func setupActions() {
        saveNameButton.addTarget(self, action: #selector(saveNameTapped), for: .touchUpInside)
        savePasswordButton.addTarget(self, action: #selector(savePasswordTapped), for: .touchUpInside)
        logoutButton.addTarget(self, action: #selector(logoutTapped), for: .touchUpInside)
        
        passwordVisibilityButton.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)
        confirmPasswordVisibilityButton.addTarget(self, action: #selector(toggleConfirmPasswordVisibility), for: .touchUpInside)
    }
    
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Actions
    
    @objc private func closeTapped() {
        dismiss(animated: true)
    }
    
    @objc private func saveNameTapped() {
        guard let name = nameTextField.text?.trimmingCharacters(in: .whitespaces), !name.isEmpty else {
            showAlert(title: "Error", message: "Please enter a valid name")
            return
        }
        
        view.endEditing(true)
        showLoadingIndicator()
        
        Task { @MainActor [weak self] in
            guard let self else { return }

            do {
                try await vm.updateName(name)
                hideLoadingIndicator()
                onNameChanged?(name)
                showAlert(title: "Success", message: "Your name has been updated successfully")
            } catch {
                hideLoadingIndicator()
                showAlert(title: "Error", message: error.localizedDescription)
            }
        }
    }
    
    @objc private func savePasswordTapped() {
        guard let password = passwordTextField.text, !password.isEmpty else {
            showPasswordError("Please enter a new password")
            return
        }
         guard password.count >= 6 else {
            showPasswordError("Password must be at least 6 characters")
            return
        }
         guard let confirmPassword = confirmPasswordTextField.text, !confirmPassword.isEmpty else {
            showPasswordError("Please confirm your password")
            return
        }
         guard password == confirmPassword else {
            showPasswordError("Passwords do not match")
            return
        }
        
        view.endEditing(true)
        passwordErrorLabel.isHidden = true
        showLoadingIndicator()
        
        Task { @MainActor [weak self] in
            guard let self else { return }

            do {
                try await vm.updatePassword(password)
                hideLoadingIndicator()
                passwordTextField.text = ""
                confirmPasswordTextField.text = ""
                showAlert(title: "Success", message: "Your password has been updated successfully")
            } catch {
                hideLoadingIndicator()
                showPasswordError(error.localizedDescription)
            }
        }
    }
    
    @objc private func togglePasswordVisibility() {
        passwordTextField.isSecureTextEntry.toggle()
        let imageName = passwordTextField.isSecureTextEntry ? "eye" : "eye.slash"
        let config = UIImage.SymbolConfiguration(pointSize: 20)
        passwordVisibilityButton.setImage(UIImage(systemName: imageName, withConfiguration: config), for: .normal)
    }
    
    @objc private func toggleConfirmPasswordVisibility() {
        confirmPasswordTextField.isSecureTextEntry.toggle()
        let imageName = confirmPasswordTextField.isSecureTextEntry ? "eye" : "eye.slash"
        let config = UIImage.SymbolConfiguration(pointSize: 20)
        confirmPasswordVisibilityButton.setImage(UIImage(systemName: imageName, withConfiguration: config), for: .normal)
    }
    
    @objc private func logoutTapped() {
        showConfirmationAlert(
            title: "Logout",
            message: "Are you sure you want to logout?",
            confirmTitle: "Logout",
            confirmStyle: .destructive
        ) { [weak self] in
            self?.performLogout()
        }
    }
    
    private func performLogout() {
        showLoadingIndicator()

        do {
            try vm.logout()
            hideLoadingIndicator()
            dismiss(animated: true) { [weak self] in
                self?.onLogout?()
            }
        } catch {
            hideLoadingIndicator()
            showAlert(title: "Error", message: error.localizedDescription)
        }
    }
    
    private func bindViewModel() {
        vm.$currentUser
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                guard let self = self, let user = user else { return }

                self.nameTextField.text = user.displayName
            }
            .store(in: &cancellables)
    }
    
    private func loadCurrentUserData() {
        vm.fetchCurrentUser()
    }
    
    private func showLoadingIndicator() {
        loadingIndicator.isHidden = false
        loadingIndicator.startAnimating()
        view.isUserInteractionEnabled = false
    }
    
    private func hideLoadingIndicator() {
        loadingIndicator.stopAnimating()
        loadingIndicator.isHidden = true
        view.isUserInteractionEnabled = true
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardFrame.height, right: 0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        scrollView.contentInset = .zero
        scrollView.scrollIndicatorInsets = .zero
    }
    
    // MARK: - Helper Methods
    
    private func showPasswordError(_ message: String) {
        passwordErrorLabel.text = message
        passwordErrorLabel.isHidden = false
    }
}

// MARK: - UITextFieldDelegate

extension SettingsVC: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        guard let insetTextField = textField as? InsetTextField else { return }
        
        UIView.animate(withDuration: 0.2) {
            insetTextField.layer.borderColor = (UIColor(named: "AccentColor") ?? .systemOrange).cgColor
            insetTextField.layer.borderWidth = 2
        }
        
        if textField == passwordTextField || textField == confirmPasswordTextField {
            passwordErrorLabel.isHidden = true
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let insetTextField = textField as? InsetTextField else { return }
        
        UIView.animate(withDuration: 0.2) {
            insetTextField.layer.borderColor = UIColor.systemGray4.cgColor
            insetTextField.layer.borderWidth = 1
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == nameTextField {
            textField.resignFirstResponder()
        } else if textField == passwordTextField {
            confirmPasswordTextField.becomeFirstResponder()
        } else if textField == confirmPasswordTextField {
            textField.resignFirstResponder()
            savePasswordTapped()
        }
        return true
    }
}
