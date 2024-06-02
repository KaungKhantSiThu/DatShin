//
//  CoverCell.swift
//  DatShin
//
//  Created by Kaung Khant Si Thu on 28/05/2024.
//

import UIKit
import NukeExtensions
import Nuke

class CoverCell: UICollectionViewCell, SelfConfiguringCell {
    static var reuseIdentifier: String = String(describing: CoverCell.self)
    private let imageView = UIImageView()
    
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
        
        imageView.layer.cornerCurve = .continuous
        imageView.layer.cornerRadius = 10
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 1.5),
        ])
        
    }
    
    func configure(with movie: Movie) {
        let imageURL = ImageLoader.shared.generateFullURL(from: movie.posterPath, as: .backdrop, idealWidth: 60)
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

