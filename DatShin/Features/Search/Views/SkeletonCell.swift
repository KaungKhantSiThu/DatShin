import UIKit

class SkeletonCell: UICollectionViewCell {
    static let reuseIdentifier = "SkeletonCell"
    
    private let placeholderView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemGray5 // A light gray for skeleton effect
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        contentView.addSubview(placeholderView)
        backgroundColor = .systemBackground // Ensure cell background matches collection view
        
        // Example: A simple full-cell placeholder
        // You can add more sophisticated skeleton UI elements here
        NSLayoutConstraint.activate([
            placeholderView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            placeholderView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            placeholderView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            placeholderView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    // Call this if you want to start a shimmer animation, for example
    func startShimmering() {
        // Basic shimmer (can be improved with gradients and animations)
        let darkColor = UIColor.systemGray4.cgColor
        let lightColor = UIColor.systemGray6.cgColor

        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [darkColor, lightColor, darkColor]
        gradientLayer.frame = CGRect(x: -bounds.width, y: 0, width: 3 * bounds.width, height: bounds.height)
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradientLayer.locations = [0.4, 0.5, 0.6]
        placeholderView.layer.addSublayer(gradientLayer)

        let animation = CABasicAnimation(keyPath: "transform.translation.x")
        animation.duration = 1.5
        animation.fromValue = -bounds.width
        animation.toValue = bounds.width
        animation.repeatCount = .infinity
        gradientLayer.add(animation, forKey: "shimmer")
    }
//
//    func stopShimmering() {
//        placeholderView.layer.sublayers?.removeAll { $0 is CAGradientLayer }
//    }

    override func prepareForReuse() {
        super.prepareForReuse()
        stopShimmering() // Stop animation when cell is reused
    }
}
