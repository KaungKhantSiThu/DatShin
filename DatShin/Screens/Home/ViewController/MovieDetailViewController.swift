//
//  MovieDetailViewController.swift
//  DatShin
//
//  Created by Kaung Khant Si Thu on 11/05/2024.
//

import UIKit

class MovieDetailViewController: NiblessViewController {
    
//    private let imageHeaderView = ImageHeaderView(frame: .zero)
//    
//    private lazy var imageView: UIImageView = {
//        let imageView = UIImageView()
//        imageView.contentMode = .scaleAspectFill
//        imageView.clipsToBounds = true
//        return imageView
//    }()
//    
//    private lazy var titleLabel: UILabel = {
//        let titleLabel = UILabel()
//        titleLabel.textColor = .label
//        titleLabel.font = UIFont.preferredFont(forTextStyle: .title1)
//        titleLabel.textAlignment = .center
//        titleLabel.adjustsFontSizeToFitWidth = true
//        return titleLabel
//    }()
//    
//    private lazy var taglineLabel: UILabel = {
//        let taglineLabel = UILabel()
//        taglineLabel.textColor = .label
//        taglineLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
//        taglineLabel.textAlignment = .center
//        taglineLabel.adjustsFontSizeToFitWidth = true
//        return taglineLabel
//    }()
//    
//    
//    private lazy var overviewTextView: UITextView = {
//        let overviewTextView = UITextView()
//        overviewTextView.textColor = .label
//        overviewTextView.font = UIFont.preferredFont(forTextStyle: .body)
//        overviewTextView.isScrollEnabled = false
//        overviewTextView.isEditable = false
//        overviewTextView.isSelectable = false
//        return overviewTextView
//    }()
//    
//    private let scrollView = UIScrollView()
//    
//    private let stackView = UIStackView()
    
    private var loadingTask: Task<Void, Never>?
    
    let viewModel: MovieDetailViewModel
    
    init(viewModel: MovieDetailViewModel) {
        self.viewModel = viewModel
        super.init()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadingTask = Task {
            do {
                try await viewModel.fetch()
            } catch {
                presentDSAlertOnMainThread(title: "Movie Fetch failed", message: error.localizedDescription, buttonTitle: "OK")
            }
            
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        loadingTask?.cancel()
    }
    
    override func loadView() {
        view = MovieDetailRootView(viewModel: viewModel)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(bookmarkTapped))
        navigationItem.rightBarButtonItem = addButton
        
    }
    
    @objc
    func bookmarkTapped() {
        viewModel.addToBookmark()
    }
}
