import Kingfisher
import SnapKit
import UIKit

final class FeaturedCarouselCell: UICollectionViewCell {
    static let reuseIdentifier = "FeaturedCarouselCell"
    
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    private let gradientView: UIView = {
        let view = UIView()
        return view
    }()
    
    private let gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [
            UIColor.black.withAlphaComponent(0.0).cgColor,
            UIColor.black.withAlphaComponent(0.6).cgColor
        ]
        layer.locations = [0.0, 1.0]
        return layer
    }()
    
    private let badgeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10, weight: .bold)
        label.textColor = .white
        label.backgroundColor = UIColor(named: "AccentColor")
        label.textAlignment = .center
        label.layer.cornerRadius = 10
        label.clipsToBounds = true
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .white
        label.numberOfLines = 1
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .white.withAlphaComponent(0.8)
        label.numberOfLines = 1
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = gradientView.bounds
    }
    
    func setupUI() {
        contentView.backgroundColor = UIColor(named: "Surface")
        contentView.layer.cornerRadius = 16
        contentView.clipsToBounds = true
        addSubviews()
        setupConstraints()
    }

    func addSubviews() {
        [imageView, gradientView, badgeLabel, titleLabel, subtitleLabel].forEach { contentView.addSubview($0) }
        gradientView.layer.addSublayer(gradientLayer)
    }

    func setupConstraints() {
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        gradientView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        badgeLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.bottom.equalTo(titleLabel.snp.top).offset(-8)
            make.height.equalTo(20)
            make.width.greaterThanOrEqualTo(80)
        }

        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalTo(subtitleLabel.snp.top).offset(-4)
        }

        subtitleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-16)
        }
    }
    
    func configure(with imageUrl: String?, title: String, subtitle: String) {
        if let urlString = imageUrl, let url = URL(string: urlString) {
            imageView.kf.setImage(with: url)
        } else {
            imageView.image = nil
        }
        
        badgeLabel.text = "  ARRIVAL  "
        titleLabel.text = title
        subtitleLabel.text = subtitle
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.kf.cancelDownloadTask()
        imageView.image = nil
        titleLabel.text = nil
        subtitleLabel.text = nil
        badgeLabel.text = nil
    }
}
