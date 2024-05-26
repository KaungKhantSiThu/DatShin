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
    
    private let imageHeaderView: ImageHeaderView = {
        let imageHeaderView = ImageHeaderView()
        imageHeaderView.title = ""
        return imageHeaderView
    }()
    
    private let taglineLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.text = ""
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private let runtimeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.text = ""
        label.font = UIFont.preferredFont(forTextStyle: .subheadline)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private let overviewTextView: UITextView = {
        let overviewTextView = UITextView()
        overviewTextView.textColor = .label
        overviewTextView.font = UIFont.preferredFont(forTextStyle: .body)
        overviewTextView.isScrollEnabled = false
        overviewTextView.isEditable = false
        overviewTextView.isSelectable = false
        return overviewTextView
    }()
    
    let scrollView = UIScrollView()
        
    lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            imageHeaderView,
            taglineLabel,
            runtimeLabel,
            overviewTextView,
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
        hierarchyNotReady = false
        print("didMoveToWindow")
    }
    
    private func constructHierarchy() {
        scrollView.addSubview(stackView)
        addSubview(scrollView)
        
        
    }
    
    func activateConstraints() {
        activateConstraintsScrollView()
        activateConstraintsStackView()
    }
    
    func activateConstraintsScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
                scrollView.topAnchor.constraint(equalTo: topAnchor),
                scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
                scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
                scrollView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
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
            .receive(on: DispatchQueue.main)
            .assign(to: \.image, on: imageHeaderView)
            .store(in: &subscriptions)
        
        viewModel.$title
            .receive(on: DispatchQueue.main)
            .assign(to: \.title!, on: imageHeaderView)
            .store(in: &subscriptions)
        
        viewModel.$tagline
            .receive(on: DispatchQueue.main)
            .assign(to: \.text!, on: taglineLabel)
            .store(in: &subscriptions)
        
        viewModel.$runtime
            .receive(on: DispatchQueue.main)
            .assign(to: \.text!, on: runtimeLabel)
            .store(in: &subscriptions)

        viewModel.$overview
            .receive(on: DispatchQueue.main)
            .assign(to: \.text, on: overviewTextView)
            .store(in: &subscriptions)
        
    }
}
