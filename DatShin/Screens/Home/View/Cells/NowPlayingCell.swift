//
//  FeaturedViewCell.swift
//  DatShin
//
//  Created by Kaung Khant Si Thu on 17/05/2024.
//

import UIKit

class NowPlayingCell: UICollectionViewCell, SelfConfiguringCell {
    
    static var reuseIdentifier: String = String(describing: NowPlayingCell.self)
    
    
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let captionLabel = UILabel()
    
    private let gradientView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .secondarySystemBackground
        // Clips to Bounds because images draw outside their bounds
        // when a corner radius is set.
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(imageView)
        
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
        gradientView.layer.insertSublayer(gradientLayer, at:0)
        
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(gradientView)
        
        titleLabel.font = Appearance.subtitleFont
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 0
        titleLabel.adjustsFontForContentSizeCategory = true
        
        subtitleLabel.font = Appearance.likeCountFont
        subtitleLabel.textColor = .lightGray
        subtitleLabel.adjustsFontForContentSizeCategory = true
                                       
        captionLabel.font = Appearance.likeCountFont
        captionLabel.textColor = .secondaryLabel
        captionLabel.adjustsFontForContentSizeCategory = true
        
        let stackView = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel, captionLabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .center
        contentView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            gradientView.topAnchor.constraint(equalTo: contentView.topAnchor),
            gradientView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            gradientView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            gradientView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
//            gradientView.heightAnchor.constraint(equalToConstant: height),
            
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configure(with movie: Movie) {
        titleLabel.text = movie.title
        
//        if let genres = movie.genres {
//            subtitleLabel.text = genres.map { $0.name }.joined(separator: ", ")
//        }
        
        subtitleLabel.text = movie.genres?.map { $0.name }.joined(separator: ", ") ?? "Fake genres"
        
        captionLabel.text = movie.tagline
        
        ImageLoader.shared.downloadImage(from: movie.posterPath, as: .poster) { [weak self] image in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.imageView.image = image
            }
        }
    }
    
}
