import Combine
import Kingfisher
import SnapKit
import UIKit

final class ProfileVC: UIViewController {
    // MARK: - Properties
    
    private let vm: ProfileVM
    private let onRoute: ((ProfileRoute) -> Void)?
    private let onLogout: (() -> Void)?
    private let imagePicker = UIImagePickerController()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - UI Components
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    private let contentView = UIView()
    
    // MARK: - Profile Header

    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 64
        imageView.backgroundColor = .systemGray5
        imageView.image = UIImage(systemName: "person.circle.fill")
        imageView.tintColor = .systemGray3
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    private let editImageButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 14, weight: .medium)
        button.setImage(UIImage(systemName: "pencil", withConfiguration: config), for: .normal)
        button.backgroundColor = UIColor(named: "PrimaryColorSet") ?? .systemBlue
        button.tintColor = .white
        button.layer.cornerRadius = 16
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.systemBackground.cgColor
        return button
    }()
    
    private let nameLabel: UILabel = {
        let label = TitleLabel(text: "User")
        label.textAlignment = .center
        return label
    }()
    
    private let emailLabel: UILabel = {
        let label = SubtitleLabel(text: "email@example.com")
        label.textAlignment = .center
        return label
    }()
    
    // MARK: - Activity Section

    private let activityHeaderLabel: UILabel = {
        let label = SubtitleLabel(text: "MY ACTIVITY", size: 11, weight: .bold)
        return label
    }()
    
    private let activityContainerView: UIView = {
        let view = CardView()
        return view
    }()
    
    private lazy var myOrdersButton = createMenuButton(
        icon: "bag",
        title: "My Orders",
        showDivider: true
    )
    
    private lazy var wishlistButton = createMenuButton(
        icon: "heart",
        title: "Wishlist",
        showDivider: true
    )
    
    private lazy var paymentsButton = createMenuButton(
        icon: "creditcard",
        title: "Payments",
        showDivider: false
    )
    
    private let preferencesHeaderLabel: UILabel = {
        let label = SubtitleLabel(text: "PREFERENCES", size: 11, weight: .bold)
        return label
    }()
    
    private let preferencesContainerView: UIView = {
        let view = CardView()
        return view
    }()
    
    private lazy var notificationsButton = createMenuButton(
        icon: "bell",
        title: "Notifications",
        showDivider: true
    )
    
    private lazy var shippingButton = createMenuButton(
        icon: "shippingbox",
        title: "Shipping Address",
        showDivider: false
    )
    
    private let supportHeaderLabel: UILabel = {
        let label = SubtitleLabel(text: "SUPPORT", size: 11, weight: .bold)
        return label
    }()
    
    private let supportContainerView: UIView = {
        let view = CardView()
        return view
    }()
    
    private lazy var helpCenterButton = createMenuButton(
        icon: "questionmark.circle",
        title: "Help Center",
        showDivider: true
    )
    
    private lazy var logoutButton: UIButton = {
        let btn = UIButton(type: .system)
        
        let iconView = UIImageView()
        iconView.contentMode = .scaleAspectFit
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        iconView.image = UIImage(systemName: "rectangle.portrait.and.arrow.right", withConfiguration: config)
        iconView.tintColor = .systemRed
        
        let iconContainer = UIView()
        iconContainer.backgroundColor = UIColor.systemRed.withAlphaComponent(0.1)
        iconContainer.layer.cornerRadius = 8
        iconContainer.addSubview(iconView)
        
        iconView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(20)
        }
        
        let label = UILabel()
        label.text = "Logout"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .systemRed
        
        btn.addSubview(iconContainer)
        btn.addSubview(label)
        
        iconContainer.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(40)
        }
        
        label.snp.makeConstraints { make in
            make.leading.equalTo(iconContainer.snp.trailing).offset(16)
            make.centerY.equalToSuperview()
        }
        
        return btn
    }()
    
    private let versionLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "VERSION 2.4.1 (124)"
        lbl.font = .systemFont(ofSize: 10, weight: .medium)
        lbl.textColor = .tertiaryLabel
        lbl.textAlignment = .center
        return lbl
    }()
    
    // MARK: - Lifecycle
    
    init(
        vm: ProfileVM,
        onRoute: ((ProfileRoute) -> Void)? = nil,
        onLogout: (() -> Void)? = nil
    ) {
        self.vm = vm
        self.onRoute = onRoute
        self.onLogout = onLogout
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        vm.fetchUserData()
    }
    
    // MARK: - Setup
    
    func setupUI() {
        view.backgroundColor = UIColor(named: "Background") ?? .systemGroupedBackground
        
        title = "Profile"
        
        let settingsButton = UIBarButtonItem(
            image: UIImage(systemName: "gearshape"),
            style: .plain,
            target: self,
            action: #selector(settingsTapped)
        )
        navigationItem.rightBarButtonItem = settingsButton

        addSubviews()
        setupConstraints()
        setupActions()
        setupImagePicker()
        bindViewModel()
    }
    
    func addSubviews() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        [
            profileImageView,
            editImageButton,
            nameLabel,
            emailLabel,
            activityHeaderLabel,
            activityContainerView,
            preferencesHeaderLabel,
            preferencesContainerView,
            supportHeaderLabel,
            supportContainerView,
            versionLabel
        ].forEach { contentView.addSubview($0) }
        
        for item in [myOrdersButton, wishlistButton, paymentsButton] {
            activityContainerView.addSubview(item)
        }
        
        for item in [notificationsButton, shippingButton] {
            preferencesContainerView.addSubview(item)
        }
        
        for item in [helpCenterButton, logoutButton] {
            supportContainerView.addSubview(item)
        }
    }
    
    func setupConstraints() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        profileImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(32)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(128)
        }
        
        editImageButton.snp.makeConstraints { make in
            make.bottom.equalTo(profileImageView).offset(-4)
            make.trailing.equalTo(profileImageView)
            make.width.height.equalTo(32)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(profileImageView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        emailLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(4)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        activityHeaderLabel.snp.makeConstraints { make in
            make.top.equalTo(emailLabel.snp.bottom).offset(32)
            make.leading.equalToSuperview().offset(32)
        }
        
        activityContainerView.snp.makeConstraints { make in
            make.top.equalTo(activityHeaderLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        myOrdersButton.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(56)
        }
        
        wishlistButton.snp.makeConstraints { make in
            make.top.equalTo(myOrdersButton.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(56)
        }
        
        paymentsButton.snp.makeConstraints { make in
            make.top.equalTo(wishlistButton.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(56)
        }
        
        preferencesHeaderLabel.snp.makeConstraints { make in
            make.top.equalTo(activityContainerView.snp.bottom).offset(24)
            make.leading.equalToSuperview().offset(32)
        }
        
        preferencesContainerView.snp.makeConstraints { make in
            make.top.equalTo(preferencesHeaderLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        notificationsButton.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(56)
        }
        
        shippingButton.snp.makeConstraints { make in
            make.top.equalTo(notificationsButton.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(56)
        }
        
        supportHeaderLabel.snp.makeConstraints { make in
            make.top.equalTo(preferencesContainerView.snp.bottom).offset(24)
            make.leading.equalToSuperview().offset(32)
        }
        
        supportContainerView.snp.makeConstraints { make in
            make.top.equalTo(supportHeaderLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        helpCenterButton.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(56)
        }
        
        logoutButton.snp.makeConstraints { make in
            make.top.equalTo(helpCenterButton.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(56)
        }
        
        versionLabel.snp.makeConstraints { make in
            make.top.equalTo(supportContainerView.snp.bottom).offset(24)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-32)
        }
    }
    
    private func setupActions() {
        let imageTap = UITapGestureRecognizer(target: self, action: #selector(profileImageTapped))
        profileImageView.addGestureRecognizer(imageTap)
        
        editImageButton.addTarget(self, action: #selector(profileImageTapped), for: .touchUpInside)
        
        myOrdersButton.addTarget(self, action: #selector(myOrdersTapped), for: .touchUpInside)
        wishlistButton.addTarget(self, action: #selector(wishlistTapped), for: .touchUpInside)
        paymentsButton.addTarget(self, action: #selector(paymentsTapped), for: .touchUpInside)
        notificationsButton.addTarget(self, action: #selector(notificationsTapped), for: .touchUpInside)
        shippingButton.addTarget(self, action: #selector(shippingTapped), for: .touchUpInside)
        helpCenterButton.addTarget(self, action: #selector(helpCenterTapped), for: .touchUpInside)
        logoutButton.addTarget(self, action: #selector(logoutTapped), for: .touchUpInside)
    }
    
    private func setupImagePicker() {
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
    }
    
    private func bindViewModel() {
        vm.$user
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                guard let self = self, let user = user else { return }
                
                self.nameLabel.text = user.displayName ?? "User"
                self.emailLabel.text = user.email
                
                if let photoURL = user.photoURL, let url = URL(string: photoURL) {
                    self.profileImageView.kf.setImage(with: url, placeholder: UIImage(systemName: "person.circle.fill"))
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Helper Methods
    
    private func createMenuButton(icon: String, title: String, showDivider: Bool) -> UIButton {
        let btn = UIButton(type: .system)
        
        let iconView = UIImageView()
        iconView.contentMode = .scaleAspectFit
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        iconView.image = UIImage(systemName: icon, withConfiguration: config)
        iconView.tintColor = UIColor(named: "PrimaryColorSet") ?? .systemBlue
        
        let iconContainer = UIView()
        iconContainer.backgroundColor = (UIColor(named: "PrimaryColorSet") ?? .systemBlue).withAlphaComponent(0.1)
        iconContainer.layer.cornerRadius = 8
        iconContainer.addSubview(iconView)
        
        iconView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(20)
        }
        
        let label = UILabel()
        label.text = title
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .label
        
        btn.addSubview(iconContainer)
        btn.addSubview(label)
        
        iconContainer.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(40)
        }
        
        label.snp.makeConstraints { make in
            make.leading.equalTo(iconContainer.snp.trailing).offset(16)
            make.centerY.equalToSuperview()
        }
        
        if showDivider {
            let divider = UIView()
            divider.backgroundColor = .separator
            btn.addSubview(divider)
            
            divider.snp.makeConstraints { make in
                make.leading.equalToSuperview().offset(72)
                make.trailing.equalToSuperview()
                make.bottom.equalToSuperview()
                make.height.equalTo(0.5)
            }
        }
        
        return btn
    }
    
    // MARK: - Actions
    
    @objc private func settingsTapped() {
        onRoute?(.settings)
    }
    
    @objc private func profileImageTapped() {
        let hasPhoto = (vm.user?.photoURL?.isEmpty == false)

        var actions: [(String, UIAlertAction.Style, () -> Void)] = [
            ("Choose from Gallery", .default, { [weak self] in self?.openGallery() }),
            ("Take Photo", .default, { [weak self] in self?.openCamera() })
        ]

        if hasPhoto {
            actions.append(("Remove Photo", .destructive, { [weak self] in
                self?.removeProfilePhoto()
            }))
        }

        showActionSheet(
            title: "Change Profile Picture",
            sourceView: profileImageView,
            actions: actions
        )
    }

    private func removeProfilePhoto() {
        let loadingAlert = UIAlertController(title: "Removing...", message: "Please wait", preferredStyle: .alert)
        present(loadingAlert, animated: true)

        Task { @MainActor in
            do {
                try await vm.removeProfileImage()

                loadingAlert.dismiss(animated: true) {
                    self.profileImageView.image = UIImage(systemName: "person.circle.fill")
                    self.profileImageView.tintColor = .systemGray3
                    self.showAlert(title: "Success", message: "Profile image removed")
                }
            } catch {
                loadingAlert.dismiss(animated: true) {
                    self.showAlert(title: "Error", message: error.localizedDescription)
                }
            }
        }
    }
    
    private func openGallery() {
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true)
    }
    
    private func openCamera() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            showAlert(title: "Camera Not Available", message: "This device doesn't have a camera.")
            return
        }

        imagePicker.sourceType = .camera
        present(imagePicker, animated: true)
    }
    
    @objc private func myOrdersTapped() {
        onRoute?(.orders)
    }
    
    @objc private func wishlistTapped() {
        onRoute?(.wishlist)
    }
    
    @objc private func paymentsTapped() {
        onRoute?(.payments)
    }
    
    @objc private func notificationsTapped() {
        onRoute?(.notifications)
    }
    
    @objc private func shippingTapped() {
        onRoute?(.shippingAddress)
    }
    
    @objc private func helpCenterTapped() {
        onRoute?(.helpCenter)
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
        do {
            try vm.signOut()
        } catch {
            showAlert(title: "Error", message: error.localizedDescription)
            return
        }

        onLogout?()
    }
}

// MARK: - UIImagePickerControllerDelegate

extension ProfileVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        let selectedImage: UIImage?
        if let editedImage = info[.editedImage] as? UIImage {
            selectedImage = editedImage
        } else if let originalImage = info[.originalImage] as? UIImage {
            selectedImage = originalImage
        } else {
            picker.dismiss(animated: true)
            return
        }
        
        guard let image = selectedImage else {
            picker.dismiss(animated: true)
            return
        }
        
        picker.dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            
             let loadingAlert = UIAlertController(title: "Uploading...", message: "Please wait", preferredStyle: .alert)
            self.present(loadingAlert, animated: true)
            
            Task { @MainActor in
                do {
                    let urlString = try await self.vm.updateProfileImage(image)
                    
                    loadingAlert.dismiss(animated: true) {
                        if let url = URL(string: urlString) {
                            self.profileImageView.kf.setImage(
                                with: url,
                                placeholder: UIImage(systemName: "person.circle.fill"),
                                options: [.forceRefresh]
                            )
                        }
                        self.showAlert(title: "Success", message: "Profile image updated successfully")
                    }
                } catch {
                    loadingAlert.dismiss(animated: true) {
                        self.showAlert(title: "Error", message: error.localizedDescription)
                    }
                }
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
