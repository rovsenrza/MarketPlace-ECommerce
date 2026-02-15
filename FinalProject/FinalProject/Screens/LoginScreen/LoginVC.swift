import Combine
import SnapKit
import UIKit

final class LoginVC: UIViewController {
    // MARK: - Properties

    private let vm: LoginVM
    private let onAuthenticated: (() -> Void)?
    private let onRegisterRequested: (() -> Void)?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - UI Components

    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        return sv
    }()
    
    private let contentView = UIView()
    
    private let welcomeLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Welcome back"
        lbl.font = AppTypography.titleLarge()
        lbl.numberOfLines = 0
        lbl.adjustsFontForContentSizeCategory = true
        return lbl
    }()
    
    private let subtitleLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Sign in to access your personalized marketplace."
        lbl.font = AppTypography.body()
        lbl.textColor = UIColor(named: "TextSecondary") ?? .secondaryLabel
        lbl.numberOfLines = 0
        lbl.adjustsFontForContentSizeCategory = true
        return lbl
    }()
    
    private let emailLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Email Address"
        lbl.font = AppTypography.label()
        lbl.adjustsFontForContentSizeCategory = true
        return lbl
    }()
    
    private lazy var emailTextField: InsetTextField = {
        let tf = InsetTextField(0, 16, 0, 16)
        tf.placeholder = "Enter your email"
        tf.autocapitalizationType = .none
        tf.keyboardType = .emailAddress
        tf.delegate = self
        tf.tag = 1
        tf.addTarget(self, action: #selector(emailDidChange), for: .editingChanged)
        return tf
    }()
    
    private let passwordLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Password"
        lbl.font = AppTypography.label()
        lbl.adjustsFontForContentSizeCategory = true
        return lbl
    }()
    
    private let forgotPasswordButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Forgot Password?", for: .normal)
        btn.titleLabel?.font = AppTypography.label()
        btn.tintColor = UIColor(named: "AccentColor") ?? .systemOrange
        return btn
    }()
    
    private let passwordContainerView = UIView()
    
    private lazy var passwordTextField: InsetTextField = {
        let tf = InsetTextField(0, 16, 0, 52)
        tf.placeholder = "Enter your password"
        tf.isSecureTextEntry = true
        tf.delegate = self
        tf.tag = 2
        tf.addTarget(self, action: #selector(passwordDidChange), for: .editingChanged)
        return tf
    }()
    
    private let visibilityButton: UIButton = {
        let btn = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 20)
        btn.setImage(UIImage(systemName: "eye", withConfiguration: config), for: .normal)
        btn.tintColor = UIColor(named: "TextMuted") ?? .secondaryLabel
        btn.accessibilityLabel = "Toggle password visibility"
        btn.accessibilityHint = "Shows or hides your password"
        btn.accessibilityTraits = .button
        return btn
    }()
    
    private let loginButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Log In", for: .normal)
        btn.titleLabel?.font = AppTypography.button()
        btn.backgroundColor = UIColor(named: "PrimaryColorSet") ?? .systemBlue
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 12
        btn.layer.shadowColor = (UIColor(named: "PrimaryColorSet") ?? .systemBlue).cgColor
        btn.layer.shadowOffset = CGSize(width: 0, height: 4)
        btn.layer.shadowOpacity = 0.2
        btn.layer.shadowRadius = 8
        return btn
    }()
    
    private let dividerLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Or continue with"
        lbl.font = AppTypography.label()
        lbl.textColor = UIColor(named: "TextMuted") ?? .secondaryLabel
        lbl.textAlignment = .center
        lbl.backgroundColor = .systemBackground
        lbl.adjustsFontForContentSizeCategory = true
        return lbl
    }()
    
    private let dividerLine: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "Divider") ?? .separator
        return view
    }()
    
    private let googleButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.backgroundColor = .systemBackground
        btn.layer.cornerRadius = 12
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor(named: "Border")?.cgColor ?? UIColor.separator.cgColor
        
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "google-icon")
        imageView.tintColor = .label
        
        let label = UILabel()
        label.text = "Google"
        label.font = AppTypography.label()
        
        btn.addSubview(imageView)
        btn.addSubview(label)
        
        imageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(40)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(20)
        }
        
        label.snp.makeConstraints { make in
            make.leading.equalTo(imageView.snp.trailing).offset(8)
            make.centerY.equalToSuperview()
        }
        
        return btn
    }()
    
    private let appleButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.backgroundColor = .systemBackground
        btn.layer.cornerRadius = 12
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor(named: "Border")?.cgColor ?? UIColor.separator.cgColor
        
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        let config = UIImage.SymbolConfiguration(pointSize: 20)
        imageView.image = UIImage(systemName: "apple.logo", withConfiguration: config)
        imageView.tintColor = .label
        
        let label = UILabel()
        label.text = "Apple"
        label.font = AppTypography.label()
        
        btn.addSubview(imageView)
        btn.addSubview(label)
        
        imageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(40)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(20)
        }
        
        label.snp.makeConstraints { make in
            make.leading.equalTo(imageView.snp.trailing).offset(8)
            make.centerY.equalToSuperview()
        }
        
        return btn
    }()
    
    private let footerLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = AppTypography.body()
        lbl.adjustsFontForContentSizeCategory = true
        
        let text = "Don't have an account? "
        let boldText = "Register"
        let attributedString = NSMutableAttributedString(string: text + boldText)
        attributedString.addAttribute(.foregroundColor, value: UIColor.label, range: NSRange(location: 0, length: text.count))
        attributedString.addAttribute(.foregroundColor, value: UIColor(named: "AccentColor") ?? UIColor.systemOrange, range: NSRange(location: text.count, length: boldText.count))
        attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 16, weight: .bold), range: NSRange(location: text.count, length: boldText.count))
        
        lbl.attributedText = attributedString
        lbl.textAlignment = .center
        lbl.isUserInteractionEnabled = true
        return lbl
    }()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.color = UIColor(named: "PrimaryColorSet") ?? .systemBlue
        return indicator
    }()
    
    // MARK: - Lifecycle

    init(
        vm: LoginVM,
        onAuthenticated: (() -> Void)? = nil,
        onRegisterRequested: (() -> Void)? = nil
    ) {
        self.vm = vm
        self.onAuthenticated = onAuthenticated
        self.onRegisterRequested = onRegisterRequested
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
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Setup

    func setupUI() {
        view.backgroundColor = UIColor(named: "Background") ?? .systemBackground
        navigationController?.setNavigationBarHidden(false, animated: false)
        title = "Authentication"
        addSubviews()
        setupConstraints()
        setupActions()
        setupKeyboardObservers()
        bindViewModel()
    }

    func addSubviews() {
        view.addSubview(scrollView)
        view.addSubview(loadingIndicator)

        scrollView.addSubview(contentView)

        [
            welcomeLabel,
            subtitleLabel,
            emailLabel,
            emailTextField,
            passwordLabel,
            forgotPasswordButton,
            passwordContainerView,
            loginButton,
            dividerLine,
            dividerLabel,
            googleButton,
            appleButton,
            footerLabel
        ].forEach { contentView.addSubview($0) }

        [
            passwordTextField,
            visibilityButton
        ].forEach { passwordContainerView.addSubview($0) }
    }

    func setupConstraints() {
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        welcomeLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(welcomeLabel.snp.bottom).offset(8)
            make.leading.trailing.equalTo(welcomeLabel)
        }
        
        emailLabel.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(32)
            make.leading.equalTo(welcomeLabel).offset(4)
        }
        
        emailTextField.snp.makeConstraints { make in
            make.top.equalTo(emailLabel.snp.bottom).offset(8)
            make.leading.trailing.equalTo(welcomeLabel)
        }
        
        passwordLabel.snp.makeConstraints { make in
            make.top.equalTo(emailTextField.snp.bottom).offset(16)
            make.leading.equalTo(emailLabel)
        }
        
        forgotPasswordButton.snp.makeConstraints { make in
            make.centerY.equalTo(passwordLabel)
            make.trailing.equalTo(welcomeLabel).offset(-4)
        }
        
        passwordContainerView.snp.makeConstraints { make in
            make.top.equalTo(passwordLabel.snp.bottom).offset(8)
            make.leading.trailing.equalTo(welcomeLabel)
            make.height.equalTo(52)
        }
        
        passwordTextField.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        visibilityButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(44)
        }
        
        loginButton.snp.makeConstraints { make in
            make.top.equalTo(passwordContainerView.snp.bottom).offset(16)
            make.leading.trailing.equalTo(welcomeLabel)
            make.height.equalTo(56)
        }
        
        dividerLine.snp.makeConstraints { make in
            make.top.equalTo(loginButton.snp.bottom).offset(32)
            make.leading.trailing.equalTo(welcomeLabel)
            make.height.equalTo(1)
        }
        
        dividerLabel.snp.makeConstraints { make in
            make.centerY.equalTo(dividerLine)
            make.centerX.equalTo(dividerLine)
            make.width.equalTo(160)
        }
        
        googleButton.snp.makeConstraints { make in
            make.top.equalTo(dividerLine.snp.bottom).offset(32)
            make.leading.equalTo(welcomeLabel)
            make.height.equalTo(56)
        }
        
        appleButton.snp.makeConstraints { make in
            make.top.equalTo(googleButton)
            make.leading.equalTo(googleButton.snp.trailing).offset(16)
            make.trailing.equalTo(welcomeLabel)
            make.height.equalTo(56)
            make.width.equalTo(googleButton)
        }
        
        footerLabel.snp.makeConstraints { make in
            make.top.equalTo(googleButton.snp.bottom).offset(32)
            make.leading.trailing.equalTo(welcomeLabel)
            make.bottom.equalToSuperview().offset(-32)
        }
        
        loadingIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    private func setupActions() {
        visibilityButton.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)
        loginButton.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
        forgotPasswordButton.addTarget(self, action: #selector(forgotPasswordTapped), for: .touchUpInside)
        googleButton.addTarget(self, action: #selector(googleLoginTapped), for: .touchUpInside)
        appleButton.addTarget(self, action: #selector(appleLoginTapped), for: .touchUpInside)
        
        let registerTap = UITapGestureRecognizer(target: self, action: #selector(registerTapped))
        footerLabel.addGestureRecognizer(registerTap)
    }
    
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - ViewModel Binding
    
    private func bindViewModel() {
        vm.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                if isLoading {
                    self?.loadingIndicator.startAnimating()
                    self?.loginButton.isEnabled = false
                    self?.loginButton.alpha = 0.6
                } else {
                    self?.loadingIndicator.stopAnimating()
                    self?.loginButton.isEnabled = true
                    self?.loginButton.alpha = 1.0
                }
            }
            .store(in: &cancellables)
        
        vm.$errorMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] errorMessage in
                guard let self = self, let error = errorMessage else { return }

                self.showError(error)
            }
            .store(in: &cancellables)
        
        vm.$isAuthenticated
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isAuthenticated in
                if isAuthenticated {
                    self?.handleSuccessfulLogin()
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Actions

    @objc private func emailDidChange() {
        vm.email = emailTextField.text ?? ""
    }
    
    @objc private func passwordDidChange() {
        vm.password = passwordTextField.text ?? ""
    }

    @objc private func togglePasswordVisibility() {
        passwordTextField.isSecureTextEntry.toggle()
        let imageName = passwordTextField.isSecureTextEntry ? "eye" : "eye.slash"
        let config = UIImage.SymbolConfiguration(pointSize: 20)
        visibilityButton.setImage(UIImage(systemName: imageName, withConfiguration: config), for: .normal)
    }
    
    @objc private func loginTapped() {
        Task {
            await vm.login()
        }
    }
    
    @objc private func forgotPasswordTapped() {
        Task {
            await vm.forgotPassword()
        }
    }
    
    @objc private func googleLoginTapped() {
        Task {
            await vm.signInWithGoogle(presentingViewController: self)
        }
    }
    
    @objc private func appleLoginTapped() {
        Task {
            await vm.signInWithApple()
        }
    }
    
    @objc private func registerTapped() {
        onRegisterRequested?()
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
    
    private func showError(_ message: String) {
        showAlert(title: "Error", message: message) { [weak self] in
            self?.vm.clearError()
        }
    }
    
    private func handleSuccessfulLogin() {
        onAuthenticated?()
    }
}

// MARK: - UITextFieldDelegate

extension LoginVC: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        guard let insetTextField = textField as? InsetTextField else { return }
        
        UIView.animate(withDuration: 0.2) {
            insetTextField.layer.borderColor = (UIColor(named: "AccentColor") ?? .systemOrange).cgColor
            insetTextField.layer.borderWidth = 2
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
        if textField.tag == 1 {
            passwordTextField.becomeFirstResponder()
        } else if textField.tag == 2 {
            textField.resignFirstResponder()
            loginTapped()
        }
        return true
    }
}
