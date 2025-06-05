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
    private let serviceFactory: ServiceFactoryProtocol // Added to pass to MovieCoordinator
    private var movieCoordinator: MovieCoordinator? // Added to manage movie detail and search results flow
    
    // MARK: - Initialization
    
    init(navigationController: UINavigationController, viewControllerFactory: ViewControllerFactoryProtocol, serviceFactory: ServiceFactoryProtocol) { // Added serviceFactory
        self.viewControllerFactory = viewControllerFactory
        self.serviceFactory = serviceFactory // Added
        super.init(navigationController: navigationController)
    }
    
    // MARK: - Coordinator
    
    override func start() {
        let searchViewController = viewControllerFactory.makeSearchViewController()
        
        // Instantiate and start MovieCoordinator, which will handle search results and movie details
        let movieCoordinator = MovieCoordinator(
            navigationController: navigationController,
            viewControllerFactory: viewControllerFactory,
            serviceFactory: serviceFactory
        )
        self.movieCoordinator = movieCoordinator
        addChildCoordinator(movieCoordinator) // Add as child
        // movieCoordinator.start() // MovieCoordinator's start doesn't push a VC, it's ready to present details/search results

        searchViewController.delegate = movieCoordinator // MovieCoordinator now handles SearchViewControllerDelegate
        navigationController.viewControllers = [searchViewController] // Set as root
    }
    
    // MARK: - Navigation Methods
    
    func showMovieDetail(movieID: Movie.ID) {
        let detailViewController = viewControllerFactory.makeMovieDetailViewController(movieID: movieID)
        navigationController.pushViewController(detailViewController, animated: true)
    }
}

// MARK: - SearchViewControllerDelegate
// SearchCoordinator no longer directly conforms to SearchViewControllerDelegate.
// This responsibility has been moved to MovieCoordinator.
// extension SearchCoordinator: SearchViewControllerDelegate {
    // func searchViewController(_ controller: SearchViewController, didSelectMovie movie: MovieListItem) { ... }
    // func searchViewController(_ controller: SearchViewController, didSelectGenre genre: Genre) { ... }
// }
