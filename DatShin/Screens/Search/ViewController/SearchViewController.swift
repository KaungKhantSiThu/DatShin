//
//  SearchViewController.swift
//  DatShin
//
//  Created by Kaung Khant Si Thu on 19/05/2024.
//

import UIKit

import Combine // Required for observing ViewModel
//import TMDb // Required for TMDb.Movie, TMDb.Genre if used directly, though ViewModel abstracts this

// MARK: - SearchViewControllerDelegate Protocol
protocol SearchViewControllerDelegate: AnyObject {
    func searchViewController(_ controller: SearchViewController, didSelectMovie movie: MovieListItem)
    func searchViewController(_ controller: SearchViewController, didSelectGenre genre: Genre)
}

class SearchViewController: DSDataLoadingViewController {
    
    // MARK: - UI Components
    lazy var searchController: UISearchController! = nil
    //    lazy var tableView = UITableView(frame: .zero, style: .grouped) // To be replaced
    var collectionView: UICollectionView! // New CollectionView
    private typealias RootView = UICollectionView // Alias for clarity if needed elsewhere

    // Define sections for the CollectionView
    enum SectionLayoutKind: Int, CaseIterable {
        case trendingMovies
        case popularMovies
        case topRatedMovies
        case nowPlayingMovies
        case upcomingMovies
        case genres
        case searchResults
        // Add more sections as needed

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
    private let viewModel: SearchViewModel
    private var cancellables = Set<AnyCancellable>()
    
    init(viewModel: SearchViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        configureViewController()
        configureHierarchy() // This will initialize collectionView
        configureCollectionView() // This will set delegates and register cells
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // loadInitialData() // ViewModel handles this
        setupBindings()
        viewModel.fetchInitialDiscoveryData()
    }
    
    // viewWillDisappear can remain if needed for searchController or other tasks, 
    // but loadingTask is removed so it's not needed for that.
    
}

extension SearchViewController {
    
    func setupBindings() {
        // Bindings for data arrays to reload collection view
        let dataChangedPublisher = Publishers.MergeMany(
            viewModel.$popularMovies.map { _ in SectionLayoutKind.popularMovies }.eraseToAnyPublisher(),
            viewModel.$topRatedMovies.map { _ in SectionLayoutKind.topRatedMovies }.eraseToAnyPublisher(),
            viewModel.$nowPlayingMovies.map { _ in SectionLayoutKind.nowPlayingMovies }.eraseToAnyPublisher(),
            viewModel.$upcomingMovies.map { _ in SectionLayoutKind.upcomingMovies }.eraseToAnyPublisher(),
            viewModel.$trendingMovies.map { _ in SectionLayoutKind.trendingMovies }.eraseToAnyPublisher(),
            viewModel.$movieGenres.map { _ in SectionLayoutKind.genres }.eraseToAnyPublisher(),
            viewModel.$searchResults.map { _ in SectionLayoutKind.searchResults }.eraseToAnyPublisher()
        )
        .receive(on: DispatchQueue.main)
        // .debounce(for: .milliseconds(100), scheduler: DispatchQueue.main) // Optional: debounce reloads
        .sink { [weak self] sectionKindThatChanged in
            // self?.collectionView.reloadData() // Reload all data
            // Or, more efficiently, reload specific sections if possible and needed:
            // if let sectionIndex = SectionLayoutKind.allCases.firstIndex(of: sectionKindThatChanged) {
            //    self?.collectionView.reloadSections(IndexSet(integer: sectionIndex))
            // }
            // For simplicity now, reload all. We can optimize later.
            self?.collectionView?.reloadData()
            print("Reloading collection view due to change in \(sectionKindThatChanged)")
        }
        .store(in: &cancellables)

        // Bind loading states (example for one, repeat for others)
        viewModel.$isLoadingPopular
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                // TODO: Show/hide loading indicator for popular section or globally
                print("Popular movies loading state: \(isLoading)")
            }
            .store(in: &cancellables)
        
        // TODO: Add similar bindings for other isLoading properties (topRated, nowPlaying, etc.)
        // to update specific section loading states or a global loading indicator.

        viewModel.$currentSearchQuery
            .receive(on: DispatchQueue.main)
            .map { $0 as String? } // Ensure the output type matches the property's optionality
            .assign(to: \.searchBar.text, on: navigationItem.searchController!)
            .store(in: &cancellables)
    }
    func configureViewController() {
        view.backgroundColor = .systemBackground
        title = "Search"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    // loadInitialData() is removed, ViewModel handles data fetching
    
    func configureHierarchy() {
        // Configure search controller
        // Consider if SearchResultsController is still needed or if results display in main collection view
        let searchResultsController = SearchResultsController() // Keeping for now
        
        searchController = UISearchController(searchResultsController: searchResultsController)
        searchController.searchResultsUpdater = self
        searchController.searchBar.searchBarStyle = .default
        searchController.searchBar.placeholder = "Search movies, TV shows, people..."
        // searchController.obscuresBackgroundDuringPresentation = true // Set to false if results are in main VC
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false // Keep search bar visible
        definesPresentationContext = true
        
        // Configure collection view
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .systemBackground
        view.addSubview(collectionView)
        // No need for manual constraints if using autoresizingMask and view.bounds for frame
        // If specific constraints are needed:
        // collectionView.translatesAutoresizingMaskIntoConstraints = false
        // NSLayoutConstraint.activate([
        //     collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
        //     collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
        //     collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        //     collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        // ])
    }
    
    func configureCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        
        // Register custom cells and supplementary views (headers)
        collectionView.register(MovieCell.self, forCellWithReuseIdentifier: MovieCell.reuseIdentifier)
        collectionView.register(GenreCell.self, forCellWithReuseIdentifier: GenreCell.reuseIdentifier)
        collectionView.register(HeaderSupplementaryView.self, 
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, 
                                withReuseIdentifier: HeaderSupplementaryView.reuseIdentifier)
    }

    func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionIndex, layoutEnvironment -> NSCollectionLayoutSection? in
            guard let self = self, let sectionKind = SectionLayoutKind(rawValue: sectionIndex) else { return nil }

            // Hide discovery sections if search is active, and search results if search is not active
            if !self.viewModel.currentSearchQuery.isEmpty && sectionKind != .searchResults {
                return self.createEmptyLayoutSection() // Effectively hides the section
            }
            if self.viewModel.currentSearchQuery.isEmpty && sectionKind == .searchResults {
                 return self.createEmptyLayoutSection()
            }

            switch sectionKind {
            case .trendingMovies, .popularMovies, .topRatedMovies, .nowPlayingMovies, .upcomingMovies:
                return self.createHorizontalCarouselSection(itemWidth: 150, itemHeight: 260, groupHeight: 270, showsHeader: true)
            case .genres:
                // Let's make genres a horizontally scrolling list of items with dynamic width
                return self.createHorizontalTagListSection(estimatedItemWidth: 100, itemHeight: 44, groupHeight: 50, showsHeader: true)
            case .searchResults:
                return self.createVerticalListSection(estimatedItemHeight: 120, showsHeader: true) // Or a grid layout
            }
        }
        return layout
    }

    // Helper to create an empty (hidden) section
    private func createEmptyLayoutSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(0.01)) // Minimal height
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(0.01))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        return section
    }

    // Helper for horizontal movie carousels
    private func createHorizontalCarouselSection(itemWidth: CGFloat, itemHeight: CGFloat, groupHeight: CGFloat, showsHeader: Bool) -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(itemWidth), 
                                              heightDimension: .absolute(itemHeight))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)

        let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(itemWidth + 10), // Account for insets
                                               heightDimension: .absolute(groupHeight))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
        section.interGroupSpacing = 0 // Spacing is handled by item insets
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
        
        if showsHeader {
            section.boundarySupplementaryItems = [createHeaderItem()]
        }
        return section
    }

    // Helper for horizontal tag-like list (e.g., for Genres)
    private func createHorizontalTagListSection(estimatedItemWidth: CGFloat, itemHeight: CGFloat, groupHeight: CGFloat, showsHeader: Bool) -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .estimated(estimatedItemWidth), 
                                              heightDimension: .absolute(itemHeight))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.edgeSpacing = NSCollectionLayoutEdgeSpacing(leading: .fixed(0), top: .fixed(0), trailing: .fixed(8), bottom: .fixed(0))

        let groupSize = NSCollectionLayoutSize(widthDimension: .estimated(estimatedItemWidth * 5), // Estimate for a few items
                                               heightDimension: .absolute(groupHeight))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16)
        section.interGroupSpacing = 8

        if showsHeader {
            section.boundarySupplementaryItems = [createHeaderItem()]
        }
        return section
    }

    // Helper for vertical list (e.g., for Search Results)
    private func createVerticalListSection(estimatedItemHeight: CGFloat, showsHeader: Bool) -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .estimated(estimatedItemHeight))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .estimated(estimatedItemHeight))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 10
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16)
        
        if showsHeader {
            section.boundarySupplementaryItems = [createHeaderItem()]
        }
        return section
    }
    
    private func createHeaderItem() -> NSCollectionLayoutBoundarySupplementaryItem {
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .estimated(44))
        return NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize,
                                                           elementKind: UICollectionView.elementKindSectionHeader,
                                                           alignment: .top)
    }
    
    // func configureTableView() is removed
    
    // func updateTableViewData() is removed
}

// MARK: - UISearchResultsUpdating
extension SearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        viewModel.currentSearchQuery = searchController.searchBar.text ?? ""
        // The actual search is now triggered by the ViewModel's debounced subscriber to currentSearchQuery
        // If SearchResultsController is still used, it needs to observe viewModel.searchResults
        // For now, assuming SearchResultsController might be phased out or adapted.
    }
}

// MARK: - UICollectionViewDataSource
extension SearchViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return SectionLayoutKind.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let sectionKind = SectionLayoutKind(rawValue: section) else { return 0 }
        
        // Return 0 if data for a section isn't loaded or if search is active and it's not a search result section
        if !viewModel.currentSearchQuery.isEmpty && sectionKind != .searchResults {
            return 0 // Hide discovery sections when search is active
        }
        if viewModel.currentSearchQuery.isEmpty && sectionKind == .searchResults {
            return 0 // Hide search results when no search is active
        }

        switch sectionKind {
        case .trendingMovies: return viewModel.trendingMovies.count
        case .popularMovies: return viewModel.popularMovies.count
        case .topRatedMovies: return viewModel.topRatedMovies.count
        case .nowPlayingMovies: return viewModel.nowPlayingMovies.count
        case .upcomingMovies: return viewModel.upcomingMovies.count
        case .genres: return viewModel.movieGenres.count
        case .searchResults: return viewModel.searchResults.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let sectionKind = SectionLayoutKind(rawValue: indexPath.section) else {
            fatalError("Invalid section kind: \(indexPath.section)")
        }
        
        switch sectionKind {
        case .trendingMovies:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MovieCell.reuseIdentifier, for: indexPath) as! MovieCell
            if indexPath.item < viewModel.trendingMovies.count {
                cell.configure(with: viewModel.trendingMovies[indexPath.item])
            }
            return cell
        case .popularMovies:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MovieCell.reuseIdentifier, for: indexPath) as! MovieCell
            if indexPath.item < viewModel.popularMovies.count {
                cell.configure(with: viewModel.popularMovies[indexPath.item])
            }
            return cell
        case .topRatedMovies:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MovieCell.reuseIdentifier, for: indexPath) as! MovieCell
            if indexPath.item < viewModel.topRatedMovies.count {
                cell.configure(with: viewModel.topRatedMovies[indexPath.item])
            }
            return cell
        case .nowPlayingMovies:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MovieCell.reuseIdentifier, for: indexPath) as! MovieCell
            if indexPath.item < viewModel.nowPlayingMovies.count {
                cell.configure(with: viewModel.nowPlayingMovies[indexPath.item])
            }
            return cell
        case .upcomingMovies:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MovieCell.reuseIdentifier, for: indexPath) as! MovieCell
            if indexPath.item < viewModel.upcomingMovies.count {
                cell.configure(with: viewModel.upcomingMovies[indexPath.item])
            }
            return cell
        case .genres:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GenreCell.reuseIdentifier, for: indexPath) as! GenreCell
            if indexPath.item < viewModel.movieGenres.count {
                cell.configure(with: viewModel.movieGenres[indexPath.item])
            }
            return cell
        case .searchResults:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MovieCell.reuseIdentifier, for: indexPath) as! MovieCell
            if indexPath.item < viewModel.searchResults.count {
                cell.configure(with: viewModel.searchResults[indexPath.item])
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else {
            fatalError("Unexpected supplementary view kind: \(kind)")
        }
        
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: HeaderSupplementaryView.reuseIdentifier, for: indexPath) as! HeaderSupplementaryView
        
        if let sectionKind = SectionLayoutKind(rawValue: indexPath.section) {
            // Hide header for empty sections (like search results when no query, or discovery when query is active)
            if (!viewModel.currentSearchQuery.isEmpty && sectionKind != .searchResults) || 
               (viewModel.currentSearchQuery.isEmpty && sectionKind == .searchResults && viewModel.searchResults.isEmpty) {
                headerView.configure(with: nil) // Or set height to 0 in layout
            } else {
                headerView.configure(with: sectionKind.title)
            }
        } else {
            headerView.configure(with: nil)
        }
        return headerView
    }
}

// MARK: - UICollectionViewDelegate
extension SearchViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let sectionKind = SectionLayoutKind(rawValue: indexPath.section) else { return }
        
        // Do not proceed if the section is hidden due to search state
        if (!viewModel.currentSearchQuery.isEmpty && sectionKind != .searchResults) || 
           (viewModel.currentSearchQuery.isEmpty && sectionKind == .searchResults) {
            return
        }

        switch sectionKind {
        case .trendingMovies:
            if indexPath.item < viewModel.trendingMovies.count {
                delegate?.searchViewController(self, didSelectMovie: viewModel.trendingMovies[indexPath.item])
            }
        case .popularMovies:
            if indexPath.item < viewModel.popularMovies.count {
                delegate?.searchViewController(self, didSelectMovie: viewModel.popularMovies[indexPath.item])
            }
        case .topRatedMovies:
            if indexPath.item < viewModel.topRatedMovies.count {
                delegate?.searchViewController(self, didSelectMovie: viewModel.topRatedMovies[indexPath.item])
            }
        case .nowPlayingMovies:
            if indexPath.item < viewModel.nowPlayingMovies.count {
                delegate?.searchViewController(self, didSelectMovie: viewModel.nowPlayingMovies[indexPath.item])
            }
        case .upcomingMovies:
            if indexPath.item < viewModel.upcomingMovies.count {
                delegate?.searchViewController(self, didSelectMovie: viewModel.upcomingMovies[indexPath.item])
            }
        case .searchResults:
            if indexPath.item < viewModel.searchResults.count {
                delegate?.searchViewController(self, didSelectMovie: viewModel.searchResults[indexPath.item])
            }
        case .genres:
            if indexPath.item < viewModel.movieGenres.count {
                delegate?.searchViewController(self, didSelectGenre: viewModel.movieGenres[indexPath.item])
            }
        }
    }
}
