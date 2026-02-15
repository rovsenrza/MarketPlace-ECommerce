import Combine
import SnapKit
import UIKit

final class CategoryDetailVC: UIViewController {
    private let vm: CategoryDetailVM
    private let wishlistVM: WishlistVM
    private let onRoute: ((CategoryDetailRoute) -> Void)?
    private var cancellables = Set<AnyCancellable>()
    
    private let searchBar: UISearchBar = {
        let bar = UISearchBar()
        bar.placeholder = "Search in category"
        bar.searchBarStyle = .minimal
        bar.backgroundColor = .clear
        return bar
    }()
    
    private let loadingView: SectionLoadingView = {
        let view = SectionLoadingView()
        view.isHidden = true
        return view
    }()
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.register(ProductCardCell.self, forCellWithReuseIdentifier: ProductCardCell.reuseIdentifier)
        collectionView.register(
            SectionHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: SectionHeaderView.reuseIdentifier
        )
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()

    private var dataSource: UICollectionViewDiffableDataSource<Section, Product>!
    
    enum Section: Int, CaseIterable {
        case products
    }
    
    init(
        vm: CategoryDetailVM,
        wishlistVM: WishlistVM,
        onRoute: ((CategoryDetailRoute) -> Void)? = nil
    ) {
        self.vm = vm
        self.wishlistVM = wishlistVM
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
    
    func setupUI() {
        view.backgroundColor = UIColor(named: "Background") ?? .systemBackground
        title = vm.title
        navigationController?.navigationBar.prefersLargeTitles = false
        addSubviews()
        setupConstraints()
        searchBar.delegate = self
        configureDataSource()
        bindViewModel()
        setupKeyboardDismiss()
        wishlistVM.fetchWishlistItems()
        vm.fetchCategories()
        vm.fetchProducts()
    }

    func addSubviews() {
        [searchBar, loadingView, collectionView].forEach { view.addSubview($0) }
    }

    func setupConstraints() {
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
            make.leading.trailing.bottom.equalToSuperview()
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
    
    private func createLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { _, _ in
            Self.makeGridSection()
        }
    }
    
    private static func makeGridSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.5),
            heightDimension: .estimated(310)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(310)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item, item])
        group.interItemSpacing = .fixed(16)
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 16
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 32, trailing: 16)
        
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(50)
        )
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        section.boundarySupplementaryItems = [header]
        
        return section
    }
    
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, Product>(collectionView: collectionView) { [weak self] collectionView, indexPath, product in
            guard let self = self else { return UICollectionViewCell() }

            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ProductCardCell.reuseIdentifier,
                for: indexPath
            ) as! ProductCardCell
            
            let categories: [Category]
            switch self.vm.mode {
            case .category(let category):
                categories = [category]
            case .trending, .flashSales, .megaDeals:
                categories = []
            }
            cell.configure(with: product, categories: categories)
            
            if let productId = product.id {
                cell.favoriteButton.isSelected = self.wishlistVM.isInWishlist(productId: productId)
                cell.favoriteButton.tintColor = cell.favoriteButton.isSelected ? UIColor(named: "Error") : UIColor(named: "TextMuted")
            }
            
            cell.onFavoriteTapped = { [weak self] _ in
                self?.wishlistVM.toggleWishlist(product: product)
            }
            
            return cell
        }
        
        dataSource.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
            guard let self = self,
                  kind == UICollectionView.elementKindSectionHeader,
                  let headerView = collectionView.dequeueReusableSupplementaryView(
                      ofKind: kind,
                      withReuseIdentifier: SectionHeaderView.reuseIdentifier,
                      for: indexPath
                  ) as? SectionHeaderView
            else {
                return nil
            }
            
            headerView.configure(title: "Products", showSeeAll: false, showFilter: true)
            headerView.onFilterTapped = { [weak self] in
                self?.presentFilter()
            }
            return headerView
        }
     }
    
    private func bindViewModel() {
        vm.$filteredProducts
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
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
            }
            .store(in: &cancellables)
        
        wishlistVM.$wishlistItems
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.collectionView.reloadData()
            }
            .store(in: &cancellables)
    }
    
    private func applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Product>()
        snapshot.appendSections([.products])
        snapshot.appendItems(vm.filteredProducts.deduplicatedByProductId(), toSection: .products)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    private func presentFilter() {
        onRoute?(.filter(
            categories: vm.categories,
            currentQuery: vm.filterQuery,
            hideCategoryFilter: true,
            onApply: { [weak self] query in
                self?.vm.applyFilterQuery(query)
            }
        ))
    }

    func applyFilterQuery(_ query: FilterQuery) {
        vm.applyFilterQuery(query)
    }
}

extension CategoryDetailVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        vm.updateSearchText(searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

extension CategoryDetailVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        guard let product = dataSource.itemIdentifier(for: indexPath) else { return }

        onRoute?(.productDetail(product))
    }
}
