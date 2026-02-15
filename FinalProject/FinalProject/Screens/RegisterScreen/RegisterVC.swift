import Combine
import SnapKit
import UIKit

final class RegisterVC: UIViewController {
    // MARK: - Properties

    private let vm: RegisterVM
    private let onAuthenticated: (() -> Void)?
    private let onLoginRequested: (() -> Void)?
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
        lbl.text = "Create Account"
        lbl.font = AppTypography.titleLarge()
        lbl.numberOfLines = 0
        lbl.adjustsFontForContentSizeCategory = true
        return lbl
    }()
    
    private let subtitleLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Join us to access your personalized marketplace."
        lbl.font = AppTypography.body()
        lbl.textColor = UIColor(named: "TextSecondary") ?? .secondaryLabel
        lbl.numberOfLines = 0
        lbl.adjustsFontForContentSizeCategory = true
        return lbl
    }()
    
    private let fullNameLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Full Name"
        lbl.font = AppTypography.label()
        lbl.adjustsFontForContentSizeCategory = true
        return lbl
    }()
    
    private lazy var fullNameTextField: InsetTextField = {
        let tf = InsetTextField(0, 16, 0, 16)
        tf.placeholder = "Enter your full name"
        tf.autocapitalizationType = .words
        tf.delegate = self
        tf.tag = 1
        tf.addTarget(self, action: #selector(fullNameChanged), for: .editingChanged)
        return tf
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
        tf.tag = 2
        tf.addTarget(self, action: #selector(emailChanged), for: .editingChanged)
        return tf
    }()
    
    private let passwordLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Password"
        lbl.font = AppTypography.label()
        lbl.adjustsFontForContentSizeCategory = true
        return lbl
    }()
    
    private let passwordContainerView = UIView()
    
    private lazy var passwordTextField: InsetTextField = {
        let tf = InsetTextField(0, 16, 0, 52)
        tf.placeholder = "Create a password"
        tf.isSecureTextEntry = true
        tf.delegate = self
        tf.tag = 3
        tf.addTarget(self, action: #selector(passwordChanged), for: .editingChanged)
        return tf
    }()
    
    private let visibilityButton: UIButton = {
        let btn = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 20)
        btn.setImage(UIImage(systemName: "eye", withConfiguration: config), for: .normal)
        btn.tintColor = UIColor(named: "TextMuted") ?? .secondaryLabel
        btn.isUserInteractionEnabled = true
        btn.accessibilityLabel = "Toggle password visibility"
        btn.accessibilityHint = "Shows or hides your password"
        btn.accessibilityTraits = .button
        return btn
    }()
    
    private let passwordStrengthView: UIView = {
        let view = UIView()
        view.isHidden = true
        return view
    }()
    
    private let passwordStrengthLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = AppTypography.label()
        lbl.textAlignment = .right
        lbl.adjustsFontForContentSizeCategory = true
        return lbl
    }()
    
    private let passwordStrengthBar: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 2
        view.backgroundColor = .systemGray5
        return view
    }()
    
    private let passwordStrengthProgress: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 2
        return view
    }()
    
    private let errorLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = AppTypography.body()
        lbl.textColor = .systemRed
        lbl.numberOfLines = 0
        lbl.isHidden = true
        lbl.adjustsFontForContentSizeCategory = true
        return lbl
    }()
    
    private let signUpButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Sign Up", for: .normal)
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
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.color = .white
        return indicator
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
        lbl.font = .systemFont(ofSize: 16, weight: .medium)
        
        let text = "Already have an account? "
        let boldText = "Log In"
        let attributedString = NSMutableAttributedString(string: text + boldText)
        attributedString.addAttribute(.foregroundColor, value: UIColor.label, range: NSRange(location: 0, length: text.count))
        attributedString.addAttribute(.foregroundColor, value: UIColor(named: "AccentColor") ?? UIColor.systemOrange, range: NSRange(location: text.count, length: boldText.count))
        attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 16, weight: .bold), range: NSRange(location: text.count, length: boldText.count))
        
        lbl.attributedText = attributedString
        lbl.textAlignment = .center
        lbl.isUserInteractionEnabled = true
        return lbl
    }()
    
    // MARK: - Lifecycle

    init(
        vm: RegisterVM,
        onAuthenticated: (() -> Void)? = nil,
        onLoginRequested: (() -> Void)? = nil
    ) {
        self.vm = vm
        self.onAuthenticated = onAuthenticated
        self.onLoginRequested = onLoginRequested
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
        scrollView.addSubview(contentView)

        [
            welcomeLabel,
            subtitleLabel,
            fullNameLabel,
            fullNameTextField,
            emailLabel,
            emailTextField,
            passwordLabel,
            passwordContainerView,
            passwordStrengthView,
            errorLabel,
            signUpButton,
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
        
        passwordStrengthView.addSubview(passwordStrengthBar)
        passwordStrengthBar.addSubview(passwordStrengthProgress)
        passwordStrengthView.addSubview(passwordStrengthLabel)
        
        signUpButton.addSubview(loadingIndicator)
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
        
        fullNameLabel.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(32)
            make.leading.equalTo(welcomeLabel).offset(4)
        }
        
        fullNameTextField.snp.makeConstraints { make in
            make.top.equalTo(fullNameLabel.snp.bottom).offset(8)
            make.leading.trailing.equalTo(welcomeLabel)
        }
        
        emailLabel.snp.makeConstraints { make in
            make.top.equalTo(fullNameTextField.snp.bottom).offset(16)
            make.leading.equalTo(fullNameLabel)
        }
        
        emailTextField.snp.makeConstraints { make in
            make.top.equalTo(emailLabel.snp.bottom).offset(8)
            make.leading.trailing.equalTo(welcomeLabel)
        }
        
        passwordLabel.snp.makeConstraints { make in
            make.top.equalTo(emailTextField.snp.bottom).offset(16)
            make.leading.equalTo(emailLabel)
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
            make.trailing.equalToSuperview().offset(-4)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(44)
        }
        
        passwordStrengthView.snp.makeConstraints { make in
            make.top.equalTo(passwordContainerView.snp.bottom).offset(8)
            make.leading.trailing.equalTo(welcomeLabel)
            make.height.equalTo(20)
        }
        
        passwordStrengthBar.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalTo(passwordStrengthLabel.snp.leading).offset(-8)
            make.centerY.equalToSuperview()
            make.height.equalTo(4)
        }
        
        passwordStrengthProgress.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.width.equalTo(0)
        }
        
        passwordStrengthLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalTo(60)
        }
        
        errorLabel.snp.makeConstraints { make in
            make.top.equalTo(passwordStrengthView.snp.bottom).offset(8)
            make.leading.trailing.equalTo(welcomeLabel)
        }
        
        signUpButton.snp.makeConstraints { make in
            make.top.equalTo(errorLabel.snp.bottom).offset(16)
            make.leading.trailing.equalTo(welcomeLabel)
            make.height.equalTo(56)
        }
        
        loadingIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        dividerLine.snp.makeConstraints { make in
            make.top.equalTo(signUpButton.snp.bottom).offset(32)
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
    }
    
    private func setupActions() {
        visibilityButton.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)
        signUpButton.addTarget(self, action: #selector(signUpTapped), for: .touchUpInside)
        googleButton.addTarget(self, action: #selector(googleSignUpTapped), for: .touchUpInside)
        appleButton.addTarget(self, action: #selector(appleSignUpTapped), for: .touchUpInside)
        
        let loginTap = UITapGestureRecognizer(target: self, action: #selector(loginTapped))
        footerLabel.addGestureRecognizer(loginTap)
    }
    
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Combine Bindings
    
    private func bindViewModel() {
        vm.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                self?.updateLoadingState(isLoading)
            }
            .store(in: &cancellables)
        
        vm.$errorMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] errorMessage in
                self?.updateErrorState(errorMessage)
            }
            .store(in: &cancellables)
        
        vm.$isAuthenticated
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isAuthenticated in
                if isAuthenticated {
                    self?.handleSuccessfulRegistration()
                }
            }
            .store(in: &cancellables)
        
        vm.$password
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updatePasswordStrength()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - UI Updates
    
    private func updateLoadingState(_ isLoading: Bool) {
        signUpButton.isEnabled = !isLoading
        
        if isLoading {
            signUpButton.setTitle("", for: .normal)
            loadingIndicator.startAnimating()
        } else {
            signUpButton.setTitle("Sign Up", for: .normal)
            loadingIndicator.stopAnimating()
        }
        
        fullNameTextField.isEnabled = !isLoading
        emailTextField.isEnabled = !isLoading
        passwordTextField.isEnabled = !isLoading
        googleButton.isEnabled = !isLoading
        appleButton.isEnabled = !isLoading
    }
    
    private func updateErrorState(_ errorMessage: String?) {
        if let error = errorMessage {
            errorLabel.text = error
            errorLabel.isHidden = false
        } else {
            errorLabel.isHidden = true
        }
    }
    
    private func updatePasswordStrength() {
        let strength = vm.passwordStrength
        
        if strength == .none {
            passwordStrengthView.isHidden = true
            passwordStrengthProgress.snp.updateConstraints { make in
                make.width.equalTo(0)
            }
            return
        }
        
        passwordStrengthView.isHidden = false
        passwordStrengthLabel.text = strength.description
        passwordStrengthLabel.textColor = strength.color
        passwordStrengthProgress.backgroundColor = strength.color
        
        let width: CGFloat
        let barWidth = passwordStrengthBar.frame.width
        
        switch strength {
        case .none:
            width = 0
        case .weak:
            width = barWidth * 0.33
        case .medium:
            width = barWidth * 0.66
        case .strong:
            width = barWidth
        }
        
        passwordStrengthProgress.snp.updateConstraints { make in
            make.width.equalTo(width)
        }
        
        UIView.animate(withDuration: 0.3) {
            self.passwordStrengthView.layoutIfNeeded()
        }
    }
    
    private func handleSuccessfulRegistration() {
        onAuthenticated?()
    }
    
    // MARK: - Text Field Actions
    
    @objc private func fullNameChanged() {
        vm.fullName = fullNameTextField.text ?? ""
    }
    
    @objc private func emailChanged() {
        vm.email = emailTextField.text ?? ""
    }
    
    @objc private func passwordChanged() {
        vm.password = passwordTextField.text ?? ""
    }
    
    // MARK: - Actions

    @objc private func togglePasswordVisibility() {
        passwordTextField.isSecureTextEntry.toggle()
        let imageName = passwordTextField.isSecureTextEntry ? "eye" : "eye.slash"
        let config = UIImage.SymbolConfiguration(pointSize: 20)
        visibilityButton.setImage(UIImage(systemName: imageName, withConfiguration: config), for: .normal)
    }
    
    @objc private func signUpTapped() {
        Task {
            await vm.signUp()
        }
    }
    
    @objc private func googleSignUpTapped() {
        Task {
            await vm.signInWithGoogle(presentingViewController: self)
        }
    }
    
    @objc private func appleSignUpTapped() {
        Task {
            await vm.signInWithApple()
        }
    }
    
    @objc private func loginTapped() {
        onLoginRequested?()
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
}

// MARK: - UITextFieldDelegate

extension RegisterVC: UITextFieldDelegate {
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
            emailTextField.becomeFirstResponder()
        } else if textField.tag == 2 {
            passwordTextField.becomeFirstResponder()
        } else if textField.tag == 3 {
            textField.resignFirstResponder()
            signUpTapped()
        }
        return true
    }
}
