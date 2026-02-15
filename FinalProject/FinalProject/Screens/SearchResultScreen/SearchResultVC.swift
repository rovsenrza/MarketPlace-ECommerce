import Combine
import SnapKit
import UIKit

final class SearchResultVC: UIViewController {
    // MARK: - Properties
    
    private let vm: SearchResultVM
    private let wishlistVM: WishlistVM
    private let onRoute: ((SearchResultRoute) -> Void)?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - UI Components
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search products..."
        searchBar.searchBarStyle = .minimal
        searchBar.showsCancelButton = true
        return searchBar
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = createLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.register(ProductCardCell.self, forCellWithReuseIdentifier: ProductCardCell.reuseIdentifier)
        cv.delegate = self
        cv.dataSource = self
        cv.keyboardDismissMode = .onDrag
        return cv
    }()
    
    private let emptyStateView: UIView = {
        let view = UIView()
        view.isHidden = true
        return view
    }()
    
    private let emptyImageView: UIImageView = {
        let config = UIImage.SymbolConfiguration(pointSize: 60, weight: .light)
        let image = UIImage(systemName: "magnifyingglass", withConfiguration: config)
        let iv = UIImageView(image: image)
        iv.tintColor = UIColor(named: "TextMuted") ?? .secondaryLabel
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    private let emptyTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Search for Products"
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textColor = UIColor(named: "TextPrimary") ?? .label
        label.textAlignment = .center
        return label
    }()
    
    private let emptySubtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Type in the search bar to find products"
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = UIColor(named: "TextMuted") ?? .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    // MARK: - Initialization
    
    init(
        vm: SearchResultVM,
        wishlistVM: WishlistVM,
        onRoute: ((SearchResultRoute) -> Void)? = nil
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
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        searchBar.becomeFirstResponder()
    }
    
    // MARK: - Setup
    
    func setupUI() {
        view.backgroundColor = UIColor(named: "Background") ?? .systemBackground
        navigationItem.titleView = searchBar
        searchBar.delegate = self
        
        addSubviews()
        setupConstraints()
        bindViewModel()
        wishlistVM.fetchWishlistItems()
    }
    
    func addSubviews() {
        view.addSubview(collectionView)
        view.addSubview(emptyStateView)
        view.addSubview(loadingIndicator)
        
        emptyStateView.addSubview(emptyImageView)
        emptyStateView.addSubview(emptyTitleLabel)
        emptyStateView.addSubview(emptySubtitleLabel)
    }
    
    func setupConstraints() {
        collectionView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        emptyStateView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(32)
        }
        
        emptyImageView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.size.equalTo(80)
        }
        
        emptyTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(emptyImageView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview()
        }
        
        emptySubtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(emptyTitleLabel.snp.bottom).offset(8)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        loadingIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .estimated(280))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(280))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item, item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 16
        section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 8, bottom: 16, trailing: 8)
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    // MARK: - Bindings
    
    private func bindViewModel() {
        vm.$products
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.collectionView.reloadData()
                self?.updateEmptyState()
            }
            .store(in: &cancellables)
        
        vm.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                if isLoading {
                    self?.loadingIndicator.startAnimating()
                } else {
                    self?.loadingIndicator.stopAnimating()
                }
                self?.updateEmptyState()
            }
            .store(in: &cancellables)
        
        wishlistVM.$wishlistItems
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.collectionView.reloadData()
            }
            .store(in: &cancellables)
    }
    
    private func updateEmptyState() {
        let hasSearchText = !vm.searchText.isEmpty
        let hasResults = !vm.products.isEmpty
        let isLoading = vm.isLoading
        
        if isLoading {
            emptyStateView.isHidden = true
            collectionView.isHidden = true
        } else if hasSearchText, !hasResults {
            emptyStateView.isHidden = false
            emptyTitleLabel.text = "No Results Found"
            emptySubtitleLabel.text = "Try searching for something else"
            emptyImageView.image = UIImage(systemName: "xmark.circle", withConfiguration: UIImage.SymbolConfiguration(pointSize: 60, weight: .light))
            collectionView.isHidden = true
        } else if !hasSearchText {
            emptyStateView.isHidden = false
            emptyTitleLabel.text = "Search for Products"
            emptySubtitleLabel.text = "Type in the search bar to find products"
            emptyImageView.image = UIImage(systemName: "magnifyingglass", withConfiguration: UIImage.SymbolConfiguration(pointSize: 60, weight: .light))
            collectionView.isHidden = true
        } else {
            emptyStateView.isHidden = true
            collectionView.isHidden = false
        }
    }
    
    // MARK: - Navigation
    
    private func navigateToProductDetail(_ product: Product) {
        onRoute?(.productDetail(product))
    }
}

// MARK: - UISearchBarDelegate

extension SearchResultVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        vm.search(searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        vm.clearSearch()
        onRoute?(.close)
    }
}

// MARK: - UICollectionViewDataSource

extension SearchResultVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return vm.products.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProductCardCell.reuseIdentifier, for: indexPath) as? ProductCardCell else {
            return UICollectionViewCell()
        }
        
        let product = vm.products[indexPath.item]
        cell.configure(with: product, categories: [])
        
        let isWishlisted = wishlistVM.isInWishlist(productId: product.id ?? "")
        cell.favoriteButton.isSelected = isWishlisted
        cell.favoriteButton.tintColor = isWishlisted ? UIColor(named: "Error") : UIColor(named: "TextMuted")
        
        cell.onFavoriteTapped = { [weak self] _ in
            self?.wishlistVM.toggleWishlist(product: product)
        }
        
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension SearchResultVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let product = vm.products[indexPath.item]
        navigateToProductDetail(product)
    }
}
