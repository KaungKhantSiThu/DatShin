//
//  MovieDetailView.swift
//  DatShin
//
//  Created by Kaung Khant Si Thu on 11/05/2024.
//

import UIKit
import Combine
import Nuke
import NukeExtensions

class MovieDetailRootView: NiblessView {
    
    private var subscriptions = Set<AnyCancellable>()
    let viewModel: MovieDetailViewModel
    var hierarchyNotReady = true
    
    lazy var imageHeaderView: ImageHeaderView = {
        let imageHeaderView = ImageHeaderView()
        imageHeaderView.title = ""
        return imageHeaderView
    }()
    
    lazy var taglineLabel: UILabel = {
        let taglineLabel = UILabel()
        taglineLabel.textColor = .secondaryLabel
        taglineLabel.text = ""
        taglineLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        taglineLabel.textAlignment = .center
        taglineLabel.adjustsFontSizeToFitWidth = true
        return taglineLabel
    }()
    
    
    lazy var overviewTextView: UITextView = {
        let overviewTextView = UITextView()
        overviewTextView.textColor = .label
        overviewTextView.font = UIFont.preferredFont(forTextStyle: .body)
        overviewTextView.isScrollEnabled = false
        overviewTextView.isEditable = false
        overviewTextView.isSelectable = false
        return overviewTextView
    }()
    
    
    // Cast Members and Recommended Movies
//    lazy var collectionView: UICollectionView = {
//        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
//        collectionView.translatesAutoresizingMaskIntoConstraints = false
//        collectionView.backgroundColor = .systemBackground
//        return collectionView
//    }()
    
    let scrollView = UIScrollView()
    
    lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            imageHeaderView,
            taglineLabel,
            overviewTextView,
//            collectionView
        ])
        stackView.spacing = 10
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        return stackView
    }()
    
    init(frame: CGRect = .zero,
         viewModel: MovieDetailViewModel) {
        self.viewModel = viewModel
        super.init(frame: frame)
        bindToViewModel()
        print("init")
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        guard hierarchyNotReady else {
            return
        }
        backgroundColor = .systemBackground
        constructHierarchy()
        activateConstraints()
        //        wireController()
        hierarchyNotReady = false
        print("didMoveToWindow")
    }
    
    private func constructHierarchy() {
        scrollView.addSubview(stackView)
        addSubview(scrollView)
    }
    
    func activateConstraints() {
        activateConstraintsScrollView()
//        activateConstraintsContentView()
//        activateConstraintsImageHeaderView()
        activateConstraintsStackView()
    }
    
    func activateConstraintsScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false

//        let frameLayoutGuide = scrollView.frameLayoutGuide
        
        NSLayoutConstraint.activate([
                scrollView.topAnchor.constraint(equalTo: topAnchor),
                scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
                scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
                scrollView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
//    func activateConstraintsContentView() {
//        contentView.translatesAutoresizingMaskIntoConstraints = false
//        

//        
//        let width = contentView.widthAnchor
//            .constraint(equalTo: widthAnchor)
//        
//        let top = contentView.topAnchor
//            .constraint(equalTo: contentLayoutGuide.topAnchor)
//        let leading = contentView.leadingAnchor
//            .constraint(equalTo: contentLayoutGuide.leadingAnchor)
//        let trailing = contentView.trailingAnchor
//            .constraint(equalTo: contentLayoutGuide.trailingAnchor)
//        let bottom = contentView.bottomAnchor
//            .constraint(equalTo: contentLayoutGuide.bottomAnchor)
//        
//        NSLayoutConstraint.activate(
//            [width, leading, trailing, top, bottom])
//    }
    
//    func activateConstraintsImageHeaderView() {
//        imageHeaderView.translatesAutoresizingMaskIntoConstraints = false
//        
//        let height = imageHeaderView.heightAnchor.constraint(equalToConstant: 250)
//        let width = imageHeaderView.widthAnchor.constraint(equalTo: widthAnchor)
//        
//        let contentLayoutGuide = scrollView.contentLayoutGuide
//        let top = imageHeaderView.topAnchor
//            .constraint(equalTo: contentLayoutGuide.topAnchor)
//        let leading = imageHeaderView.leadingAnchor
//            .constraint(equalTo: contentLayoutGuide.leadingAnchor)
//        let trailing = imageHeaderView.trailingAnchor
//            .constraint(equalTo: contentLayoutGuide.trailingAnchor)
//        
//        
//        NSLayoutConstraint.activate(
//            [width, height, leading, trailing, top])
//    }
    
    func activateConstraintsStackView() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        let contentLayoutGuide = scrollView.contentLayoutGuide
        
        NSLayoutConstraint.activate([
            imageHeaderView.heightAnchor.constraint(equalToConstant: 250),
            
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            stackView.leadingAnchor
                .constraint(equalTo: contentLayoutGuide.leadingAnchor),
            stackView.trailingAnchor
                .constraint(equalTo: contentLayoutGuide.trailingAnchor),
            stackView.topAnchor
                .constraint(equalTo: contentLayoutGuide.topAnchor),
            
            stackView.bottomAnchor.constraint(equalTo: contentLayoutGuide.bottomAnchor)
            
            
        ])

    }
    
    func bindToViewModel() {
        
        viewModel.$image
            .receive(on: RunLoop.main)
            .assign(to: \.image, on: imageHeaderView)
            .store(in: &subscriptions)
        
        viewModel.$title
            .receive(on: RunLoop.main)
            .assign(to: \.title!, on: imageHeaderView)
            .store(in: &subscriptions)
        
        viewModel.$tagline
            .receive(on: RunLoop.main)
            .assign(to: \.text!, on: taglineLabel)
            .store(in: &subscriptions)
        
        viewModel.$overview
            .receive(on: RunLoop.main)
            .assign(to: \.text, on: overviewTextView)
            .store(in: &subscriptions)
    }
}
