//
//  SearchViewController.swift
//  DatShin
//
//  Created by Kaung Khant Si Thu on 19/05/2024.
//

import UIKit
import Combine // Required for observing ViewModel
import Nuke

// MARK: - SearchViewControllerDelegate Protocol
protocol SearchViewControllerDelegate: AnyObject {
    func searchViewController(_ controller: SearchViewController, didSelectMovie movie: MovieListItem) // Can be deprecated or adapted if didSelectMedia covers its use case
    func searchViewController(_ controller: SearchViewController, didSelectGenre genre: Genre)
    func searchViewController(_ controller: SearchViewController, didSelectMedia media: Media) // New method for any media type
    // func searchViewControllerDidTapSearchButton(_ controller: SearchViewController) // This is handled by UISearchController now
}

// Pagination indicator struct removed (no longer needed for search screen)

// MARK: - Supporting Types

class SearchViewController: DataLoadingViewController, SearchResultsViewControllerDelegate {

    // Internal access for use in extensions
    let skeletonCellCount = 5 // Used by DataSource extension
    internal let imagePrefetcher = ImagePrefetcher()
    
    // MARK: - UI Components
    // Internal for access from Layout extension
    // lazy var searchController: UISearchController! = nil // Removed: Search bar moved to SearchResultsViewController
    var collectionView: UICollectionView!
    
    // MARK: - Delegate
    weak var delegate: SearchViewControllerDelegate?
    
    // MARK: - ViewModel
    let viewModel: SearchViewModel // Accessed by Bindings, DataSource, Delegate extensions
    private let searchResultsViewController: SearchResultsViewController
    private let searchController: UISearchController
    var cancellables = Set<AnyCancellable>() // Accessed by Bindings extension
    
    // MARK: - Collection View Data Source
    internal var dataSource: SearchCollectionViewDataSource!

    // MARK: - Initialization
    init(viewModel: SearchViewModel, serviceFactory: ServiceFactoryProtocol) {
        self.viewModel = viewModel
        let searchResultsViewModel = serviceFactory.makeSearchResultsViewModel()
        self.searchResultsViewController = SearchResultsViewController(viewModel: searchResultsViewModel)
        self.searchController = UISearchController(searchResultsController: self.searchResultsViewController)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle Methods
    override func loadView() {
        super.loadView()
        // Calls to methods now in extensions
        configureViewController()
        configureHierarchy()
        configureCollectionView()
        collectionView.prefetchDataSource = self // Set prefetch data source
        dataSource = SearchCollectionViewDataSource(collectionView: collectionView, viewModel: viewModel)
        dataSource.configureSupplementaryViews()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Calls to methods now in extensions
        configureSearchController()
        dataSource.applyAllSectionsSnapshot(animatingDifferences: false)

        setupBindings()
        viewModel.fetchInitialDiscoveryData() // Initial data fetch trigger
    }

    // MARK: - Search Controller Configuration
    private func configureSearchController() {
        searchController.searchResultsUpdater = searchResultsViewController
        searchController.searchBar.delegate = searchResultsViewController // For cancel/search button taps
        searchController.obscuresBackgroundDuringPresentation = false
//        searchController.hidesSearchBarWhenScrolling = false // Keep search bar visible
        searchController.searchBar.placeholder = "Search Movies, TV Shows, People"
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false // Ensure it stays visible while scrolling
        definesPresentationContext = true // Important for presenting search results controller correctly
        
        // Set delegate for search results selection
        searchResultsViewController.delegate = self
    }

    // MARK: - UI Configuration
    // configureSearchNavigationItem() and searchButtonTapped() are no longer needed as UISearchController handles this.
}

// MARK: - SearchResultsViewControllerDelegate
extension SearchViewController {
    func searchResultsViewController(_ controller: SearchResultsViewController, didSelectMedia media: Media) {
        // Pass the selection to this ViewController's delegate (likely a Coordinator)
        delegate?.searchViewController(self, didSelectMedia: media)
    }
}
