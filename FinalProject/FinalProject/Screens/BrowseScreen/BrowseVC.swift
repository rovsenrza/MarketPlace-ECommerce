
import Combine
import SnapKit
import UIKit

final class BrowseVC: UIViewController {
    private let vm: BrowseVM
    private let onRoute: ((BrowseRoute) -> Void)?
    private var cancellables = Set<AnyCancellable>()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = .clear
        tableView.layer.cornerRadius = 16
        tableView.clipsToBounds = true
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.showsVerticalScrollIndicator = false
        tableView.delegate = self
        tableView.register(BrowseCategoryCell.self, forCellReuseIdentifier: BrowseCategoryCell.reuseIdentifier)
        tableView.tableFooterView = UIView()
        return tableView
    }()
    
    private let searchField: UITextField = {
        let field = UITextField()
        field.placeholder = "Search all categories"
        field.font = AppTypography.body()
        field.textColor = UIColor(named: "TextPrimary") ?? .label
        field.returnKeyType = .search
        field.clearButtonMode = .whileEditing
        return field
    }()
    
    private let featuredSectionLabel: UILabel = {
        let label = UILabel()
        label.text = "Featured Collections"
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        label.textColor = UIColor(named: "TextMuted") ?? .secondaryLabel
        label.textAlignment = .left
        label.adjustsFontForContentSizeCategory = true
        return label
    }()
    
    private let categoriesSectionLabel: UILabel = {
        let label = UILabel()
        label.text = "All Categories"
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        label.textColor = UIColor(named: "TextMuted") ?? .secondaryLabel
        label.textAlignment = .left
        label.adjustsFontForContentSizeCategory = true
        return label
    }()
    
    private let featuredGrid: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 12
        stack.distribution = .fillEqually
        return stack
    }()
    
    private let promoBanner: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "TextPrimary") ?? .label
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        return view
    }()
    
    private let promoTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Spring Refresh Sale 40% OFF"
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .systemBackground
        label.numberOfLines = 2
        return label
    }()
    
    private let promoSubtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "SEASONAL PROMO"
        label.font = .systemFont(ofSize: 10, weight: .bold)
        label.textColor = UIColor(named: "PrimaryColorSet") ?? .systemBlue
        return label
    }()
    
    private let promoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Shop Collection", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 12, weight: .bold)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(named: "PrimaryColorSet") ?? .systemBlue
        button.layer.cornerRadius = 14
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateHeaderFooterLayout()
    }

    init(vm: BrowseVM, onRoute: ((BrowseRoute) -> Void)? = nil) {
        self.vm = vm
        self.onRoute = onRoute
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    func setupUI() {
        view.backgroundColor = UIColor(named: "Background") ?? .systemBackground
        title = "Browse"
        navigationController?.navigationBar.prefersLargeTitles = false
        
        addSubviews()
        setupConstraints()
        setupKeyboardDismiss()
        setupHeaderFooter()
        bindViewModel()
        vm.fetchCategories()
    }
    
    func addSubviews() {
        view.addSubview(tableView)
    }
    
    func setupConstraints() {
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(12)
        }
    }
    
    private func setupKeyboardDismiss() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func setupHeaderFooter() {
        let headerView = UIView()
        headerView.backgroundColor = .clear
        headerView.tag = 101
        
        let searchContainer: UIView = {
            let view = UIView()
            view.backgroundColor = UIColor(named: "Surface") ?? UIColor.systemGray6
            view.layer.cornerRadius = 12
            return view
        }()
        
        let searchIcon: UIImageView = {
            let iv = UIImageView(image: UIImage(systemName: "magnifyingglass"))
            iv.tintColor = UIColor(named: "TextMuted") ?? .secondaryLabel
            return iv
        }()
        
        let trendingCard = makeFeaturedCard(
            title: "Trending Now",
            iconName: "flame"
        )
        let salesCard = makeFeaturedCard(
            title: "Flash Sales",
            iconName: "tag"
        )
        let trendingTap = UITapGestureRecognizer(target: self, action: #selector(trendingTapped))
        let flashTap = UITapGestureRecognizer(target: self, action: #selector(flashTapped))
        trendingCard.addGestureRecognizer(trendingTap)
        salesCard.addGestureRecognizer(flashTap)
        featuredGrid.addArrangedSubview(trendingCard)
        featuredGrid.addArrangedSubview(salesCard)
        
        headerView.addSubview(searchContainer)
        searchContainer.addSubview(searchIcon)
        searchContainer.addSubview(searchField)
        headerView.addSubview(featuredSectionLabel)
        headerView.addSubview(featuredGrid)
        headerView.addSubview(categoriesSectionLabel)
        
        searchContainer.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(40)
        }
        
        searchIcon.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(12)
            make.width.height.equalTo(18)
        }
        
        searchField.snp.makeConstraints { make in
            make.leading.equalTo(searchIcon.snp.trailing).offset(8)
            make.trailing.equalToSuperview().offset(-12)
            make.centerY.equalToSuperview()
        }
        
        featuredSectionLabel.snp.makeConstraints { make in
            make.top.equalTo(searchContainer.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        featuredGrid.snp.makeConstraints { make in
            make.top.equalTo(featuredSectionLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(96)
        }
        
        categoriesSectionLabel.snp.makeConstraints { make in
            make.top.equalTo(featuredGrid.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-8)
        }
        
        headerView.layoutIfNeeded()
        let headerSize = headerView.systemLayoutSizeFitting(CGSize(width: view.bounds.width, height: UIView.layoutFittingCompressedSize.height))
        headerView.frame = CGRect(origin: .zero, size: headerSize)
        tableView.tableHeaderView = headerView
        
        let footerView: UIView = {
            let view = UIView()
            view.backgroundColor = .clear
            return view
        }()
        footerView.tag = 102
        
        footerView.addSubview(promoBanner)
        promoBanner.addSubview(promoSubtitleLabel)
        promoBanner.addSubview(promoTitleLabel)
        promoBanner.addSubview(promoButton)
        addPromoDecorations(to: promoBanner)
        
        promoBanner.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(140)
            make.bottom.equalToSuperview().offset(-24)
        }
        
        promoSubtitleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.equalToSuperview().offset(16)
        }
        
        promoTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(promoSubtitleLabel.snp.bottom).offset(6)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-80)
        }
        
        promoButton.snp.makeConstraints { make in
            make.top.equalTo(promoTitleLabel.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(16)
            make.height.equalTo(28)
            make.width.equalTo(120)
        }
        promoButton.addTarget(self, action: #selector(megaDealsTapped), for: .touchUpInside)
        
        footerView.layoutIfNeeded()
        let footerSize = footerView.systemLayoutSizeFitting(CGSize(width: view.bounds.width, height: UIView.layoutFittingCompressedSize.height))
        footerView.frame = CGRect(origin: .zero, size: footerSize)
        tableView.tableFooterView = footerView
    }

    private func updateHeaderFooterLayout() {
        if let headerView = tableView.tableHeaderView, headerView.tag == 101 {
            let size = headerView.systemLayoutSizeFitting(CGSize(width: view.bounds.width, height: UIView.layoutFittingCompressedSize.height))
            if headerView.frame.size.height != size.height {
                headerView.frame.size.height = size.height
                tableView.tableHeaderView = headerView
            }
        }
        
        if let footerView = tableView.tableFooterView, footerView.tag == 102 {
            let size = footerView.systemLayoutSizeFitting(CGSize(width: view.bounds.width, height: UIView.layoutFittingCompressedSize.height))
            if footerView.frame.size.height != size.height {
                footerView.frame.size.height = size.height
                tableView.tableFooterView = footerView
            }
        }
    }
    
    private func addPromoDecorations(to banner: UIView) {
        let ring = UIView()
        ring.layer.borderWidth = 16
        ring.layer.borderColor = (UIColor(named: "PrimaryColorSet") ?? .systemBlue).cgColor
        ring.layer.cornerRadius = 64
        ring.alpha = 0.2
        
        let circle = UIView()
        circle.backgroundColor = UIColor(named: "PrimaryColorSet") ?? .systemBlue
        circle.layer.cornerRadius = 24
        circle.alpha = 0.2
        
        banner.addSubview(ring)
        banner.addSubview(circle)
        
        ring.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(24)
            make.top.equalToSuperview().offset(-20)
            make.width.height.equalTo(128)
        }
        
        circle.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-12)
            make.width.height.equalTo(48)
        }
    }
    
    private func makeFeaturedCard(title: String, iconName: String) -> UIView {
        let card = UIView()
        card.backgroundColor = (UIColor(named: "PrimaryColorSet") ?? .systemBlue).withAlphaComponent(0.05)
        card.layer.cornerRadius = 12
        card.layer.borderWidth = 1
        card.layer.borderColor = (UIColor(named: "PrimaryColorSet") ?? .systemBlue).withAlphaComponent(0.1).cgColor
        card.isUserInteractionEnabled = true
        
        let icon = UIImageView(image: UIImage(systemName: iconName))
        icon.tintColor = UIColor(named: "PrimaryColorSet") ?? .systemBlue
        icon.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 22, weight: .regular)
        
        let label: UILabel = {
            let lbl = UILabel()
            lbl.text = title
            lbl.font = .systemFont(ofSize: 13, weight: .bold)
            lbl.textColor = UIColor(named: "TextPrimary") ?? .label
            return lbl
        }()
        
        card.addSubview(icon)
        card.addSubview(label)
        
        icon.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(12)
            make.width.height.equalTo(24)
        }
        
        label.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(12)
            make.top.equalTo(icon.snp.bottom).offset(8)
            make.trailing.equalToSuperview().offset(-8)
        }
        
        return card
    }
    
    private func bindViewModel() {
        vm.$categories
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
    }

    @objc private func trendingTapped() {
        onRoute?(.categoryDetail(.trending))
    }
    
    @objc private func flashTapped() {
        onRoute?(.categoryDetail(.flashSales))
    }
    
    @objc private func megaDealsTapped() {
        onRoute?(.categoryDetail(.megaDeals))
    }
}

extension BrowseVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        vm.categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: BrowseCategoryCell.reuseIdentifier, for: indexPath) as! BrowseCategoryCell
        let category = vm.categories[indexPath.row]
        cell.configure(with: category, isLast: indexPath.row == vm.categories.count - 1)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        56
    }
}

extension BrowseVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let category = vm.categories[indexPath.row]
        onRoute?(.categoryDetail(.category(category)))
    }
}
