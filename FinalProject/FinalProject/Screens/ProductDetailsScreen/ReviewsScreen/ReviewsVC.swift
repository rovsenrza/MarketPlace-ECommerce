import Combine
import SnapKit
import UIKit

final class ReviewsVC: UIViewController {
    private let vm: ReviewsVM
    private var cancellables = Set<AnyCancellable>()
    
    private let dismissButton: UIButton = {
        let btn = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold)
        btn.setImage(UIImage(systemName: "xmark", withConfiguration: config), for: .normal)
        btn.tintColor = UIColor(named: "PrimaryColorSet")
        btn.backgroundColor = UIColor(named: "Background")
        btn.layer.cornerRadius = 20
        return btn
    }()
    
    private let headerLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Add Review"
        lbl.font = .systemFont(ofSize: 24, weight: .bold)
        lbl.textColor = .label
        return lbl
    }()
    
    private let starsContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "Background")
        view.layer.cornerRadius = 16
        return view
    }()
    
    private let starsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 12
        stack.distribution = .fillEqually
        return stack
    }()
    
    private var starButtons: [UIButton] = []
    
    private let reviewTextView: UITextView = {
        let tv = UITextView()
        tv.font = .systemFont(ofSize: 16, weight: .regular)
        tv.textColor = .label
        tv.backgroundColor = UIColor(named: "Background")
        tv.layer.cornerRadius = 16
        tv.layer.borderWidth = 1
        tv.layer.borderColor = UIColor.separator.cgColor
        tv.textContainerInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        tv.text = "Write your review here..."
        tv.textColor = .secondaryLabel
        return tv
    }()
    
    private let submitButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Submit Review", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = UIColor(named: "PrimaryColorSet")
        btn.layer.cornerRadius = 16
        return btn
    }()
    
    private lazy var tableView: UITableView = {
        let tv = UITableView()
        tv.backgroundColor = .clear
        tv.separatorStyle = .none
        tv.dataSource = self
        tv.delegate = self
        tv.register(ReviewCell.self, forCellReuseIdentifier: ReviewCell.reuseIdentifier)
        return tv
    }()
    
    private let reviewsHeaderLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "All Reviews"
        lbl.font = .systemFont(ofSize: 20, weight: .bold)
        lbl.textColor = .label
        return lbl
    }()
    
    init(vm: ReviewsVM) {
        self.vm = vm
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
        view.backgroundColor = .systemBackground

        addSubviews()
        setupConstraints()
        setupActions()
        bindViewModel()
        setupStars()
        reviewTextView.delegate = self
    }

    func addSubviews() {
        [dismissButton, headerLabel, starsContainerView, reviewTextView, submitButton, reviewsHeaderLabel, tableView].forEach { view.addSubview($0) }
        starsContainerView.addSubview(starsStack)
    }

    func setupConstraints() {
        dismissButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.size.equalTo(40)
        }
        
        headerLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalTo(dismissButton.snp.leading).offset(-16)
        }
        
        starsContainerView.snp.makeConstraints { make in
            make.top.equalTo(headerLabel.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(80)
        }
        
        starsStack.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.equalTo(48)
        }
        
        reviewTextView.snp.makeConstraints { make in
            make.top.equalTo(starsContainerView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(120)
        }
        
        submitButton.snp.makeConstraints { make in
            make.top.equalTo(reviewTextView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(56)
        }
        
        reviewsHeaderLabel.snp.makeConstraints { make in
            make.top.equalTo(submitButton.snp.bottom).offset(32)
            make.leading.equalToSuperview().offset(16)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(reviewsHeaderLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    private func setupStars() {
        let buttons: [UIButton] = (1 ... 5).map { i in
            let button = UIButton(type: .custom)
            let config = UIImage.SymbolConfiguration(pointSize: 32, weight: .medium)
            button.setImage(UIImage(systemName: "star.fill", withConfiguration: config), for: .normal)
            button.tintColor = UIColor(named: "PrimaryColorSet")
            button.tag = i
            button.addTarget(self, action: #selector(starTapped(_:)), for: .touchUpInside)

            return button
        }

        starButtons = buttons
        starsStack.arrangedSubviews.forEach { starsStack.removeArrangedSubview($0); $0.removeFromSuperview() }
        buttons.forEach { starsStack.addArrangedSubview($0) }
    }
    
    private func setupActions() {
        dismissButton.addTarget(self, action: #selector(dismissTapped), for: .touchUpInside)
        submitButton.addTarget(self, action: #selector(submitTapped), for: .touchUpInside)
    }
    
    private func bindViewModel() {
        vm.$reviews
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
        
        vm.$selectedStars
            .receive(on: DispatchQueue.main)
            .sink { [weak self] selectedCount in
                self?.updateStarColors(selectedCount: selectedCount)
            }
            .store(in: &cancellables)
    }
    
    private func updateStarColors(selectedCount: Int) {
        for (index, button) in starButtons.enumerated() {
            let starNumber = index + 1
            if starNumber <= selectedCount {
                button.tintColor = UIColor(named: "Rating")
            } else {
                button.tintColor = UIColor(named: "PrimaryColorSet")
            }
        }
    }
    
    @objc private func starTapped(_ sender: UIButton) {
        vm.selectStars(sender.tag)
    }
    
    @objc private func dismissTapped() {
        dismiss(animated: true)
    }
    
    @objc private func submitTapped() {
        Task {
            do {
                try await vm.submitReview()
                
                let alert = UIAlertController(title: "Success", message: "Your review has been submitted", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                present(alert, animated: true)
                
                reviewTextView.text = "Write your review here..."
                reviewTextView.textColor = .secondaryLabel
            } catch {
                let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                present(alert, animated: true)
            }
        }
    }
}

extension ReviewsVC: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .secondaryLabel {
            textView.text = ""
            textView.textColor = .label
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Write your review here..."
            textView.textColor = .secondaryLabel
        } else {
            vm.reviewText = textView.text
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.textColor == .label {
            vm.reviewText = textView.text
        }
    }
}

extension ReviewsVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vm.reviews.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ReviewCell.reuseIdentifier, for: indexPath) as! ReviewCell
        let review = vm.reviews[indexPath.row]
        cell.configure(with: review)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
