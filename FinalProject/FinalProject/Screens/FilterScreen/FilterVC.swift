import SnapKit
import UIKit

final class FilterVC: UIViewController {
    private let vm: FilterVM
    var onApply: ((FilterQuery) -> Void)?
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let headerTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Filter"
        label.font = AppTypography.title()
        label.textColor = UIColor(named: "TextPrimary")
        return label
    }()
    
    private let closeButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: "xmark")
        button.setImage(image, for: .normal)
        button.tintColor = UIColor(named: "TextPrimary")
        return button
    }()
    
    private let sortTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Sort by"
        label.font = AppTypography.title()
        label.textColor = UIColor(named: "TextPrimary")
        return label
    }()
    
    private let categoryTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Category"
        label.font = AppTypography.title()
        label.textColor = UIColor(named: "TextPrimary")
        return label
    }()
    
    private let categorySeeAllButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("See all", for: .normal)
        button.titleLabel?.font = AppTypography.label()
        button.setTitleColor(UIColor(named: "PrimaryColorSet"), for: .normal)
        return button
    }()
    
    private let priceTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Price"
        label.font = AppTypography.title()
        label.textColor = UIColor(named: "TextPrimary")
        return label
    }()
    
    private let applyButton = PrimaryButton(title: "Apply", style: .filled)
    
    private var sortGridStack = UIStackView()
    private var categoryGridStack = UIStackView()
    private let sortSectionStack = UIStackView()
    private let categorySectionStack = UIStackView()
    private let headerStack = UIStackView()
    private let categoryHeaderStack = UIStackView()
    private let priceFieldsStack = UIStackView()
    private let priceSectionStack = UIStackView()
    private let mainStack = UIStackView()
    
    private let minPriceField = UITextField()
    private let maxPriceField = UITextField()
    
    private var sortOptionViews: [FilterQuery.SortOption: RadioOptionRow] = [:]
    private var categoryOptionViews: [String: RadioOptionRow] = [:]
    private var allCategoryOptionView: RadioOptionRow?
    
    init(vm: FilterVM) {
        self.vm = vm
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .pageSheet
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
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
        view.layer.cornerRadius = 24
        view.layer.masksToBounds = true
        scrollView.delaysContentTouches = false
        scrollView.canCancelContentTouches = true

        addSubviews()
        setupConstraints()
        configurePriceField(minPriceField, placeholder: "$  Lowest")
        configurePriceField(maxPriceField, placeholder: "$  Highest")
        applyButton.contentEdgeInsets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        setupActions()
        setupKeyboardDismiss()
        configureContent()
        updateSortSelection()
        updateCategorySelection()
    }

    func addSubviews() {
        headerStack.axis = .horizontal
        headerStack.alignment = .center
        headerStack.arrangedSubviews.forEach { headerStack.removeArrangedSubview($0); $0.removeFromSuperview() }
        [headerTitleLabel, UIView(), closeButton].forEach { headerStack.addArrangedSubview($0) }

        sortSectionStack.axis = .vertical
        sortSectionStack.spacing = 16
        sortSectionStack.arrangedSubviews.forEach { sortSectionStack.removeArrangedSubview($0); $0.removeFromSuperview() }
        [sortTitleLabel, sortGridStack].forEach { sortSectionStack.addArrangedSubview($0) }

        categoryHeaderStack.axis = .horizontal
        categoryHeaderStack.alignment = .center
        categoryHeaderStack.arrangedSubviews.forEach { categoryHeaderStack.removeArrangedSubview($0); $0.removeFromSuperview() }
        [categoryTitleLabel, UIView(), categorySeeAllButton].forEach { categoryHeaderStack.addArrangedSubview($0) }

        categorySectionStack.axis = .vertical
        categorySectionStack.spacing = 16
        categorySectionStack.arrangedSubviews.forEach { categorySectionStack.removeArrangedSubview($0); $0.removeFromSuperview() }
        [categoryHeaderStack, categoryGridStack].forEach { categorySectionStack.addArrangedSubview($0) }

        priceFieldsStack.axis = .horizontal
        priceFieldsStack.spacing = 16
        priceFieldsStack.distribution = .fillEqually
        priceFieldsStack.arrangedSubviews.forEach { priceFieldsStack.removeArrangedSubview($0); $0.removeFromSuperview() }
        [minPriceField, maxPriceField].forEach { priceFieldsStack.addArrangedSubview($0) }

        priceSectionStack.axis = .vertical
        priceSectionStack.spacing = 16
        priceSectionStack.arrangedSubviews.forEach { priceSectionStack.removeArrangedSubview($0); $0.removeFromSuperview() }
        [priceTitleLabel, priceFieldsStack].forEach { priceSectionStack.addArrangedSubview($0) }

        mainStack.axis = .vertical
        mainStack.spacing = 28
        mainStack.arrangedSubviews.forEach { mainStack.removeArrangedSubview($0); $0.removeFromSuperview() }
        [headerStack, sortSectionStack, categorySectionStack, priceSectionStack, applyButton].forEach { mainStack.addArrangedSubview($0) }

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(mainStack)
    }

    func setupConstraints() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }

        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView)
        }

        mainStack.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().offset(-24)
        }
    }
    
    private func setupActions() {
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        applyButton.addTarget(self, action: #selector(applyTapped), for: .touchUpInside)
        categorySeeAllButton.addTarget(self, action: #selector(toggleCategorySeeAll), for: .touchUpInside)
        minPriceField.addTarget(self, action: #selector(priceFieldChanged), for: .editingChanged)
        maxPriceField.addTarget(self, action: #selector(priceFieldChanged), for: .editingChanged)
    }
    
    private func configureContent() {
        buildSortGrid()
        
        if vm.hideCategoryFilter {
            categorySectionStack.isHidden = true
        } else {
            buildCategoryGrid()
            categorySeeAllButton.isHidden = vm.categories.count <= 6
        }
        
        minPriceField.text = vm.minPriceText
        maxPriceField.text = vm.maxPriceText
    }
    
    private func buildSortGrid() {
        sortGridStack = makeGridStack()
        sortOptionViews.removeAll()
        let options = FilterQuery.SortOption.allCases
        let views = options.map { option -> RadioOptionRow in
            let row = RadioOptionRow(title: option.title)
            row.onTap = { [weak self] in
                self?.vm.selectedSort = option
                self?.updateSortSelection()
            }
            sortOptionViews[option] = row
            return row
        }
        populateGrid(sortGridStack, with: views)
        sortSectionStack.arrangedSubviews.forEach { sortSectionStack.removeArrangedSubview($0); $0.removeFromSuperview() }
        [sortTitleLabel, sortGridStack].forEach { sortSectionStack.addArrangedSubview($0) }
    }
    
    private func buildCategoryGrid() {
        categoryGridStack = makeGridStack()
        
        var views: [RadioOptionRow] = []
        let allOption = RadioOptionRow(title: "All Categories")
        allOption.onTap = { [weak self] in
            self?.vm.selectedCategoryId = nil
            self?.updateCategorySelection()
        }
        allCategoryOptionView = allOption
        views.append(allOption)
        
        categoryOptionViews.removeAll()
        for category in vm.visibleCategories {
            let row = RadioOptionRow(title: category.title)
            let categoryId = category.id ?? ""
            row.onTap = { [weak self] in
                self?.vm.selectedCategoryId = categoryId
                self?.updateCategorySelection()
            }
            categoryOptionViews[categoryId] = row
            views.append(row)
        }
        
        populateGrid(categoryGridStack, with: views)
        categorySectionStack.arrangedSubviews.forEach { categorySectionStack.removeArrangedSubview($0); $0.removeFromSuperview() }
        [categoryHeaderStack, categoryGridStack].forEach { categorySectionStack.addArrangedSubview($0) }
    }
    
    private func updateSortSelection() {
        for (option, view) in sortOptionViews {
            view.isSelectedOption = option == vm.selectedSort
        }
    }
    
    private func updateCategorySelection() {
        let selectedId = vm.selectedCategoryId
        allCategoryOptionView?.isSelectedOption = selectedId == nil
        for (id, view) in categoryOptionViews {
            view.isSelectedOption = id == selectedId
        }
    }
    
    private func configurePriceField(_ field: UITextField, placeholder: String) {
        field.placeholder = placeholder
        field.font = AppTypography.body()
        field.textColor = UIColor(named: "TextPrimary")
        field.backgroundColor = .clear
        field.layer.cornerRadius = 14
        field.layer.borderWidth = 1
        field.layer.borderColor = (UIColor(named: "BorderColor") ?? UIColor.systemGray4).cgColor
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 1))
        field.leftViewMode = .always
        field.keyboardType = .decimalPad
        field.snp.makeConstraints { make in
            make.height.equalTo(52)
        }
    }
    
    private func makeGridStack() -> UIStackView {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 14
        return stack
    }
    
    private func populateGrid(_ grid: UIStackView, with views: [UIView]) {
        var rows: [UIView] = []
        for index in stride(from: 0, to: views.count, by: 2) {
            let rowViews = [views[index], index + 1 < views.count ? views[index + 1] : UIView()]
            let row = UIStackView(arrangedSubviews: rowViews)
            row.axis = .horizontal
            row.spacing = 16
            row.distribution = .fillEqually
            rows.append(row)
        }
        grid.arrangedSubviews.forEach { grid.removeArrangedSubview($0); $0.removeFromSuperview() }
        rows.forEach { grid.addArrangedSubview($0) }
    }
    
    @objc private func closeTapped() {
        dismiss(animated: true)
    }
    
    @objc private func applyTapped() {
        let query = vm.makeQuery()
        onApply?(query)
        dismiss(animated: true)
    }
    
    @objc private func toggleCategorySeeAll() {
        vm.showsAllCategories.toggle()
        buildCategoryGrid()
        updateCategorySelection()
        categorySeeAllButton.setTitle(vm.showsAllCategories ? "See less" : "See all", for: .normal)
    }
    
    @objc private func priceFieldChanged() {
        vm.minPriceText = minPriceField.text ?? ""
        vm.maxPriceText = maxPriceField.text ?? ""
    }
}

final class RadioOptionRow: UIControl {
    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    private let contentStack = UIStackView()
    private lazy var tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
    
    var onTap: (() -> Void)?
    var isSelectedOption: Bool = false {
        didSet { updateSelection() }
    }
    
    init(title: String) {
        super.init(frame: .zero)
        titleLabel.text = title
        titleLabel.font = AppTypography.body()
        titleLabel.textColor = UIColor(named: "TextPrimary")
        setupUI()
        addTarget(self, action: #selector(handleTap), for: .touchUpInside)
        addGestureRecognizer(tapGesture)
        updateSelection()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        isUserInteractionEnabled = true
        backgroundColor = .clear
        contentStack.axis = .horizontal
        contentStack.spacing = 12
        contentStack.alignment = .center
        contentStack.isUserInteractionEnabled = false
        iconView.isUserInteractionEnabled = false
        titleLabel.isUserInteractionEnabled = false
        addSubviews()
        setupConstraints()
    }

    func addSubviews() {
        [iconView, titleLabel].forEach { contentStack.addArrangedSubview($0) }
        addSubview(contentStack)
    }

    func setupConstraints() {
        contentStack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        iconView.snp.makeConstraints { make in
            make.width.height.equalTo(22)
        }
        snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(28)
        }
    }
    
    private func updateSelection() {
        let imageName = isSelectedOption ? "largecircle.fill.circle" : "circle"
        iconView.image = UIImage(systemName: imageName)
        iconView.tintColor = isSelectedOption ? (UIColor(named: "PrimaryColorSet") ?? .systemBlue) : .systemGray3
    }
    
    @objc private func handleTap() {
        onTap?()
    }
}
