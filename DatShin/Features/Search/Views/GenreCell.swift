//
//  GenreCell.swift
//  DatShin
//
//  Created by Cascade on [Current Date].
//

import UIKit

class GenreCell: UICollectionViewCell {
    static let reuseIdentifier = "GenreCell"
    
    let titleLabel = DSTitleLabel(textAlignment: .center, fontSize: 16)
    
    // MARK: - Placeholder View
    private let titlePlaceholderView = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
        setupPlaceholders()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        contentView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.numberOfLines = 1
        
        // Make the cell visually distinct, e.g., with a background color and rounded corners
        contentView.backgroundColor = .systemGray6
        contentView.layer.cornerRadius = 8
        contentView.clipsToBounds = true
        
        NSLayoutConstraint.activate([
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
        ])
    }
    
    func configure(with genre: Genre) {
        showSkeleton(false) // Ensure skeleton is off
        titleLabel.text = genre.name
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        showSkeleton(false) // Reset skeleton state
    }
    
    // MARK: - Skeleton Loading
    private func setupPlaceholders() {
        titlePlaceholderView.backgroundColor = .systemGray4 // Slightly darker for contrast with cell background
        titlePlaceholderView.layer.cornerRadius = 4
        titlePlaceholderView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titlePlaceholderView)
        titlePlaceholderView.isHidden = true

        NSLayoutConstraint.activate([
            titlePlaceholderView.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            titlePlaceholderView.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor, constant: 0),
            titlePlaceholderView.widthAnchor.constraint(equalTo: titleLabel.widthAnchor, multiplier: 0.6), // Placeholder width
            titlePlaceholderView.heightAnchor.constraint(equalToConstant: titleLabel.font.pointSize * 0.8) // Placeholder height
        ])
    }

    func showSkeleton(_ show: Bool) {
        let isSkeleton = show

        titleLabel.isHidden = isSkeleton
        titlePlaceholderView.isHidden = !isSkeleton

        if isSkeleton {
            // contentView.bringSubviewToFront(titlePlaceholderView)
            titlePlaceholderView.startShimmering()
        } else {
            titlePlaceholderView.stopShimmering()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        titlePlaceholderView.updateShimmerFrame()
    }
}
