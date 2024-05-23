//
//  FavoriteCell.swift
//  DatShin
//
//  Created by Kaung Khant Si Thu on 14/05/2024.
//

import UIKit

class FavoriteCell: UITableViewCell {
    
    let cellIdentifier = "FavoriteCell"
    
    let posterImageView = UIImageView(frame: .zero)
    let titleLabel = UILabel()
    
    lazy var genresLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.font = UIFont.preferredFont(forTextStyle: .subheadline)
        label.textAlignment = .left
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        posterImageView.contentMode = .scaleAspectFill
        posterImageView.clipsToBounds = true
        posterImageView.image = Images.placeholder
        
        posterImageView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(posterImageView)
        
        titleLabel.font = .preferredFont(forTextStyle: .headline)
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 0
        titleLabel.adjustsFontSizeToFitWidth = true

        
        let captionStack = UIStackView(arrangedSubviews: [titleLabel, genresLabel])
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
            captionStack.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -padding),

            captionStack.leadingAnchor.constraint(equalTo: posterImageView.trailingAnchor, constant: padding),
            captionStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
        ])
    }
}
