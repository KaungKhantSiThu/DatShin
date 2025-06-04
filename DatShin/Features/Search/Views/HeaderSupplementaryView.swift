//
//  HeaderSupplementaryView.swift
//  DatShin
//
//  Created by Cascade on 05/06/2025.
//

import UIKit

class HeaderSupplementaryView: UICollectionReusableView {
    static let reuseIdentifier = "HeaderSupplementaryView"
    
    let titleLabel = DSTitleLabel(textAlignment: .left, fontSize: 22)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])
    }
    
    func configure(with title: String?) {
        titleLabel.text = title
    }
}
