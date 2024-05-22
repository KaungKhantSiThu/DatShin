//
//  MovieDetailViewController.swift
//  DatShin
//
//  Created by Kaung Khant Si Thu on 11/05/2024.
//

import UIKit

//protocol MovieDetailViewControllerDelegate: AnyObject {
//    func movieDetailViewController(_ viewcontroller: MovieDetailViewController, didTapFavorite: Movie.ID)
//}

class MovieDetailViewController: DSDataLoadingViewController {
    
    private var loadingTask: Task<Void, Never>?
    
    let viewModel: MovieDetailViewModel
    
    init(viewModel: MovieDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        viewModel.addToWatchlist()
    }
}
