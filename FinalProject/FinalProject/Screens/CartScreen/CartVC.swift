import Combine
import SnapKit
import UIKit

final class CartVC: UIViewController {
    // MARK: - Properties
    
    let vm: CartVM
    private let pricingCalculator: PricingCalculatorProtocol
    private let onRoute: ((CartRoute) -> Void)?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - UI Components
    
    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.backgroundColor = .clear
        tv.separatorStyle = .none
        tv.showsVerticalScrollIndicator = false
        tv.delegate = self
        tv.dataSource = self
        tv.register(CartItemCell.self, forCellReuseIdentifier: CartItemCell.reuseIdentifier)
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    private let emptyStateView: UIView = {
        let view = UIView()
        view.isHidden = true
        return view
    }()
    
    private let emptyIconContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 96
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.05
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 8
        return view
    }()
    
    private let emptyIconBackground: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "PrimaryColorSet")?.withAlphaComponent(0.05) ?? .systemBlue.withAlphaComponent(0.05)
        view.layer.cornerRadius = 96
        return view
    }()
    
    private let emptyIconImageView: UIImageView = {
        let iv = UIImageView()
        let config = UIImage.SymbolConfiguration(pointSize: 96, weight: .thin)
        iv.image = UIImage(systemName: "bag", withConfiguration: config)
        iv.tintColor = UIColor(named: "PrimaryColorSet") ?? .systemBlue
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    private let emptyBadge: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "PrimaryColorSet")?.withAlphaComponent(0.1) ?? .systemBlue.withAlphaComponent(0.1)
        view.layer.cornerRadius = 12
        return view
    }()
    
    private let emptyBadgeIcon: UIImageView = {
        let iv = UIImageView()
        let config = UIImage.SymbolConfiguration(pointSize: 12, weight: .bold)
        iv.image = UIImage(systemName: "plus", withConfiguration: config)
        iv.tintColor = UIColor(named: "PrimaryColorSet") ?? .systemBlue
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    private let emptyTitleLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Your Cart is Empty"
        lbl.font = .systemFont(ofSize: 24, weight: .bold)
        lbl.textAlignment = .center
        lbl.textColor = .label
        return lbl
    }()
    
    private let emptySubtitleLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Looks like you haven't added anything to your cart yet."
        lbl.font = .systemFont(ofSize: 16, weight: .regular)
        lbl.textAlignment = .center
        lbl.textColor = .secondaryLabel
        lbl.numberOfLines = 0
        return lbl
    }()
    
    private let startShoppingButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Start Shopping", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        btn.backgroundColor = UIColor(named: "PrimaryColorSet") ?? .systemBlue
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 12
        btn.layer.shadowColor = (UIColor(named: "PrimaryColorSet") ?? .systemBlue).cgColor
        btn.layer.shadowOpacity = 0.2
        btn.layer.shadowOffset = CGSize(width: 0, height: 8)
        btn.layer.shadowRadius = 16
        return btn
    }()
    
    private let shippingProgressContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 16
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.05
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 8
        view.isHidden = true
        return view
    }()
    
    private let shippingLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 14, weight: .medium)
        lbl.textColor = .label
        return lbl
    }()
    
    private let shippingIcon: UIImageView = {
        let iv = UIImageView()
        let config = UIImage.SymbolConfiguration(pointSize: 20)
        iv.image = UIImage(systemName: "shippingbox", withConfiguration: config)
        iv.tintColor = UIColor(named: "Accent") ?? .systemOrange
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    private let progressBarBackground: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray5
        view.layer.cornerRadius = 3
        view.clipsToBounds = true
        return view
    }()
    
    private let progressBarFill: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "Accent") ?? .systemOrange
        view.layer.cornerRadius = 3
        return view
    }()
    
    private let footerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: -4)
        view.layer.shadowRadius = 20
        view.isHidden = true
        return view
    }()
    
    private let subtotalLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Subtotal"
        lbl.font = .systemFont(ofSize: 14, weight: .medium)
        lbl.textColor = .secondaryLabel
        return lbl
    }()
    
    private let subtotalValueLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "$0.00"
        lbl.font = .systemFont(ofSize: 14, weight: .medium)
        lbl.textColor = .secondaryLabel
        lbl.textAlignment = .right
        return lbl
    }()
    
    private let shippingFeeLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Shipping"
        lbl.font = .systemFont(ofSize: 14, weight: .medium)
        lbl.textColor = .secondaryLabel
        return lbl
    }()
    
    private let shippingFeeValueLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "$0.00"
        lbl.font = .systemFont(ofSize: 14, weight: .medium)
        lbl.textColor = .systemGreen
        lbl.textAlignment = .right
        return lbl
    }()
    
    private let taxLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Estimated Tax"
        lbl.font = .systemFont(ofSize: 14, weight: .medium)
        lbl.textColor = .secondaryLabel
        return lbl
    }()
    
    private let taxValueLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "$0.00"
        lbl.font = .systemFont(ofSize: 14, weight: .medium)
        lbl.textColor = .secondaryLabel
        lbl.textAlignment = .right
        return lbl
    }()
    
    private let dividerView: UIView = {
        let view = UIView()
        view.backgroundColor = .separator
        return view
    }()
    
    private let totalLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Total"
        lbl.font = .systemFont(ofSize: 18, weight: .bold)
        lbl.textColor = .label
        return lbl
    }()
    
    private let totalValueLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "$0.00"
        lbl.font = .systemFont(ofSize: 24, weight: .black)
        lbl.textColor = UIColor(named: "PrimaryColorSet") ?? .systemBlue
        lbl.textAlignment = .right
        return lbl
    }()
    
    private let checkoutButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Checkout", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 17, weight: .bold)
        btn.backgroundColor = UIColor(named: "PrimaryColorSet") ?? .systemBlue
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 16
        return btn
    }()
    
    private let checkoutArrow: UIImageView = {
        let iv = UIImageView()
        let config = UIImage.SymbolConfiguration(pointSize: 20)
        iv.image = UIImage(systemName: "arrow.forward", withConfiguration: config)
        iv.tintColor = .white
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    // MARK: - Lifecycle
    
    init(
        vm: CartVM,
        pricingCalculator: PricingCalculatorProtocol,
        onRoute: ((CartRoute) -> Void)? = nil
    ) {
        self.vm = vm
        self.pricingCalculator = pricingCalculator
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
    
    // MARK: - Setup
    
    func setupUI() {
        view.backgroundColor = UIColor(named: "Background") ?? .systemGroupedBackground
        title = "Shopping Cart"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Clear All",
            style: .plain,
            target: self,
            action: #selector(clearAllTapped)
        )
        addSubviews()
        setupConstraints()
        setupActions()
        bindViewModel()
        vm.fetchCartItems()
    }
    
    func addSubviews() {
        view.addSubview(shippingProgressContainer)
        view.addSubview(tableView)
        view.addSubview(emptyStateView)
        view.addSubview(footerView)

        emptyStateView.addSubview(emptyIconBackground)
        emptyStateView.addSubview(emptyIconContainer)
        emptyIconContainer.addSubview(emptyIconImageView)
        emptyIconContainer.addSubview(emptyBadge)
        emptyBadge.addSubview(emptyBadgeIcon)
        emptyStateView.addSubview(emptyTitleLabel)
        emptyStateView.addSubview(emptySubtitleLabel)
        emptyStateView.addSubview(startShoppingButton)

        shippingProgressContainer.addSubview(shippingLabel)
        shippingProgressContainer.addSubview(shippingIcon)
        shippingProgressContainer.addSubview(progressBarBackground)
        progressBarBackground.addSubview(progressBarFill)

        footerView.addSubview(subtotalLabel)
        footerView.addSubview(subtotalValueLabel)
        footerView.addSubview(shippingFeeLabel)
        footerView.addSubview(shippingFeeValueLabel)
        footerView.addSubview(taxLabel)
        footerView.addSubview(taxValueLabel)
        footerView.addSubview(dividerView)
        footerView.addSubview(totalLabel)
        footerView.addSubview(totalValueLabel)
        footerView.addSubview(checkoutButton)
        checkoutButton.addSubview(checkoutArrow)
    }

    private func setupActions() {
        startShoppingButton.addTarget(self, action: #selector(startShoppingTapped), for: .touchUpInside)
        checkoutButton.addTarget(self, action: #selector(checkoutTapped), for: .touchUpInside)
    }
    
    func setupConstraints() {
        shippingProgressContainer.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(72)
        }
        
        shippingLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(16)
            make.trailing.equalTo(shippingIcon.snp.leading).offset(-8)
        }
        
        shippingIcon.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalTo(shippingLabel)
            make.width.height.equalTo(24)
        }
        
        progressBarBackground.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.top.equalTo(shippingLabel.snp.bottom).offset(8)
            make.height.equalTo(6)
        }
        
        progressBarFill.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.8)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(shippingProgressContainer.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(footerView.snp.top)
        }
        
        emptyStateView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.equalToSuperview().offset(32)
            make.trailing.equalToSuperview().offset(-32)
        }
        
        emptyIconBackground.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview()
            make.width.height.equalTo(192)
        }
        
        emptyIconContainer.snp.makeConstraints { make in
            make.center.equalTo(emptyIconBackground)
            make.width.height.equalTo(192)
        }
        
        emptyIconImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(96)
        }
        
        emptyBadge.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(32)
            make.trailing.equalToSuperview().offset(-32)
            make.width.height.equalTo(24)
        }
        
        emptyBadgeIcon.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(12)
        }
        
        emptyTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(emptyIconContainer.snp.bottom).offset(40)
            make.leading.trailing.equalToSuperview()
        }
        
        emptySubtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(emptyTitleLabel.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview()
        }
        
        startShoppingButton.snp.makeConstraints { make in
            make.top.equalTo(emptySubtitleLabel.snp.bottom).offset(40)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(54)
            make.bottom.equalToSuperview()
        }
        
        footerView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(280)
        }
        
        subtotalLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(24)
            make.top.equalToSuperview().offset(24)
        }
        
        subtotalValueLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-24)
            make.centerY.equalTo(subtotalLabel)
        }
        
        shippingFeeLabel.snp.makeConstraints { make in
            make.leading.equalTo(subtotalLabel)
            make.top.equalTo(subtotalLabel.snp.bottom).offset(12)
        }
        
        shippingFeeValueLabel.snp.makeConstraints { make in
            make.trailing.equalTo(subtotalValueLabel)
            make.centerY.equalTo(shippingFeeLabel)
        }
        
        taxLabel.snp.makeConstraints { make in
            make.leading.equalTo(subtotalLabel)
            make.top.equalTo(shippingFeeLabel.snp.bottom).offset(12)
        }
        
        taxValueLabel.snp.makeConstraints { make in
            make.trailing.equalTo(subtotalValueLabel)
            make.centerY.equalTo(taxLabel)
        }
        
        dividerView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().offset(-24)
            make.top.equalTo(taxLabel.snp.bottom).offset(16)
            make.height.equalTo(1)
        }
        
        totalLabel.snp.makeConstraints { make in
            make.leading.equalTo(subtotalLabel)
            make.top.equalTo(dividerView.snp.bottom).offset(16)
        }
        
        totalValueLabel.snp.makeConstraints { make in
            make.trailing.equalTo(subtotalValueLabel)
            make.centerY.equalTo(totalLabel)
        }
        
        checkoutButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().offset(-24)
            make.top.equalTo(totalLabel.snp.bottom).offset(24)
            make.height.equalTo(56)
        }
        
        checkoutArrow.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-20)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(20)
        }
    }
    
    private func bindViewModel() {
        vm.$cartItems
            .receive(on: DispatchQueue.main)
            .sink { [weak self] items in
                self?.updateUI(isEmpty: items.isEmpty)
                self?.tableView.reloadData()
                self?.updatePricing()
            }
            .store(in: &cancellables)
    }
    
    private func updateUI(isEmpty: Bool) {
        emptyStateView.isHidden = !isEmpty
        shippingProgressContainer.isHidden = isEmpty
        footerView.isHidden = isEmpty
        navigationItem.rightBarButtonItem?.isEnabled = !isEmpty
    }
    
    private func updatePricing() {
        let summary = pricingCalculator.makeSummary(
            cartItems: vm.cartItems,
            deliveryFee: pricingCalculator.standardDeliveryFee,
            applyFreeShippingThreshold: true
        )
        let subtotal = summary.subtotal
        let shipping = summary.shippingFee
        let tax = summary.tax
        let total = summary.total
        
        subtotalValueLabel.text = String(format: "$%.2f", subtotal)
        taxValueLabel.text = String(format: "$%.2f", tax)
        totalValueLabel.text = String(format: "$%.2f", total)
        
        if shipping == 0 {
            shippingFeeValueLabel.text = "Free"
            shippingFeeValueLabel.textColor = .systemGreen
        } else {
            shippingFeeValueLabel.text = String(format: "$%.2f", shipping)
            shippingFeeValueLabel.textColor = .secondaryLabel
        }
        
        updateShippingProgress(subtotal: subtotal)
    }
    
    private func updateShippingProgress(subtotal: Double) {
        let progressState = pricingCalculator.makeFreeShippingProgress(subtotal: subtotal)
        let remaining = progressState.remaining
        let progress = progressState.progress
        
        if remaining > 0 {
            let attributedString = NSMutableAttributedString(string: "Free shipping in ")
            let priceString = NSAttributedString(
                string: String(format: "$%.2f", remaining),
                attributes: [
                    .foregroundColor: UIColor(named: "PrimaryColorSet") ?? UIColor.systemBlue,
                    .font: UIFont.systemFont(ofSize: 14, weight: .bold)
                ]
            )
            attributedString.append(priceString)
            shippingLabel.attributedText = attributedString
            shippingLabel.textColor = .label
        } else {
            shippingLabel.text = "You've unlocked free shipping!"
            shippingLabel.textColor = .systemGreen
        }
        
        progressBarFill.snp.remakeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(progress)
        }
        
        UIView.animate(withDuration: 0.3) {
            self.progressBarBackground.layoutIfNeeded()
        }
    }
    
    // MARK: - Actions
    
    @objc private func clearAllTapped() {
        let alert = UIAlertController(
            title: "Clear Cart",
            message: "Are you sure you want to remove all items from your cart?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Clear All", style: .destructive) { [weak self] _ in
            self?.vm.clearCart()
        })
        present(alert, animated: true)
    }
    
    @objc private func startShoppingTapped() {
        onRoute?(.goToHome)
    }
    
    @objc private func checkoutTapped() {
        onRoute?(.checkout)
    }
}

// MARK: - UITableViewDelegate & DataSource

extension CartVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vm.cartItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CartItemCell.reuseIdentifier, for: indexPath) as? CartItemCell else {
            return UITableViewCell()
        }
        
        let item = vm.cartItems[indexPath.row]
        guard let product = item.product else { return cell }
        
        let imageUrl = product.images?.first ?? product.imageUrl
        
        cell.configure(
            imageUrl: imageUrl,
            name: product.title,
            variants: item.selectedVariants,
            price: product.discountPrice ?? product.basePrice,
            quantity: item.quantity,
            isOnSale: product.discountPrice != nil
        )
        
        cell.onQuantityChanged = { [weak self] newQuantity in
            self?.vm.updateQuantity(for: item, quantity: newQuantity)
        }
        
        cell.onDeleteTapped = { [weak self] in
            self?.vm.removeFromCart(item: item)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 114
    }
}
