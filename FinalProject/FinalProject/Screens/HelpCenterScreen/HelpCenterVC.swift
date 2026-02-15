import SnapKit
import UIKit

final class HelpCenterVC: UIViewController {
    private let vm: HelpCenterVM
    private let onRoute: ((HelpCenterRoute) -> Void)?
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: HelpCenterLayoutBuilder.createLayout())
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(HelpCenterCategoryCell.self, forCellWithReuseIdentifier: HelpCenterCategoryCell.reuseIdentifier)
        collectionView.register(HelpCenterOrderStatusCell.self, forCellWithReuseIdentifier: HelpCenterOrderStatusCell.reuseIdentifier)
        collectionView.register(HelpCenterQuestionCell.self, forCellWithReuseIdentifier: HelpCenterQuestionCell.reuseIdentifier)
        collectionView.register(
            SectionHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: SectionHeaderView.reuseIdentifier
        )
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()

    private var dataSource: UICollectionViewDiffableDataSource<HelpCenterSectionType, HelpCenterSectionItem>!
    private let whatsappNumber = "994507193149"

    init(vm: HelpCenterVM, onRoute: ((HelpCenterRoute) -> Void)? = nil) {
        self.vm = vm
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
        title = "Help Center"
        navigationController?.navigationBar.prefersLargeTitles = false

        let supportButton = UIBarButtonItem(
            image: UIImage(systemName: "headset"),
            style: .plain,
            target: self,
            action: #selector(contactSupportTapped)
        )
        let chatButton = UIBarButtonItem(
            image: UIImage(systemName: "bubble.left.and.bubble.right.fill"),
            style: .plain,
            target: self,
            action: #selector(openChatTapped)
        )
        navigationItem.rightBarButtonItems = [supportButton, chatButton]
        addSubviews()
        setupConstraints()
        configureDataSource()
        applySnapshot()
    }

    func addSubviews() {
        view.addSubview(collectionView)
    }

    func setupConstraints() {
        collectionView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }

    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<HelpCenterSectionType, HelpCenterSectionItem>(collectionView: collectionView) { collectionView, indexPath, item in
            switch item {
            case .category(let category):
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HelpCenterCategoryCell.reuseIdentifier, for: indexPath) as? HelpCenterCategoryCell else {
                    return UICollectionViewCell()
                }

                cell.configure(with: category)
                return cell

            case .orderStatus(let category):
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HelpCenterOrderStatusCell.reuseIdentifier, for: indexPath) as? HelpCenterOrderStatusCell else {
                    return UICollectionViewCell()
                }

                cell.configure(with: category)
                return cell

            case .question(let question):
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HelpCenterQuestionCell.reuseIdentifier, for: indexPath) as? HelpCenterQuestionCell else {
                    return UICollectionViewCell()
                }

                cell.configure(with: question)
                return cell
            }
        }

        dataSource.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
            guard let self = self,
                  kind == UICollectionView.elementKindSectionHeader,
                  let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SectionHeaderView.reuseIdentifier, for: indexPath) as? SectionHeaderView,
                  let sectionType = HelpCenterSectionType(rawValue: indexPath.section)
            else {
                return UICollectionReusableView()
            }

            header.configure(title: sectionType.title, showSeeAll: false)
            return header
        }
    }

    private func applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<HelpCenterSectionType, HelpCenterSectionItem>()
        snapshot.appendSections([.categories, .orderStatus, .trending])
        snapshot.appendItems(vm.categories.map { .category($0) }, toSection: .categories)
        snapshot.appendItems([.orderStatus(vm.orderStatus)], toSection: .orderStatus)
        snapshot.appendItems(vm.trendingQuestions.map { .question($0) }, toSection: .trending)
        dataSource.apply(snapshot, animatingDifferences: false)
    }

    @objc private func contactSupportTapped() {
        let urlString = "https://wa.me/\(whatsappNumber)"
        guard let url = URL(string: urlString) else { return }

        UIApplication.shared.open(url)
    }

    @objc private func openChatTapped() {
        onRoute?(.chat)
    }

    private func showDetail(title: String, subtitle: String, body: String) {
        onRoute?(.detail(title: title, subtitle: subtitle, body: body))
    }
}

extension HelpCenterVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }

        switch item {
        case .category(let category), .orderStatus(let category):
            showDetail(title: category.detailTitle, subtitle: category.title, body: category.detailBody)
        case .question(let question):
            showDetail(title: question.detailTitle, subtitle: "Trending Question", body: question.detailBody)
        }
    }
}
