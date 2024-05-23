//
//  SearchViewController.swift
//  DatShin
//
//  Created by Kaung Khant Si Thu on 19/05/2024.
//

import UIKit

class SearchViewController: DSDataLoadingViewController {

//    var collectionViewDataSource: UICollectionViewDiffableDataSource<Section, Int>! = nil
//    var collectionView: UICollectionView! = nil
    
    lazy var searchController: UISearchController! = nil
    var filteredMovies: [Movie] = []
    let service: SearchService
    
    private var loadingTask: Task<Void, Never>?
    
    init(service: SearchService) {
        self.service = service
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        configureViewController()
        configureHierarchy()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        loadingTask?.cancel()
    }
    
}

extension SearchViewController {
    func configureViewController() {
        view.backgroundColor = .systemBackground
        title = "Search"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    func configureHierarchy() {

        let searchResultsController = SearchResultsController()
        
        searchController = UISearchController(searchResultsController: searchResultsController)
        searchController.searchResultsUpdater = self
        searchController.searchBar.searchBarStyle = .default
        searchController.searchBar.placeholder = "Movies"
        
        
        navigationItem.searchController = searchController
        
    }
}

extension SearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text, !text.isEmpty else { return }
        loadingTask?.cancel()
        loadingTask = Task {
            // Simulate network delay
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            
            // Check for cancellation
            guard !Task.isCancelled else { return }
            
            do {
                print("Fetching Search Results (Movie)")
                filteredMovies = try await service.fetchMovies(query: text)
                if let resultsController = searchController.searchResultsController as? SearchResultsController {
                    resultsController.update(with: filteredMovies)
                }
            } catch {
                presentDSAlertOnMainThread(title: "Search failed", message: error.localizedDescription, buttonTitle: "Ok")
            }
        }
    }
}
