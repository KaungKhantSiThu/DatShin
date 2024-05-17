//
//  FeaturedPropertiesView.swift
//  DatShin
//
//  Created by Kaung Khant Si Thu on 17/05/2024.
//

import UIKit

class FeaturedPropertiesView: UIView {

    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let captionLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .secondarySystemBackground
        
        titleLabel.font = Appearance.titleFont
        titleLabel.textColor = UIColor.label
        titleLabel.adjustsFontForContentSizeCategory = true
        
        subtitleLabel.font = Appearance.subtitleFont
        subtitleLabel.textColor = UIColor.secondaryLabel
        subtitleLabel.adjustsFontForContentSizeCategory = true
                                       
        captionLabel.font = Appearance.likeCountFont
        captionLabel.textColor = .secondaryLabel
        captionLabel.adjustsFontForContentSizeCategory = true
        
        let stackView = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel, captionLabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
