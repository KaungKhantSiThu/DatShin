//
//  PersonCell.swift
//  DatShin
//
//  Created by Kaung Khant Si Thu on 27/05/2024.
//

import UIKit
import NukeExtensions
import Nuke

class PersonCell: UICollectionViewCell {
    static var reuseIdentifier: String = String(describing: PersonCell.self)
    
    private let imageView = UIImageView()
    
    private let nameLabel = UILabel()
    private let roleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .gray
        imageView.clipsToBounds = true
        
//        imageView.layer.masksToBounds = false
        imageView.layer.cornerRadius = 60
        imageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(imageView)
        
        
        nameLabel.font = .preferredFont(forTextStyle: .subheadline)
        nameLabel.textColor = .label
        nameLabel.numberOfLines = 0
        
        roleLabel.font = .preferredFont(forTextStyle: .caption1)
        roleLabel.textColor = .secondaryLabel
        roleLabel.numberOfLines = 0
        
        let captionStack = UIStackView(arrangedSubviews: [nameLabel, roleLabel])
        captionStack.axis = .vertical
        captionStack.spacing = 0
        captionStack.distribution = .fillProportionally
        captionStack.alignment = .center
        
        captionStack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(captionStack)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor),

            
            captionStack.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 5),
            captionStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            captionStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            captionStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
        
    }
    
    func configure(with castMember: CastMember) {
        nameLabel.text = castMember.name
        roleLabel.text = castMember.character
        let imageURL = ImageLoader.shared.generateFullURL(from: castMember.profilePath, as: .profile, idealWidth: 60)
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
