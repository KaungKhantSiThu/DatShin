//
//  WatchlistCoordinator.swift
//  DatShin
//
//  Created by Kaung Khant Si Thu on 03/06/2025.
//

import UIKit

/// Coordinator responsible for handling the watchlist flow
final class WatchlistCoordinator: BaseCoordinator {
    // MARK: - Properties
    
    private let viewControllerFactory: ViewControllerFactoryProtocol
    
    // MARK: - Initialization
    
    init(navigationController: UINavigationController, viewControllerFactory: ViewControllerFactoryProtocol) {
        self.viewControllerFactory = viewControllerFactory
        super.init(navigationController: navigationController)
    }
    
    // MARK: - Coordinator
    
    override func start() {
        let watchlistViewController = viewControllerFactory.makeWatchListViewController()
        navigationController.pushViewController(watchlistViewController, animated: false)
    }
    
    // MARK: - Navigation Methods
    
    func showMovieDetail(movieID: Movie.ID) {
        let detailViewController = viewControllerFactory.makeMovieDetailViewController(movieID: movieID)
        navigationController.pushViewController(detailViewController, animated: true)
    }
}
