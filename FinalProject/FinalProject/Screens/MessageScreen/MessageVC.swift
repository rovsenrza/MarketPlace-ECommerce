import Combine
import SnapKit
import UIKit

final class MessageVC: UIViewController {
    private let vm: MessageVM
    private var cancellables = Set<AnyCancellable>()

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.register(MessageCell.self, forCellReuseIdentifier: MessageCell.reuseIdentifier)
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.keyboardDismissMode = .interactive
        tableView.dataSource = self
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableView.automaticDimension
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    private let inputContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "SurfaceElevated") ?? .secondarySystemBackground
        view.layer.borderColor = (UIColor(named: "Divider") ?? UIColor.systemGray4).cgColor
        view.layer.borderWidth = 1
        return view
    }()

    private let sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "arrow.up"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = UIColor(named: "PrimaryColorSet") ?? .systemBlue
        button.layer.cornerRadius = 18
        return button
    }()

    private let messageField: UITextField = {
        let field = UITextField()
        field.placeholder = "Message"
        field.backgroundColor = UIColor(named: "Surface") ?? .systemBackground
        field.layer.cornerRadius = 18
        field.layer.borderColor = (UIColor(named: "Divider") ?? UIColor.systemGray4).cgColor
        field.layer.borderWidth = 1
        field.setLeftPadding(12)
        field.setRightPadding(12)
        return field
    }()

    private var inputBottomConstraint: Constraint?

    init(vm: MessageVM) {
        self.vm = vm
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

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        vm.stop()
    }

    func setupUI() {
        view.backgroundColor = UIColor(named: "Background") ?? .systemBackground
        navigationController?.navigationBar.prefersLargeTitles = false
        configureTitleView()

        if presentingViewController != nil, navigationController?.viewControllers.first == self {
            navigationItem.leftBarButtonItem = UIBarButtonItem(
                image: UIImage(systemName: "chevron.left"),
                style: .plain,
                target: self,
                action: #selector(closeTapped)
            )
        }

        addSubviews()
        setupConstraints()
        sendButton.addTarget(self, action: #selector(sendTapped), for: .touchUpInside)
        bindViewModel()
        setupKeyboardObservers()
        vm.start()
    }

    func addSubviews() {
        view.addSubview(tableView)
        view.addSubview(inputContainer)
        [messageField, sendButton].forEach { inputContainer.addSubview($0) }
    }

    func setupConstraints() {
        inputContainer.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            inputBottomConstraint = make.bottom.equalTo(view.safeAreaLayoutGuide).constraint
        }

        tableView.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalTo(inputContainer.snp.top)
        }

        sendButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.size.equalTo(36)
        }

        messageField.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalTo(sendButton.snp.leading).offset(-12)
            make.top.equalToSuperview().offset(10)
            make.bottom.equalToSuperview().offset(-10)
            make.height.greaterThanOrEqualTo(36)
        }
    }

    private func configureTitleView() {
        let titleLabel = UILabel()
        titleLabel.text = vm.supportName
        titleLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        titleLabel.textColor = UIColor(named: "TextPrimary") ?? .label

        let statusDot = UIView()
        statusDot.backgroundColor = vm.isSupportOnline ? .systemGreen : .systemGray
        statusDot.layer.cornerRadius = 4

        let statusLabel = UILabel()
        statusLabel.text = vm.isSupportOnline ? "Online" : "Offline"
        statusLabel.font = .systemFont(ofSize: 11, weight: .medium)
        statusLabel.textColor = UIColor(named: "TextSecondary") ?? .secondaryLabel

        let statusStack = UIStackView(arrangedSubviews: [statusDot, statusLabel])
        statusStack.axis = .horizontal
        statusStack.alignment = .center
        statusStack.spacing = 6

        let titleStack = UIStackView(arrangedSubviews: [titleLabel, statusStack])
        titleStack.axis = .vertical
        titleStack.alignment = .center
        titleStack.spacing = 2

        statusDot.snp.makeConstraints { make in
            make.size.equalTo(8)
        }

        navigationItem.titleView = titleStack
    }

    private func bindViewModel() {
        vm.$messages
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
                self?.scrollToBottom()
            }
            .store(in: &cancellables)

        vm.$errorMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] message in
                guard let message, let self else { return }

                self.showAlert(title: "Error", message: message)
            }
            .store(in: &cancellables)
    }

    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }

    private func scrollToBottom() {
        guard !vm.messages.isEmpty else { return }

        let indexPath = IndexPath(row: vm.messages.count - 1, section: 0)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }

    @objc private func sendTapped() {
        vm.inputText = messageField.text ?? ""
        vm.sendCurrentMessage()
        messageField.text = ""
    }

    @objc private func closeTapped() {
        dismiss(animated: true)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }

        let height = keyboardFrame.height - view.safeAreaInsets.bottom
        inputBottomConstraint?.update(offset: -height)
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }

    @objc private func keyboardWillHide(notification: NSNotification) {
        inputBottomConstraint?.update(offset: 0)
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }
}

extension MessageVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        vm.messages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MessageCell.reuseIdentifier, for: indexPath) as? MessageCell else {
            return UITableViewCell()
        }

        let message = vm.messages[indexPath.row]
        let isIncoming = message.isFromAdmin
        cell.configure(with: message, isIncoming: isIncoming)
        return cell
    }
}

private extension UITextField {
    func setLeftPadding(_ value: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: value, height: 1))
        leftView = paddingView
        leftViewMode = .always
    }

    func setRightPadding(_ value: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: value, height: 1))
        rightView = paddingView
        rightViewMode = .always
    }
}
