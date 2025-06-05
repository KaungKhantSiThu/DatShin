//
//  MovieCell.swift
//  DatShin
//
//  Created by Cascade on 05/06/2025.
//

import UIKit
import Nuke
import NukeExtensions

/**
 MovieCell is used in the main Search screen's discovery carousels (Popular, Top Rated, Now Playing, Upcoming).
 It displays a movie poster, title, and vote average. It supports skeleton loading for smooth UX and uses Nuke for image loading and caching.
 - Registered in SearchViewController+Layout.swift (configureCollectionView)
 - Used exclusively by SearchCollectionViewDataSource
*/
class MovieCell: UICollectionViewCell {

    // MARK: - Placeholder Views
    private let posterPlaceholderView = UIView()
    static let reuseIdentifier = "MovieCell"
    
    let posterImageView = UIImageView(frame: .zero) // Assuming DSImageView is a custom UIImageView for image loading

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

        
        posterImageView.translatesAutoresizingMaskIntoConstraints = false
        
        // Basic constraints - these will need to be refined for a good layout
        NSLayoutConstraint.activate([
            posterImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            posterImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            posterImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            posterImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
        
        posterImageView.contentMode = .scaleAspectFill
        posterImageView.clipsToBounds = true
        posterImageView.layer.cornerRadius = 8

        // Constraints for placeholder views (mirroring actual views)
        NSLayoutConstraint.activate([
            posterPlaceholderView.topAnchor.constraint(equalTo: posterImageView.topAnchor),
            posterPlaceholderView.leadingAnchor.constraint(equalTo: posterImageView.leadingAnchor),
            posterPlaceholderView.trailingAnchor.constraint(equalTo: posterImageView.trailingAnchor),
            posterPlaceholderView.bottomAnchor.constraint(equalTo: posterImageView.bottomAnchor)
        ])

        // Initially hide placeholders
        posterPlaceholderView.isHidden = true

    }
    
    /// Configures the cell with a MovieListItem and ImagesConfiguration (from TMDb API)
    /// - Parameters:
    ///   - movie: The movie item to display
    ///   - imagesConfiguration: The configuration for constructing poster URLs
    ///
    /// Best practice: Always call showSkeleton(false) before setting real data.
    /// Nuke is used for image loading; image requests are cancelled in prepareForReuse.
    func configure(with movie: MovieListItem, imagesConfiguration: ImagesConfiguration) {
        showSkeleton(false) // Ensure skeleton is off when configuring with real data

        if let posterPath = movie.posterPath {
            // Calculate ideal width based on imageView size and screen scale for optimal quality
            let idealWidth = Int(bounds.width * UIScreen.main.scale)
            guard let fullPosterURL = imagesConfiguration.posterURL(for: posterPath, idealWidth: idealWidth) else {
                posterImageView.image = UIImage(systemName: "film") // Placeholder if URL construction fails
                return
            }

            let options = ImageLoadingOptions(
                placeholder: UIImage(systemName: "photo"), // General placeholder
                transition: .fadeIn(duration: 0.25)
            )
            
            loadImage(with: fullPosterURL, options: options, into: posterImageView)
        } else {
            posterImageView.image = UIImage(systemName: "film") // Placeholder for no poster path
        }
    }
    
    /// Prepares the cell for reuse by cancelling any ongoing image requests and resetting UI state.
    override func prepareForReuse() {
        super.prepareForReuse()
        cancelRequest(for: posterImageView)
        posterImageView.image = nil // Reset image

        // Reset skeleton state
        showSkeleton(false)
    }

    // MARK: - Skeleton Loading
    /// Call showSkeleton(true) to display skeleton placeholders with shimmer animation.
    /// Call showSkeleton(false) to display real content.
    /// Placeholders are layered and animated for a smooth loading experience.
    private func setupPlaceholders() {
        let placeholderBackgroundColor = UIColor.systemGray5
        let placeholderCornerRadius: CGFloat = 4

        posterPlaceholderView.backgroundColor = placeholderBackgroundColor
        posterPlaceholderView.layer.cornerRadius = posterImageView.layer.cornerRadius // Match actual poster corner radius
        posterPlaceholderView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(posterPlaceholderView)

    }

    func showSkeleton(_ show: Bool) {
        let isSkeleton = show

        posterImageView.isHidden = isSkeleton
        

        posterPlaceholderView.isHidden = !isSkeleton

        if isSkeleton {
            
            posterPlaceholderView.startShimmering()

        } else {
            posterPlaceholderView.stopShimmering()

        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Update shimmer frames if the cell's layout changes
        posterPlaceholderView.updateShimmerFrame()

    }
}
