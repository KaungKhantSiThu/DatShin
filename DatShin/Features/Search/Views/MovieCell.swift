//
//  MovieCell.swift
//  DatShin
//
//  Created by Cascade on 05/06/2025.
//

import UIKit
//import TMDb

class MovieCell: UICollectionViewCell {

    // MARK: - Placeholder Views
    private let posterPlaceholderView = UIView()
    private let titlePlaceholderView = UIView()
    private let votePlaceholderView = UIView()
    static let reuseIdentifier = "MovieCell"
    
    let posterImageView = UIImageView(frame: .zero) // Assuming DSImageView is a custom UIImageView for image loading
    let titleLabel = DSTitleLabel(textAlignment: .center, fontSize: 16)
    let voteAverageLabel = DSBodyLabel(textAlignment: .center)

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        setupPlaceholders()

        contentView.addSubview(posterImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(voteAverageLabel)
        
        posterImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        voteAverageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Basic constraints - these will need to be refined for a good layout
        NSLayoutConstraint.activate([
            posterImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            posterImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            posterImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            posterImageView.heightAnchor.constraint(equalTo: posterImageView.widthAnchor, multiplier: 1.5), // Aspect ratio for poster
            
            titleLabel.topAnchor.constraint(equalTo: posterImageView.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            
            voteAverageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            voteAverageLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            voteAverageLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            voteAverageLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
        
        titleLabel.numberOfLines = 2 // Allow for longer titles
        posterImageView.contentMode = .scaleAspectFill
        posterImageView.clipsToBounds = true
        posterImageView.layer.cornerRadius = 8

        // Constraints for placeholder views (mirroring actual views)
        NSLayoutConstraint.activate([
            posterPlaceholderView.topAnchor.constraint(equalTo: posterImageView.topAnchor),
            posterPlaceholderView.leadingAnchor.constraint(equalTo: posterImageView.leadingAnchor),
            posterPlaceholderView.trailingAnchor.constraint(equalTo: posterImageView.trailingAnchor),
            posterPlaceholderView.bottomAnchor.constraint(equalTo: posterImageView.bottomAnchor),

            titlePlaceholderView.topAnchor.constraint(equalTo: titleLabel.topAnchor),
            titlePlaceholderView.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor, constant: 0), // Adjust if titleLabel has specific leading padding for text
            titlePlaceholderView.widthAnchor.constraint(equalTo: titleLabel.widthAnchor, multiplier: 0.7), // Shorter placeholder for text
            titlePlaceholderView.heightAnchor.constraint(equalToConstant: titleLabel.font.pointSize),

            votePlaceholderView.topAnchor.constraint(equalTo: voteAverageLabel.topAnchor),
            votePlaceholderView.leadingAnchor.constraint(equalTo: voteAverageLabel.leadingAnchor, constant: 0),
            votePlaceholderView.widthAnchor.constraint(equalTo: voteAverageLabel.widthAnchor, multiplier: 0.4),
            votePlaceholderView.heightAnchor.constraint(equalToConstant: voteAverageLabel.font.pointSize)
        ])

        // Initially hide placeholders
        posterPlaceholderView.isHidden = true
        titlePlaceholderView.isHidden = true
        votePlaceholderView.isHidden = true
    }
    
    func configure(with movie: MovieListItem) {
        showSkeleton(false) // Ensure skeleton is off when configuring with real data

        titleLabel.text = movie.title
        if let voteAverage = movie.voteAverage, voteAverage > 0 {
            voteAverageLabel.text = String(format: "%.1f ★", voteAverage)
        } else {
            voteAverageLabel.text = "N/A"
        }

        if let posterPath = movie.posterPath {
            ImageLoader.shared.downloadImage(from: posterPath, as: .poster) { [weak self] image in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.posterImageView.image = image
                }
            }
        } else {
            posterImageView.image = UIImage(systemName: "film") // Placeholder image
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        posterImageView.image = nil // Reset image
        titleLabel.text = nil
        voteAverageLabel.text = nil

        // Reset skeleton state
        showSkeleton(false)
    }

    // MARK: - Skeleton Loading
    private func setupPlaceholders() {
        let placeholderBackgroundColor = UIColor.systemGray5
        let placeholderCornerRadius: CGFloat = 4

        posterPlaceholderView.backgroundColor = placeholderBackgroundColor
        posterPlaceholderView.layer.cornerRadius = posterImageView.layer.cornerRadius // Match actual poster corner radius
        posterPlaceholderView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(posterPlaceholderView)

        titlePlaceholderView.backgroundColor = placeholderBackgroundColor
        titlePlaceholderView.layer.cornerRadius = placeholderCornerRadius
        titlePlaceholderView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titlePlaceholderView)

        votePlaceholderView.backgroundColor = placeholderBackgroundColor
        votePlaceholderView.layer.cornerRadius = placeholderCornerRadius
        votePlaceholderView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(votePlaceholderView)
    }

    func showSkeleton(_ show: Bool) {
        let isSkeleton = show

        posterImageView.isHidden = isSkeleton
        titleLabel.isHidden = isSkeleton
        voteAverageLabel.isHidden = isSkeleton

        posterPlaceholderView.isHidden = !isSkeleton
        titlePlaceholderView.isHidden = !isSkeleton
        votePlaceholderView.isHidden = !isSkeleton

        if isSkeleton {
            // Ensure placeholders are at the front if shimmer is active
            // contentView.bringSubviewToFront(posterPlaceholderView)
            // contentView.bringSubviewToFront(titlePlaceholderView)
            // contentView.bringSubviewToFront(votePlaceholderView)
            
            posterPlaceholderView.startShimmering()
            titlePlaceholderView.startShimmering()
            votePlaceholderView.startShimmering()
        } else {
            posterPlaceholderView.stopShimmering()
            titlePlaceholderView.stopShimmering()
            votePlaceholderView.stopShimmering()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Update shimmer frames if the cell's layout changes
        posterPlaceholderView.updateShimmerFrame()
        titlePlaceholderView.updateShimmerFrame()
        votePlaceholderView.updateShimmerFrame()
    }
}
