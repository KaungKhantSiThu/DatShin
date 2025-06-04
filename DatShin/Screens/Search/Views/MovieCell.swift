//
//  MovieCell.swift
//  DatShin
//
//  Created by Cascade on 05/06/2025.
//

import UIKit
//import TMDb

class MovieCell: UICollectionViewCell {
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
    }
    
    func configure(with movie: MovieListItem) {
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
    }
}
