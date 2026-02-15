import Combine
import SnapKit
import UIKit

final class CheckoutVC: UIViewController {
    private let vm: CheckoutVM
    private let cartVM: CartVM
    private let onRoute: ((CheckoutRoute) -> Void)?
    private var cancellables = Set<AnyCancellable>()

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()

    private let contentView: UIView = {
        let view = UIView()
        return view
    }()

    private let shippingHeaderLabel = SectionHeaderLabel(text: "Shipping Address")

    private let shippingCard: UIView = {
        let view = InfoCard()
        return view
    }()

    private let shippingIcon: UIImageView = {
        let imageView = UIImageView()
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)
        imageView.image = UIImage(systemName: "house.fill", withConfiguration: config)
        imageView.tintColor = UIColor(named: "PrimaryColorSet") ?? .systemBlue
        return imageView
    }()

    private let shippingTitleLabel: UILabel = {
        let label = TitleLabel(size: 16)
        return label
    }()

    private let shippingDetailLabel: UILabel = {
        let label = SubtitleLabel(lines: 0)
        return label
    }()

    private let shippingChangeButton: UIButton = {
        let button = ChangeButton()
        return button
    }()

    private let addShippingButton = PrimaryButton(title: "Add Shipping Address", style: .filled)

    private let deliveryHeaderLabel = SectionHeaderLabel(text: "Delivery Method")
    private let deliveryScroll: UIScrollView = {
        let scrollView = UIScrollView()
        return scrollView
    }()

    private let deliveryStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 12
        stack.alignment = .center
        return stack
    }()

    private let paymentHeaderLabel = SectionHeaderLabel(text: "Payment Method")

    private let paymentCard: UIView = {
        let view = InfoCard()
        return view
    }()

    private let paymentIconContainer: UIView = {
        let view = IconContainer()
        return view
    }()

    private let paymentIcon: UIImageView = {
        let imageView = UIImageView()
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)
        imageView.image = UIImage(systemName: "creditcard", withConfiguration: config)
        imageView.tintColor = UIColor(named: "PrimaryColorSet") ?? .systemBlue
        return imageView
    }()

    private let paymentTitleLabel: UILabel = {
        let label = TitleLabel(size: 16)
        return label
    }()

    private let paymentSubtitleLabel: UILabel = {
        let label = SubtitleLabel(size: 12)
        return label
    }()

    private let paymentChangeButton: UIButton = {
        let button = ChangeButton()
        return button
    }()

    private let addPaymentButton = PrimaryButton(title: "Add Payment Method", style: .filled)

    private let summaryHeaderLabel = SectionHeaderLabel(text: "Order Summary")

    private let summaryCard: UIView = {
        let view = InfoCard()
        return view
    }()

    private let subtotalRow = SummaryRowView(title: "Subtotal")
    private let shippingRow = SummaryRowView(title: "Shipping")
    private let taxRow = SummaryRowView(title: "Estimated Tax")
    private let totalRow = SummaryRowView(title: "Total", isBold: true)

    private let summaryDivider = DividerView(color: UIColor(named: "Divider") ?? .separator, height: 1)

    private let bottomBar: UIView = {
        let view = UIView()
        return view
    }()

    private let totalAmountLabel: UILabel = {
        let label = SubtitleLabel(text: "Total Amount", size: 10, weight: .bold)
        return label
    }()

    private let totalAmountValueLabel: UILabel = {
        let label = TitleLabel(size: 22)
        return label
    }()

    private let placeOrderButton = PrimaryButton(title: "Place Order", style: .filled)

    private let loadingView: LoadingView = {
        let view = LoadingView(message: "Preparing checkout...")
        view.isHidden = true
        return view
    }()

    init(
        vm: CheckoutVM,
        cartVM: CartVM,
        onRoute: ((CheckoutRoute) -> Void)? = nil
    ) {
        self.vm = vm
        self.cartVM = cartVM
        self.onRoute = onRoute
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
        vm.refreshDefaults()
    }

    func setupUI() {
        view.backgroundColor = UIColor(named: "Background") ?? .systemBackground
        title = "Checkout"
        navigationController?.navigationBar.prefersLargeTitles = false

        deliveryScroll.showsHorizontalScrollIndicator = false

        addSubviews()
        setupConstraints()
        configureDeliveryButtons()
        setupActions()
        bindViewModel()
        vm.updateTotals(cartItems: cartVM.cartItems)
        updateSummary()
        updateShipping(vm.shippingAddress)
        updatePayment(vm.paymentMethod)
    }

    func addSubviews() {
        view.addSubview(scrollView)
        view.addSubview(bottomBar)
        view.addSubview(loadingView)
        scrollView.addSubview(contentView)

        [
            shippingHeaderLabel,
            shippingCard,
            addShippingButton,
            deliveryHeaderLabel,
            deliveryScroll,
            paymentHeaderLabel,
            paymentCard,
            addPaymentButton,
            summaryHeaderLabel,
            summaryCard
        ].forEach { contentView.addSubview($0) }

        [shippingIcon, shippingTitleLabel, shippingDetailLabel, shippingChangeButton].forEach { shippingCard.addSubview($0) }
        [paymentIconContainer, paymentTitleLabel, paymentSubtitleLabel, paymentChangeButton].forEach { paymentCard.addSubview($0) }
        paymentIconContainer.addSubview(paymentIcon)
        deliveryScroll.addSubview(deliveryStack)

        [
            subtotalRow,
            shippingRow,
            taxRow,
            summaryDivider,
            totalRow
        ].forEach { summaryCard.addSubview($0) }

        bottomBar.addSubview(totalAmountLabel)
        bottomBar.addSubview(totalAmountValueLabel)
        bottomBar.addSubview(placeOrderButton)
    }

    func setupConstraints() {
        scrollView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(bottomBar.snp.top)
        }

        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }

        shippingHeaderLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        shippingCard.snp.makeConstraints { make in
            make.top.equalTo(shippingHeaderLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        shippingIcon.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.equalToSuperview().offset(16)
            make.width.height.equalTo(20)
        }

        shippingTitleLabel.snp.makeConstraints { make in
            make.leading.equalTo(shippingIcon.snp.trailing).offset(8)
            make.top.equalToSuperview().offset(14)
            make.trailing.equalTo(shippingChangeButton.snp.leading).offset(-8)
        }

        shippingDetailLabel.snp.makeConstraints { make in
            make.leading.equalTo(shippingTitleLabel)
            make.top.equalTo(shippingTitleLabel.snp.bottom).offset(6)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-16)
        }

        shippingChangeButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.top.equalToSuperview().offset(12)
        }

        addShippingButton.snp.makeConstraints { make in
            make.top.equalTo(shippingHeaderLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(52)
        }

        deliveryHeaderLabel.snp.makeConstraints { make in
            make.top.greaterThanOrEqualTo(shippingCard.snp.bottom).offset(24)
            make.top.greaterThanOrEqualTo(addShippingButton.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        deliveryScroll.snp.makeConstraints { make in
            make.top.equalTo(deliveryHeaderLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(50)
        }

        deliveryStack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16))
            make.height.equalToSuperview()
        }

        paymentHeaderLabel.snp.makeConstraints { make in
            make.top.equalTo(deliveryScroll.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        paymentCard.snp.makeConstraints { make in
            make.top.equalTo(paymentHeaderLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        paymentIconContainer.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.equalTo(48)
            make.height.equalTo(32)
        }

        paymentIcon.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(20)
        }

        paymentTitleLabel.snp.makeConstraints { make in
            make.leading.equalTo(paymentIconContainer.snp.trailing).offset(12)
            make.top.equalToSuperview().offset(12)
            make.trailing.equalTo(paymentChangeButton.snp.leading).offset(-8)
        }

        paymentSubtitleLabel.snp.makeConstraints { make in
            make.leading.equalTo(paymentTitleLabel)
            make.top.equalTo(paymentTitleLabel.snp.bottom).offset(4)
            make.bottom.equalToSuperview().offset(-12)
            make.trailing.equalTo(paymentTitleLabel)
        }

        paymentChangeButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.top.equalToSuperview().offset(12)
        }

        addPaymentButton.snp.makeConstraints { make in
            make.top.equalTo(paymentHeaderLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(52)
        }

        summaryHeaderLabel.snp.makeConstraints { make in
            make.top.greaterThanOrEqualTo(paymentCard.snp.bottom).offset(24)
            make.top.greaterThanOrEqualTo(addPaymentButton.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        summaryCard.snp.makeConstraints { make in
            make.top.equalTo(summaryHeaderLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-24)
        }

        subtotalRow.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(20)
        }

        shippingRow.snp.makeConstraints { make in
            make.top.equalTo(subtotalRow.snp.bottom).offset(12)
            make.leading.trailing.equalTo(subtotalRow)
            make.height.equalTo(20)
        }

        taxRow.snp.makeConstraints { make in
            make.top.equalTo(shippingRow.snp.bottom).offset(12)
            make.leading.trailing.equalTo(subtotalRow)
            make.height.equalTo(20)
        }

        summaryDivider.snp.makeConstraints { make in
            make.top.equalTo(taxRow.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        totalRow.snp.makeConstraints { make in
            make.top.equalTo(summaryDivider.snp.bottom).offset(16)
            make.leading.trailing.equalTo(subtotalRow)
            make.height.equalTo(24)
            make.bottom.equalToSuperview().offset(-16)
        }

        bottomBar.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
        }

        totalAmountLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.leading.equalToSuperview().offset(24)
        }

        totalAmountValueLabel.snp.makeConstraints { make in
            make.top.equalTo(totalAmountLabel.snp.bottom).offset(4)
            make.leading.equalTo(totalAmountLabel)
        }

        placeOrderButton.snp.makeConstraints { make in
            make.centerY.equalTo(totalAmountValueLabel)
            make.trailing.equalToSuperview().offset(-24)
            make.height.equalTo(52)
            make.width.equalTo(160)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-12)
        }

        loadingView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func configureDeliveryButtons() {
        deliveryStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        for option in vm.deliveryOptions {
            let button = UIButton(type: .system)
            button.setTitle(option.subtitle, for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 12, weight: .semibold)
            button.layer.cornerRadius = 12
            button.layer.borderWidth = 1
            button.layer.borderColor = (UIColor(named: "Divider") ?? UIColor.systemGray4).cgColor
            button.setTitleColor(UIColor(named: "TextPrimary") ?? .label, for: .normal)
            button.backgroundColor = UIColor(named: "Surface") ?? .systemBackground
            button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
            button.addAction(UIAction { [weak self] _ in
                guard let self = self else { return }

                self.vm.setDelivery(option, cartItems: self.cartVM.cartItems)
                self.updateDeliverySelection()
                self.updateSummary()
            }, for: .touchUpInside)
            deliveryStack.addArrangedSubview(button)
        }
        updateDeliverySelection()
    }

    private func updateDeliverySelection() {
        for (index, view) in deliveryStack.arrangedSubviews.enumerated() {
            guard let button = view as? UIButton else { continue }

            let option = vm.deliveryOptions[index]
            let isSelected = option == vm.selectedDelivery
            button.backgroundColor = isSelected ? (UIColor(named: "PrimaryColorSet") ?? .systemBlue) : (UIColor(named: "Surface") ?? .systemBackground)
            button.setTitleColor(isSelected ? .white : (UIColor(named: "TextPrimary") ?? .label), for: .normal)
            button.layer.borderColor = isSelected ? (UIColor(named: "PrimaryColorSet") ?? .systemBlue).cgColor : (UIColor(named: "Divider") ?? UIColor.systemGray4).cgColor
        }
    }

    private func bindViewModel() {
        cartVM.$cartItems
            .receive(on: DispatchQueue.main)
            .sink { [weak self] items in
                self?.vm.updateTotals(cartItems: items)
                self?.updateSummary()
            }
            .store(in: &cancellables)

        vm.$shippingAddress
            .receive(on: DispatchQueue.main)
            .sink { [weak self] address in
                self?.updateShipping(address)
            }
            .store(in: &cancellables)

        vm.$paymentMethod
            .receive(on: DispatchQueue.main)
            .sink { [weak self] payment in
                self?.updatePayment(payment)
            }
            .store(in: &cancellables)

        vm.$total
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateSummary()
            }
            .store(in: &cancellables)

        vm.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                self?.loadingView.isHidden = !isLoading
            }
            .store(in: &cancellables)

        vm.$errorMessage
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] message in
                self?.showAlert(title: "Error", message: message)
            }
            .store(in: &cancellables)
    }

    private func updateShipping(_ address: ShippingAddress?) {
        let hasAddress = address != nil
        shippingCard.isHidden = !hasAddress
        addShippingButton.isHidden = hasAddress

        if let address = address {
            shippingTitleLabel.text = address.name
            shippingDetailLabel.text = "\(address.phoneNumber)\n\(address.streetAddress), \(address.city)\n\(address.state), \(address.zipCode)"
        }
    }

    private func updatePayment(_ payment: PaymentMethod?) {
        let hasPayment = payment != nil
        paymentCard.isHidden = !hasPayment
        addPaymentButton.isHidden = hasPayment

        if let payment = payment {
            paymentTitleLabel.text = "\(maskCardNumber(payment.cardNumber))"
            paymentSubtitleLabel.text = "Expires \(payment.expiryDate)"
        }
    }

    private func updateSummary() {
        subtotalRow.valueLabel.text = currency(vm.subtotal)
        shippingRow.valueLabel.text = currency(vm.shippingFee)
        taxRow.valueLabel.text = currency(vm.tax)
        totalRow.valueLabel.text = currency(vm.total)
        totalAmountValueLabel.text = currency(vm.total)
    }

    private func currency(_ value: Double) -> String {
        String(format: "$%.2f", value)
    }

    private func maskCardNumber(_ number: String) -> String {
        let digits = number.filter { $0.isNumber }
        let trimmed = String(digits.prefix(16))
        let last = trimmed.count > 4 ? String(trimmed.suffix(4)) : ""
        return "Visa •••• \(last)"
    }

    private func setupActions() {
        addShippingButton.addTarget(self, action: #selector(addShippingTapped), for: .touchUpInside)
        addPaymentButton.addTarget(self, action: #selector(addPaymentTapped), for: .touchUpInside)
        shippingChangeButton.addTarget(self, action: #selector(changeShippingTapped), for: .touchUpInside)
        paymentChangeButton.addTarget(self, action: #selector(changePaymentTapped), for: .touchUpInside)
        placeOrderButton.addTarget(self, action: #selector(placeOrderTapped), for: .touchUpInside)
    }

    @objc private func addShippingTapped() {
        onRoute?(.addShipping(address: nil))
    }

    @objc private func addPaymentTapped() {
        onRoute?(.addPayment)
    }

    @objc private func changeShippingTapped() {
        onRoute?(.selectShipping)
    }

    @objc private func changePaymentTapped() {
        onRoute?(.selectPayment)
    }

    @objc private func placeOrderTapped() {
        placeOrderButton.isEnabled = false
        Task { @MainActor in
            do {
                let order = try await vm.placeOrder(cartItems: cartVM.cartItems)
                onRoute?(.orderSuccess(orderNumber: order.orderNumber))
            } catch {
                showAlert(title: "Error", message: error.localizedDescription)
                placeOrderButton.isEnabled = true
            }
        }
    }
}
