//
//  MovieDetailViewController.swift
//  DatShin
//
//  Created by Kaung Khant Si Thu on 11/05/2024.
//

import UIKit
import Combine
//protocol MovieDetailViewControllerDelegate: AnyObject {
//    func movieDetailViewController(_ viewcontroller: MovieDetailViewController, didTapFavorite: Movie.ID)
//}

class MovieDetailViewController: DSDataLoadingViewController {
    
//    private var loadingTask: Task<Void, Never>?
    
    let viewModel: MovieDetailViewModel
    
    private var subscriptions = Set<AnyCancellable>()

    
    init(viewModel: MovieDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: viewModel, action: #selector(MovieDetailViewModel.addToWatchlist))
        navigationItem.rightBarButtonItem = addButton
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        loadingTask = Task {
//            do {
//                try await viewModel.fetch()
//            } catch {
//                presentDSAlertOnMainThread(title: "Movie Fetch failed", message: error.localizedDescription, buttonTitle: "OK")
//            }
//            
//        }
//    }
    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        loadingTask?.cancel()
//    }
    
    override func loadView() {
        view = MovieDetailRootView(viewModel: viewModel)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        viewModel.fetchData()
        observeErrorMessages()
    }
    
    func observeErrorMessages() {
      viewModel
            .$error
        .receive(on: DispatchQueue.main)
        .sink { [weak self] error in
            guard let error = error else { return }
            self?.presentDSAlertOnMainThread(title: "Error", message: error.localizedDescription, buttonTitle: "Ok")
        }.store(in: &subscriptions)
    }

}
