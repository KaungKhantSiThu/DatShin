//
//  StreamingCell.swift
//  DatShin
//
//  Created by Kaung Khant Si Thu on 29/05/2024.
//

import UIKit

class StreamingCell: UICollectionViewCell {
    static var reuseIdentifier: String = String(describing: StreamingCell.self)
    private let imageView = UIImageView()
    private let label = UILabel()
    
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
        
//        imageView.translatesAutoresizingMaskIntoConstraints = false
//        contentView.addSubview(imageView)
        
        label.font = UIFont.preferredFont(forTextStyle: .subheadline)
        label.textColor = .label
        
//        label.translatesAutoresizingMaskIntoConstraints = false
//        contentView.addSubview(label)
        
        let stackView = UIStackView(arrangedSubviews: [imageView, label])
        stackView.axis = .horizontal
        stackView.distribution = .fillProportionally
        stackView.alignment = .center
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)
        
        contentView.layer.cornerRadius = 15
        contentView.backgroundColor = .systemGray6
        
        let padding: CGFloat = 10
        NSLayoutConstraint.activate([
//            imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding),
//            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
//            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),
            
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding)

//            label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding),
//            label.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: padding),
//            label.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -padding)
//            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding),
        ])
        
    }
    
    func configure(with watchProvider: WatchProvider) {
        ImageLoader.shared.downloadImage(from: watchProvider.logoPath, as: .logo) { [weak self] image in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.imageView.image = image
            }
        }
        
        self.label.text = watchProvider.name
    }
}
