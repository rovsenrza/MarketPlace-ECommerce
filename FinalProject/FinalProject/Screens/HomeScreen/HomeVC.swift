import Combine
import SnapKit
import UIKit

final class HomeVC: UIViewController {
    // MARK: - Properties
    
    let vm: HomeVM
    let wishlistVM: WishlistVM
    private let onRoute: ((HomeRoute) -> Void)?
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: HomeLayoutBuilder.createLayout())
        collectionView.backgroundColor = UIColor(named: "Background") ?? .systemBackground
        collectionView.delegate = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(FeaturedCarouselCell.self, forCellWithReuseIdentifier: FeaturedCarouselCell.reuseIdentifier)
        collectionView.register(CategoryPillCell.self, forCellWithReuseIdentifier: CategoryPillCell.reuseIdentifier)
        collectionView.register(ProductCardCell.self, forCellWithReuseIdentifier: ProductCardCell.reuseIdentifier)
        collectionView.register(
            SectionHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: SectionHeaderView.reuseIdentifier
        )
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()

    private var dataSource: UICollectionViewDiffableDataSource<HomeSectionType, HomeSectionItem>!
    private var cancellables = Set<AnyCancellable>()
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search for products, brands..."
        searchBar.searchBarStyle = .minimal
        searchBar.backgroundColor = .clear
        return searchBar
    }()
    
    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = UIColor(named: "TextMuted")
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()

    private let loadingView: SectionLoadingView = {
        let view = SectionLoadingView()
        view.isHidden = true
        return view
    }()

    private let notificationButton = UIButton(type: .system)
    private let notificationContainer = UIView()
    private let notificationBadgeBackground: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "Error") ?? .systemRed
        view.layer.cornerRadius = 9
        view.layer.masksToBounds = true
        view.isHidden = true
        return view
    }()

    private let notificationBadgeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 11, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        vm.refreshUnreadNotifications()
    }
    
    init(
        vm: HomeVM,
        wishlistVM: WishlistVM,
        onRoute: ((HomeRoute) -> Void)? = nil
    ) {
        self.vm = vm
        self.wishlistVM = wishlistVM
        self.onRoute = onRoute
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    // MARK: - Setup
    
    private func bindViewModel() {
        vm.$featuredProducts
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.applySnapshot()
            }
            .store(in: &cancellables)
        
        wishlistVM.$wishlistItems
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateVisibleCellsWishlistState()
            }
            .store(in: &cancellables)
        
        vm.$categories
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.applySnapshot()
            }
            .store(in: &cancellables)
        
        vm.$filteredProducts
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateEmptyStateVisibility()
                self?.applySnapshot()
            }
            .store(in: &cancellables)
        
        vm.$selectedCategoryIndex
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateEmptyStateVisibility()
                self?.applySnapshot()
            }
            .store(in: &cancellables)

        vm.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                guard let self = self else { return }

                self.loadingView.setLoading(isLoading)
                self.searchBar.isHidden = isLoading
                self.collectionView.isHidden = isLoading
                self.updateEmptyStateVisibility(isLoading: isLoading)
            }
            .store(in: &cancellables)

        vm.$unreadNotificationsCount
            .receive(on: DispatchQueue.main)
            .sink { [weak self] count in
                self?.updateNotificationBadge(count: count)
            }
            .store(in: &cancellables)
    }
    
    private func setupKeyboardDismiss() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func setupUI() {
        view.backgroundColor = UIColor(named: "Background") ?? .systemBackground
        searchBar.delegate = self
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Marketplace"

        let bellConfig = UIImage.SymbolConfiguration(pointSize: 18, weight: .regular)
        notificationButton.setImage(UIImage(systemName: "bell", withConfiguration: bellConfig), for: .normal)
        notificationButton.tintColor = UIColor(named: "TextPrimary")
        notificationButton.addTarget(self, action: #selector(notificationTapped), for: .touchUpInside)

        notificationContainer.clipsToBounds = false

        addSubviews()
        setupConstraints()

        let barButton = UIBarButtonItem(customView: notificationContainer)
        notificationContainer.snp.makeConstraints { make in
            make.width.height.equalTo(28)
        }
        navigationItem.rightBarButtonItem = barButton

        configureDataSource()
        bindViewModel()
        setupKeyboardDismiss()
        vm.fetchData()
        wishlistVM.fetchWishlistItems()
    }

    func addSubviews() {
        [searchBar, loadingView, collectionView, emptyStateLabel].forEach { view.addSubview($0) }
        notificationContainer.addSubview(notificationButton)
        notificationContainer.addSubview(notificationBadgeBackground)
        notificationContainer.addSubview(notificationBadgeLabel)
    }

    func setupConstraints() {
        notificationButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        notificationBadgeBackground.snp.makeConstraints { make in
            make.top.equalTo(notificationButton.snp.top).offset(-4)
            make.trailing.equalTo(notificationButton.snp.trailing).offset(4)
            make.height.equalTo(18)
            make.width.greaterThanOrEqualTo(18)
        }

        notificationBadgeLabel.snp.makeConstraints { make in
            make.edges.equalTo(notificationBadgeBackground).inset(2)
        }

        searchBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(50)
        }

        loadingView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(view.safeAreaLayoutGuide)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        
        emptyStateLabel.snp.makeConstraints { make in
            make.center.equalTo(collectionView)
        }
    }

    private func updateEmptyStateVisibility(isLoading: Bool? = nil) {
        let loading = isLoading ?? vm.isLoading
        if loading {
            emptyStateLabel.isHidden = true
            return
        }
        let shouldHide = !vm.filteredProducts.isEmpty || vm.selectedCategoryIndex == 0
        emptyStateLabel.isHidden = shouldHide
    }
    
    // MARK: - Data Source
    
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<HomeSectionType, HomeSectionItem>(collectionView: collectionView) { [weak self] collectionView, indexPath, item in
            guard let self = self else { return UICollectionViewCell() }
            
            let sectionType = HomeSectionType(rawValue: indexPath.section)
            
            switch sectionType {
            case .featured:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FeaturedCarouselCell.reuseIdentifier, for: indexPath) as? FeaturedCarouselCell else {
                    return UICollectionViewCell()
                }
                
                if case .featured(let product) = item {
                    let imageUrl = product.imageUrl ?? product.variantImages?.first
                    cell.configure(
                        with: imageUrl,
                        title: product.title,
                        subtitle: product.description ?? ""
                    )
                }
                return cell
                
            case .categories:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryPillCell.reuseIdentifier, for: indexPath) as? CategoryPillCell else {
                    return UICollectionViewCell()
                }
                
                switch item {
                case .allCategory:
                    cell.configureAsAll()
                    collectionView.selectItem(at: indexPath, animated: true, scrollPosition: [])

                case .category(let category):
                    cell.configure(with: category, showIcon: true)

                default:
                    break
                }
                
                cell.isSelected = indexPath.item == self.vm.selectedCategoryIndex
                return cell
                
            case .products:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProductCardCell.reuseIdentifier, for: indexPath) as? ProductCardCell else {
                    return UICollectionViewCell()
                }
                
                if case .product(let product) = item {
                    cell.configure(with: product, categories: self.vm.categories)
                    
                    if let productId = product.id {
                        cell.favoriteButton.isSelected = self.wishlistVM.isInWishlist(productId: productId)
                        cell.favoriteButton.tintColor = cell.favoriteButton.isSelected ? UIColor(named: "Error") : UIColor(named: "TextMuted")
                    }
                    
                    cell.onFavoriteTapped = { [weak self] _ in
                        self?.wishlistVM.toggleWishlist(product: product)
                    }
                }
                return cell
                
            case .none:
                return UICollectionViewCell()
            }
        }
        
        dataSource.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
            guard let self = self,
                  kind == UICollectionView.elementKindSectionHeader,
                  let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SectionHeaderView.reuseIdentifier, for: indexPath) as? SectionHeaderView
            else {
                return nil
            }
            
            let sectionType = HomeSectionType(rawValue: indexPath.section)
            let isProductsSection = sectionType == .products
            headerView.configure(
                title: sectionType?.title ?? "",
                showSeeAll: sectionType?.showSeeAll ?? false,
                showFilter: isProductsSection
            )
            headerView.onSeeAllTapped = {
                self.handleSeeAllTapped(for: sectionType)
            }
            headerView.onFilterTapped = { [weak self] in
                guard isProductsSection else { return }

                self?.presentFilter()
            }
            
            return headerView
        }
    }
    
    private func applySnapshot(animatingDifferences: Bool = true) {
        var snapshot = NSDiffableDataSourceSnapshot<HomeSectionType, HomeSectionItem>()
        
        snapshot.appendSections([.featured, .categories, .products])
        
        let featuredItems = vm.featuredProducts.map { HomeSectionItem.featured($0) }
        snapshot.appendItems(featuredItems, toSection: .featured)
        
        var categoryItems: [HomeSectionItem] = [.allCategory]
        categoryItems.append(contentsOf: vm.categories.map { HomeSectionItem.category($0) })
        snapshot.appendItems(categoryItems, toSection: .categories)
        
        let productItems = vm.filteredProducts.map { HomeSectionItem.product($0) }
        snapshot.appendItems(productItems, toSection: .products)
        
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }
    
    // MARK: - Actions
    
    @objc private func notificationTapped() {
        onRoute?(.notifications)
    }

    private func updateNotificationBadge(count: Int) {
        if count <= 0 {
            notificationBadgeBackground.isHidden = true
            notificationBadgeLabel.isHidden = true
            notificationBadgeLabel.text = nil
        } else {
            notificationBadgeBackground.isHidden = false
            notificationBadgeLabel.isHidden = false
            notificationBadgeLabel.text = count > 99 ? "99+" : "\(count)"
        }
    }
    
    private func handleSeeAllTapped(for section: HomeSectionType?) {
        guard section == .categories else { return }

        onRoute?(.browse)
    }
    
    private func presentFilter() {
        onRoute?(.filter(
            categories: vm.categories,
            currentQuery: vm.filterQuery,
            hideCategoryFilter: false,
            onApply: { [weak self] query in
                self?.vm.applyFilterQuery(query)
            }
        ))
    }

    func applyFilterQuery(_ query: FilterQuery) {
        vm.applyFilterQuery(query)
    }
}

// MARK: - UICollectionViewDelegate

extension HomeVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let sectionType = HomeSectionType(rawValue: indexPath.section)
        
        switch sectionType {
        case .categories:
            vm.selectedCategoryIndex = indexPath.item
            
            if indexPath.item == 0 {
                vm.filterProducts(byCategoryId: nil)
            } else {
                let categoryIndex = indexPath.item - 1
                if categoryIndex < vm.categories.count {
                    let categoryId = vm.categories[categoryIndex].id
                    vm.filterProducts(byCategoryId: categoryId)
                }
            }
            
        case .products:
            collectionView.deselectItem(at: indexPath, animated: false)
            
            if let item = dataSource.itemIdentifier(for: indexPath),
               case .product(let product) = item
            {
                navigateToProductDetail(product: product)
            }
            
        case .featured:
            collectionView.deselectItem(at: indexPath, animated: false)
            
            if let item = dataSource.itemIdentifier(for: indexPath),
               case .featured(let product) = item
            {
                navigateToProductDetail(product: product)
            }
            
        case .none:
            break
        }
    }
    
    private func updateVisibleCellsWishlistState() {
        let visibleIndexPaths = collectionView.indexPathsForVisibleItems
        
        for indexPath in visibleIndexPaths {
            guard let cell = collectionView.cellForItem(at: indexPath) as? ProductCardCell,
                  indexPath.item < vm.allProducts.count else { continue }
            guard let item = dataSource.itemIdentifier(for: indexPath) else { continue }
            
            if case .product(let product) = item, let productId = product.id {
                let isInWishlist = wishlistVM.isInWishlist(productId: productId)
                cell.favoriteButton.isSelected = isInWishlist
                cell.favoriteButton.tintColor = isInWishlist ? UIColor(named: "Error") : UIColor(named: "TextMuted")
            }
        }
    }
    
    private func navigateToProductDetail(product: Product) {
        onRoute?(.productDetail(product))
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        let sectionType = HomeSectionType(rawValue: indexPath.section)
        return sectionType != .featured
    }
}

// MARK: - UISearchBarDelegate

extension HomeVC: UISearchBarDelegate {
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        onRoute?(.search)
        return false
    }
}
