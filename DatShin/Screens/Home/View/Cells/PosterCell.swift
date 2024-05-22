//
//  PosterCell.swift
//  DatShin
//
//  Created by Kaung Khant Si Thu on 11/05/2024.
//

import UIKit
import NukeExtensions
import Nuke

class PosterCell: UICollectionViewCell, SelfConfiguringCell {
    static var reuseIdentifier: String = String(describing: PosterCell.self)
    
    
    
    private let imageView = UIImageView()
    
    private let rankLabel = UILabel()
    private let titleLabel = UILabel()
    private let ratingLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(imageView)
        
        rankLabel.font = .systemFont(ofSize: 40, weight: .bold)
        rankLabel.textColor = .secondaryLabel
        rankLabel.numberOfLines = 1
        
        rankLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(rankLabel)
        
        titleLabel.font = .preferredFont(forTextStyle: .caption1)
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 1
        
        ratingLabel.font = .preferredFont(forTextStyle: .caption2)
        ratingLabel.textColor = .secondaryLabel
        ratingLabel.numberOfLines = 1
        
        let configuration = UIImage.SymbolConfiguration(weight: .medium)
        let ratingSymbol = UIImage(systemName: "star.fill", withConfiguration: configuration)
        let ratingImage = UIImageView(image: ratingSymbol)
        ratingImage.tintColor = .systemYellow
        
        let ratingStackView = UIStackView(arrangedSubviews: [ratingImage, ratingLabel])
        ratingStackView.axis = .horizontal
        ratingStackView.spacing = 5
        ratingStackView.alignment = .center
        
        let captionStack = UIStackView(arrangedSubviews: [titleLabel, ratingStackView])
        captionStack.axis = .vertical
        captionStack.spacing = 5
        captionStack.alignment = .leading
        
        captionStack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(captionStack)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: 1.5),
            
            rankLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 5),
            rankLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            rankLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            captionStack.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 5),
            captionStack.leadingAnchor.constraint(equalTo: rankLabel.trailingAnchor, constant: 10),
            captionStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 5),
            captionStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

        ])
        
    }
    
    func configure(with movie: Movie) {
        titleLabel.text = movie.title
        ratingLabel.text = movie.voteAverage?.formatted(.number.precision(.fractionLength(1)))
        rankLabel.text = "1"
        let imageURL = ImageLoader.shared.generateFullURL(from: movie.backdropPath, as: .backdrop, idealWidth: 100)
        let request = self.makeRequest(with: imageURL, cellSize: bounds.size)
        let options = self.makeImageLoadingOptions()
        NukeExtensions.loadImage(with: request, options: options, into: imageView)
    }
    
    func makeRequest(with url: URL, cellSize: CGSize) -> ImageRequest {
        ImageRequest(url: url)
    }
    
    func makeImageLoadingOptions() -> ImageLoadingOptions {
        ImageLoadingOptions(transition: .fadeIn(duration: 0.25))
    }
}
