//
//  ViewControllerFactoryProtocol.swift
//  DatShin
//
//  Created by Kaung Khant Si Thu on 03/06/2025.
//

import UIKit

/// Protocol defining the interface for a view controller factory
protocol ViewControllerFactoryProtocol {
    /// Creates the main tab bar controller
    func makeTabBarController() -> UITabBarController
    
    /// Creates the watchlist view controller
    func makeWatchListViewController() -> UIViewController
    
    /// Creates the search view controller
    func makeSearchViewController() -> SearchViewController
    
    /// Creates a navigation controller with the specified root view controller
    func makeNavigationController(rootViewController: UIViewController) -> UINavigationController
    
    /// Creates a movie detail view controller for the specified movie ID
    func makeMovieDetailViewController(movieID: Movie.ID) -> MovieDetailViewController
    
    /// Creates a search results view controller with the specified view model
    func makeSearchResultsViewController(viewModel: SearchResultsViewModel) -> SearchResultsViewController
    
    /// Creates a log viewer view controller for debugging
    func makeLogViewerViewController() -> UIViewController
    
    /// Creates a debug menu view controller
    func makeDebugMenuViewController() -> UIViewController
}
