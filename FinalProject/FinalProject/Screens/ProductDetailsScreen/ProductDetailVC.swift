import Combine
import Kingfisher
import SnapKit
import UIKit

final class ProductDetailVC: UIViewController {
    // MARK: - Properties
    
    private let vm: ProductDetailVM
    private let onRoute: ((ProductDetailRoute) -> Void)?
    private var cancellables = Set<AnyCancellable>()
    private var currentImageIndex: Int = 0
    
    // MARK: - UI Components
    
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.contentInsetAdjustmentBehavior = .never
        return sv
    }()
    
    private let contentView = UIView()
    
    private let favoriteButton: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .systemBackground
        btn.layer.cornerRadius = 20
        btn.layer.shadowColor = UIColor.gray.cgColor
        btn.layer.shadowOpacity = 0.1
        btn.layer.shadowOffset = CGSize(width: 0, height: 2)
        btn.layer.shadowRadius = 4
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        btn.setImage(UIImage(systemName: "heart.fill", withConfiguration: config), for: .normal)
        btn.tintColor = UIColor(named: "TextMuted")
        
        return btn
    }()
    
    private let imageGalleryView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "Background")
        view.layer.cornerRadius = 24
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.15
        view.layer.shadowOffset = CGSize(width: 0, height: 10)
        view.layer.shadowRadius = 20
        return view
    }()
    
    private let imageScrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.isPagingEnabled = true
        sv.showsHorizontalScrollIndicator = false
        sv.clipsToBounds = true
        sv.layer.cornerRadius = 24
        return sv
    }()
    
    private let imageStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 0
        return stack
    }()
    
    private let pageIndicatorStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 6
        stack.distribution = .fillEqually
        return stack
    }()
    
    private let pageIndicatorContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        view.layer.cornerRadius = 16
        return view
    }()
    
    private let productNameLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 24, weight: .black)
        lbl.textColor = UIColor(named: "PrimaryColorSet")
        lbl.numberOfLines = 2
        lbl.text = "STUDIO MAX ULTRA"
        return lbl
    }()
    
    private let productSubtitleLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 14, weight: .medium)
        lbl.textColor = .secondaryLabel
        lbl.text = "Acoustic Engineering Series"
        return lbl
    }()
    
    private let discountBadge: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "AccentColor")?.withAlphaComponent(0.15)
        view.layer.cornerRadius = 12
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor(named: "AccentColor")?.withAlphaComponent(0.2).cgColor
        return view
    }()
    
    private let discountLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 14, weight: .bold)
        lbl.textColor = UIColor(named: "AccentColor")
        lbl.text = "-20%"
        return lbl
    }()
    
    private let priceLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 30, weight: .black)
        lbl.textColor = .label
        return lbl
    }()
    
    private let originalPriceLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 18, weight: .semibold)
        lbl.textColor = .secondaryLabel
        return lbl
    }()
    
    private let ratingContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 16
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.separator.cgColor
        view.layer.shadowColor = UIColor.gray.cgColor
        view.layer.shadowOpacity = 0.05
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        return view
    }()
    
    private let starsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 2
        stack.distribution = .fillEqually
        return stack
    }()
    
    private let ratingLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 16, weight: .bold)
        lbl.textColor = .label
        return lbl
    }()
    
    private let reviewCountLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 14, weight: .regular)
        lbl.textColor = .secondaryLabel
        return lbl
    }()
    
    private let variantsContainerStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 32
        return stack
    }()
    
    private var variantSectionViews: [VariantSectionView] = []
    
    private let descriptionSectionLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 12, weight: .bold)
        lbl.textColor = .secondaryLabel
        lbl.text = "PRODUCT STORY"
        return lbl
    }()
    
    private let descriptionContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 16
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.separator.cgColor
        return view
    }()
    
    private let descriptionLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 15, weight: .regular)
        lbl.textColor = .secondaryLabel
        lbl.numberOfLines = 4
        return lbl
    }()
    
    private let readMoreButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Read more", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .bold)
        btn.setTitleColor(UIColor(named: "PrimaryColorSet"), for: .normal)
        return btn
    }()
    
    private let reviewSectionLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 13, weight: .bold)
        lbl.textColor = .label
        lbl.text = "Customer Experience"
        return lbl
    }()
    
    private let bigRatingLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 48, weight: .black)
        lbl.textColor = UIColor(named: "PrimaryColorSet")
        return lbl
    }()
    
    private let bigStarsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 2
        stack.distribution = .fillEqually
        return stack
    }()
    
    private let verifiedReviewsLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 14, weight: .medium)
        lbl.textColor = .secondaryLabel
        return lbl
    }()
    
    private let ratingBarsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        stack.distribution = .fillEqually
        return stack
    }()
    
    private let viewAllReviewsButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("View All Reviews", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .bold)
        btn.setTitleColor(UIColor(named: "PrimaryColorSet"), for: .normal)
        btn.backgroundColor = .systemBackground
        btn.layer.cornerRadius = 16
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.separator.cgColor
        return btn
    }()
    
    private let bottomBar: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.95)
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: -4)
        view.layer.shadowRadius = 12
        return view
    }()
    
    private let quantityContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "Background")
        view.layer.cornerRadius = 16
        return view
    }()
    
    private let decrementButton: UIButton = {
        let btn = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)
        btn.setImage(UIImage(systemName: "minus", withConfiguration: config), for: .normal)
        btn.tintColor = UIColor(named: "PrimaryColorSet")
        return btn
    }()
    
    private let quantityLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 18, weight: .bold)
        lbl.textColor = .label
        lbl.textAlignment = .center
        lbl.text = "1"
        return lbl
    }()
    
    private let incrementButton: UIButton = {
        let btn = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)
        btn.setImage(UIImage(systemName: "plus", withConfiguration: config), for: .normal)
        btn.tintColor = UIColor(named: "PrimaryColorSet")
        return btn
    }()
    
    private let addToCartButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Add to Cart", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 18, weight: .black)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = UIColor(named: "PrimaryColorSet")
        btn.layer.cornerRadius = 16
        btn.layer.shadowColor = UIColor(named: "PrimaryColorSet")?.cgColor
        btn.layer.shadowOpacity = 0.25
        btn.layer.shadowOffset = CGSize(width: 0, height: 8)
        btn.layer.shadowRadius = 12
        return btn
    }()
    
    private let cartIconImageView: UIImageView = {
        let iv = UIImageView()
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold)
        iv.image = UIImage(systemName: "cart", withConfiguration: config)
        iv.tintColor = .white
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    // MARK: - Initialization
    
    init(vm: ProductDetailVM, onRoute: ((ProductDetailRoute) -> Void)? = nil) {
        self.vm = vm
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
    
    // MARK: - Setup
    
    func setupUI() {
        view.backgroundColor = UIColor(named: "Background")

        setupNavigationBar()
        addSubviews()
        setupConstraints()
        setupStars()
        setupActions()
        bindViewModel()
        configureWithProduct()
        setupImageGallery()
        imageScrollView.delegate = self
    }

    func addSubviews() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        view.addSubview(bottomBar)
        bottomBar.addSubview(quantityContainer)
        [decrementButton, quantityLabel, incrementButton].forEach { quantityContainer.addSubview($0) }
        bottomBar.addSubview(addToCartButton)
        addToCartButton.addSubview(cartIconImageView)

        [
            imageGalleryView,
            productNameLabel,
            productSubtitleLabel,
            discountBadge,
            priceLabel,
            originalPriceLabel,
            ratingContainerView,
            variantsContainerStack,
            descriptionSectionLabel,
            descriptionContainer,
            reviewSectionLabel,
            bigRatingLabel,
            bigStarsStack,
            verifiedReviewsLabel,
            ratingBarsStack,
            viewAllReviewsButton
        ].forEach { contentView.addSubview($0) }

        [imageScrollView, pageIndicatorContainer].forEach { imageGalleryView.addSubview($0) }
        imageScrollView.addSubview(imageStackView)
        pageIndicatorContainer.addSubview(pageIndicatorStack)

        discountBadge.addSubview(discountLabel)
        [starsStack, ratingLabel, reviewCountLabel].forEach { ratingContainerView.addSubview($0) }
        [descriptionLabel, readMoreButton].forEach { descriptionContainer.addSubview($0) }
    }
    
    func setupConstraints() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        imageGalleryView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(imageGalleryView.snp.width)
        }
        
        imageScrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        imageStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalToSuperview()
        }
        
        pageIndicatorContainer.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-16)
            make.centerX.equalToSuperview()
            make.height.equalTo(32)
        }
        
        pageIndicatorStack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12))
        }
        
        productNameLabel.snp.makeConstraints { make in
            make.top.equalTo(imageGalleryView.snp.bottom).offset(24)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalTo(discountBadge.snp.leading).offset(-16)
        }
        
        productSubtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(productNameLabel.snp.bottom).offset(4)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }
        
        discountBadge.snp.makeConstraints { make in
            make.top.equalTo(imageGalleryView.snp.bottom).offset(24)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(36)
        }
        
        discountLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12))
        }
        
        priceLabel.snp.makeConstraints { make in
            make.top.equalTo(productSubtitleLabel.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(16)
        }
        
        originalPriceLabel.snp.makeConstraints { make in
            make.leading.equalTo(priceLabel.snp.trailing).offset(12)
            make.bottom.equalTo(priceLabel.snp.bottom).offset(-4)
        }
        
        ratingContainerView.snp.makeConstraints { make in
            make.top.equalTo(priceLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(52)
        }
        
        starsStack.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.height.equalTo(20)
            make.width.equalTo(110)
        }
        
        ratingLabel.snp.makeConstraints { make in
            make.leading.equalTo(starsStack.snp.trailing).offset(8)
            make.centerY.equalToSuperview()
        }
        
        reviewCountLabel.snp.makeConstraints { make in
            make.leading.equalTo(ratingLabel.snp.trailing).offset(8)
            make.centerY.equalToSuperview()
        }
        
        variantsContainerStack.snp.makeConstraints { make in
            make.top.equalTo(ratingContainerView.snp.bottom).offset(32)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        descriptionSectionLabel.snp.makeConstraints { make in
            make.top.equalTo(vm.availableVariantKeys.isEmpty ? ratingContainerView.snp.bottom : variantsContainerStack.snp.bottom).offset(32)
            make.leading.equalToSuperview().offset(16)
        }
        
        descriptionContainer.snp.makeConstraints { make in
            make.top.equalTo(descriptionSectionLabel.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(20)
        }
        
        readMoreButton.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(20)
            make.bottom.equalToSuperview().offset(-20)
        }
        
        reviewSectionLabel.snp.makeConstraints { make in
            if (vm.product.description?.isEmpty) == false {
                make.top.equalTo(descriptionContainer.snp.bottom).offset(32)
            } else if vm.availableVariantKeys.isEmpty {
                make.top.equalTo(ratingContainerView.snp.bottom).offset(32)
            } else {
                make.top.equalTo(variantsContainerStack.snp.bottom).offset(32)
            }

            make.leading.equalToSuperview().offset(16)
        }
        
        bigRatingLabel.snp.makeConstraints { make in
            make.top.equalTo(reviewSectionLabel.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(16)
        }
        
        bigStarsStack.snp.makeConstraints { make in
            make.top.equalTo(bigRatingLabel.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(16)
            make.height.equalTo(24)
            make.width.equalTo(130)
        }
        
        verifiedReviewsLabel.snp.makeConstraints { make in
            make.top.equalTo(bigStarsStack.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(16)
        }
        
        ratingBarsStack.snp.makeConstraints { make in
            make.leading.equalTo(bigStarsStack.snp.trailing).offset(12)
            make.trailing.equalToSuperview().offset(-16)
            make.top.equalTo(bigRatingLabel)
            make.bottom.lessThanOrEqualTo(verifiedReviewsLabel)
        }
        
        viewAllReviewsButton.snp.makeConstraints { make in
            make.top.greaterThanOrEqualTo(verifiedReviewsLabel.snp.bottom).offset(24)
            make.top.greaterThanOrEqualTo(ratingBarsStack.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(56)
            make.bottom.equalToSuperview().offset(-120)
        }
        
        bottomBar.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(100)
        }
        
        quantityContainer.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(16)
            make.height.equalTo(56)
            make.width.equalTo(120)
        }
        
        decrementButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(8)
            make.centerY.equalToSuperview()
            make.size.equalTo(40)
        }
        
        quantityLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(32)
        }
        
        incrementButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-8)
            make.centerY.equalToSuperview()
            make.size.equalTo(40)
        }
        
        addToCartButton.snp.makeConstraints { make in
            make.leading.equalTo(quantityContainer.snp.trailing).offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.top.equalToSuperview().offset(16)
            make.height.equalTo(56)
        }
        
        cartIconImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
            make.size.equalTo(24)
        }
    }
    
    private func setupStars() {
        let smallStars: [UIImageView] = (0..<5).map { _ in
            let starImageView = UIImageView()
            let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
            starImageView.image = UIImage(systemName: "star.fill", withConfiguration: config)
            starImageView.tintColor = UIColor(named: "Rating")
            starImageView.contentMode = .scaleAspectFit
            return starImageView
        }

        let largeStars: [UIImageView] = (0..<5).map { _ in
            let starImageView = UIImageView()
            let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
            starImageView.image = UIImage(systemName: "star.fill", withConfiguration: config)
            starImageView.tintColor = UIColor(named: "Rating")
            starImageView.contentMode = .scaleAspectFit
            return starImageView
        }

        starsStack.arrangedSubviews.forEach { starsStack.removeArrangedSubview($0); $0.removeFromSuperview() }
        smallStars.forEach { starsStack.addArrangedSubview($0) }
        bigStarsStack.arrangedSubviews.forEach { bigStarsStack.removeArrangedSubview($0); $0.removeFromSuperview() }
        largeStars.forEach { bigStarsStack.addArrangedSubview($0) }
    }
    
    private func setupActions() {
        favoriteButton.addTarget(self, action: #selector(favoriteTapped), for: .touchUpInside)
        decrementButton.addTarget(self, action: #selector(decrementTapped), for: .touchUpInside)
        incrementButton.addTarget(self, action: #selector(incrementTapped), for: .touchUpInside)
        addToCartButton.addTarget(self, action: #selector(addToCartTapped), for: .touchUpInside)
        
        viewAllReviewsButton.addTarget(self, action: #selector(viewAllReviewsTapped), for: .touchUpInside)
        readMoreButton.addTarget(self, action: #selector(readMoreTapped), for: .touchUpInside)

        let ratingTap = UITapGestureRecognizer(target: self, action: #selector(viewAllReviewsTapped))
        ratingContainerView.addGestureRecognizer(ratingTap)
    }
    
    private func bindViewModel() {
        vm.$quantity
            .receive(on: DispatchQueue.main)
            .sink { [weak self] quantity in
                self?.quantityLabel.text = "\(quantity)"
            }
            .store(in: &cancellables)
        
        vm.$isInWishlist
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isInWishlist in
                self?.favoriteButton.isSelected = isInWishlist
                self?.favoriteButton.tintColor = isInWishlist ? UIColor(named: "Error") : UIColor(named: "TextMuted")
            }
            .store(in: &cancellables)
        
        vm.$variantSelectionChanged
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateVariantSelections()
            }
            .store(in: &cancellables)
        
        vm.$categoryName
            .receive(on: DispatchQueue.main)
            .sink { [weak self] categoryName in
                guard let self = self else { return }

                self.productSubtitleLabel.text = categoryName.isEmpty ? (self.vm.product.brand ?? "") : categoryName
            }
            .store(in: &cancellables)
        
        vm.$product
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateRatingDisplay()
            }
            .store(in: &cancellables)

        vm.$errorMessage
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                guard let self = self else { return }

                let alert = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
                self.vm.clearError()
            }
            .store(in: &cancellables)
    }

    private func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.backButtonDisplayMode = .minimal
        favoriteButton.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: favoriteButton)
    }
    
    private func setupImageGallery() {
        let product = vm.product
        
        var imageUrls: [String] = []
        if let images = product.images, !images.isEmpty {
            imageUrls = images
        } else if let imageUrl = product.imageUrl {
            imageUrls = [imageUrl]
        }
        
        imageStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for imageUrlString in imageUrls {
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            imageView.backgroundColor = UIColor(named: "Background")
            
            if let url = URL(string: imageUrlString) {
                imageView.kf.setImage(with: url)
            }
            
            imageStackView.addArrangedSubview(imageView)
            imageView.snp.makeConstraints { make in
                make.width.equalTo(imageGalleryView.snp.width)
            }
        }
        
        setupPageIndicators(count: imageUrls.count)
        updatePageIndicators()
    }
    
    private func setupPageIndicators(count: Int = 1) {
        pageIndicatorStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        guard count > 0 else { return }
        
        for _ in 0..<count {
            let indicator = UIView()
            indicator.backgroundColor = .white.withAlphaComponent(0.5)
            indicator.layer.cornerRadius = 4
            indicator.snp.makeConstraints { make in
                make.width.height.equalTo(8)
            }
            pageIndicatorStack.addArrangedSubview(indicator)
        }
    }
    
    private func updatePageIndicators() {
        for (index, indicator) in pageIndicatorStack.arrangedSubviews.enumerated() {
            indicator.backgroundColor = index == currentImageIndex ? .white : .white.withAlphaComponent(0.5)
        }
    }
    
    private func configureWithProduct() {
        let product = vm.product
        
        productNameLabel.text = product.title.uppercased()
        productSubtitleLabel.text = vm.categoryName.isEmpty ? (product.brand ?? "") : vm.categoryName
        
        priceLabel.text = String(format: "$%.2f", vm.displayPrice)
        
        if vm.hasDiscount {
            discountBadge.isHidden = false
            if let percentage = vm.discountPercentage {
                discountLabel.text = "-\(percentage)%"
            }
            
            let attributedString = NSMutableAttributedString(string: String(format: "$%.2f", product.basePrice))
            attributedString.addAttribute(.strikethroughStyle, value: 2, range: NSRange(location: 0, length: attributedString.length))
            attributedString.addAttribute(.strikethroughColor, value: UIColor.systemRed, range: NSRange(location: 0, length: attributedString.length))
            originalPriceLabel.attributedText = attributedString
            originalPriceLabel.isHidden = false
        } else {
            discountBadge.isHidden = true
            originalPriceLabel.isHidden = true
        }
        
        ratingLabel.text = String(format: "%.1f", vm.averageRating)
        reviewCountLabel.text = "(\(vm.reviewCount) Reviews)"
        
        bigRatingLabel.text = String(format: "%.1f", vm.averageRating)
        verifiedReviewsLabel.text = "\(vm.reviewCount) verified reviews"
        
        descriptionLabel.text = product.description
        
        let hasDescription = !(product.description?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
        descriptionSectionLabel.isHidden = !hasDescription
        descriptionContainer.isHidden = !hasDescription
        
        setupVariantSections()
        setupRatingBars()
        
        favoriteButton.isSelected = vm.isInWishlist
        favoriteButton.tintColor = vm.isInWishlist ? UIColor(named: "Error") : UIColor(named: "TextMuted")
    }
    
    private func updateRatingDisplay() {
        ratingLabel.text = String(format: "%.1f", vm.averageRating)
        reviewCountLabel.text = "(\(vm.reviewCount) Reviews)"
        updateStars(in: starsStack, rating: vm.averageRating, size: 18)
        
        bigRatingLabel.text = String(format: "%.1f", vm.averageRating)
        verifiedReviewsLabel.text = "\(vm.reviewCount) verified reviews"
        updateStars(in: bigStarsStack, rating: vm.averageRating, size: 20)
        
        setupRatingBars()
    }
    
    private func updateStars(in stack: UIStackView, rating: Double, size: CGFloat) {
        let fullStars = Int(rating)
        let hasHalfStar = (rating - Double(fullStars)) >= 0.5
        let config = UIImage.SymbolConfiguration(pointSize: size, weight: .medium)
        
        for (index, view) in stack.arrangedSubviews.enumerated() {
            guard let starView = view as? UIImageView else { continue }
            
            if index < fullStars {
                starView.image = UIImage(systemName: "star.fill", withConfiguration: config)
                starView.tintColor = UIColor(named: "Rating")
            } else if index == fullStars, hasHalfStar {
                starView.image = UIImage(systemName: "star.leadinghalf.filled", withConfiguration: config)
                starView.tintColor = UIColor(named: "Rating")
            } else {
                starView.image = UIImage(systemName: "star", withConfiguration: config)
                starView.tintColor = UIColor(named: "Rating")?.withAlphaComponent(0.3)
            }
        }
    }
    
    private func setupVariantSections() {
        variantSectionViews.forEach { $0.removeFromSuperview() }
        variantSectionViews.removeAll()
        variantsContainerStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for variantKey in vm.availableVariantKeys {
            let options = vm.getVariantOptions(for: variantKey)
            let selectedValue = vm.getSelectedValue(for: variantKey)
            
            let sectionView = VariantSectionView(
                variantKey: variantKey,
                options: options,
                selectedValue: selectedValue
            ) { [weak self] selectedValue in
                self?.vm.selectVariant(key: variantKey, value: selectedValue)
            }
            
            variantSectionViews.append(sectionView)
            variantsContainerStack.addArrangedSubview(sectionView)
        }
    }
    
    private func setupRatingBars() {
        ratingBarsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        let distribution = vm.ratingDistribution
        
        for rating in (1 ... 5).reversed() {
            let barView = createRatingBar(rating: rating, count: distribution[rating] ?? 0, total: vm.reviewCount)
            ratingBarsStack.addArrangedSubview(barView)
        }
    }
    
    private func createRatingBar(rating: Int, count: Int, total: Int) -> UIView {
        let container = UIView()
        
        let ratingLabel = UILabel()
        ratingLabel.text = "\(rating)"
        ratingLabel.font = .systemFont(ofSize: 12, weight: .bold)
        ratingLabel.textColor = .secondaryLabel
        
        let progressBg = UIView()
        progressBg.backgroundColor = UIColor(named: "Background")
        progressBg.layer.cornerRadius = 3
        
        let progressFill = UIView()
        progressFill.backgroundColor = UIColor(named: "PrimaryColorSet")
        progressFill.layer.cornerRadius = 3
        
        let percentage = total > 0 ? Double(count) / Double(total) : 0.0
        let percentLabel = UILabel()
        percentLabel.text = String(format: "%.0f%%", percentage * 100)
        percentLabel.font = .systemFont(ofSize: 12, weight: .medium)
        percentLabel.textColor = .secondaryLabel
        percentLabel.textAlignment = .right
        
        container.addSubview(ratingLabel)
        container.addSubview(progressBg)
        progressBg.addSubview(progressFill)
        container.addSubview(percentLabel)
        
        ratingLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalTo(20)
        }
        
        progressBg.snp.makeConstraints { make in
            make.leading.equalTo(ratingLabel.snp.trailing).offset(8)
            make.centerY.equalToSuperview()
            make.height.equalTo(6)
            make.trailing.equalTo(percentLabel.snp.leading).offset(-8)
        }
        
        progressFill.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(percentage)
        }
        
        percentLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalTo(40)
        }
        
        container.snp.makeConstraints { make in
            make.height.equalTo(24)
        }
        
        return container
    }
    
    private func updateVariantSelections() {
        for (index, sectionView) in variantSectionViews.enumerated() {
            let variantKey = vm.availableVariantKeys[index]
            let selectedValue = vm.getSelectedValue(for: variantKey)
            sectionView.updateSelection(selectedValue: selectedValue)
        }
    }
    
    // MARK: - Actions
    
    @objc private func backTapped() {
        onRoute?(.back)
    }
    
    @objc private func favoriteTapped() {
        vm.toggleWishlist()
     }
    
    @objc private func decrementTapped() {
        vm.decrementQuantity()
    }
    
    @objc private func incrementTapped() {
        vm.incrementQuantity()
    }
    
    @objc private func addToCartTapped() {
        vm.addToCart()
        
        let alert = UIAlertController(title: "Added to Cart", message: "\(vm.product.title) has been added to your cart", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    @objc private func viewAllReviewsTapped() {
        onRoute?(.reviews(vm.product))
    }
    
    @objc private func readMoreTapped() {
        if descriptionLabel.numberOfLines == 4 {
            descriptionLabel.numberOfLines = 0
            readMoreButton.setTitle("Show less", for: .normal)
        } else {
            descriptionLabel.numberOfLines = 4
            readMoreButton.setTitle("Read more", for: .normal)
        }
    }
}

// MARK: - UIScrollViewDelegate

extension ProductDetailVC: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView == imageScrollView else { return }
        
        let pageWidth = scrollView.frame.width
        let currentPage = Int((scrollView.contentOffset.x + pageWidth / 2) / pageWidth)
        
        if currentPage != currentImageIndex {
            currentImageIndex = currentPage
            updatePageIndicators()
        }
    }
}
