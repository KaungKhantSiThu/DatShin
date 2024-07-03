//
//  GenreCell.swift
//  DatShin
//
//  Created by Kaung Khant Si Thu on 03/06/2024.
//

import UIKit

class GenreCell: UICollectionViewCell {
    static var reuseIdentifier: String = String(describing: GenreCell.self)
    private let label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        
//        imageView.translatesAutoresizingMaskIntoConstraints = false
//        contentView.addSubview(imageView)
        
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.textColor = .label
        
        label.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(label)
        
        contentView.layer.cornerRadius = 15
        contentView.backgroundColor = .systemGray6
        
//        let padding: CGFloat = 10
        NSLayoutConstraint.activate([

            label.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
//            label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding),
//            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding),
//            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
//            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding)

        ])
        
    }
    
    func configure(with genre: Genre) {
        self.label.text = genre.name
    }
}

