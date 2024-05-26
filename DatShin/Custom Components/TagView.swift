//
//  TagView.swift
//  DatShin
//
//  Created by Kaung Khant Si Thu on 24/05/2024.
//

import UIKit

struct Tag {
    let name: String
    let color: UIColor
}

class TagCell: UICollectionViewCell {
    
    static var reuseIdentifier = String(describing: TagCell.self)
    private let label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        label.numberOfLines = 0
        label.textAlignment = .center
        
        contentView.addSubview(label)
        
        
        contentView.layer.cornerRadius = 10
        
        let padding: CGFloat = 10
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding)
        ])
    }
    
    func configure(with tag: Tag) {
        label.text = tag.name
        contentView.backgroundColor = tag.color
    }
    
    override var intrinsicContentSize: CGSize {
        let width = label.intrinsicContentSize.width + 10 + 10
        let height = label.intrinsicContentSize.height + 5 + 5
        return CGSize(width: width, height: height)
    }
}
