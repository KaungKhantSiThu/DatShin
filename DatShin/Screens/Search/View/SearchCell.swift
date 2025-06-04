//
//  SearchCell.swift
//  DatShin
//
//  Created by Kaung Khant Si Thu on 19/05/2024.
//

import UIKit
import NukeExtensions
import Nuke

class SearchCell: UITableViewCell {

    static let reuseIdentifier = "SearchCell"
    
    // MARK: - UI Components
    let movieImageView = UIImageView()
    let titleLabel = UILabel()
    let overviewLabel = UILabel()
    let genreIconView = UIImageView()
    
    // MARK: - Properties
    private var imageTask: Task<Void, Never>?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configure()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageTask?.cancel()
        movieImageView.image = nil
        genreIconView.isHidden = true
    }
    
    func configure() {
        // Add subviews
        addSubview(movieImageView)
        addSubview(titleLabel)
        addSubview(overviewLabel)
        addSubview(genreIconView)
        
        // Configure auto layout
        movieImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        overviewLabel.translatesAutoresizingMaskIntoConstraints = false
        genreIconView.translatesAutoresizingMaskIntoConstraints = false
        
        // Configure image view
        movieImageView.layer.cornerRadius = 10
        movieImageView.clipsToBounds = true
        movieImageView.contentMode = .scaleAspectFill
        movieImageView.backgroundColor = .systemGray6
        
        // Configure genre icon view
        genreIconView.contentMode = .scaleAspectFit
        genreIconView.tintColor = .systemBlue
        genreIconView.isHidden = true
        
        // Configure labels
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel.textColor = .label
        
        overviewLabel.font = UIFont.systemFont(ofSize: 14)
        overviewLabel.textColor = .secondaryLabel
        overviewLabel.numberOfLines = 2
        
        // Set constraints
        NSLayoutConstraint.activate([
            movieImageView.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            movieImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            movieImageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
            movieImageView.widthAnchor.constraint(equalToConstant: 80),
            movieImageView.heightAnchor.constraint(equalToConstant: 120),
            
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: movieImageView.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            
            overviewLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            overviewLabel.leadingAnchor.constraint(equalTo: movieImageView.trailingAnchor, constant: 12),
            overviewLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            overviewLabel.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -12),
            
            genreIconView.centerYAnchor.constraint(equalTo: centerYAnchor),
            genreIconView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            genreIconView.widthAnchor.constraint(equalToConstant: 30),
            genreIconView.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with movie: Movie) {
        // Cancel any previous image loading task
        imageTask?.cancel()
        
        // Configure for movie display
        titleLabel.text = movie.title
        overviewLabel.text = movie.overview
        genreIconView.isHidden = true
        movieImageView.isHidden = false
        
        // Load poster image with Nuke
        if let posterPath = movie.posterPath {
            let urlString = "https://image.tmdb.org/t/p/w200\(posterPath)"
            if let url = URL(string: urlString) {
                imageTask = Task {
                    do {
                        // Load image asynchronously
                        loadImage(with: url, into: movieImageView)
                    }
                }
            }
        } else {
            // Set placeholder image if no poster
            movieImageView.image = UIImage(systemName: "film")
            movieImageView.contentMode = .center
            movieImageView.tintColor = .systemGray
        }
    }
    
    func configureAsGenre(with genre: Genre) {
        // Cancel any previous image loading task
        imageTask?.cancel()
        
        // Configure for genre display
        titleLabel.text = genre.name
        overviewLabel.text = "Browse movies in this genre"
        
        // Show genre icon instead of movie poster
        movieImageView.isHidden = true
        genreIconView.isHidden = false
        genreIconView.image = UIImage(systemName: "film.stack")
        genreIconView.tintColor = .systemBlue
    }
    
    func makeImageLoadingOptions() -> ImageLoadingOptions {
        ImageLoadingOptions(transition: .fadeIn(duration: 0.25))
    }
}
