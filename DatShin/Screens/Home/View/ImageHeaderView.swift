//
//  ImageHeaderView.swift
//  DatShin
//
//  Created by Kaung Khant Si Thu on 13/05/2024.
//

import UIKit

class ImageHeaderView: UIView {
    
    var image: UIImage? {
        didSet {
            backgroundImageView.image = image
        }
    }
    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }
    
    private lazy var backgroundImageView: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false // To flag that we are using Constraints to set the layout
        image.contentMode = .scaleAspectFill
        return image
    }()

    private lazy var gradientView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false // IMPORTANT IF YOU ARE USING CONSTRAINTS INSTEAD OF FRAMES
        return view
    }()

    // VStack equivalent in UIKit
    private lazy var contentStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.distribution = .fillProportionally // Setting the distribution to fill based on the content
        return stack
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0 // Setting line number to 0 to allow sentence breaks
        label.font = UIFont.preferredFont(forTextStyle: .title1) // Custom font defined for the project
        label.textColor = .white
        return label
    }()
    
    convenience init(image: UIImage?, title: String) {
        self.init(frame: .zero)
        self.backgroundImageView.image = image
        self.titleLabel.text = title
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        self.addSubview(backgroundImageView) // Adding the subview to the current view. i.e., self

//        // Setting the corner radius of the view
//        self.layer.cornerRadius = 10
//        self.layer.masksToBounds = true

        NSLayoutConstraint.activate([
            backgroundImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            backgroundImageView.topAnchor.constraint(equalTo: topAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])

        setupGradientView()
        setupTitleLabel()
    }

    private func setupGradientView() {
        let height = frame.height * 0.9 // Height of the translucent gradient view

        addSubview(gradientView)
        NSLayoutConstraint.activate([
            gradientView.leadingAnchor.constraint(equalTo: leadingAnchor),
            gradientView.trailingAnchor.constraint(equalTo: trailingAnchor),
            gradientView.bottomAnchor.constraint(equalTo: bottomAnchor),
            gradientView.heightAnchor.constraint(equalToConstant: height)
        ])

        // Adding the gradient
        let colorTop =  UIColor.clear
        let colorBottom = UIColor.black

        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [colorTop.cgColor, colorBottom.cgColor]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.frame = CGRect(
            x: 0,
            y: self.frame.height - height,
            width: self.frame.width,
            height: height)
        gradientView.layer.insertSublayer(gradientLayer, at:0)
    }

    private func setupTitleLabel() {

        // Adding the views to the stackview
        contentStack.addArrangedSubview(titleLabel)

        gradientView.addSubview(contentStack)
        NSLayoutConstraint.activate([
            contentStack.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            contentStack.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            contentStack.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -20)
        ])
    }
}

//#Preview {
//    let imageHeader = ImageHeaderView()
//    imageHeader.image = UIImage(named: "backdrop")
//    imageHeader.title = "Kingdom of the planet of the apes"
//    return imageHeader
//}
