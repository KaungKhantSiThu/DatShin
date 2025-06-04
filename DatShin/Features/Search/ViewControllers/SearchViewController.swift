//
//  SearchViewController.swift
//  DatShin
//
//  Created by Kaung Khant Si Thu on 19/05/2024.
//

import UIKit
import Combine // Required for observing ViewModel

// MARK: - SearchViewControllerDelegate Protocol
protocol SearchViewControllerDelegate: AnyObject {
    func searchViewController(_ controller: SearchViewController, didSelectMovie movie: MovieListItem)
    func searchViewController(_ controller: SearchViewController, didSelectGenre genre: Genre)
}

class SearchViewController: DataLoadingViewController {

    // Struct to represent placeholder items for diffable data source
    struct PlaceholderItem: Hashable {
        let id = UUID()
    }
    // Internal access for use in extensions
    let skeletonCellCount = 5 // Used by DataSource extension
    
    // MARK: - UI Components
    // Internal for access from Layout extension
    lazy var searchController: UISearchController! = nil 
    var collectionView: UICollectionView!

    // Define sections for the CollectionView. Internal for access from extensions.
    enum SectionLayoutKind: Int, CaseIterable {
        case trendingMovies
        case popularMovies
        case topRatedMovies
        case nowPlayingMovies
        case upcomingMovies
        case genres
        case searchResults

        var title: String? {
            switch self {
            case .trendingMovies: return "Trending Now"
            case .popularMovies: return "Popular"
            case .topRatedMovies: return "Top Rated"
            case .nowPlayingMovies: return "Now Playing"
            case .upcomingMovies: return "Coming Soon"
            case .genres: return "Browse by Genre"
            case .searchResults: return "Search Results"
            }
        }
    }
    
    // MARK: - Delegate
    weak var delegate: SearchViewControllerDelegate?
    
    // MARK: - ViewModel
    let viewModel: SearchViewModel // Accessed by Bindings, DataSource, Delegate extensions
    var cancellables = Set<AnyCancellable>() // Accessed by Bindings extension
    
    // MARK: - Diffable Data Source
    // Internal for access from DataSource extension
    var dataSource: UICollectionViewDiffableDataSource<SectionLayoutKind, AnyHashable>!

    // MARK: - Initialization
    init(viewModel: SearchViewModel) {
        self.viewModel = viewModel
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
        configureDataSource()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Calls to methods now in extensions
        applyAllSectionsSnapshot(animatingDifferences: false) 
        setupBindings()
        viewModel.fetchInitialDiscoveryData() // Initial data fetch trigger
    }
}
