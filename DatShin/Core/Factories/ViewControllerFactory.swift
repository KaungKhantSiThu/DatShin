//
//  ViewControllerFactory.swift
//  DatShin
//
//  Created by Kaung Khant Si Thu on 03/06/2025.
//

import UIKit

/// Concrete implementation of ViewControllerFactoryProtocol
final class ViewControllerFactory: ViewControllerFactoryProtocol {
    // MARK: - Private Properties
    
    private let serviceFactory: ServiceFactoryProtocol
    private let logger: LoggerProtocol
    
    // MARK: - Initialization
    
    init(serviceFactory: ServiceFactoryProtocol) {
        self.serviceFactory = serviceFactory
        self.logger = serviceFactory.makeUILogger()
        
        logger.info("ViewControllerFactory initialized")
    }
    
    // MARK: - ViewControllerFactoryProtocol
    
    func makeTabBarController() -> UITabBarController {
        logger.debug("Creating TabBarController")
        let tabBarController = TabBarController(viewControllerFactory: self)
        return tabBarController
    }
    
    func makeWatchListViewController() -> UIViewController {
        logger.debug("Creating WatchListViewController")
        let moviesFetcher = serviceFactory.makeMovieService()
        let watchlistVC = WatchListViewController(fetcherService: moviesFetcher)
        watchlistVC.title = "Watchlist"
        return watchlistVC
    }
    
    @MainActor func makeSearchViewController() -> SearchViewController {
        logger.debug("Creating new SearchViewController with SearchViewModel")
        
        let movieService = serviceFactory.makeMovieService()
        let searchService = serviceFactory.makeSearchService()
        let trendingService = serviceFactory.makeTrendingService()
        let genreService = serviceFactory.makeGenreService()
        
        let viewModel = SearchViewModel(
            movieService: movieService,
            searchService: searchService,
            trendingService: trendingService,
            genreService: genreService
        )
        
        let searchVC = SearchViewController(viewModel: viewModel)
        searchVC.title = "Discover & Search"
        // The coordinator that calls this method will set itself as the delegate.
        return searchVC
    }
    
    func makeNavigationController(rootViewController: UIViewController) -> UINavigationController {
        logger.debug("Creating NavigationController with root: \(type(of: rootViewController))")
        let navigationController = UINavigationController(rootViewController: rootViewController)
        return navigationController
    }
    
    func makeMovieDetailViewController(movieID: Movie.ID) -> UIViewController {
        logger.debug("Creating MovieDetailViewController for movie ID: \(movieID)")
        let moviesFetcher = serviceFactory.makeMovieService()
        let viewModel = MovieDetailViewModel(id: movieID, fetcherService: moviesFetcher)
        let detailVC = MovieDetailViewController(viewModel: viewModel)
        return detailVC
    }
}
