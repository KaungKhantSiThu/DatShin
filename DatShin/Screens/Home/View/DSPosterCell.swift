//
//  DSPosterCell.swift
//  DatShin
//
//  Created by Kaung Khant Si Thu on 11/05/2024.
//

import UIKit
import NukeExtensions
import Nuke

class DSPosterCell: UICollectionViewCell, SelfConfiguringCell {
    static var reuseIdentifier: String = String(describing: DSPosterCell.self)
    
    
    
    let imageView = UIImageView()
    
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
        contentView.addSubview(imageView)
        imageView.pinToSuperview()
    }
    
    func configure(with movie: Movie) {
        let imageURL = ImageLoader.shared.generateFullURL(from: movie.posterPath, as: .poster, idealWidth: 100)
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
