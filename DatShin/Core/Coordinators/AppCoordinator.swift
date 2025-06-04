//
//  AppCoordinator.swift
//  DatShin
//
//  Created by Kaung Khant Si Thu on 03/06/2025.
//

import UIKit

/// Main coordinator for the application that manages the app's flow
final class AppCoordinator: BaseCoordinator {
    // MARK: - Properties
    
    private let window: UIWindow
    fileprivate let viewControllerFactory: ViewControllerFactoryProtocol
    private var tabBarController: UITabBarController?
    
    // MARK: - Initialization
    
    init(window: UIWindow, viewControllerFactory: ViewControllerFactoryProtocol) {
        self.window = window
        self.viewControllerFactory = viewControllerFactory
        
        // Create a dummy navigation controller for the base coordinator
        // This won't be used directly as we're setting the window's root to a tab bar controller
        let navigationController = UINavigationController()
        
        super.init(navigationController: navigationController)
    }
    
    // MARK: - Coordinator
    
    override func start() {
        setupTabBarController()
        window.rootViewController = tabBarController
        // SceneDelegate now handles making the window key and visible.
        window.makeKeyAndVisible()
        setupTabCoordinators()
        print(#function)
    }
    
    private func setupTabBarController() {
        tabBarController = viewControllerFactory.makeTabBarController()
    }
    
    private func setupTabCoordinators() {
        guard let tabBarController = tabBarController,
              let viewControllers = tabBarController.viewControllers else { return }
        
        // Setup coordinators for each tab
        for (index, navigationController) in viewControllers.compactMap({ $0 as? UINavigationController }).enumerated() {
            switch index {
            // Case 0 (formerly Home tab) is removed.
            // Tabs will now be Watchlist (index 0) and Search (index 1) if TabBarController is updated accordingly.
            case 0: // Watchlist tab (previously index 1)
                let watchlistCoordinator = WatchlistCoordinator(navigationController: navigationController, viewControllerFactory: viewControllerFactory)
                addChildCoordinator(watchlistCoordinator)
                watchlistCoordinator.start()
            case 1: // Search tab (previously index 2)
                let searchCoordinator = SearchCoordinator(navigationController: navigationController, viewControllerFactory: viewControllerFactory)
                addChildCoordinator(searchCoordinator)
                searchCoordinator.start()
            default:
                break
            }
        }
    }
    
    // MARK: - Navigation Methods
    
    /// Shows the movie detail screen for the specified movie ID
    func showMovieDetail(movieID: Movie.ID, from navigationController: UINavigationController) {
        let detailViewController = viewControllerFactory.makeMovieDetailViewController(movieID: movieID)
        navigationController.pushViewController(detailViewController, animated: true)
    }
    
    /// Shows the search results for the specified query
    func showSearchResults(query: String, from navigationController: UINavigationController) {
        // Implement when needed
    }
    
    /// Shows the debug menu
    func showDebugMenu() {
        logger.debug("Showing debug menu")
        
        // Create a navigation controller
        let navigationController = UINavigationController()
        navigationController.modalPresentationStyle = .formSheet
        
        // Create the debug menu view controller
        let debugMenuVC = viewControllerFactory.makeDebugMenuViewController()
        navigationController.viewControllers = [debugMenuVC]
        
        // Present the debug menu
        if let rootViewController = window.rootViewController {
            rootViewController.present(navigationController, animated: true)
        }
    }
}

// MARK: - Extension for AppCoordinator

extension AppCoordinator {
    /// Shows the logging coordinator as a modal
    func showLoggingCoordinator() {
        logger.debug("Showing logging coordinator")
        
        // Create a navigation controller
        let navigationController = UINavigationController()
        navigationController.modalPresentationStyle = .formSheet
        
        // Create and start the logging coordinator
        let loggingCoordinator = LoggingCoordinator(
            navigationController: navigationController,
            viewControllerFactory: viewControllerFactory,
            logger: logger
        )
        
        // Add as child coordinator
        addChildCoordinator(loggingCoordinator)
        
        // Start the coordinator
        loggingCoordinator.start()
        
        // Present the navigation controller
        self.navigationController.present(navigationController, animated: true)
    }
}
