//
//  LoggingCoordinator.swift
//  DatShin
//
//  Created by Kaung Khant Si Thu on 03/06/2025.
//

import UIKit

/// Coordinator for handling logging-related navigation
final class LoggingCoordinator: BaseCoordinator {
    // MARK: - Properties
    
    private let viewControllerFactory: ViewControllerFactoryProtocol
    
    // MARK: - Initialization
    
    init(
        navigationController: UINavigationController,
        viewControllerFactory: ViewControllerFactoryProtocol,
        logger: LoggerProtocol = Log.coordinator
    ) {
        self.viewControllerFactory = viewControllerFactory
        super.init(navigationController: navigationController, logger: logger)
    }
    
    // MARK: - Coordinator
    
    override func start() {
        super.start()
        showLogViewer()
    }
    
    // MARK: - Navigation
    
    /// Shows the log viewer screen
    private func showLogViewer() {
        logger.debug("Showing log viewer")
        let logViewerVC = viewControllerFactory.makeLogViewerViewController()
        navigationController.pushViewController(logViewerVC, animated: true)
    }
}


