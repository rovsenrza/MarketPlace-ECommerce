import Combine
import SnapKit
import UIKit

final class WishlistVC: UIViewController {
    // MARK: - Properties
    
    let vm: WishlistVM
    private let onRoute: ((WishlistRoute) -> Void)?
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.backgroundColor = UIColor(named: "Background")
        collectionView.delegate = self
        collectionView.register(ProductCardCell.self, forCellWithReuseIdentifier: ProductCardCell.reuseIdentifier)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()

    private var dataSource: UICollectionViewDiffableDataSource<Int, Product>?
    private var cancellables = Set<AnyCancellable>()
    private var currentProducts: [Product] = []
    
    // MARK: - Empty State Views
    
    private let emptyStateContainer: UIView = {
        let view = UIView()
        view.isHidden = true
        return view
        
    }()
    
    private let dashedCircle: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor(named: "PrimaryColorSet")?.withAlphaComponent(0.3).cgColor
        view.layer.cornerRadius = 96
        let dashBorder = CAShapeLayer()
        dashBorder.strokeColor = UIColor(named: "PrimaryColorSet")?.withAlphaComponent(0.4).cgColor
        dashBorder.lineDashPattern = [8, 8]
        dashBorder.frame = CGRect(x: 0, y: 0, width: 192, height: 192)
        dashBorder.fillColor = nil
        dashBorder.path = UIBezierPath(ovalIn: dashBorder.frame).cgPath
        view.layer.addSublayer(dashBorder)
        return view
    }()
    
    private let outerCircle: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "PrimaryColorSet")?.withAlphaComponent(0.1)
        view.layer.cornerRadius = 80
        return view
    }()
    
    private let innerCircle: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "PrimaryColorSet")?.withAlphaComponent(0.2)
        view.layer.cornerRadius = 56
        return view
    }()
    
    private let heartIcon: UIImageView = {
        let iv = UIImageView()
        let config = UIImage.SymbolConfiguration(pointSize: 72, weight: .regular)
        iv.image = UIImage(systemName: "heart.fill", withConfiguration: config)
        iv.tintColor = UIColor(named: "PrimaryColorSet")
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    private let floatingDot1: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "PrimaryColorSet")?.withAlphaComponent(0.4)
        view.layer.cornerRadius = 12
        return view
    }()
    
    private let floatingDot2: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "PrimaryColorSet")?.withAlphaComponent(0.3)
        view.layer.cornerRadius = 8
        return view
    }()
    
    private let emptyTitle: UILabel = {
        let label = UILabel()
        label.text = "Wishlist is Empty"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = UIColor(named: "TextPrimary")
        label.textAlignment = .center
        return label
    }()
    
    private let emptySubtitle: UILabel = {
        let label = UILabel()
        label.text = "Save items you like for later by tapping the heart icon while browsing our collection."
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = UIColor(named: "TextMuted")
        label.textAlignment = .center
        label.numberOfLines = 0
        label.alpha = 0.8
        return label
    }()
    
    private let browseButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Browse Products", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = UIColor(named: "PrimaryColorSet")
        btn.layer.cornerRadius = 28
        btn.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        btn.layer.shadowColor = UIColor(named: "PrimaryColorSet")?.cgColor
        btn.layer.shadowOffset = CGSize(width: 0, height: 10)
        btn.layer.shadowRadius = 25
        btn.layer.shadowOpacity = 0.3
        return btn
    }()

    // MARK: - Loading Views
    
    private let loadingView: SectionLoadingView = {
        let view = SectionLoadingView()
        view.isHidden = true
        return view
    }()
    
    private var loadingHeightConstraint: Constraint?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = false
        vm.fetchWishlistItems()
    }
    
    init(
        vm: WishlistVM,
        onRoute: ((WishlistRoute) -> Void)? = nil
    ) {
        self.vm = vm
        self.onRoute = onRoute
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    // MARK: - Setup
    
    func setupUI() {
        view.backgroundColor = UIColor(named: "Background")
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.largeTitleDisplayMode = .never
        title = "Wishlist"
        addSubviews()
        setupConstraints()
        browseButton.addTarget(self, action: #selector(browseTapped), for: .touchUpInside)
        let rotation = CABasicAnimation(keyPath: "transform.rotation")
        rotation.fromValue = 0
        rotation.toValue = Double.pi * 2
        rotation.duration = 20
        rotation.repeatCount = .infinity
        dashedCircle.layer.sublayers?.first?.add(rotation, forKey: "rotation")
        configureDataSource()
        bindViewModel()
    }

    func addSubviews() {
        view.addSubview(loadingView)
        view.addSubview(collectionView)
        view.addSubview(emptyStateContainer)
        emptyStateContainer.addSubview(dashedCircle)
        emptyStateContainer.addSubview(outerCircle)
        outerCircle.addSubview(innerCircle)
        innerCircle.addSubview(heartIcon)
        emptyStateContainer.addSubview(floatingDot1)
        emptyStateContainer.addSubview(floatingDot2)
        emptyStateContainer.addSubview(emptyTitle)
        emptyStateContainer.addSubview(emptySubtitle)
        emptyStateContainer.addSubview(browseButton)
    }

    func setupConstraints() {
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.bottom.equalToSuperview()
        }

        loadingView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            self.loadingHeightConstraint = make.height.equalTo(0).constraint
        }

        emptyStateContainer.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(32)
        }
        
        dashedCircle.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview()
            make.width.height.equalTo(192)
        }
        
        outerCircle.snp.makeConstraints { make in
            make.center.equalTo(dashedCircle)
            make.width.height.equalTo(160)
        }
        
        innerCircle.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(112)
        }
        
        heartIcon.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(72)
        }
        
        floatingDot1.snp.makeConstraints { make in
            make.top.equalTo(dashedCircle).offset(-8)
            make.trailing.equalTo(dashedCircle).offset(8)
            make.width.height.equalTo(24)
        }
        
        floatingDot2.snp.makeConstraints { make in
            make.bottom.equalTo(dashedCircle).offset(16)
            make.leading.equalTo(dashedCircle).offset(-16)
            make.width.height.equalTo(16)
        }
        
        emptyTitle.snp.makeConstraints { make in
            make.top.equalTo(dashedCircle.snp.bottom).offset(40)
            make.leading.trailing.equalToSuperview()
        }
        
        emptySubtitle.snp.makeConstraints { make in
            make.top.equalTo(emptyTitle.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        browseButton.snp.makeConstraints { make in
            make.top.equalTo(emptySubtitle.snp.bottom).offset(48)
            make.centerX.equalToSuperview()
            make.width.equalTo(280)
            make.height.equalTo(56)
            make.bottom.equalToSuperview()
        }
    }

    private func createLayout() -> UICollectionViewCompositionalLayout {
        UICollectionViewCompositionalLayout { _, _ in
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .absolute(310))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 6, bottom: 0, trailing: 6)

            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(310))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 0, bottom: 16, trailing: 0)
            section.interGroupSpacing = 12
            return section
        }
    }
    
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Int, Product>(
            collectionView: collectionView
        ) { [weak self] (collectionView: UICollectionView, indexPath: IndexPath, product: Product) -> UICollectionViewCell? in
            guard let self = self else { return nil }

            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProductCardCell.reuseIdentifier, for: indexPath) as! ProductCardCell
            cell.configure(with: product, categories: self.vm.categories)
            
            cell.favoriteButton.isSelected = true
            cell.favoriteButton.tintColor = UIColor(named: "Error")
            
            cell.onFavoriteTapped = { [weak self] _ in
                self?.vm.removeFromWishlist(product: product)
            }
            
            return cell
        }
    }
    
    private func bindViewModel() {
        vm.$wishlistItems
            .receive(on: DispatchQueue.main)
            .sink { [weak self] items in
                guard let self = self else { return }

                let products = items.compactMap { $0.product }.deduplicatedByProductId()
                self.currentProducts = products
                self.updateUIState(isLoading: self.vm.isLoading, products: products)
                self.applySnapshot(items: products)
            }
            .store(in: &cancellables)
        
        vm.$categories
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self = self else { return }

                let products = self.vm.wishlistItems.compactMap { $0.product }.deduplicatedByProductId()
                self.applySnapshot(items: products)
            }
            .store(in: &cancellables)

        vm.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                guard let self = self else { return }

                self.updateUIState(isLoading: isLoading, products: self.currentProducts)
            }
            .store(in: &cancellables)
    }
    
    private func updateUIState(isLoading: Bool, products: [Product]) {
        if isLoading {
            loadingHeightConstraint?.update(offset: 140)
            loadingView.setLoading(true)
            collectionView.isHidden = true
            emptyStateContainer.isHidden = true
            return
        }
        
        loadingHeightConstraint?.update(offset: 0)
        loadingView.setLoading(false)
        
        let isEmpty = products.isEmpty
        emptyStateContainer.isHidden = !isEmpty
        collectionView.isHidden = isEmpty
    }
    
    private func applySnapshot(items: [Product]) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, Product>()
        snapshot.appendSections([0])
        snapshot.appendItems(items.deduplicatedByProductId())
        dataSource?.apply(snapshot, animatingDifferences: true)
    }
    
    @objc private func browseTapped() {
        onRoute?(.goToHome)
    }
}

extension WishlistVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)

        guard let product = dataSource?.itemIdentifier(for: indexPath) else { return }

        navigateToProductDetail(product: product)
    }

    private func navigateToProductDetail(product: Product) {
        onRoute?(.productDetail(product))
    }
}
