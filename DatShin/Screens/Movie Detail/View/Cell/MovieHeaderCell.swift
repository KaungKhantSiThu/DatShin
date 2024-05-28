//
//  MovieHeaderCell.swift
//  DatShin
//
//  Created by Kaung Khant Si Thu on 28/05/2024.
//

import UIKit

class MovieHeaderCell: UICollectionViewCell {
    static let reuseIdentifier = "MovieHeaderCell"
    
    private let posterImageView = UIImageView()
    private let titleLabel = UILabel()
    private let genreLabel = UILabel()
    private let releasedDateLabel = UILabel()
    private let runtimeLabel = UILabel()
    private let descriptionLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        
        posterImageView.contentMode = .scaleAspectFill
        posterImageView.clipsToBounds = true
        
        posterImageView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(posterImageView)
        
        // Height of the translucent gradient view
        let height = frame.height * 0.9
            
        let colorTop =  UIColor.clear
        let colorBottom = UIColor.black

        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [colorTop.cgColor, colorBottom.cgColor]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.frame = CGRect(
            x: 0,
            y: self.frame.height - height,
            width: self.frame.width,
            height: height)
        
        let gradientView = UIView()
        
        gradientView.layer.insertSublayer(gradientLayer, at:0)
        
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(gradientView)
        
        
        
        titleLabel.font = Appearance.titleFont
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 0
        
        genreLabel.font = UIFont.preferredFont(forTextStyle: .callout)
        genreLabel.textColor = .lightGray
        genreLabel.numberOfLines = 0
        
        runtimeLabel.font = UIFont.preferredFont(forTextStyle: .callout)
        runtimeLabel.textColor = .lightGray
        runtimeLabel.numberOfLines = 0
        
        releasedDateLabel.font = UIFont.preferredFont(forTextStyle: .callout)
        releasedDateLabel.textColor = .lightGray
        releasedDateLabel.numberOfLines = 0
        
        descriptionLabel.font = UIFont.preferredFont(forTextStyle: .body)
        descriptionLabel.textColor = .white
        descriptionLabel.numberOfLines = 3
        
        let attributeStackView = UIStackView(arrangedSubviews: [genreLabel, releasedDateLabel, runtimeLabel])
        attributeStackView.axis = .horizontal
        attributeStackView.distribution = .fillProportionally
        
        let stackView = UIStackView(arrangedSubviews: [titleLabel, attributeStackView, descriptionLabel])
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)
        
        let padding: CGFloat = 10
        
        NSLayoutConstraint.activate([
            posterImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            posterImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            posterImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            posterImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            gradientView.topAnchor.constraint(equalTo: contentView.topAnchor),
            gradientView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            gradientView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            gradientView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding)
        ])
    }
    
    func configure(with movie: Movie) {
        ImageLoader.shared.downloadImage(from: movie.posterPath, as: .poster) { [weak self] image in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.posterImageView.image = image
            }
        }
        
        titleLabel.text = movie.title
        genreLabel.text = movie.genres?.first?.name ?? "No genres"
        releasedDateLabel.text = movie.releaseDate?.formatted(.dateTime.day().month().year()) ?? "No Date"
        runtimeLabel.text = "\(movie.runtime ?? 0) m"
        descriptionLabel.text = movie.overview ?? "No Overview"
    }
}
