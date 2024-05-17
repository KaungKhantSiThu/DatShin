//
//  TopChartMovieCell.swift
//  DatShin
//
//  Created by Kaung Khant Si Thu on 09/05/2024.
//

import UIKit
import Nuke
import NukeExtensions

class TopChartMovieCell: UICollectionViewCell {
    static let reuseID = "TopCharMovieCell"
    let backdropImageView = DSBackdropImageView(frame: .zero)
    let titleLabel = DSTitleLabel(textAlignment: .left, fontSize: 16)
    let subtitleLabel = DSSecondaryTitleLabel(fontSize: 14)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        let stackView = UIStackView(arrangedSubviews: [backdropImageView, titleLabel, subtitleLabel])
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
        ])
//        contentView.addSubview(backdropImageView)
//        contentView.addSubview(titleLabel)
//        contentView.addSubview(subtitleLabel)
        
//        let spacing: CGFloat = 8
        
        
//        NSLayoutConstraint.activate([
//            backdropImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
//            backdropImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
//            backdropImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
//            
//            titleLabel.topAnchor.constraint(equalTo: backdropImageView.bottomAnchor, constant: spacing),
//            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
//            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
//            
//            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
//            subtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
//            subtitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
//        ])
    }
}
