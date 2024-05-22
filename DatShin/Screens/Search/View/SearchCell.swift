//
//  SearchCell.swift
//  DatShin
//
//  Created by Kaung Khant Si Thu on 19/05/2024.
//

import UIKit
import NukeExtensions
import Nuke

class SearchCell: UITableViewCell, SelfConfiguringCell {
    static var reuseIdentifier: String { String(describing: Self.self) }
    
    let posterImageView = UIImageView(frame: .zero)
    let titleLabel = DSTitleLabel(textAlignment: .left, fontSize: 16)
    private let ratingLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        posterImageView.contentMode = .scaleAspectFill
        posterImageView.clipsToBounds = true
        posterImageView.backgroundColor = .systemGray
//        posterImageView.layer.cornerRadius = 10
        
        posterImageView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(posterImageView)
        
        titleLabel.numberOfLines = 0
        
        ratingLabel.font = .preferredFont(forTextStyle: .caption2)
        ratingLabel.textColor = .secondaryLabel
        ratingLabel.numberOfLines = 0
        
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
        
        accessoryType = .disclosureIndicator
        
        let padding: CGFloat = 10
        
        
        NSLayoutConstraint.activate([
            posterImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding),
            posterImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding),

//            posterImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            posterImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            
            posterImageView.widthAnchor.constraint(equalToConstant: 90),
            posterImageView.heightAnchor.constraint(equalTo: posterImageView.widthAnchor, multiplier: 1.5),

            captionStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding),
            captionStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding),

            captionStack.leadingAnchor.constraint(equalTo: posterImageView.trailingAnchor, constant: padding),
            captionStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
//            captionStack.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with movie: Movie) {
        titleLabel.text = movie.title
        ratingLabel.text = movie.voteAverage?.formatted(.number.precision(.fractionLength(1)))
        let imageURL = ImageLoader.shared.generateFullURL(from: movie.posterPath, as: .poster)
        let request = self.makeRequest(with: imageURL, cellSize: bounds.size)
        let options = self.makeImageLoadingOptions()
        NukeExtensions.loadImage(with: request, options: options, into: posterImageView)
    }
    
    func makeRequest(with url: URL, cellSize: CGSize) -> ImageRequest {
        ImageRequest(url: url)
    }
    
    func makeImageLoadingOptions() -> ImageLoadingOptions {
        ImageLoadingOptions(transition: .fadeIn(duration: 0.25))
    }
}
