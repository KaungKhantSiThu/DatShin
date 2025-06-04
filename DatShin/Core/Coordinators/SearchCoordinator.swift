//
//  SearchCoordinator.swift
//  DatShin
//
//  Created by Kaung Khant Si Thu on 03/06/2025.
//

import UIKit

/// Coordinator responsible for handling the search flow
final class SearchCoordinator: BaseCoordinator {
    // MARK: - Properties
    
    private let viewControllerFactory: ViewControllerFactoryProtocol
    
    // MARK: - Initialization
    
    init(navigationController: UINavigationController, viewControllerFactory: ViewControllerFactoryProtocol) {
        self.viewControllerFactory = viewControllerFactory
        super.init(navigationController: navigationController)
    }
    
    // MARK: - Coordinator
    
    override func start() {
        let searchViewController = viewControllerFactory.makeSearchViewController()
        searchViewController.delegate = self // Set the delegate
        navigationController.viewControllers = [searchViewController] // Set as root of the navigation stack for this tab
    }
    
    // MARK: - Navigation Methods
    
    func showMovieDetail(movieID: Movie.ID) {
        let detailViewController = viewControllerFactory.makeMovieDetailViewController(movieID: movieID)
        navigationController.pushViewController(detailViewController, animated: true)
    }
}

// MARK: - SearchViewControllerDelegate

extension SearchCoordinator: SearchViewControllerDelegate {
    func searchViewController(_ controller: SearchViewController, didSelectMovie movie: MovieListItem) {
        logger.debug("SearchCoordinator: didSelectMovie with ID \(movie.id)")
        showMovieDetail(movieID: movie.id)
    }
    
    func searchViewController(_ controller: SearchViewController, didSelectGenre genre: Genre) {
        logger.debug("SearchCoordinator: didSelectGenre: \(genre.name) (ID: \(genre.id))")
        // TODO: Implement navigation to a genre-specific screen or filter results by genre.
        // For now, we can just log it or perhaps show an alert.
        let alert = UIAlertController(title: "Genre Selected", message: "Displaying movies for genre '\(genre.name)' is not yet implemented.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        navigationController.present(alert, animated: true)
    }
}
