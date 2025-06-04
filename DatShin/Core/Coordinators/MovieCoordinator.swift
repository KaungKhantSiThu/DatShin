//
//  MovieCoordinator.swift
//  DatShin
//
//  Created by Kaung Khant Si Thu on 03/06/2025.
//

import UIKit

/// Coordinator responsible for handling movie detail presentation.
/// This coordinator might be further refactored or absorbed if its role diminishes significantly.
final class MovieCoordinator: BaseCoordinator {
    // MARK: - Properties
    
    private let viewControllerFactory: ViewControllerFactoryProtocol
    
    // MARK: - Initialization
    
    init(navigationController: UINavigationController, viewControllerFactory: ViewControllerFactoryProtocol) {
        self.viewControllerFactory = viewControllerFactory
        super.init(navigationController: navigationController)
    }
    
    // MARK: - Coordinator
    
    override func start() {
        // This coordinator no longer manages a primary view for a tab.
        // Its main purpose, if retained, would be to facilitate the presentation of movie details
        // when invoked by other coordinators.
        logger.debug("MovieCoordinator started. It does not push a default view controller.")
    }
    
    // MARK: - Navigation Methods
    
    func showMovieDetail(movieID: Movie.ID) {
        let detailViewController = viewControllerFactory.makeMovieDetailViewController(movieID: movieID)
        navigationController.pushViewController(detailViewController, animated: true)
    }
}
